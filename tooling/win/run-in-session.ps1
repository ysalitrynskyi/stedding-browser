<#
Runs a bash script in the operator's interactive session, detached, as a one-off scheduled task.
An SSH session lands in session 0, where browser tests have no desktop and an installer sees a
virtualised profile (docs/HANDOFF.md, trap 40); the task runs where the operator is logged in, and
survives the SSH session that started it. The task deletes itself when the script ends, so
tooling\win\leftovers.ps1 has no one-off task to report.

  tooling\win\run-in-session.ps1 -Script <path\to\job.sh> [-Name <task>] [-Arguments '<args>']

Prints the task's state. The script keeps its own log.
#>
param(
  [Parameter(Mandatory = $true)][string]$Script,
  [string]$Name = '',
  [string]$Arguments = ''
)
$ErrorActionPreference = 'Stop'
$full = (Resolve-Path $Script).Path
if (-not $Name) { $Name = 'stedding-' + [IO.Path]::GetFileNameWithoutExtension($full) }
$bash = Join-Path $env:ProgramFiles 'Git\bin\bash.exe'
if (-not (Test-Path $bash)) { throw "no Git for Windows bash at $bash" }
# C:\a\b.sh -> /c/a/b.sh, as Git's bash takes it.
$posix = '/' + $full.Substring(0, 1).ToLower() + ($full.Substring(2) -replace '\\', '/')
$go = Join-Path $env:TEMP "$Name-go.ps1"
@"
(Get-Process -Id `$PID).PriorityClass = 'Normal'
& '$bash' '$posix' $Arguments
schtasks /Delete /TN '$Name' /F 2>`$null | Out-Null
Remove-Item -LiteralPath '$go' -ErrorAction SilentlyContinue
"@ | Set-Content -LiteralPath $go -Encoding UTF8
schtasks /Delete /TN $Name /F 2>$null | Out-Null
schtasks /Create /TN $Name /TR "powershell -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$go`"" `
  /SC ONCE /ST 23:59 /SD 2026/01/01 /IT /RU $env:USERNAME /F 2>$null | Out-Null
$task = Get-ScheduledTask -TaskName $Name
$task.Settings.Priority = 4
$task.Settings.ExecutionTimeLimit = 'PT16H'
Set-ScheduledTask -InputObject $task | Out-Null
schtasks /Run /TN $Name | Out-Null
Start-Sleep 5
"$Name state=$((Get-ScheduledTask -TaskName $Name -ErrorAction SilentlyContinue).State)"
