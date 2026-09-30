<#
Runs the Windows installer against a real install, and never deletes a profile. One step per
call, so a scheduled task (below) can run it outside an agent's sandbox.

  -Mode status          what is installed now: the version resource, the uninstall entry, the
                        ProgIds, the Start menu shortcut
  -Mode backup          copies %LOCALAPPDATA%\Stedding (program and User Data) to -Backup;
                        refuses to overwrite an earlier backup
  -Mode upgrade         runs -Installer over what is installed (needs the backup)
  -Mode uninstall-keep  setup.exe --uninstall --force-uninstall, never --delete-profile
                        (needs the backup)
  -Mode install         runs -Installer when nothing is installed

The log is -Log, one line per fact, ending in "task done". Wait for that line.

Why it is built like this. An install made from an agent's own shell lands in a virtualised
copy of %LOCALAPPDATA% and HKCU that is not the user's (docs/HANDOFF.md, trap 40), so it runs
as a scheduled task of the user's own, created once on the machine:

  schtasks /Create /TN SteddingInstallTest /SC ONCE /ST 00:00 /TR "powershell -NoProfile
    -ExecutionPolicy Bypass -File <a wrapper that calls this script with the mode it reads
    from a file>"
  schtasks /Run /TN SteddingInstallTest            # then read -Log

An earlier version of this cycle ended in an uninstall that deleted the profile and took the
operator's own beta 5 (2026-09-10): the steps that remove anything keep the profile and need
the backup first. The defaults keep the log and the backup in dist\installer-test\, which is
outside AppData and not tracked.
#>
param(
  [ValidateSet('status', 'backup', 'upgrade', 'uninstall-keep', 'install')]
  [string]$Mode = 'status',
  [string]$Installer = '',
  [string]$Backup = '',
  [string]$Log = ''
)
$root = Split-Path (Split-Path $PSScriptRoot)
$work = Join-Path $root 'dist\installer-test'
New-Item -ItemType Directory -Force $work | Out-Null
if (-not $Backup) { $Backup = Join-Path $work 'backup' }
if (-not $Log) { $Log = Join-Path $work 'test.log' }
$version = (Get-Content (Join-Path $root 'VERSION')).Trim()
if (-not $Installer) { $Installer = Join-Path $root "dist\Stedding-$version-win-x64.exe" }

$stedding = Join-Path $env:LOCALAPPDATA 'Stedding'
$app = Join-Path $stedding 'Application'
$exe = Join-Path $app 'chrome.exe'
$data = Join-Path $stedding 'User Data'

function Log([string]$s) { Add-Content -Path $Log -Value ('[{0}] {1}' -f (Get-Date).ToString('HH:mm:ss'), $s) }

function Describe {
  Log "LOCALAPPDATA=$env:LOCALAPPDATA user=$env:USERNAME"
  Log "chrome.exe present: $(Test-Path $exe)"
  if (Test-Path $exe) {
    $vi = (Get-Item $exe).VersionInfo
    Log "version resource: ProductName='$($vi.ProductName)' FileVersion='$($vi.FileVersion)' Company='$($vi.CompanyName)'"
    Log ('application dir: ' + ((Get-ChildItem $app | ForEach-Object { $_.Name }) -join ', '))
  }
  Log "user data present: $(Test-Path $data)"
  $un = Get-ChildItem 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall' -ErrorAction SilentlyContinue |
    Where-Object { ($_ | Get-ItemProperty).DisplayName -like '*Stedding*' }
  $entry = 'none'
  if ($un) { $p = $un | Get-ItemProperty; $entry = "$($p.DisplayName) $($p.DisplayVersion) -> $($p.UninstallString)" }
  Log "uninstall entry: $entry"
  $progids = Get-ChildItem 'HKCU:\Software\Classes' -ErrorAction SilentlyContinue |
    Where-Object { $_.PSChildName -like 'SteddingHTM*' -or $_.PSChildName -like 'SteddingPDF*' } | ForEach-Object { $_.PSChildName }
  Log ('progids: ' + $(if ($progids) { $progids -join ', ' } else { 'none' }))
  Log "HKCU\Software\Stedding: $(Test-Path 'HKCU:\Software\Stedding')"
  $lnk = Get-ChildItem (Join-Path $env:APPDATA 'Microsoft\Windows\Start Menu\Programs') -Filter 'Stedding*.lnk' -ErrorAction SilentlyContinue | Select-Object -First 1
  Log ('start menu: ' + $(if ($lnk) { $lnk.Name } else { 'none' }))
}

function Need-Backup {
  if (-not (Test-Path (Join-Path $Backup 'User Data'))) { Log "refusing: no backup of the profile at $Backup (run -Mode backup first)"; return $false }
  return $true
}
function Need-Installer {
  if (-not (Test-Path $Installer)) { Log "refusing: no installer at $Installer"; return $false }
  return $true
}

Set-Content -Path $Log -Value "task start, mode=$Mode, version=$version"
switch ($Mode) {
  'status' { Describe }
  'backup' {
    if (Test-Path $Backup) { Log "a backup already exists at $Backup; leaving it" }
    elseif (-not (Test-Path $stedding)) { Log "nothing installed at ${stedding}: nothing to back up" }
    else {
      New-Item -ItemType Directory -Force $Backup | Out-Null
      robocopy $stedding $Backup /E /R:1 /W:1 /NFL /NDL /NJH /NJS /NP | Out-Null
      $n = (Get-ChildItem $Backup -Recurse -File -ErrorAction SilentlyContinue | Measure-Object).Count
      $src = (Get-ChildItem $stedding -Recurse -File -ErrorAction SilentlyContinue | Measure-Object).Count
      Log "backup copied: $n files of $src to $Backup"
    }
  }
  'upgrade' {
    if ((Need-Backup) -and (Need-Installer)) {
      Describe
      Log "--- running $Installer"
      $i = Start-Process -FilePath $Installer -ArgumentList @('--do-not-launch-chrome') -PassThru -Wait
      Log "install exit $($i.ExitCode)"
      Start-Sleep -Seconds 3
      Describe
    }
  }
  'uninstall-keep' {
    if (Need-Backup) {
      # A running Stedding is somebody's session: ask for it to be quit, never kill it.
      $running = @(Get-Process chrome -ErrorAction SilentlyContinue | Where-Object { $_.Path -eq $exe })
      if ($running.Count -gt 0) { Log "refusing: Stedding is running from $exe ($($running.Count) processes); quit it first"; Log 'task done'; return }
      $setup = Get-ChildItem $app -Recurse -Filter setup.exe -ErrorAction SilentlyContinue | Select-Object -First 1
      if ($setup) {
        $u = Start-Process -FilePath $setup.FullName -ArgumentList @('--uninstall', '--force-uninstall') -PassThru -Wait
        Log "uninstall exit $($u.ExitCode) (19 is UNINSTALL_SUCCESSFUL)"
      } else { Log 'uninstall: no setup.exe found' }
      Start-Sleep -Seconds 3
      Describe
    }
  }
  'install' {
    if (Test-Path $app) { Log "refusing: an install already exists at $app" }
    elseif (Need-Installer) {
      $i = Start-Process -FilePath $Installer -ArgumentList @('--do-not-launch-chrome') -PassThru -Wait
      Log "install exit $($i.ExitCode)"
      Start-Sleep -Seconds 3
      Describe
    }
  }
}
Log 'task done'
