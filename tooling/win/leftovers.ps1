# What this project's builds, tests and releases left on the PC: processes still running
# from the Chromium output directory, build tools nobody waits on, local servers started
# for a check, temporary files, and one-time scheduled tasks that ran a script from
# %TEMP% (docs/HANDOFF.md, trap 147). The Mac's is tooling/leftovers.
#
# Windows PowerShell 5.1. Run it when a build, a sweep or a release is done:
#
#   powershell -NoProfile -File tooling\win\leftovers.ps1            lists them
#   powershell -NoProfile -File tooling\win\leftovers.ps1 -Clean     ends and deletes them
#
# The exit code is 1 when anything is left. Never touched: a Stedding installed for the
# person (it runs from %LOCALAPPDATA%), a server that does not name this project in its
# command line, a scheduled task that runs anything outside %TEMP%, and anything at all
# while a build or another tooling script runs: it would be that run's.
param(
  [switch]$Clean,
  [string]$Src = $env:STEDDING_CHROMIUM_SRC
)
$ErrorActionPreference = 'SilentlyContinue'
$temp = [IO.Path]::GetTempPath().TrimEnd('\')
$out = if ($Src) { (Join-Path $Src 'out') + '\' } else { $null }
$all = Get-CimInstance Win32_Process

function Get-Busy {
  # A build, or another tooling script (build.ps1, build-until-done.ps1, drive.ps1, tooling/dev ...).
  $all | Where-Object {
    $_.ProcessId -ne $PID -and $_.CommandLine -and
    $_.CommandLine -match '(^|[\s\\/"])tooling[\\/][\w.\\/-]+' -and
    $_.CommandLine -notmatch 'leftovers\.ps1'
  }
}

function Get-OutProcesses {
  if (-not $out) { return @() }
  $all | Where-Object { $_.ExecutablePath -and $_.ExecutablePath.StartsWith($out, 'OrdinalIgnoreCase') }
}

function Get-BuildTools { $all | Where-Object { $_.Name -in 'siso.exe', 'ninja.exe' } }

function Get-Servers {
  $listening = Get-NetTCPConnection -State Listen | Select-Object -ExpandProperty OwningProcess -Unique
  $all | Where-Object {
    $_.ProcessId -in $listening -and $_.Name -match '^(python|pythonw|node)(\d|\.exe)' -and
    $_.CommandLine -match 'stedding'
  }
}

function Get-TempPaths {
  # siso's logs, the tests' scoped folders, and the names the tooling makes.
  $names = 'siso*', 'scoped_dir*', 'stedding-drive', 'stedding-capture-profile', 'stedding-shots',
           'stedding-update-n1', 'stedding-s173', 'stedding-release-probe-*', 'stedding-move.*'
  foreach ($n in $names) { Get-ChildItem $temp -Filter $n -Force }
}

function Get-StaleTasks {
  Get-ScheduledTask | Where-Object {
    $_.State -ne 'Running' -and
    ($_.Actions | Where-Object { ($_.Execute + ' ' + $_.Arguments) -like "*$temp*" -or
                                 ($_.Execute + ' ' + $_.Arguments) -like '*\AppData\Local\Temp\*' }) -and
    -not ($_ | Get-ScheduledTaskInfo).NextRunTime
  }
}

$busy = @(Get-Busy) + @(Get-BuildTools)
if ($Clean) {
  if ($busy.Count -gt 0) {
    Write-Host "a build or another tooling script is running; what it has running is its own. Nothing ended or deleted:"
    $busy | ForEach-Object { Write-Host ("     {0} {1}" -f $_.ProcessId, $_.Name) }
    exit 1
  }
  Get-OutProcesses | ForEach-Object { Stop-Process -Id $_.ProcessId -Force }
  Get-Servers | ForEach-Object { Stop-Process -Id $_.ProcessId -Force }
  Start-Sleep -Seconds 2
  Get-TempPaths | Remove-Item -Recurse -Force
  Get-StaleTasks | ForEach-Object { schtasks /Delete /TN $_.TaskName /F | Out-Null }
  $all = Get-CimInstance Win32_Process
} elseif ($busy.Count -gt 0) {
  Write-Host "a build or another tooling script is running: what follows may be its own"
}

$found = $false
$list = @(Get-OutProcesses)
if ($list.Count -gt 0) {
  $found = $true
  Write-Host "running from ${out}:"
  $list | ForEach-Object { Write-Host ("     {0} {1}" -f $_.ProcessId, $_.ExecutablePath) }
}
$list = @(Get-BuildTools)
if ($list.Count -gt 0) {
  $found = $true
  Write-Host "build tools running (siso, ninja): $(@($list | ForEach-Object { $_.ProcessId }) -join ', ')"
}
$list = @(Get-Servers)
if ($list.Count -gt 0) {
  $found = $true
  Write-Host "local servers for this project:"
  $list | ForEach-Object { Write-Host ("     {0} {1}" -f $_.ProcessId, $_.CommandLine) }
}
$list = @(Get-TempPaths)
if ($list.Count -gt 0) {
  $found = $true
  $bytes = ($list | ForEach-Object {
    if ($_.PSIsContainer) { (Get-ChildItem $_.FullName -Recurse -Force | Measure-Object Length -Sum).Sum } else { $_.Length }
  } | Measure-Object -Sum).Sum
  Write-Host ("{0} temporary files and folders in {1}, {2:N1} GB" -f $list.Count, $temp, ($bytes / 1GB))
}
$list = @(Get-StaleTasks)
if ($list.Count -gt 0) {
  $found = $true
  Write-Host "one-time scheduled tasks that ran a script from %TEMP%: $(@($list | ForEach-Object { $_.TaskName }) -join ', ')"
}
if (-not $found) { Write-Host "nothing left over" }
if ($found) { exit 1 }
exit 0
