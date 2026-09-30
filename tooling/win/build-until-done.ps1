<#
Builds a Windows configuration to the end, chunk after chunk, and stops only when it is
done, broken or stuck. One detached job and one status file, instead of an agent polling
every fifteen minutes and starting the next chunk by hand.

Usage (PowerShell, from anywhere; run it detached, see below):
  tooling\win\build-until-done.ps1 -Config win-checks -Targets unit_tests,stedding_browser_tests
  tooling\win\build-until-done.ps1 -Jobs 22 -ChunkMinutes 45 -MaxChunks 30

It calls tooling\win\build.ps1 (which owns gn gen, the progress line every minute and the
budget) over and over. build.ps1's exit code says what happened:
  0  built                      -> done, exit 0
  2  stopped by the budget      -> the next chunk resumes where it stopped (siso keeps what it built)
  3  stopped, nothing moving    -> stuck, exit 3: read build.log
  1  a step failed              -> exit 1, with the distinct failing steps

What the budget does and does not mean: it is a dead-man's switch, not a schedule. It kills
the steps in flight, so each stop costs those steps' minutes; a long chunk wastes less than
a short one. A build that ends every chunk with the same steps "failed" is not making
progress on those steps: they were killed before they could finish, every time. This script
compares the failing step names at consecutive stops and, on the second repeat, stops with
exit 4 and names them. On 2026-09-30 three ASan-built assembler steps did exactly that for
five chunks before anyone looked (docs/HANDOFF.md, trap 57). Measure one by hand.

Status goes to <checkout>\out\<config>\supervisor.log with a time on every line, and its
last line is SUPERVISOR_EXIT=<code>. Wait for that line, never for a clock:

  until grep -q '^SUPERVISOR_EXIT=' "$LOG"; do sleep 30; done      # in a background call
  tail -3 "$LOG"                                                   # at any time, for a number

Start it detached so the tool that started it cannot take it down (trap 54):
  Start-Process powershell -ArgumentList '-NoProfile','-File','tooling\win\build-until-done.ps1',
    '-Config','win-checks','-Jobs','22' -WindowStyle Hidden

Environment as build.ps1: STEDDING_CHROMIUM_SRC, STEDDING_DEPOT_TOOLS, STEDDING_VPYTHON_ROOT.
#>
param(
  [string]$Config = "win-release",
  [string[]]$Targets = @("chrome", "mini_installer", "unit_tests", "stedding_browser_tests"),
  [int]$Jobs = 22,
  [int]$ChunkMinutes = 45,
  [int]$MaxChunks = 40,
  [string]$Src = $env:STEDDING_CHROMIUM_SRC
)
$ErrorActionPreference = "Stop"
# `powershell -File` hands a comma list over as one string ("a,b"): split it (docs/HANDOFF.md, trap 34 family).
$Targets = @($Targets | ForEach-Object { $_ -split "," } | Where-Object { $_ })
if (-not $Src) { throw "set STEDDING_CHROMIUM_SRC to the checkout's src directory, or pass -Src" }
if ($ChunkMinutes -lt 1) { throw "-ChunkMinutes must be at least 1: a chunk with no budget cannot be stopped from here" }
$outDir = Join-Path $Src "out\$Config"
New-Item -ItemType Directory -Force $outDir | Out-Null
$status = Join-Path $outDir "supervisor.log"
$buildLog = Join-Path $outDir "build.log"

function Say([string]$m) {
  $line = "{0} {1}" -f (Get-Date -Format "HH:mm:ss"), $m
  Write-Host $line
  Add-Content -Path $status -Value $line
}
function Finish([int]$code, [string]$why) {
  Say $why
  Add-Content -Path $status -Value "SUPERVISOR_EXIT=$code"
  exit $code
}

# The steps build.log says failed, by output name (colour codes and ids stripped).
function Failed-Steps {
  if (-not (Test-Path $buildLog)) { return @() }
  $names = @()
  foreach ($l in (Get-Content $buildLog -ErrorAction SilentlyContinue)) {
    if ($l -match 'FAILED: \S+ "([^"]+)"') { $names += $Matches[1] }
  }
  return @($names | Sort-Object -Unique)
}

$started = Get-Date
$previous = @()
$repeats = 0
Say ("start: {0}, targets {1}, {2} jobs, chunks of {3} min, at most {4}" -f $Config, ($Targets -join ","), $Jobs, $ChunkMinutes, $MaxChunks)
for ($chunk = 1; $chunk -le $MaxChunks; $chunk++) {
  Say "chunk $chunk"
  & (Join-Path $PSScriptRoot "build.ps1") -Config $Config -Targets $Targets -KeepGoing -Jobs $Jobs -BudgetMinutes $ChunkMinutes
  $code = $LASTEXITCODE
  $elapsed = [int]((Get-Date) - $started).TotalMinutes
  if ($code -eq 0) { Finish 0 "done: built $($Targets -join ', ') in out\$Config after $chunk chunk(s), $elapsed min" }
  if ($code -eq 3) { Finish 3 "stuck: no step finished and no compiler running at the end of chunk $chunk; read $buildLog" }
  if ($code -eq 1) {
    $failed = Failed-Steps
    Say ("failed: {0} distinct step(s):" -f $failed.Count)
    $failed | Select-Object -First 20 | ForEach-Object { Say "  $_" }
    if ($failed.Count -eq 0) {
      # Not a step: a target that does not exist, a gn error. The log's last lines say which.
      Get-Content $buildLog -Tail 6 -ErrorAction SilentlyContinue | ForEach-Object { Say ("  log: " + $_.Substring(0, [math]::Min(200, $_.Length))) }
    }
    Finish 1 "failed at chunk $chunk, $elapsed min"
  }
  if ($code -ne 2) { Finish $code "build.ps1 exited $code, which this script does not know" }

  # Stopped by the budget: steps in flight are listed as failed. The same ones twice running are stuck.
  $failed = Failed-Steps
  $same = @($failed | Where-Object { $previous -contains $_ })
  Say ("chunk {0} stopped by the budget, {1} min in; {2} step(s) in flight or failed, {3} also at the last stop" -f $chunk, $elapsed, $failed.Count, $same.Count)
  if ($same.Count -gt 0) {
    $repeats++
    $same | Select-Object -First 10 | ForEach-Object { Say "  again: $_" }
    if ($repeats -ge 2) {
      Finish 4 "stuck steps: the same step(s) were killed at the end of three chunks in a row; time one by hand before building on (trap 57)"
    }
  } else { $repeats = 0 }
  $previous = $failed
}
Finish 5 "gave up after $MaxChunks chunks, $([int]((Get-Date) - $started).TotalMinutes) min: still making progress, run it again"
