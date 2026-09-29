<#
Build a Windows configuration from the repository's gn args, the way
tooling/build-chromium does on the Mac: the args file is copied into the output
directory verbatim with stedding_version appended from VERSION, so the args of any
build are recoverable from the build itself.

Usage (PowerShell, from anywhere):
  tooling\win\build.ps1                          # win-release: chrome and mini_installer, 15 minutes
  tooling\win\build.ps1 -Config win-release -Targets chrome
  tooling\win\build.ps1 -Targets unit_tests,stedding_browser_tests -KeepGoing
  tooling\win\build.ps1 -Jobs 20                 # at most 20 steps at a time
  tooling\win\build.ps1 -BudgetMinutes 45        # allow 45 minutes; 0 = unlimited
  tooling\win\build.ps1 -GenOnly                 # gn gen and stop

Environment:
  STEDDING_CHROMIUM_SRC   the checkout's src directory (or -Src)
  STEDDING_DEPOT_TOOLS    depot_tools, if it is not already on PATH
  STEDDING_VPYTHON_ROOT   a short directory for vpython's venv (docs/HANDOFF.md,
                          trap 34: a long %LOCALAPPDATA% blows past MAX_PATH)
  STEDDING_BUILD_BUDGET_MIN   the default for -BudgetMinutes

Budget: a build gets 15 minutes of wall clock by default, as on the Mac
(docs/AGENT-LOOP.md). Every minute it prints the steps finished and the compilers
running; when the budget runs out it stops the build and says so, and the next run
resumes where it stopped, because siso keeps what it built. Anything longer is a
decision the operator makes: ask, then pass -BudgetMinutes. A build that stops on the
budget exits 2 (still making progress) or 3 (no step finished and no compiler
running: treat it as stuck, not slow); a build that fails exits 1.

-KeepGoing passes -k 0 to autoninja, so one pass lists every error a batch of edits
introduced (docs/HANDOFF.md, trap 50) instead of stopping at the first.

-Jobs passes -j to autoninja. On a machine with 32 threads and 32 GB the default is
too many: the first full build of the M155 tree ran out of commit (46 "LLVM ERROR: out
of memory", MemoryError in Blink's Python binding generators, even the tool's own
shell dying), so name a number the memory can carry -- the progress line shows the
commit charge against its limit (docs/HANDOFF.md, trap 54).

Two rules this script keeps for you: the Windows toolchain is the installed Visual
Studio, never Google's (DEPOT_TOOLS_WIN_TOOLCHAIN=0), and a build is refused while a
browser from the same output directory is running, because the link would fail with
"permission denied" a long way into it. Never edit the checkout while a build runs:
siso stats the sources once, near its start (trap 1).
#>
param(
  [string]$Config = "win-release",
  [string[]]$Targets = @("chrome", "mini_installer"),
  [string]$Src = $env:STEDDING_CHROMIUM_SRC,
  [switch]$GenOnly,
  [switch]$KeepGoing,
  [int]$Jobs = $(if ($env:STEDDING_BUILD_JOBS) { [int]$env:STEDDING_BUILD_JOBS } else { 0 }),
  [int]$BudgetMinutes = $(if ($env:STEDDING_BUILD_BUDGET_MIN) { [int]$env:STEDDING_BUILD_BUDGET_MIN } else { 15 })
)
$ErrorActionPreference = "Stop"
$root = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
if (-not $Src) { throw "set STEDDING_CHROMIUM_SRC to the checkout's src directory, or pass -Src" }
if (-not (Test-Path (Join-Path $Src "BUILD.gn"))) { throw "no Chromium checkout at $Src" }
$argsFile = Join-Path $root "tooling\args\$Config.gn"
if (-not (Test-Path $argsFile)) { throw "no gn args for '$Config' (expected $argsFile)" }
$version = (Get-Content (Join-Path $root "VERSION") -Raw).Trim()
if (-not $version) { throw "VERSION is empty" }
if ($BudgetMinutes -lt 0) { throw "-BudgetMinutes takes whole minutes, 0 for unlimited" }
$out = "out\$Config"

$outExe = Join-Path (Join-Path $Src $out) "chrome.exe"
$running = Get-Process chrome -ErrorAction SilentlyContinue | Where-Object { $_.Path -eq $outExe }
if ($running) {
  throw "a browser from $out is running (pid $($running[0].Id)); close it, or the link fails with permission denied"
}

$env:DEPOT_TOOLS_WIN_TOOLCHAIN = "0"
if ($env:STEDDING_DEPOT_TOOLS) { $env:PATH = "$($env:STEDDING_DEPOT_TOOLS);$($env:PATH)" }
if ($env:STEDDING_VPYTHON_ROOT) { $env:VPYTHON_ROOT = $env:STEDDING_VPYTHON_ROOT }
if (-not (Get-Command gn -ErrorAction SilentlyContinue)) {
  throw "gn is not on PATH; set STEDDING_DEPOT_TOOLS to your depot_tools directory"
}

# Object files rewritten since $since: the count of finished compile steps, the way
# tooling/build-chromium reads it. siso compacts its own log on start, so the log
# says nothing reliable about a resumed build; a fresh object is newer than the run.
function Get-StepsDone([string]$dir, [datetime]$since) {
  $objDir = Join-Path $dir "obj"
  if (-not (Test-Path $objDir)) { return 0 }
  $n = 0
  $sinceUtc = $since.ToUniversalTime()
  foreach ($f in [IO.Directory]::EnumerateFiles($objDir, "*.obj", [IO.SearchOption]::AllDirectories)) {
    if ([IO.File]::GetLastWriteTimeUtc($f) -gt $sinceUtc) { $n++ }
  }
  return $n
}

Push-Location $Src
try {
  New-Item -ItemType Directory -Force $out | Out-Null
  $gnArgs = (Get-Content $argsFile -Raw) -replace "`r`n", "`n"
  $gnArgs += "`n# Set by tooling/win/build.ps1 from VERSION; do not edit here.`nstedding_version = `"$version`"`n"
  # UTF-8 without a BOM, LF: gn reads the file as bytes.
  [IO.File]::WriteAllText((Join-Path (Get-Location).Path "$out\args.gn"), $gnArgs, (New-Object Text.UTF8Encoding $false))
  Write-Host "gn gen $out (stedding_version $version)"
  gn gen $out
  if ($LASTEXITCODE -ne 0) { throw "gn gen failed" }
  if ($GenOnly) { return }

  $ninjaArgs = @("-C", $out)
  if ($KeepGoing) { $ninjaArgs += @("-k", "0") }
  if ($Jobs -gt 0) { $ninjaArgs += @("-j", "$Jobs") }
  $ninjaArgs += $Targets
  $budgetNote = if ($BudgetMinutes -eq 0) { "no budget: the operator said so" } else { "budget: $BudgetMinutes min; progress every minute" }
  Write-Host "autoninja $($ninjaArgs -join ' ')  ($budgetNote)"

  $log = Join-Path (Get-Location).Path "$out\build.log"
  $start = Get-Date
  # autoninja is a batch file; cmd runs it and owns the redirect, so the output
  # reaches the log whole and this script only reads the log's tail at the end.
  $cmdLine = "/c autoninja $($ninjaArgs -join ' ') > `"$log`" 2>&1"
  $proc = Start-Process -FilePath "cmd.exe" -ArgumentList $cmdLine -NoNewWindow -PassThru
  # Touching the handle keeps the exit code readable after the process is gone
  # (Windows PowerShell 5.1 returns $null for a -PassThru process otherwise).
  $null = $proc.Handle
  $stoppedByBudget = $false
  $steps = 0
  while (-not $proc.WaitForExit(60000)) {
    $elapsed = (Get-Date) - $start
    $steps = Get-StepsDone (Join-Path (Get-Location).Path $out) $start
    $compilers = @(Get-Process clang-cl -ErrorAction SilentlyContinue).Count
    $os = Get-CimInstance Win32_OperatingSystem
    $commitGB = ($os.TotalVirtualMemorySize - $os.FreeVirtualMemory) / 1MB
    $limitGB = $os.TotalVirtualMemorySize / 1MB
    Write-Host ("progress: {0} min, {1} steps done, {2} compilers, commit {3:n0} of {4:n0} GB" -f [int]$elapsed.TotalMinutes, $steps, $compilers, $commitGB, $limitGB)
    if ($BudgetMinutes -gt 0 -and $elapsed.TotalMinutes -ge $BudgetMinutes) {
      Write-Warning "build budget of $BudgetMinutes min exceeded at $steps steps; stopping it."
      $stoppedByBudget = $true
      & taskkill /F /T /PID $proc.Id | Out-Null
      # siso may outlive the cmd that started it; stop only the ones for this output directory.
      Get-CimInstance Win32_Process -Filter "Name='siso.exe'" -ErrorAction SilentlyContinue |
        Where-Object { $_.CommandLine -like "*$out*" } |
        ForEach-Object { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue }
      $compilers = @(Get-Process clang-cl -ErrorAction SilentlyContinue).Count
      break
    }
  }

  if (Test-Path $log) {
    Write-Host "--- build.log (last 12 lines)"
    Get-Content $log -Tail 12 | ForEach-Object { Write-Host $_ }
  }
  if ($stoppedByBudget) {
    if ($steps -gt 0 -or $compilers -gt 0) {
      Write-Host "stopped by the budget while still making progress; a rerun resumes where it stopped. Ask the operator, then rerun with -BudgetMinutes <minutes> (0 = unlimited)."
      exit 2
    }
    Write-Host "stopped by the budget with no step finished and no compiler running: treat as stuck, not slow. Read $log before rerunning."
    exit 3
  }
  if ($proc.ExitCode -ne 0) {
    Write-Host "autoninja failed (exit $($proc.ExitCode)); the failing steps:"
    Select-String -Path $log -Pattern "^FAILED:" | Select-Object -First 40 | ForEach-Object { Write-Host $_.Line }
    exit 1
  }
  Write-Host "built: $($Targets -join ', ') in $out"
} finally {
  Pop-Location
}
