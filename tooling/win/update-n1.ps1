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

-TwoWindowPins also checks the first launch's merge of every window's pins into the profile's store
(ADR 0035; docs/features/windows.md G2, G19), for an A whose pins were each window's own. Before
the update A gets a second window, and pages served from <dir> are pinned with Ctrl+D: n1-alpha and
n1-shared in the first window, n1-shared and n1-beta in the second (one address in both, in the
same Space). The setup ends in PINS_SETUP_DONE or PINS_SETUP_INCOMPLETE. The pill's restart brings
the last session back whatever the startup setting, so both windows return in B. Each must then
show n1-alpha, n1-shared and n1-beta once, above its New Tab row: PINS_MERGED, or PINS_NOT_MERGED
with what each window showed. B is then quit through DevTools, an ordinary quit that writes the
preferences, and the log lists the records of stedding.pins.store in Default\Preferences:
STORE_MERGED when each page is one record. Ctrl+T and Ctrl+D are real keys (drive.ps1): run it in
a connected session with nobody at the keyboard (trap 59).
#>
param(
  [Parameter(Mandatory = $true)][string]$Feed,
  [int]$Port = 8766,
  [string]$Profile = (Join-Path $env:TEMP 'stedding-update-n1'),
  [string]$Log = '',
  [string]$Python = '',
  [int]$SidebarWidth = 0,
  [switch]$TwoWindowPins
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

# -TwoWindowPins: the pages to pin, served from the feed's folder. Each title is its file's name, so
# a row reads the same whether it shows the page's title or its address. n1-start is the first
# window's own page, never pinned. drive.ps1's lines (REFUSED, TIMEOUT) go to this log too.
$pinPages = @('n1-alpha', 'n1-shared', 'n1-beta')
if ($TwoWindowPins) {
  $script:Drive.LogFile = $Log
  foreach ($t in @('n1-start') + $pinPages) {
    $html = '<!doctype html><meta charset="utf-8"><title>{0}</title><body style="font:48px sans-serif;margin:40px">{0}</body>' -f $t
    [IO.File]::WriteAllText((Join-Path $Feed "$t.html"), $html, (New-Object Text.UTF8Encoding $false))
  }
}
# The browser's own top-level windows; its bubbles and menus are smaller.
function MainWindows {
  return @([StedDrive]::WindowsOf([uint32]$script:Drive.Pid) | Where-Object {
      $cls = New-Object Text.StringBuilder 256; [void][StedDrive]::GetClassName($_, $cls, 256)
      $r = New-Object StedDrive+RECT; [void][StedDrive]::GetWindowRect($_, [ref]$r)
      $cls.ToString() -eq 'Chrome_WidgetWin_1' -and ($r.Right - $r.Left) -gt 300 -and ($r.Bottom - $r.Top) -gt 300 })
}
# Window $h in front, for keys meant for it. drive.ps1's guard asks only that some window of the
# browser be in front, and both windows are one process: Drive-Focus takes the other one for it.
function Front([IntPtr]$h) {
  $script:Drive.Hwnd = $h
  for ($i = 0; $i -lt 4; $i++) {
    $null = Drive-Focus
    if ([StedDrive]::GetForegroundWindow() -eq $h) { return $true }
    if (-not (Drive-WaitOwnerIdle 120)) { return $false }
    [StedDrive]::keybd_event(0x12, 0, 0, [UIntPtr]::Zero); [StedDrive]::keybd_event(0x12, 0, 2, [UIntPtr]::Zero)
    Drive-Mark
    [void][StedDrive]::SetForegroundWindow($h)
    Start-Sleep -Milliseconds 400
  }
  return ([StedDrive]::GetForegroundWindow() -eq $h)
}
# The pages DevTools lists with the title $t: a page has its title once it has committed.
function Titled([string]$t) { return @(Drive-Pages | Where-Object { $_.title -eq $t }).Count }
function WaitTitled([string]$t, [int]$n, [int]$Seconds) {
  $until = (Get-Date).AddSeconds($Seconds)
  while ((Titled $t) -lt $n) {
    if ((Get-Date) -gt $until) { return $false }
    Start-Sleep -Milliseconds 500
  }
  return $true
}
# A page opened as a new tab of the window in front, as a person does it: Ctrl+T, its address,
# Enter (TST-6 step 12). True once DevTools lists one more page of that title than before.
function OpenInBar([string]$t) {
  $had = Titled $t
  $ok = (Drive-Keys 'ctrl+t'); Start-Sleep -Milliseconds 800
  $ok = $ok -and (Drive-Type "http://127.0.0.1:$Port/$t.html"); Start-Sleep -Milliseconds 800
  $ok = $ok -and (Drive-Keys 'enter')
  if (-not $ok) { Say "open ${t}: a key was refused"; return $false }
  if (-not (WaitTitled $t ($had + 1) 30)) { Say "open ${t}: no page of that title in 30 s"; return $false }
  return $true
}
# The window's New Tab row (a Button), where the pinned run ends: of the buttons so named, the one
# nearest the column of the row $near.
function NewTabRow($near) {
  $x = if ($near) { $near.X } else { 0 }
  return (Drive-Rows 'Button' | Where-Object { $_.Name -like '*New Tab*' } | Sort-Object { [math]::Abs($_.X - $x) } | Select-Object -First 1)
}
# Ctrl+D pins the active tab of the window in front in its Space; its row then lies above the
# New Tab row (TST-9 step 11). In A the pin is that window's own.
function PinActive([string]$t, [int]$w) {
  if (-not (Drive-Keys 'ctrl+d')) { Say "window $w, ${t}: Ctrl+D refused"; return $false }
  Start-Sleep -Milliseconds 1200
  $row = Drive-Rows | Where-Object { $_.Name -like "*$t*" } | Sort-Object Y | Select-Object -First 1
  $nt = NewTabRow $row
  $ok = [bool]($row -and $nt -and $row.Y -lt $nt.Y)
  Say "window $w pinned ${t}: $ok (row y $($row.Y), New Tab y $($nt.Y))"
  return $ok
}
function RowNames { return ((@(Drive-Rows) | Sort-Object Y | ForEach-Object { $_.Name }) -join ' | ') }
# What each window shows of the pinned pages: its rows by UI Automation, named by the page's title
# (an asleep tab's row by the title its record keeps), each to be once in the window and above its
# New Tab row. A window with no rows at all (a dialog) is not counted as one of the browser's.
function PinsSeen {
  $ok = $true; $n = 0; $parts = @()
  foreach ($h in @(MainWindows)) {
    $script:Drive.Hwnd = $h
    $rows = @(Drive-Rows)
    if ($rows.Count -eq 0) { continue }
    $n++
    $nt = NewTabRow $rows[0]
    $each = foreach ($t in $pinPages) {
      $mine = @($rows | Where-Object { $_.Name -like "*$t*" })
      $place = if (-not $nt) { 'place unknown' } elseif (@($mine | Where-Object { $_.Y -gt $nt.Y }).Count -gt 0) { 'below New Tab' } else { 'pinned' }
      if ($mine.Count -ne 1 -or $place -eq 'below New Tab') { $ok = $false }
      "$t x$($mine.Count) $place"
    }
    $parts += "window ${n}: $($each -join ', ') [rows: $(($rows | Sort-Object Y | ForEach-Object { $_.Name }) -join ' | ')]"
  }
  if ($n -ne 2) { $ok = $false }
  return @{ Ok = $ok; Text = "$n windows; $($parts -join '; ')" }
}
# B quit the way a person quits it, so its preferences are written: DevTools' Browser.close, then
# up to a minute for every process on the profile to go. One still there is stopped by force.
function CloseBrowser {
  $t0 = Get-Date
  try {
    $req = [Net.HttpWebRequest]::Create("http://127.0.0.1:$($script:Drive.Port)/json/version")
    $req.Timeout = 5000; $req.ReadWriteTimeout = 5000; $req.Proxy = $null
    $resp = $req.GetResponse()
    try { $text = (New-Object IO.StreamReader($resp.GetResponseStream())).ReadToEnd() } finally { $resp.Close() }
    $wsUrl = (ConvertFrom-Json -InputObject $text).webSocketDebuggerUrl
    $ws = New-Object System.Net.WebSockets.ClientWebSocket
    $cts = New-Object Threading.CancellationTokenSource
    try {
      if ($ws.ConnectAsync([Uri]$wsUrl, $cts.Token).Wait(5000)) {
        $bytes = [Text.Encoding]::UTF8.GetBytes('{"id":1,"method":"Browser.close"}')
        $null = $ws.SendAsync((New-Object ArraySegment[byte] -ArgumentList @(,$bytes)), [Net.WebSockets.WebSocketMessageType]::Text, $true, $cts.Token).Wait(5000)
        # The answer, or the socket closing as the browser goes: either is fine.
        $buf = New-Object byte[] 4096
        try { $null = $ws.ReceiveAsync((New-Object ArraySegment[byte] -ArgumentList @(,$buf)), $cts.Token).Wait(5000) } catch {}
      } else { Say 'close: DevTools did not answer' }
    } finally { try { $cts.Cancel(); $ws.Abort() } catch {}; $ws.Dispose(); $cts.Dispose() }
  } catch { Say "close: $($_.Exception.Message)" }
  $gone = $false
  for ($i = 0; $i -lt 60 -and -not $gone; $i++) {
    Start-Sleep -Seconds 1
    $left = @(Get-CimInstance Win32_Process -Filter "Name='chrome.exe'" -OperationTimeoutSec 15 | Where-Object { $_.CommandLine -like "*$Profile*" })
    $gone = ($left.Count -eq 0)
  }
  if ($gone) { Say "B quit through DevTools in $([int]((Get-Date) - $t0).TotalSeconds) s" }
  else { Say 'B still ran a minute after Browser.close: stopped by force, so the preferences may be older than its last change'; Drive-Stop; Start-Sleep -Seconds 2 }
}
# The profile's pin store as B left it in Preferences (stedding.pins.store, one dict per record).
function StoreSays {
  try {
    $p = Get-Content (Join-Path $Profile 'Default\Preferences') -Raw -Encoding UTF8 | ConvertFrom-Json
    $records = @($p.stedding.pins.store | Where-Object { $_ })
    $ok = $true
    $each = foreach ($t in $pinPages) {
      $c = @($records | Where-Object { "$($_.home)" -like "*$t*" }).Count
      if ($c -ne 1) { $ok = $false }
      "$t x$c"
    }
    $list = ($records | ForEach-Object { "$($_.tier) '$($_.title)' $($_.home)" }) -join ' | '
    return "$($records.Count) records, store_ready=$($p.stedding.pins.store_ready); $($each -join ', '); [$list] $(if ($ok) { 'STORE_MERGED' } else { 'STORE_NOT_MERGED' })"
  } catch { return "unreadable: $($_.Exception.Message)" }
}

$serverLog = Join-Path $Feed 'server.log'
$serverOut = Join-Path $Feed 'server.out'
Remove-Item $serverLog, $serverOut -ErrorAction SilentlyContinue
# Its output goes to a file too: run from a scheduled task there is no console, and the
# server stopped at its first line ("Bad file descriptor"), so the feed was never served.
$server = Start-Process $Python -ArgumentList '-I', '-m', 'http.server', "$Port", '--bind', '127.0.0.1', '--directory', $Feed -PassThru -WindowStyle Hidden -RedirectStandardError $serverLog -RedirectStandardOutput $serverOut
Start-Sleep -Seconds 2
Say "before: $(Keys) chrome.exe=$(Ver $exe) new_chrome.exe=$(Test-Path (Join-Path $app 'new_chrome.exe'))"

$seed = @{ stedding = @{ welcome = @{ shown = $true } } }
if ($SidebarWidth -gt 0) { $seed.vertical_tabs = @{ uncollapsed_width = $SidebarWidth } }
# The width the profile holds, once the browser has written its preferences (they are committed
# about ten seconds after a change).
function Width {
  try { (Get-Content (Join-Path $Profile 'Default\Preferences') -Raw | ConvertFrom-Json).vertical_tabs.uncollapsed_width } catch { 'unreadable' }
}
$urls = @('https://example.com/', 'https://example.org/')
if ($TwoWindowPins) { $urls = @("http://127.0.0.1:$Port/n1-start.html") }
$null = Drive-Launch -Profile $Profile -Urls $urls `
  -Seed $seed `
  -Extra @("--stedding-update-feed=http://127.0.0.1:$Port/appcast-windows.xml", '--no-first-run', '--disable-search-engine-choice-screen')
$started = Get-Date
Say "launched, pid $($script:Drive.Pid)"
$pillUntil = $started.AddSeconds(300)

if ($TwoWindowPins) {
  $setupOk = $true
  $w1 = $script:Drive.Hwnd
  if (-not (WaitTitled 'n1-start' 1 60)) { Say 'n1-start had not loaded in 60 s' }
  if (Front $w1) {
    foreach ($t in 'n1-alpha', 'n1-shared') {
      if (-not (OpenInBar $t)) { $setupOk = $false }
      elseif (-not (PinActive $t 1)) { $setupOk = $false }
    }
    $null = Drive-Shot 'n1-pins-window1'
  } else { Say 'window 1 did not come to the front: nothing pinned in it'; $setupOk = $false }
  # The second window: the address handed to the running browser, whose single instance opens it
  # in a new window of the profile, on the first Space (windows G6), as that window's only tab.
  # n1-shared is not typed into the bar here: the bar lists the first window's tab of it, and Enter
  # on that row would ask where to show it (windows G12) instead of opening a tab.
  $null = Start-Process -FilePath $exe -ArgumentList @("--user-data-dir=`"$Profile`"", '--new-window', "http://127.0.0.1:$Port/n1-shared.html") -PassThru
  # The new window is the one with a row for that page: a bubble of the update is no window of it.
  $w2 = [IntPtr]::Zero
  for ($i = 0; $i -lt 30 -and $w2 -eq [IntPtr]::Zero; $i++) {
    Start-Sleep -Seconds 1
    foreach ($h in @(MainWindows | Where-Object { $_ -ne $w1 })) {
      $script:Drive.Hwnd = $h
      if (@(Drive-Rows | Where-Object { $_.Name -like '*n1-shared*' }).Count -gt 0) { $w2 = $h; break }
    }
  }
  if ($w2 -eq [IntPtr]::Zero) { Say 'no second window with n1-shared in 30 s'; $setupOk = $false }
  else {
    if (-not (WaitTitled 'n1-shared' 2 30)) { Say 'the second window''s n1-shared had not loaded in 30 s' }
    if (Front $w2) {
      if (-not (PinActive 'n1-shared' 2)) { $setupOk = $false }
      if (-not (OpenInBar 'n1-beta')) { $setupOk = $false }
      elseif (-not (PinActive 'n1-beta' 2)) { $setupOk = $false }
      $null = Drive-Shot 'n1-pins-window2'
    } else { Say 'window 2 did not come to the front: nothing pinned in it'; $setupOk = $false }
  }
  $script:Drive.Hwnd = $w1; Say "before the update, window 1: $(RowNames)"
  if ($w2 -ne [IntPtr]::Zero) { $script:Drive.Hwnd = $w2; Say "before the update, window 2: $(RowNames)" }
  $script:Drive.Hwnd = $w1
  # The session is written a few seconds after a change, and the restart writes it again.
  Start-Sleep -Seconds 3
  if ($setupOk) { Say 'PINS_SETUP_DONE' } else { Say 'PINS_SETUP_INCOMPLETE' }
  # The keys took a while: the pill gets its five minutes from here.
  $pillUntil = (Get-Date).AddSeconds(300)
}

# The pill: ten seconds to the check, then the download, the signature and the installer. With
# -TwoWindowPins it is looked for in each window, and pressed in the one it was found in.
$pill = $null
while ((Get-Date) -lt $pillUntil) {
  Start-Sleep -Seconds 5
  $look = if ($TwoWindowPins) { @(MainWindows) } else { @($script:Drive.Hwnd) }
  foreach ($h in $look) {
    $script:Drive.Hwnd = $h
    $pill = Drive-Rows 'Button' | Where-Object { $_.Name -like '*New Stedding Version Available*' } | Select-Object -First 1
    if ($pill) { break }
  }
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
  if ($TwoWindowPins) {
    if ($back -eq [IntPtr]::Zero) { Say 'pins after the update: no window after the restart PINS_NOT_MERGED' }
    else {
      # The restore brings the windows back one by one, and each window's pins settle a turn after
      # it: two windows within a minute, then up to a minute for their rows.
      for ($i = 0; $i -lt 30 -and @(MainWindows).Count -lt 2; $i++) { Start-Sleep -Seconds 2 }
      Say "windows after the restart: $(@(MainWindows).Count)"
      $seen = $null
      $until = (Get-Date).AddSeconds(60)
      do {
        Start-Sleep -Seconds 3
        $seen = PinsSeen
      } while (-not $seen.Ok -and (Get-Date) -lt $until)
      $script:Drive.Hwnd = $back
      Say "pins after the update: $($seen.Text) $(if ($seen.Ok) { 'PINS_MERGED' } else { 'PINS_NOT_MERGED' })"
    }
  }
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
  if ($TwoWindowPins -and $back -ne [IntPtr]::Zero) {
    CloseBrowser
    Say "pin store: $(StoreSays)"
    Say "sidebar backups: $(@(Get-ChildItem (Join-Path $Profile 'Default\Stedding Sidebar Sync\backups') -Filter '*.json' -ErrorAction SilentlyContinue).Count)"
  }
} elseif ($TwoWindowPins) { Say 'pins after the update: no update, so B never ran PINS_NOT_MERGED' }
Drive-Stop
Stop-Process -Id $server.Id -Force -ErrorAction SilentlyContinue
Get-Content $serverLog -ErrorAction SilentlyContinue | Select-String 'GET' | ForEach-Object { Say "served: $($_.Line)" }
Say 'N1_DONE'
