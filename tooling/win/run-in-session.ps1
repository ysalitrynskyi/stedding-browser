<#
Runs a bash script in the operator's interactive session, detached, as a one-off scheduled task.
An SSH session lands in session 0, where browser tests have no desktop and an installer sees a
virtualised profile (docs/HANDOFF.md, trap 40); the task runs where the operator is logged in, and
survives the SSH session that started it. A task cannot delete itself: it was made from the
elevated SSH session, and the operator's session gets "Access is denied". So the script's
launcher deletes itself when the script ends, and each run first deletes the one-off tasks of
earlier runs whose launcher is gone; tooling\win\leftovers.ps1 -Clean deletes any left.

  tooling\win\run-in-session.ps1 -Script <path\to\job.sh> [-Name <task>] [-Arguments '<args>']

Prints the task's state. The script keeps its own log.
#>
param(
  [Parameter(Mandatory = $true)][string]$Script,
  [string]$Name = '',
  [string]$Arguments = ''
)
$full = (Resolve-Path $Script -ErrorAction Stop).Path
if (-not $Name) { $Name = 'stedding-' + [IO.Path]::GetFileNameWithoutExtension($full) }
$bash = Join-Path $env:ProgramFiles 'Git\bin\bash.exe'
if (-not (Test-Path $bash)) { Write-Error "no Git for Windows bash at $bash"; exit 1 }
# C:\a\b.sh -> /c/a/b.sh, as Git's bash takes it.
$posix = '/' + $full.Substring(0, 1).ToLower() + ($full.Substring(2) -replace '\\', '/')
$go = Join-Path $env:TEMP "$Name-go.ps1"
@"
(Get-Process -Id `$PID).PriorityClass = 'Normal'
& '$bash' '$posix' $Arguments
Remove-Item -LiteralPath '$go' -ErrorAction SilentlyContinue
"@ | Set-Content -LiteralPath $go -Encoding UTF8
# Earlier runs' tasks whose script has ended (their launcher in %TEMP% is gone).
Get-ScheduledTask | Where-Object { $_.State -ne 'Running' } | ForEach-Object {
  $launcher = @($_.Actions | ForEach-Object { if ($_.Arguments -match '-File\s+"?(.+?-go\.ps1)') { $Matches[1] } })
  if ($launcher.Count -eq 1 -and $launcher[0] -like "$env:TEMP\*" -and -not (Test-Path -LiteralPath $launcher[0])) {
    & schtasks /Delete /TN $_.TaskName /F 2>&1 | Out-Null
  }
}
# A task of that name from an earlier run, if any; "cannot find" is the usual answer.
& schtasks /Delete /TN $Name /F 2>&1 | Out-Null
schtasks /Create /TN $Name /TR "powershell -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$go`"" `
  /SC ONCE /ST 23:59 /SD 2026/01/01 /IT /RU $env:USERNAME /F 2>$null | Out-Null
$task = Get-ScheduledTask -TaskName $Name -ErrorAction SilentlyContinue
if (-not $task) { Write-Error "the task $Name was not made"; exit 1 }
$task.Settings.Priority = 4
$task.Settings.ExecutionTimeLimit = 'PT16H'
Set-ScheduledTask -InputObject $task | Out-Null
schtasks /Run /TN $Name | Out-Null
Start-Sleep 5
"$Name state=$((Get-ScheduledTask -TaskName $Name -ErrorAction SilentlyContinue).State)"
