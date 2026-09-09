<#
Build a Windows configuration from the repository's gn args, the way
tooling/build-chromium does on the Mac: the args file is copied into the output
directory verbatim with stedding_version appended from VERSION, so the args of any
build are recoverable from the build itself.

Usage (PowerShell, from anywhere):
  tooling\win\build.ps1                          # win-release: chrome and mini_installer
  tooling\win\build.ps1 -Config win-release -Targets chrome
  tooling\win\build.ps1 -GenOnly                 # gn gen and stop

Environment:
  STEDDING_CHROMIUM_SRC   the checkout's src directory (or -Src)
  STEDDING_DEPOT_TOOLS    depot_tools, if it is not already on PATH
  STEDDING_VPYTHON_ROOT   a short directory for vpython's venv (docs/HANDOFF.md,
                          trap 34: a long %LOCALAPPDATA% blows past MAX_PATH)

Two rules this script keeps for you: the Windows toolchain is the installed Visual
Studio, never Google's (DEPOT_TOOLS_WIN_TOOLCHAIN=0), and a build is refused while a
browser from the same output directory is running, because the link would fail with
"permission denied" a long way into it.
#>
param(
  [string]$Config = "win-release",
  [string[]]$Targets = @("chrome", "mini_installer"),
  [string]$Src = $env:STEDDING_CHROMIUM_SRC,
  [switch]$GenOnly
)
$ErrorActionPreference = "Stop"
$root = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
if (-not $Src) { throw "set STEDDING_CHROMIUM_SRC to the checkout's src directory, or pass -Src" }
if (-not (Test-Path (Join-Path $Src "BUILD.gn"))) { throw "no Chromium checkout at $Src" }
$argsFile = Join-Path $root "tooling\args\$Config.gn"
if (-not (Test-Path $argsFile)) { throw "no gn args for '$Config' (expected $argsFile)" }
$version = (Get-Content (Join-Path $root "VERSION") -Raw).Trim()
if (-not $version) { throw "VERSION is empty" }
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
  Write-Host "autoninja -C $out $($Targets -join ' ')"
  autoninja -C $out @Targets
  if ($LASTEXITCODE -ne 0) { throw "autoninja failed" }
  Write-Host "built: $($Targets -join ', ') in $out"
} finally {
  Pop-Location
}
