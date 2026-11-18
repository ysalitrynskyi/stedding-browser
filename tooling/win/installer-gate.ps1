<#
A Windows release's installer checks, the way users meet the installer (docs/HANDOFF.md, trap 47),
after tooling\win\package-installer.ps1 made dist\Stedding-<Version>-win-x64.exe and the previous
release's image sits beside it as dist\Stedding-<From>-win-x64.exe.

1. The update. The installed copy is backed up; <From> is installed (a newer copy first uninstalled,
   keeping the profile, since an older installer refuses to downgrade); a local feed signed for
   <Version> is served, and update-n1.ps1 -TwoWindowPins has <From> find it, install it and restart
   into it with pins in two windows. The log quotes the pins before and after: they must match.
   (The PINS_MERGED and STORE_MERGED markers judge only an update from before 0.6.0, whose pins
   were each window's own.)
2. The cycle. <From> again, upgraded by <Version>'s installer; an uninstall that keeps the
   profile; a fresh install. It ends with <Version> installed.

Run it in the operator's session (run-in-session.ps1; trap 40). It refuses, changing nothing,
while Stedding runs from the installed folder: that is the owner's browser (trap 62). The log
(-Log, default %TEMP%\stedding-gate\installer-<Version>.log) ends in INSTALLER_CHECKS_DONE.

  tooling\win\installer-gate.ps1 -Version 0.6.1 -From 0.6.0
#>
param(
  [Parameter(Mandatory = $true)][string]$Version,
  [Parameter(Mandatory = $true)][string]$From,
  [string]$Log = ''
)
(Get-Process -Id $PID).PriorityClass = 'Normal'
$repo = Split-Path (Split-Path $PSScriptRoot)
$dir = Join-Path $env:TEMP 'stedding-gate'
New-Item -ItemType Directory -Force $dir | Out-Null
if (-not $Log) { $Log = Join-Path $dir "installer-$Version.log" }
"start $(Get-Date -Format HH:mm:ss): $From -> $Version" | Set-Content $Log
$it = Join-Path $repo 'dist\installer-test'
New-Item -ItemType Directory -Force $it | Out-Null
$backup = Join-Path $it 'gate-backup'
$old = Join-Path $repo "dist\Stedding-$From-win-x64.exe"
$new = Join-Path $repo "dist\Stedding-$Version-win-x64.exe"
$installed = Join-Path $env:LOCALAPPDATA 'Stedding\Application\chrome.exe'

$refuse = @()
foreach ($f in @($old, $new)) { if (-not (Test-Path $f)) { $refuse += "no installer at $f" } }
if (@(Get-Process chrome -ErrorAction SilentlyContinue | Where-Object { $_.Path -eq $installed }).Count -gt 0) {
  $refuse += "Stedding runs from $installed"
}
if ($refuse.Count -gt 0) {
  "refusing, nothing done: $($refuse -join '; ')" | Add-Content $Log
  "INSTALLER_CHECKS_DONE refused" | Add-Content $Log
  exit 1
}

function Step($mode, $name, $extra) {
  $l = Join-Path $it "gate-$name.log"
  $a = @{ Mode = $mode; Log = $l } + $extra
  & (Join-Path $repo 'tooling\win\test-installer.ps1') @a
  "--- $name" | Add-Content $Log
  Get-Content $l -ErrorAction SilentlyContinue | Select-Object -Last 8 | Add-Content $Log
}
function Installed { (Get-Item $installed -ErrorAction SilentlyContinue).VersionInfo.FileVersion }

# 1. The update.
Step 'status' 'status-before' @{}
Step 'backup' 'backup' @{ Backup = $backup }
Step 'upgrade' "upgrade-$From" @{ Installer = $old; Backup = $backup }
# A release x.y.z installs as <milestone>.y.z.999 (docs/HANDOFF.md, "The updater (Windows)").
if ($From -match '^\d+\.(\d+)\.(\d+)$' -and (Installed) -notlike "*.$($Matches[1]).$($Matches[2]).999") {
  Step 'uninstall-keep' 'uninstall' @{ Backup = $backup }
  Step 'install' "install-$From" @{ Installer = $old }
}
"installed: $(Installed)" | Add-Content $Log
$feed = Join-Path $dir "feed-$Version"
Remove-Item -Recurse -Force $feed -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Force $feed | Out-Null
Copy-Item $new $feed
try {
  & (Join-Path $repo 'tooling\win\publish-appcast.ps1') -Installer $new -Feed "$feed\appcast-windows.xml" `
    -Url "http://127.0.0.1:8766/$(Split-Path $new -Leaf)" 2>&1 | Select-Object -Last 3 | Add-Content $Log
} catch { "publish-appcast: $($_.Exception.Message)" | Add-Content $Log }
& (Join-Path $repo 'tooling\win\update-n1.ps1') -Feed $feed -TwoWindowPins 2>&1 | Select-Object -Last 3 | Add-Content $Log
'n1 log:' | Add-Content $Log
Get-Content "$feed\n1.log" -ErrorAction SilentlyContinue | Add-Content $Log
Start-Sleep 20
Get-CimInstance Win32_Process -Filter "Name='chrome.exe'" | Where-Object { $_.CommandLine -like '*stedding-update-n1*' } |
  ForEach-Object { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue }
Step 'status' 'status-after-update' @{}

# 2. The cycle.
Step 'uninstall-keep' 'uninstall-1' @{ Backup = $backup }
Step 'install' 'install-old' @{ Installer = $old }
Step 'status' 'status-old' @{}
Step 'upgrade' 'upgrade' @{ Installer = $new; Backup = $backup }
Step 'status' 'status-upgraded' @{}
Step 'uninstall-keep' 'uninstall-2' @{ Backup = $backup }
Step 'install' 'install-new' @{ Installer = $new }
Step 'status' 'status-end' @{}
"INSTALLER_CHECKS_DONE $(Get-Date -Format HH:mm:ss); installed: $(Installed)" | Add-Content $Log
