<#
The Windows updater's n-1 check (docs/HANDOFF.md, "The updater (Windows)"; docs/features/updates.md
Up14-Up19): the installed Stedding, on a scratch profile and pointed at a local feed that lists the
next build, finds it, downloads it, checks it, installs it beside itself and shows the sidebar's pill;
pressing the pill restarts into the new version. The pill is pressed through UI Automation, which
needs neither the pointer nor the foreground (docs/HANDOFF.md, trap 118): a one-off task's window
could not take the foreground, and drive.ps1 refused the click.

Run it in the operator's own session, from a one-off scheduled task (trap 40: a process of the
agent's app sees a virtualised %LOCALAPPDATA% and HKCU):

  tooling\win\update-n1.ps1 -Feed <dir>

<dir> holds appcast-windows.xml, written by
  tooling\win\publish-appcast.ps1 -Installer <B> -Feed <dir>\appcast-windows.xml -Url http://127.0.0.1:<Port>/<B's name>
and B's installer itself. The installed copy must be the older build (A), installed with
tooling\win\test-installer.ps1 -Mode upgrade -Installer <A>. The log ends in N1_DONE; screenshots of
the window go to <dir>\shots.

-SidebarWidth <DIP> also checks the sidebar's width across the update, the way GitHub issue 65 was
reported (docs/features/sidebar.md Y47): A starts with that width set, and after the restart into B
the profile must still hold it. The log says WIDTH_KEPT or WIDTH_LOST.
#>
param(
  [Parameter(Mandatory = $true)][string]$Feed,
  [int]$Port = 8766,
  [string]$Profile = (Join-Path $env:TEMP 'stedding-update-n1'),
  [string]$Log = '',
  [string]$Python = '',
  [int]$SidebarWidth = 0
)
$ErrorActionPreference = 'Continue'
if (-not $Log) { $Log = Join-Path $Feed 'n1.log' }
if (-not $Python) { $Python = (Get-Command python -ErrorAction Stop).Source }
"start $(Get-Date -Format s)" | Set-Content $Log -Encoding UTF8
function Say([string]$m) { "$(Get-Date -Format HH:mm:ss) $m" | Add-Content $Log -Encoding UTF8 }
$app = Join-Path $env:LOCALAPPDATA 'Stedding\Application'
$exe = Join-Path $app 'chrome.exe'
. (Join-Path $PSScriptRoot 'drive.ps1') -Exe $exe
$script:Drive.Shots = Join-Path $Feed 'shots'
New-Item -ItemType Directory -Force $script:Drive.Shots | Out-Null
function Ver([string]$path) { (Get-Item $path -ErrorAction SilentlyContinue).VersionInfo.FileVersion }
# What Chromium's installer records for an in-use update (chrome/installer/setup): pv the version
# installed, opv and cmd the swap still to run, InstallerError 30 for IN_USE_UPDATED.
function Keys {
  $k = Get-ItemProperty 'HKCU:\Software\Stedding' -ErrorAction SilentlyContinue
  $u = (Get-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\Stedding' -ErrorAction SilentlyContinue).DisplayVersion
  "pv=$($k.pv) opv=$($k.opv) cmd=$($k.cmd) InstallerResult=$($k.InstallerResult) InstallerError=$($k.InstallerError) uninstall=$u"
}

$serverLog = Join-Path $Feed 'server.log'
Remove-Item $serverLog -ErrorAction SilentlyContinue
$server = Start-Process $Python -ArgumentList '-I', '-m', 'http.server', "$Port", '--bind', '127.0.0.1', '--directory', $Feed -PassThru -WindowStyle Hidden -RedirectStandardError $serverLog
Start-Sleep -Seconds 2
Say "before: $(Keys) chrome.exe=$(Ver $exe) new_chrome.exe=$(Test-Path (Join-Path $app 'new_chrome.exe'))"

$seed = @{ stedding = @{ welcome = @{ shown = $true } } }
if ($SidebarWidth -gt 0) { $seed.vertical_tabs = @{ uncollapsed_width = $SidebarWidth } }
# The width the profile holds, once the browser has written its preferences (they are committed
# about ten seconds after a change).
function Width {
  try { (Get-Content (Join-Path $Profile 'Default\Preferences') -Raw | ConvertFrom-Json).vertical_tabs.uncollapsed_width } catch { 'unreadable' }
}
$null = Drive-Launch -Profile $Profile -Urls @('https://example.com/', 'https://example.org/') `
  -Seed $seed `
  -Extra @("--stedding-update-feed=http://127.0.0.1:$Port/appcast-windows.xml", '--no-first-run', '--disable-search-engine-choice-screen')
$started = Get-Date
Say "launched, pid $($script:Drive.Pid)"

# The pill: ten seconds to the check, then the download, the signature and the installer.
$pill = $null
while (((Get-Date) - $started).TotalSeconds -lt 300) {
  Start-Sleep -Seconds 5
  $pill = Drive-Rows 'Button' | Where-Object { $_.Name -like '*New Stedding Version Available*' } | Select-Object -First 1
  if ($pill) { break }
}
Say "pill: $(if ($pill) { "$($pill.Name) at $($pill.X),$($pill.Y) after $([int]((Get-Date) - $started).TotalSeconds) s" } else { 'none in 300 s' })"
Say "after install: $(Keys) new_chrome.exe=$(Test-Path (Join-Path $app 'new_chrome.exe')) new version=$(Ver (Join-Path $app 'new_chrome.exe')) folders=$((Get-ChildItem $app -Directory | ForEach-Object Name) -join ',')"
$null = Drive-Shot 'n1-pill'
if ($SidebarWidth -gt 0) { Say "sidebar width before the update: $(Width)" }

if ($pill) {
  $oldPid = $script:Drive.Pid
  Add-Type -AssemblyName UIAutomationClient, UIAutomationTypes
  $rootEl = [System.Windows.Automation.AutomationElement]::FromHandle($script:Drive.Hwnd)
  $all = $rootEl.FindAll([System.Windows.Automation.TreeScope]::Descendants, [System.Windows.Automation.Condition]::TrueCondition)
  $target = $null
  foreach ($el in $all) {
    if ($el.Current.Name -like '*New Stedding Version Available*' -and $el.Current.ControlType.ProgrammaticName -eq 'ControlType.Button') { $target = $el; break }
  }
  if ($target) {
    $target.GetCurrentPattern([System.Windows.Automation.InvokePattern]::Pattern).Invoke()
    Say 'pressed the pill through UI Automation'
  } else { Say 'no pill element for UI Automation' }
  # The old process goes, the swap runs, and the new version opens on the same profile.
  $back = [IntPtr]::Zero
  $until = (Get-Date).AddSeconds(90)
  while ((Get-Date) -lt $until) {
    Start-Sleep -Seconds 2
    if (Get-Process -Id $oldPid -ErrorAction SilentlyContinue) { continue }
    $back = Drive-Find $Profile
    if ($back -ne [IntPtr]::Zero) { break }
  }
  Say "relaunched: $($back -ne [IntPtr]::Zero), pid $($script:Drive.Pid)"
  Start-Sleep -Seconds 6
  $running = (Get-Process -Id $script:Drive.Pid -ErrorAction SilentlyContinue).Path
  Say "after restart: $(Keys) chrome.exe=$(Ver $exe) running=$running new_chrome.exe=$(Test-Path (Join-Path $app 'new_chrome.exe')) old_chrome.exe=$(Test-Path (Join-Path $app 'old_chrome.exe'))"
  Say "tabs: $((Drive-Pages | ForEach-Object { $_.title }) -join ' | ')"
  if ($SidebarWidth -gt 0) {
    Start-Sleep -Seconds 15
    $w = Width
    Say "sidebar width: set $SidebarWidth, after the update $w $(if ("$w" -eq "$SidebarWidth") { 'WIDTH_KEPT' } else { 'WIDTH_LOST' })"
  }
  try {
    $req = [Net.HttpWebRequest]::Create("http://127.0.0.1:$($script:Drive.Port)/json/new?chrome://settings/help")
    $req.Method = 'PUT'; $req.Timeout = 5000; $req.Proxy = $null; $req.GetResponse().Close()
    Start-Sleep -Seconds 4
    $about = Drive-Pages | Where-Object { $_.url -like 'chrome://settings/help*' } | Select-Object -First 1
    $text = if ($about) { Drive-Eval $about.webSocketDebuggerUrl "document.querySelector('settings-ui').shadowRoot.querySelector('settings-main').shadowRoot.querySelector('settings-about-page').shadowRoot.textContent.replace(/\s+/g,' ').slice(0,600)" 5000 } else { 'no About page' }
    Say "about: $text"
  } catch { Say "about: $($_.Exception.Message)" }
  $null = Drive-Shot 'n1-after'
}
Drive-Stop
Stop-Process -Id $server.Id -Force -ErrorAction SilentlyContinue
Get-Content $serverLog -ErrorAction SilentlyContinue | Select-String 'GET' | ForEach-Object { Say "served: $($_.Line)" }
Say 'N1_DONE'
