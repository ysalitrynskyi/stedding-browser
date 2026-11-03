<#
The live half of BACKLOG S-173 on Windows: the core-loop acceptance script (TST-6), the drags
onto a folder header and a Space chip (TST-7) and the core keyboard (TST-9), with real input
through tooling\win\drive.ps1. Rows, buttons and chips are found by UI Automation
(Drive-Rows), never by fixed coordinates; what a step did is read back from DevTools
(Drive-Visible: the page that says it is visible) and UI Automation, not from a picture. The
captures are for the record.

It moves the real pointer and presses real keys: run it only with the operator's yes, nobody
at the keyboard, in a connected session (docs/HANDOFF.md trap 59). drive.ps1's guards stop
input whenever another window is in front or the operator touched the machine.

  powershell -NoProfile -ExecutionPolicy Bypass -File s173-live.ps1 -Part layout
  powershell -NoProfile -ExecutionPolicy Bypass -File s173-live.ps1 -Part all
  powershell ... -Part all -Exe "$env:LOCALAPPDATA\Stedding\Application\chrome.exe"   # installed

-Part layout builds the fixture and lists what UI Automation sees (rows, buttons, chips), so
the names this script looks for can be confirmed first. Results: one PASS or FAIL line per
step in $env:TEMP\stedding-s173\results.txt, or NOT-CHECKED where the step's condition was not
there to check (tst9-9 with no infobar up); captures in $env:TEMP\stedding-drive.

Every step logs what it is about to do, and every key, click and wait on the browser, to
$env:TEMP\stedding-s173\progress.log as it happens: a run that stops names the step and the
call. No call waits for ever (drive.ps1, "Nothing here may wait for ever"); one that gives no
answer in time is logged as TIMEOUT, its step reads it as nothing found, and the run goes on.

Names the script assumes and -Part layout confirms (GUESS): a row's UI Automation name starts
with its page title; the folder's header is a Button whose name holds "New Folder"; a Space
chip is a Button whose name holds the Space's name; the sidebar's toggle is a Button named
"Collapse tabs (Ctrl+S)" or "Expand tabs (Ctrl+S)"; the address field is an Edit whose name holds "Address".
#>
param(
  [ValidateSet('layout', 'tst6', 'tst7', 'tst9', 'all')][string]$Part = 'layout',
  [string]$Exe = '',
  [string]$Repo = (Join-Path $env:USERPROFILE 'work\stedding-browser')
)
$ErrorActionPreference = 'Stop'
$drive = Join-Path $Repo 'tooling\win\drive.ps1'
if ($Exe) { . $drive -Exe $Exe } else { . $drive }

$work = Join-Path $env:TEMP 'stedding-s173'
$pages = Join-Path $work 'pages'
New-Item -ItemType Directory -Force $pages | Out-Null
$script:Drive.LogFile = Join-Path $work 'progress.log'
"S-173 live run $(Get-Date -Format s) part=$Part" | Set-Content -Path $script:Drive.LogFile -Encoding UTF8
$script:Drive.Trace = $true
# Page A has a saturated colour of its own (tst9-9, toolbar T36): the line a hidden address row left
# is in the page's colour, and on a white page no light mat could tell it from the mat around it.
foreach ($n in 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h') {
  $t = 'Page ' + $n.ToUpper()
  $look = if ($n -eq 'a') { 'background:#b0127a;color:#fff;' } else { '' }
  "<!doctype html><meta charset=`"utf-8`"><title>$t</title><body style=`"${look}font:48px sans-serif;margin:40px`">$t</body>" |
    Set-Content -Path (Join-Path $pages "$n.html") -Encoding UTF8
}
function Url([string]$n) { 'file:///' + ((Join-Path $pages "$n.html") -replace '\\', '/') }

# A browser an earlier run left on one of these profiles (a run that threw after its launch) would
# take this run's launch as a second window of its own: stop it first, found by its profile path.
Get-CimInstance Win32_Process -Filter "Name = 'chrome.exe'" -OperationTimeoutSec 15 |
  Where-Object { $_.CommandLine -like "*$work\profile-*" } |
  ForEach-Object { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue }
Start-Sleep -Seconds 2

$results = Join-Path $work 'results.txt'
"S-173 live run $(Get-Date -Format s) exe=$($script:Drive.Exe)" | Set-Content -Path $results -Encoding UTF8
function Result([string]$Id, [bool]$Ok, [string]$What, [string]$Seen) {
  $line = '{0,-8} {1} {2} | seen: {3}' -f $Id, $(if ($Ok) { 'PASS' } else { 'FAIL' }), $What, $Seen
  Add-Content -Path $results -Value $line -Encoding UTF8
  Drive-Log $line
}
# A step whose condition was not there to be checked (tst9-9 with no infobar up): neither a pass nor
# a fail, and counted at the end of results.txt.
$script:NotChecked = 0
function NotChecked([string]$Id, [string]$What, [string]$Seen) {
  $script:NotChecked++
  $line = '{0,-8} NOT-CHECKED {1} | seen: {2}' -f $Id, $What, $Seen
  Add-Content -Path $results -Value $line -Encoding UTF8
  Drive-Log $line
}
# Each step names itself before it acts, so a run that stops says where.
function Step([string]$Id, [string]$What) { Drive-Log ('---- {0}: {1}' -f $Id, $What) }

# ---- what UI Automation and DevTools say ----------------------------------------------------

function Row([string]$Title) { Drive-Rows | Where-Object { $_.Name -like "$Title*" } | Select-Object -First 1 }
function RowNames { (Drive-Rows | Sort-Object Y | ForEach-Object { $_.Name }) -join ', ' }
function Button([string]$Pattern) { Drive-Rows 'Button' | Where-Object { $_.Name -like $Pattern } | Select-Object -First 1 }
function Visible { Start-Sleep -Milliseconds 400; Drive-Visible }
# The browser's own top-level windows: a drag that tears a window off makes two.
function BrowserWindows {
  @([StedDrive]::WindowsOf([uint32]$script:Drive.Pid) | Where-Object {
      $cls = New-Object Text.StringBuilder 256; [void][StedDrive]::GetClassName($_, $cls, 256)
      $r = New-Object StedDrive+RECT; [void][StedDrive]::GetWindowRect($_, [ref]$r)
      $cls.ToString() -eq 'Chrome_WidgetWin_1' -and ($r.Right - $r.Left) -gt 300 }).Count
}
# Whether the sidebar is the rail: Page A's row narrower than half its open width.
$script:OpenWidth = 0
function IsRail { $a = Row 'Page A'; return [bool]($a -and $script:OpenWidth -gt 0 -and $a.W -lt $script:OpenWidth / 2) }
function IsOpen { $a = Row 'Page A'; return [bool]($a -and $script:OpenWidth -gt 0 -and $a.W -ge $script:OpenWidth * 0.9) }
# toolbar T36 (BACKLOG S-231): with the address row hidden and an infobar up, Chromium's 1 DIP
# separator under the top container was drawn on its own across the window's top, from the card's
# left edge to short of the caption buttons, in the page's colour (the separator is the row's, and
# the row is the page's: T15): white over the white pages of the PC run. It is drawn only while an
# infobar is up on the visible tab ("Continue where you left off" on a new profile), so the scan
# says whether one is. Read from the capture $Shot (Drive-Shot, so ShotOrigin is its), across the
# left half of the card, every row from the window's top to the bar's (to the page's with none):
#   Bar    an infobar up: UI Automation's infobar container (a Group) or infobar (a Window), named
#          "Infobar...", in one of its two places: over the page, its bottom on the page's top
#          (Chromium's), or under it across the page's bottom edge, the page ending well above the
#          bar's bottom (a Stedding window, toolbar T54; seen 2026-11-02 at 946..1018). A hidden
#          container keeps its last bounds in the tree, which then lie inside the page instead.
#   Lines  each thin run of rows in the page's colour, 1 to 3 rows with a row of another colour
#          below it (and above, or the window's edge): 'y+rows'.
#   Stop   the top of the first page-coloured run taller than that (the row itself, still drawn),
#          where the scan stops.
#   State  'read'; 'unread' with no capture, no page, the window off the capture or the page's
#          corner not one colour; 'mat' when the strip above the card is the page's colour itself,
#          where a line could not be seen (tst9-9 reads Page A, whose colour no mat has).
function SameColour($a, $b) { return ([math]::Abs($a.R - $b.R) -le 48 -and [math]::Abs($a.G - $b.G) -le 48 -and [math]::Abs($a.B - $b.B) -le 48) }
function Rgb($c) { return '{0},{1},{2}' -f $c.R, $c.G, $c.B }
function PageColourScan([string]$Shot) {
  $out = @{ State = 'unread'; Bar = $false; BarSeen = 'none'; Lines = @(); Stop = 0; Page = '?'; Mat = '?' }
  $doc = Drive-Rows 'Document' | Sort-Object { $_.W * $_.H } -Descending | Select-Object -First 1
  if (-not $Shot -or -not (Test-Path $Shot) -or -not $doc) { return $out }
  $named = @(@(Drive-Rows 'Group') + @(Drive-Rows 'Window') | Where-Object { $_ -and $_.Name -like 'Infobar*' })
  if ($named.Count -gt 0) { $out.BarSeen = ($named | ForEach-Object { '{0} {1}..{2}' -f $_.Name, $_.T, ($_.T + $_.H) }) -join '; ' }
  $docB = $doc.T + $doc.H
  $bar = $named | Where-Object { $_.H -ge 8 -and ([math]::Abs($_.T + $_.H - $doc.T) -le 4 -or
      ($_.T -lt $docB -and $docB -le $_.T + $_.H - 16)) } | Sort-Object T | Select-Object -First 1
  $out.Bar = [bool]$bar
  $end = if ($bar -and $bar.T -lt $doc.T) { $bar.T } else { $doc.T }
  $top = (Drive-VisibleRect).Top
  $ox = $script:Drive.ShotOrigin[0]; $oy = $script:Drive.ShotOrigin[1]
  $x0 = $doc.L + 8; $x1 = $doc.L + [int]($doc.W / 2)
  $bmp = New-Object Drawing.Bitmap $Shot
  try {
    if ($x0 - $ox -lt 0 -or $x1 - $ox -gt $bmp.Width -or $top - $oy -lt 0 -or $doc.T + 32 - $oy -gt $bmp.Height) { return $out }
    # The page's colour from its own top-left corner, inside its margin; the mat's from the strip.
    $page = $bmp.GetPixel($doc.L + 16 - $ox, $doc.T + 16 - $oy)
    foreach ($p in @(@(28, 16), @(16, 28))) {
      if (-not (SameColour $page ($bmp.GetPixel($doc.L + $p[0] - $ox, $doc.T + $p[1] - $oy)))) { return $out }
    }
    $mat = $bmp.GetPixel($x0 - $ox, $top + 3 - $oy)
    $out.Page = Rgb $page; $out.Mat = Rgb $mat
    if (SameColour $page $mat) { $out.State = 'mat'; return $out }
    $out.State = 'read'
    $run = 0
    for ($y = $top + 1; $y -le $end; $y++) {
      $n = 0; $hits = 0
      for ($x = $x0; $x -lt $x1; $x += 4) {
        $n++
        if (SameColour $page ($bmp.GetPixel($x - $ox, $y - $oy))) { $hits++ }
      }
      if ($n -gt 0 -and $hits -ge 0.9 * $n) { $run++; continue }
      if ($run -gt 3) { $out.Stop = $y - $run; break }
      if ($run -gt 0) { $out.Lines += ('{0}+{1}' -f ($y - $run), $run) }
      $run = 0
    }
    # A run still open at the end reaches the bar or the page: part of them, not a line.
    return $out
  } finally { $bmp.Dispose() }
}

# ---- input that drive.ps1 has no single call for ---------------------------------------------

function ClickRow([string]$Title) {
  $r = Row $Title
  if (-not $r) { Drive-Log "no row '$Title' (rows: $(RowNames))"; return $false }
  return (Drive-Click $r.X $r.Y)
}
function ClickButton([string]$Pattern) {
  $b = Button $Pattern
  if (-not $b) { Drive-Log "no button like '$Pattern'"; return $false }
  return (Drive-Click $b.X $b.Y)
}
# The Start menu in front (Ctrl+Esc, tst9-6) is closed with Escape, the one key it is given; the
# browser then comes back to the front. Without this every later step is refused, a later run's too.
function ShellMenuAway {
  $h = [StedDrive]::GetForegroundWindow(); $p = 0
  [void][StedDrive]::GetWindowThreadProcessId($h, [ref]$p)
  $name = (Get-Process -Id $p -ErrorAction SilentlyContinue).ProcessName
  if ($name -in @('SearchHost', 'StartMenuExperienceHost', 'ShellExperienceHost')) {
    Drive-Log "closing the shell's $name over the browser"
    Drive-Key 0x1B; Drive-Key 0x1B -Up; Start-Sleep -Milliseconds 800
  }
  if (-not (Drive-ForegroundIsBrowser)) { $null = Drive-Focus; Start-Sleep -Milliseconds 500 }
  # The Escape and Drive-Focus's Alt nudge are this script's input: marked as ours, the next
  # guarded step does not take them for the operator's and wait.
  Drive-Mark
}
# The pointer off the sidebar, so a hover-expanded rail folds back (sidebar Y11).
function Away {
  $r = Drive-VisibleRect
  Drive-Move ([int](($r.Left + $r.Right) / 2 + 200)) ([int](($r.Top + $r.Bottom) / 2))
  Start-Sleep -Milliseconds 2500
}
# A key held down on its own, and let go (Ctrl for the row numbers and Ctrl+Tab).
function Hold([string]$Key) { if (-not (Drive-Guard)) { return $false }; Drive-Key (Drive-VkOf $Key); Drive-Mark; return $true }
function Release([string]$Key) { Drive-Key (Drive-VkOf $Key) -Up; Drive-Mark }
# A drag in two halves, so a capture can land while the button is down (a drop highlight).
function DragTo([int]$x1, [int]$y1, [int]$x2, [int]$y2) {
  # A row or chip not found (or a UI Automation call that timed out) gives 0, 0: a press there
  # would land on the desktop's corner, not in the window.
  $w = Drive-VisibleRect
  foreach ($p in @(@($x1, $y1), @($x2, $y2))) {
    if ($p[0] -le $w.Left -or $p[0] -ge $w.Right -or $p[1] -le $w.Top -or $p[1] -ge $w.Bottom) {
      Drive-Log "REFUSED: a drag from $x1,$y1 to $x2,$y2 leaves the window (an element not found?)"
      return $false
    }
  }
  if (-not (Drive-Guard)) { return $false }
  Drive-Move $x1 $y1; Start-Sleep -Milliseconds 150
  [StedDrive]::mouse_event(0x0002, 0, 0, 0, [UIntPtr]::Zero); Start-Sleep -Milliseconds 120
  for ($i = 1; $i -le 30; $i++) {
    if (-not (Drive-ForegroundIsBrowser)) { DropHere; Drive-Log 'REFUSED mid-drag: released'; return $false }
    Drive-Move ([int]($x1 + ($x2 - $x1) * $i / 30)) ([int]($y1 + ($y2 - $y1) * $i / 30))
    Start-Sleep -Milliseconds 18
  }
  Start-Sleep -Milliseconds 500
  Drive-Mark
  return $true
}
function DropHere { [StedDrive]::mouse_event(0x0004, 0, 0, 0, [UIntPtr]::Zero); Start-Sleep -Milliseconds 800; Drive-Mark }

# ---- the profile -----------------------------------------------------------------------------

$seed = @{
  stedding = @{
    welcome = @{ shown = $true }
    spaces  = @{ registry = @(
        @{ id = '5ED1D9A1A0C04B0B9C1F0A11C0FE0001'; name = 'Home'; color = -10785908; color_chosen = $false; icon = ''; isolated = $false; pins_collapsed = $false; profile = '' },
        @{ id = '5ED1D9A1A0C04B0B9C1F0A11C0FE0002'; name = 'Work'; color = -10785908; color_chosen = $false; icon = ''; isolated = $false; pins_collapsed = $false; profile = '' },
        @{ id = '5ED1D9A1A0C04B0B9C1F0A11C0FE0003'; name = 'Play'; color = -10785908; color_chosen = $false; icon = ''; isolated = $false; pins_collapsed = $false; profile = '' }) }
  }
}
# The version that last ran, so the first window is not an update's: a profile with none recorded
# counts as updated, and its first window opens stedding.dev's thank-you page (updates Up10), a
# row the fixture does not hold. The installed build's version is this repository's VERSION.
$localState = @{ stedding = @{ updates = @{ last_run_version = (Get-Content (Join-Path $Repo 'VERSION') -Raw).Trim() } } }
$extra = @('--disable-search-engine-choice-screen')

# A seeded profile and the fixture, filed through the product's own keys:
#   Home: Page A, a folder holding Page B, Page C, Page D;  Work: Page E;  Play: Page F.
# -NoHoverExpand turns expand-on-hover off: a drag rests on the rail longer than its hover pause, and
# the rail would open under it, so the rail half would test the open sidebar again (as on the Mac).
function Fixture([string]$Name, [switch]$NoHoverExpand) {
  Step "$Name-0" 'launch on a seeded profile, then file the fixture with the product''s keys'
  $dir = Join-Path $work "profile-$Name"
  $s = $seed.Clone()
  if ($NoHoverExpand) { $s['vertical_tabs'] = @{ expand_on_hover = $false } }
  $null = Drive-Launch -Profile $dir -Urls (@('a', 'b', 'c', 'd', 'e', 'f') | ForEach-Object { Url $_ }) -Seed $s -Extra $extra -LocalState $localState
  Start-Sleep -Seconds 4
  # The keys below go to a browser that answers them only once its first page is on screen.
  # On a busy machine the window stood for about twenty seconds with no page drawn and took no
  # key, and the fixture's keys were lost (2026-10-19, after a multi-gigabyte link): wait for
  # DevTools to call Page A visible, up to a minute. A part that starts seconds after another
  # part's keys opens behind the operator's window, where Windows keeps it, with Page A hidden
  # for the whole minute (S-248): bring it to the front first, and again while it waits.
  ShellMenuAway
  $ready = (Get-Date).AddSeconds(60)
  while ((Get-Date) -lt $ready -and (Drive-Visible) -notmatch 'Page A') {
    Start-Sleep -Seconds 1
    if (-not (Drive-ForegroundIsBrowser)) { $null = Drive-Focus }
  }
  Drive-Log "first page on screen: $(Drive-Visible)"
  ShellMenuAway
  if (-not (Drive-Focus)) { throw 'the browser did not come to the front' }
  $null = Drive-Keys 'ctrl+2'
  $null = Drive-Keys 'ctrl+shift+p'; Start-Sleep -Milliseconds 800
  $null = Drive-Type 'new folder'; Start-Sleep -Milliseconds 1200
  $null = Drive-Shot "$Name-setup-01-actions"
  $null = Drive-Keys 'enter'; Start-Sleep -Milliseconds 1200
  $null = Drive-Keys 'ctrl+5'
  $null = Drive-Keys 'ctrl+alt+shift+right'; Start-Sleep -Seconds 2
  $null = Drive-Keys 'alt+1'; Start-Sleep -Seconds 2
  $null = Drive-Keys 'ctrl+5'
  $null = Drive-Keys 'ctrl+alt+shift+right'; Start-Sleep -Seconds 2
  $null = Drive-Keys 'ctrl+alt+shift+right'; Start-Sleep -Seconds 2
  $null = Drive-Keys 'alt+1'; Start-Sleep -Seconds 2
  $null = Drive-Keys 'ctrl+1'; Start-Sleep -Seconds 1
  $null = Drive-Shot "$Name-setup-02-open"
  $script:OpenWidth = (Row 'Page A').W
  $rows = RowNames
  Result "$Name-0" ($rows -like 'Page A*Page B*Page C*Page D*' -and $rows -notlike '*Page E*' -and $rows -notlike '*Page F*') 'fixture: Home shows A, B (in the folder), C, D and no other Space''s rows' $rows
  return $dir
}

function Quit([string]$Dir) {
  $null = Drive-Keys 'ctrl+shift+w'
  for ($i = 0; $i -lt 60; $i++) {
    Start-Sleep -Milliseconds 500
    $left = Get-CimInstance Win32_Process -Filter "Name='chrome.exe'" -OperationTimeoutSec 15 | Where-Object { $_.CommandLine -like "*$Dir*" }
    if (-not $left) { return $true }
  }
  return $false
}

# The same profile again, kept: Drive-Launch would wipe it.
function Relaunch([string]$Dir) {
  $argv = @("--user-data-dir=$Dir", "--remote-debugging-port=$($script:Drive.Port)") + $extra
  $null = Start-Process -FilePath $script:Drive.Exe -ArgumentList $argv -PassThru
  $h = [IntPtr]::Zero
  for ($i = 0; $i -lt 60 -and $h -eq [IntPtr]::Zero; $i++) { Start-Sleep -Milliseconds 500; $h = Drive-Find $Dir }
  if ($h -eq [IntPtr]::Zero) { throw "no window after the relaunch on $Dir" }
  Start-Sleep -Seconds 4
  return (Drive-Focus)
}

# ---- TST-6: the core loop ------------------------------------------------------------------

function Tst6 {
  $dir = Fixture 'tst6'
  Step 'tst6-1' 'the page on screen at the start'
  $null = Drive-Shot 'tst6-01-start'
  $v = Visible
  Result 'tst6-1' ($v -eq 'Page A') 'start: Home on screen, Page A selected' $v

  Step 'tst6-2' 'a click on each row of the open sidebar'
  $ok = $true; $seen = @()
  foreach ($t in 'Page A', 'Page B', 'Page C', 'Page D') {
    $null = ClickRow $t; $v = Visible; $seen += "$t->$v"; $ok = $ok -and ($v -eq $t)
  }
  $null = Drive-Shot 'tst6-02-open-rows'
  Result 'tst6-2' $ok 'a click on each row of the open sidebar selects it and shows its page' ($seen -join '; ')

  Step 'tst6-3' 'the sidebar''s toggle, to the rail'
  if (-not (ClickButton '*tabs (Ctrl+S)*')) { $null = Drive-Keys 'ctrl+s' }
  Start-Sleep -Seconds 2; Away
  $a = Row 'Page A'
  $null = Drive-Shot 'tst6-03-rail'
  Result 'tst6-3' (IsRail) 'the toggle closes the sidebar to the rail' "row A is $($a.W) px wide, $($script:OpenWidth) px open"

  Step 'tst6-4' 'a click on each row of the rail'
  $ok = $true; $seen = @()
  foreach ($t in 'Page A', 'Page B', 'Page D', 'Page A') {
    $null = ClickRow $t; $v = Visible; $seen += "$t->$v"; $ok = $ok -and ($v -eq $t); Away
  }
  $null = Drive-Shot 'tst6-04-rail-rows'
  Result 'tst6-4' ($ok -and (IsRail)) 'a click on each row of the rail selects it; the rail stays a rail' ($seen -join '; ')

  Step 'tst6-5' 'the sidebar''s toggle, open again'
  if (-not (ClickButton '*tabs (Ctrl+S)*')) { $null = Drive-Keys 'ctrl+s' }
  Start-Sleep -Seconds 2; Away
  $a = Row 'Page A'
  Result 'tst6-5' (IsOpen) 'the toggle opens the sidebar again' "row A is $($a.W) px wide"

  Step 'tst6-6' 'a click on the Work chip'
  $null = ClickButton '*Work*'; Start-Sleep -Seconds 2
  $v = Visible; $null = Drive-Shot 'tst6-06-chip-work'
  Result 'tst6-6' ($v -eq 'Page E' -and -not (Row 'Page A')) 'the Work chip shows Work: Page E, no row of Home' "$v; rows: $(RowNames)"

  Step 'tst6-7' 'Alt+3'
  $null = Drive-Keys 'alt+3'; Start-Sleep -Seconds 2
  $v = Visible; $null = Drive-Shot 'tst6-07-alt3-play'
  Result 'tst6-7' ($v -eq 'Page F') 'Alt+3 shows Play: Page F' $v

  Step 'tst6-8' 'Ctrl+Alt+Left twice'
  $null = Drive-Keys 'ctrl+alt+left'; Start-Sleep -Seconds 2; $v1 = Visible
  $null = Drive-Keys 'ctrl+alt+left'; Start-Sleep -Seconds 2; $v2 = Visible
  $null = Drive-Shot 'tst6-08-previous-twice'
  Result 'tst6-8' ($v1 -eq 'Page E' -and $v2 -eq 'Page A') 'Ctrl+Alt+Left twice: Work (Page E), then Home on the tab left there (Page A)' "$v1, then $v2"

  Step 'tst6-9' 'Ctrl+T, "Page F", Down, Enter'
  $null = Drive-Keys 'ctrl+t'; Start-Sleep -Milliseconds 800
  $null = Drive-Type 'Page F'; Start-Sleep -Milliseconds 1500
  $null = Drive-Keys 'down'
  $null = Drive-Shot 'tst6-09a-bar'
  $null = Drive-Keys 'enter'; Start-Sleep -Seconds 2
  $v = Visible; $null = Drive-Shot 'tst6-09b-bar-play'
  Result 'tst6-9' ($v -eq 'Page F' -and (Row 'Page F')) 'the bar''s row for another Space''s tab switches to Play and shows Page F' "$v; rows: $(RowNames)"

  Step 'tst6-10' 'Alt+1, Page A, the folder''s header collapses it, Alt+2, Alt+1'
  $null = Drive-Keys 'alt+1'; Start-Sleep -Seconds 2
  $null = ClickRow 'Page A'
  $null = ClickButton '*New Folder*'; Start-Sleep -Milliseconds 1500
  $collapsed = -not (Row 'Page B')
  $null = Drive-Shot 'tst6-10a-collapsed'
  $null = Drive-Keys 'alt+2'; Start-Sleep -Seconds 2
  $null = Drive-Keys 'alt+1'; Start-Sleep -Seconds 2
  $v = Visible; $null = Drive-Shot 'tst6-10b-back'
  Result 'tst6-10' ($collapsed -and -not (Row 'Page B') -and $v -eq 'Page A') 'the collapsed folder hides Page B; away and back it is still collapsed and Page A is on screen' "$v; rows: $(RowNames)"

  Step 'tst6-11' 'quit (Ctrl+Shift+W) and relaunch on the same profile; Alt+2, Alt+3, Alt+1'
  $quit = Quit $dir
  $back = Relaunch $dir
  $v = Visible; $rows = RowNames; $null = Drive-Shot 'tst6-11a-relaunched'
  $null = Drive-Keys 'alt+2'; Start-Sleep -Seconds 2; $w = Visible
  $null = Drive-Keys 'alt+3'; Start-Sleep -Seconds 2; $p = Visible
  $null = Drive-Keys 'alt+1'; Start-Sleep -Seconds 2
  Result 'tst6-11' ($quit -and $back -and $v -eq 'Page A' -and $rows -notlike '*Page B*' -and $rows -like '*Page C*Page D*' -and $w -eq 'Page E' -and $p -eq 'Page F') 'quit and relaunch: Home on Page A, the folder still collapsed, Work and Play as left' "quit=$quit back=$back; $v; rows: $rows; Work: $w; Play: $p"

  Step 'tst6-12' 'Ctrl+T, Page G''s address, Enter'
  $before = (Drive-Rows).Count
  $null = Drive-Keys 'ctrl+t'; Start-Sleep -Milliseconds 800
  $null = Drive-Type (Url 'g'); Start-Sleep -Milliseconds 800
  $null = Drive-Keys 'enter'; Start-Sleep -Seconds 3
  $v = Visible; $after = (Drive-Rows).Count; $null = Drive-Shot 'tst6-12-ctrl-t'
  Result 'tst6-12' ($v -eq 'Page G' -and $after -eq $before + 1 -and (Row 'Page G')) 'Ctrl+T, an address, Enter: a new row in Home shows Page G' "$v; rows $before -> $after"

  Step 'tst6-13' 'Ctrl+L, Page H''s address, Enter'
  $before = (Drive-Rows).Count
  $null = Drive-Keys 'ctrl+l'; Start-Sleep -Milliseconds 800
  $null = Drive-Shot 'tst6-13a-ctrl-l'
  $null = Drive-Type (Url 'h'); Start-Sleep -Milliseconds 800
  $null = Drive-Keys 'enter'; Start-Sleep -Seconds 3
  $v = Visible; $after = (Drive-Rows).Count; $null = Drive-Shot 'tst6-13b-same-tab'
  Result 'tst6-13' ($v -eq 'Page H' -and $after -eq $before -and -not (Row 'Page G')) 'Ctrl+L, an address, Enter: the same row now shows Page H; no new row' "$v; rows $before -> $after"
  Drive-Stop
}

# ---- TST-7: drags onto a folder header and a Space chip --------------------------------------

function Tst7 {
  $null = Fixture 'tst7' -NoHoverExpand
  # Open sidebar, Page D onto the folder's header.
  Step 'tst7-1' 'open sidebar: drag Page D onto the folder''s header'
  $d = Row 'Page D'; $h = Button '*New Folder*'
  $null = DragTo $d.X $d.Y $h.X $h.Y
  $null = Drive-Shot 'tst7-01a-open-over-header'
  DropHere
  # Membership: collapsing the folder hides its rows, but for the active tab (folders F3), which the
  # drag made Page D: Page A, outside the folder, is made active first.
  $null = ClickRow 'Page A'
  $null = ClickButton '*New Folder*'; Start-Sleep -Milliseconds 1200
  $inside = -not (Row 'Page D') -and -not (Row 'Page B')
  $null = ClickButton '*New Folder*'; Start-Sleep -Milliseconds 1200
  $null = Drive-Shot 'tst7-01b-open-joined'
  Result 'tst7-1' ($inside -and (Row 'Page D')) 'open sidebar: Page D dropped on the folder header joins the folder' "rows: $(RowNames)"

  # Open sidebar, Page C onto the Work chip.
  Step 'tst7-2' 'open sidebar: drag Page C onto the Work chip'
  $c = Row 'Page C'; $chip = Button '*Work*'
  $null = DragTo $c.X $c.Y $chip.X $chip.Y
  $null = Drive-Shot 'tst7-02a-open-over-chip'
  DropHere; Start-Sleep -Seconds 1
  $v = Visible; $windows = BrowserWindows
  $null = Drive-Shot 'tst7-02b-open-moved'
  Result 'tst7-2' ($v -eq 'Page C' -and (Row 'Page E') -and (Row 'Page C') -and $windows -eq 1) 'open sidebar: Page C dropped on the Work chip moves to Work, which comes on screen with it; no window tears off' "$v; rows: $(RowNames); windows: $windows"
  $null = Drive-Keys 'alt+1'; Start-Sleep -Seconds 2

  # The rail.
  Step 'tst7-3' 'the rail: drag Page A onto the folder''s glyph'
  if (-not (ClickButton '*tabs (Ctrl+S)*')) { $null = Drive-Keys 'ctrl+s' }
  Start-Sleep -Seconds 2; Away
  $a = Row 'Page A'; $h = Button '*New Folder*'
  $null = DragTo $a.X $a.Y $h.X $h.Y
  $null = Drive-Shot 'tst7-03a-rail-over-glyph'
  DropHere; Away
  $railKept = IsRail; $windows = BrowserWindows
  # Membership is read in the open sidebar, where a folder's rows sit indented under its header:
  # the rail draws them in one column, and a click on the rail's glyph does not fold the folder.
  if (-not (ClickButton '*tabs (Ctrl+S)*')) { $null = Drive-Keys 'ctrl+s' }
  Start-Sleep -Seconds 2; Away
  $ra = Row 'Page A'; $rd = Row 'Page D'; $hd = Button '*New Folder*'
  $inside = [bool]($ra -and $rd -and $hd -and [math]::Abs($ra.X - $rd.X) -le 2 -and $ra.X -gt $hd.X + 3)
  $null = Drive-Shot 'tst7-03b-rail-joined'
  Result 'tst7-3' ($inside -and $railKept -and $windows -eq 1) 'rail: Page A dropped on the folder''s glyph joins the folder; the rail stays a rail' "rows: $(RowNames); A at $($ra.X), D at $($rd.X), header at $($hd.X); rail kept: $railKept"
  if (-not (ClickButton '*tabs (Ctrl+S)*')) { $null = Drive-Keys 'ctrl+s' }
  Start-Sleep -Seconds 2; Away

  Step 'tst7-4' 'the rail: drag Page B, in the folder, onto the Work chip'
  $b = Row 'Page B'; $chip = Button '*Work*'
  $null = DragTo $b.X $b.Y $chip.X $chip.Y
  $null = Drive-Shot 'tst7-04a-rail-over-chip'
  DropHere; Start-Sleep -Seconds 1; Away
  $v = Visible; $null = Drive-Shot 'tst7-04b-rail-moved'
  $null = Drive-Keys 'alt+1'; Start-Sleep -Seconds 2
  $homeRows = RowNames
  Result 'tst7-4' ($v -eq 'Page B' -and $homeRows -notlike '*Page B*' -and $homeRows -like '*Page A*' -and (BrowserWindows) -eq 1) 'rail: Page B, from inside the folder, dropped on the Work chip moves to Work and leaves the folder, which keeps Page A and Page D' "$v; Home rows: $homeRows"
  Drive-Stop
}

# ---- TST-9: the core keyboard ----------------------------------------------------------------

function Tst9 {
  $null = Fixture 'tst9'
  $null = Drive-Keys 'ctrl+1'

  Step 'tst9-1' 'Ctrl held a moment, captured, let go, captured'
  if (Hold 'ctrl') {
    try { Start-Sleep -Milliseconds 800; $null = Drive-Shot 'tst9-01a-numbers' } finally { Release 'ctrl' }
  }
  Start-Sleep -Milliseconds 500; $null = Drive-Shot 'tst9-01b-numbers-gone'
  Result 'tst9-1' $true 'Ctrl held: numbers 1-4 on the rows (9 on the last), Alt+1-3 on the chips; gone on release (read the two captures)' 'tst9-01a, tst9-01b'

  Step 'tst9-2' 'Ctrl+2, Ctrl+9, Ctrl+1'
  $null = Drive-Keys 'ctrl+2'; $v2 = Visible
  $null = Drive-Keys 'ctrl+9'; $v9 = Visible
  $null = Drive-Keys 'ctrl+1'; $v1 = Visible
  Result 'tst9-2' ($v2 -eq 'Page B' -and $v9 -eq 'Page D' -and $v1 -eq 'Page A') 'Ctrl+2, Ctrl+9 (the last row), Ctrl+1' "$v2, $v9, $v1"

  Step 'tst9-3' 'Ctrl+Alt+Down, Ctrl+Alt+Up'
  $null = Drive-Keys 'ctrl+alt+down'; $vd = Visible
  $null = Drive-Keys 'ctrl+alt+up'; $vu = Visible
  Result 'tst9-3' ($vd -eq 'Page B' -and $vu -eq 'Page A') 'Ctrl+Alt+Down and Up: the next row down the sidebar, and back' "$vd, $vu"

  Step 'tst9-4' 'Ctrl+3, Ctrl+1, Ctrl+Tab tapped'
  $null = Drive-Keys 'ctrl+3'; $null = Drive-Keys 'ctrl+1'
  $null = Drive-Keys 'ctrl+tab'; $v = Visible
  Result 'tst9-4' ($v -eq 'Page C') 'Ctrl+Tab tapped: the tab used before' $v

  Step 'tst9-5' 'Ctrl held, Tab, capture, Tab, Ctrl let go'
  $start = Visible; $v1 = ''; $v2 = ''
  if (Hold 'ctrl') {
    try {
      Drive-Key 0x09; Drive-Key 0x09 -Up; Start-Sleep -Milliseconds 600; $v1 = Drive-Visible
      $null = Drive-Shot 'tst9-05a-strip'
      Drive-Key 0x09; Drive-Key 0x09 -Up; Start-Sleep -Milliseconds 400; $v2 = Drive-Visible
    } finally { Release 'ctrl' }
  }
  Start-Sleep -Milliseconds 800; $v3 = Visible; $null = Drive-Shot 'tst9-05b-committed'
  Result 'tst9-5' ($v1 -ne $start -and $v2 -ne $v1 -and $v3 -eq $v2) 'Ctrl+Tab held: the strip shows, Tab steps it, letting go of Ctrl keeps the tab reached' "$start -> $v1 -> $v2, after release $v3"

  # switcher X3 on Windows (BACKLOG S-228): Ctrl+Esc is the shell's hot key for the Start menu, and
  # Windows takes it before the browser hears it. Stedding leaves it there (no system-wide keyboard
  # hook): the Start menu opens, the browser loses the foreground and the run ends on the tab it
  # had reached. With the menu closed, a Ctrl+Tab tap goes back where the run began. A run that
  # went back at once instead means Escape reached the window, and X3 and docs/SHORTCUTS.md are
  # wrong about Windows.
  Step 'tst9-6' 'Ctrl held, Tab, Escape (Ctrl+Esc), Ctrl let go; the Start menu closed; Ctrl+Tab tapped'
  $start = Visible; $v1 = ''
  if (Hold 'ctrl') {
    try { Drive-Key 0x09; Drive-Key 0x09 -Up; Start-Sleep -Milliseconds 600; $v1 = Drive-Visible; Drive-Key 0x1B; Drive-Key 0x1B -Up } finally { Release 'ctrl' }
  }
  Start-Sleep -Milliseconds 800; $front = [bool](Drive-ForegroundIsBrowser)
  # The Start menu holds the foreground: every later step would be refused.
  ShellMenuAway
  $v = Visible
  $null = Drive-Keys 'ctrl+tab'; $back = Visible
  Result 'tst9-6' ($v1 -ne $start -and -not $front -and $v -eq $v1 -and $back -eq $start) 'Ctrl+Tab held, then Ctrl+Esc: the Start menu takes it and the run keeps the tab it reached; with the menu closed, a Ctrl+Tab tap goes back where the run began (switcher X3, BACKLOG S-228)' "$start -> $v1, after Ctrl+Esc $v (browser in front just after: $front), after the tap $back"

  # switcher X3 on Windows (BACKLOG S-228): the way out of a run there. Ctrl still held, Shift+Tab
  # steps back to the first tab, and letting go of Ctrl ends the run on it. Shift goes down and up
  # as a key of its own, as a keyboard sends it; neither ends the run.
  Step 'tst9-6b' 'Ctrl held, Tab, Tab, Shift+Tab, Shift+Tab, Ctrl let go'
  $start = Visible; $v1 = ''; $v2 = ''; $b1 = ''; $b2 = ''
  if (Hold 'ctrl') {
    try {
      Drive-Key 0x09; Drive-Key 0x09 -Up; Start-Sleep -Milliseconds 600; $v1 = Drive-Visible
      Drive-Key 0x09; Drive-Key 0x09 -Up; Start-Sleep -Milliseconds 400; $v2 = Drive-Visible
      $null = Drive-Shot 'tst9-06b-strip-reached'
      Drive-Key 0x10
      try {
        Drive-Key 0x09; Drive-Key 0x09 -Up; Start-Sleep -Milliseconds 400; $b1 = Drive-Visible
        Drive-Key 0x09; Drive-Key 0x09 -Up; Start-Sleep -Milliseconds 400; $b2 = Drive-Visible
      } finally { Drive-Key 0x10 -Up }
    } finally { Release 'ctrl' }
  }
  Start-Sleep -Milliseconds 800; $front = [bool](Drive-ForegroundIsBrowser); $v = Visible
  Result 'tst9-6b' ($v1 -ne $start -and $v2 -ne $v1 -and $v2 -ne $start -and $b1 -eq $v1 -and $b2 -eq $start -and $v -eq $start -and $front) 'Ctrl+Tab held, Tab twice, then Shift+Tab twice and Ctrl let go: back where the run began, the browser in front (the way out of a run on Windows: switcher X3, BACKLOG S-228)' "$start -> $v1 -> $v2, back $b1 -> $b2, after release $v; browser in front: $front"
  ShellMenuAway

  Step 'tst9-7' 'Ctrl+1, Ctrl+Shift+E twice'
  $null = Drive-Keys 'ctrl+1'
  $null = Drive-Keys 'ctrl+shift+e'; Start-Sleep -Milliseconds 1200; $hidden = -not (Row 'Page B')
  $null = Drive-Keys 'ctrl+shift+e'; Start-Sleep -Milliseconds 1200; $shown = [bool](Row 'Page B')
  Result 'tst9-7' ($hidden -and $shown) 'Ctrl+Shift+E collapses the Space''s folders, and again opens them' "hidden=$hidden shown=$shown"

  Step 'tst9-8' 'Ctrl+S twice'
  $null = Drive-Keys 'ctrl+s'; Start-Sleep -Seconds 2; Away; $rail = IsRail; $w1 = (Row 'Page A').W
  $null = Drive-Keys 'ctrl+s'; Start-Sleep -Seconds 2; $open = IsOpen; $w2 = (Row 'Page A').W
  Result 'tst9-8' ($rail -and $open) 'Ctrl+S closes the sidebar to the rail, and again opens it' "row A $w1 px, then $w2 px"

  # toolbar T10, T36 (BACKLOG S-231). A hidden row's address field stays in UI Automation's tree
  # with its last bounds (Chromium lists a hidden view's controls), so the field counts as shown
  # only while it can take the keyboard (GUESS: IsKeyboardFocusable is false for a hidden view's
  # control; the seen text records each field found). The capture of the hidden row, on Page A's
  # colour, is read for the 1 px line in the page's colour the row left at the window's top
  # (PageColourScan). The line is drawn only over an infobar: with none up, or a capture that
  # cannot be read, the step is NOT-CHECKED, never a pass.
  Step 'tst9-9' 'Ctrl+1 (Page A), Ctrl+Shift+D, the fields, the infobar, a capture read for a line; Ctrl+Shift+D'
  $null = Drive-Keys 'ctrl+1'; $va = Visible
  $null = Drive-Keys 'ctrl+shift+d'; Start-Sleep -Milliseconds 1200
  $fields = @(Drive-Rows 'Edit' | Where-Object { $_.Name -like '*Address*' })
  $gone = -not ($fields | Where-Object { $_.Focusable })
  $hiddenFields = ($fields | ForEach-Object { '{0}x{1} at {2},{3} focusable={4}' -f $_.W, $_.H, $_.L, $_.T, $_.Focusable }) -join '; '
  $shot = Drive-Shot 'tst9-09-address-row-hidden'
  $scan = PageColourScan $shot
  $null = Drive-Keys 'ctrl+shift+d'; Start-Sleep -Milliseconds 1200
  $back = [bool](Drive-Rows 'Edit' | Where-Object { $_.Name -like '*Address*' -and $_.Focusable })
  $lineSeen = if ($scan.Lines.Count -gt 0) { $scan.Lines -join ', ' } else { 'none' }
  $tall = if ($scan.Stop) { "; a taller run in the page's colour from y $($scan.Stop) (the row still drawn?)" } else { '' }
  $seen = "visible: $va; gone=$gone back=$back; infobar up: $($scan.Bar) (UI Automation: $($scan.BarSeen)); scan: $($scan.State), page $($scan.Page), mat $($scan.Mat); thin runs in the page's colour above the bar at y: $lineSeen$tall; fields while hidden: $hiddenFields"
  $what = 'Ctrl+Shift+D hides the address row and, with an infobar up, leaves no line in the page''s colour where it was (toolbar T36, S-231); again, it shows'
  if (-not ($gone -and $back) -or $scan.Lines.Count -gt 0 -or $scan.Stop) { Result 'tst9-9' $false $what $seen }
  elseif ($scan.State -ne 'read' -or -not $scan.Bar) { NotChecked 'tst9-9' $what $seen }
  else { Result 'tst9-9' $true $what $seen }

  Step 'tst9-10' 'Alt+2, Ctrl+Alt+Right, Ctrl+Alt+Left twice'
  $null = Drive-Keys 'alt+2'; Start-Sleep -Seconds 2; $va = Visible
  $null = Drive-Keys 'ctrl+alt+right'; Start-Sleep -Seconds 2; $vn = Visible
  $null = Drive-Keys 'ctrl+alt+left'; Start-Sleep -Seconds 2
  $null = Drive-Keys 'ctrl+alt+left'; Start-Sleep -Seconds 2; $vh = Visible
  Result 'tst9-10' ($va -eq 'Page E' -and $vn -eq 'Page F' -and $vh -like 'Page *' -and $vh -notin @('Page E', 'Page F')) 'Alt+2, Ctrl+Alt+Right, Ctrl+Alt+Left twice' "$va, $vn, $vh"

  # Ctrl+D is Stedding's pin on Windows too (accelerator_table.cc, spaces B21): Bookmark This Tab
  # lost the chord, so no bookmark dialog opens. Ctrl+W on the pin puts it to sleep (pins H3): from
  # here a tab is asleep, which never answers DevTools, and each Visible waits out its three
  # seconds on it (Drive-Eval). The run stopped here for good while that wait had no clock.
  Step 'tst9-11' 'Ctrl+3 (Page C), Ctrl+D pins it, rows and the New Tab row; Ctrl+W puts the pin to sleep'
  $null = Drive-Keys 'ctrl+3'; $v3 = Visible
  $null = Drive-Keys 'ctrl+d'; Start-Sleep -Milliseconds 1200
  $c = Row 'Page C'; $nt = Button '*New Tab*'
  $pinned = [bool]($c -and $nt -and $c.Y -lt $nt.Y)
  $null = Drive-Keys 'ctrl+w'; Start-Sleep -Seconds 2
  $v = Visible; $null = Drive-Shot 'tst9-11-pin-slept'
  Result 'tst9-11' ($v3 -eq 'Page C' -and $pinned -and (Row 'Page C') -and $v -like 'Page *' -and $v -ne 'Page C') 'Ctrl+3, then Ctrl+D pins Page C above the New Tab row; Ctrl+W puts it to sleep: its row stays (dimmed in the capture), another page shows' "Ctrl+3: $v3; pinned=$pinned (C at y $($c.Y), New Tab at y $($nt.Y)); after Ctrl+W: $v"

  # From here the numbers count the pin: Page C 1, Page A 2, Page B 3, Page D 4.
  Step 'tst9-12' 'a click on Page A, Ctrl+Alt+Shift+Down'
  $null = ClickRow 'Page A'
  $null = Drive-Keys 'ctrl+alt+shift+down'; Start-Sleep -Milliseconds 1200
  $a = Row 'Page A'; $b = Row 'Page B'
  Result 'tst9-12' ($a -and $b -and $a.Y -gt $b.Y) 'Ctrl+Alt+Shift+Down moves Page A below the folder (a folder beside it is one row)' "rows: $(RowNames)"

  Step 'tst9-13' 'Ctrl+Alt+Shift+Right on Page A, then Alt+1'
  $null = Drive-Keys 'ctrl+alt+shift+right'; Start-Sleep -Seconds 2
  $v = Visible; $rows = RowNames
  Result 'tst9-13' ($v -eq 'Page A' -and $rows -like '*Page E*') 'Ctrl+Alt+Shift+Right moves Page A to Work and the window follows' "$v; rows: $rows"
  $null = Drive-Keys 'alt+1'; Start-Sleep -Seconds 2

  # Home is the pin Page C (1), Page B (2), Page D (3); the link copied is Page D's, as on the Mac.
  Step 'tst9-14' 'Ctrl+3 (Page D), Ctrl+Shift+C, the clipboard'
  $null = Drive-Keys 'ctrl+3'; $vd = Visible
  $null = Drive-Keys 'ctrl+shift+c'; Start-Sleep -Milliseconds 600
  $null = Drive-Shot 'tst9-14-copy-link-toast'
  $clip = Drive-Clipboard
  Result 'tst9-14' ($vd -eq 'Page D' -and $clip -like 'file:///*/d.html') 'Ctrl+Shift+C copies the page''s address (and the toast says so: capture)' "$vd; clipboard: $clip"
  # The toast goes before the split's capture.
  Start-Sleep -Seconds 3

  Step 'tst9-15' 'Alt+Shift+N, capture, Escape'
  $null = Drive-Keys 'alt+shift+n'; Start-Sleep -Seconds 2
  $null = Drive-Shot 'tst9-15-split'
  Result 'tst9-15' $true 'Alt+Shift+N splits Page D with a new tab (read the capture)' 'tst9-15-split'
  $null = Drive-Keys 'esc'; Start-Sleep -Milliseconds 800

  Step 'tst9-16' 'Ctrl+2 (Page B), Ctrl+W, Ctrl+Shift+T'
  $null = Drive-Keys 'ctrl+2'; $t = Visible
  $null = Drive-Keys 'ctrl+w'; Start-Sleep -Milliseconds 1200; $closed = -not (Row $t)
  $null = Drive-Shot 'tst9-16a-closed-toast'
  $null = Drive-Keys 'ctrl+shift+t'; Start-Sleep -Seconds 2; $v = Visible
  Result 'tst9-16' ($t -eq 'Page B' -and $closed -and $v -eq $t -and (Row $t)) 'Ctrl+W closes a plain row (Page B) with the Undo toast; Ctrl+Shift+T brings it back' "closed '$t'=$closed; back: $v"

  Step 'tst9-17' 'Ctrl+Shift+P, capture, Escape'
  $null = Drive-Keys 'ctrl+shift+p'; Start-Sleep -Milliseconds 800
  $null = Drive-Shot 'tst9-17-actions'
  $null = Drive-Keys 'esc'; Start-Sleep -Milliseconds 800

  # The first Escape leaves actions mode for the bar's search, the second closes the bar: with one,
  # the Ctrl+M after it went to the bar, not the tab.
  Step 'tst9-18' 'Ctrl+M, Ctrl+Shift+P, "mute", capture, Escape twice, Ctrl+M'
  $null = Drive-Keys 'ctrl+m'; Start-Sleep -Milliseconds 800
  $null = Drive-Keys 'ctrl+shift+p'; Start-Sleep -Milliseconds 800
  $null = Drive-Type 'mute'; Start-Sleep -Milliseconds 800
  $null = Drive-Shot 'tst9-18-mute-row'
  $null = Drive-Keys 'esc'; Start-Sleep -Milliseconds 500
  $null = Drive-Keys 'esc'; Start-Sleep -Milliseconds 800
  $null = Drive-Keys 'ctrl+m'
  Result 'tst9-18' $true 'Ctrl+M mutes the tab: the bar''s row reads Unmute Tab, with Ctrl+M (read the capture)' 'tst9-18-mute-row'

  Step 'tst9-19' 'Ctrl+Shift+K'
  $null = Drive-Keys 'ctrl+shift+k'; Start-Sleep -Seconds 2
  $rows = RowNames; $null = Drive-Shot 'tst9-19-clear'
  Result 'tst9-19' ($rows -like '*Page C*' -and $rows -notlike '*Page D*') 'Ctrl+Shift+K clears the Space''s unpinned tabs and keeps the pin' "rows: $rows"
  Drive-Stop
}

# ---- run -------------------------------------------------------------------------------------

try {
  switch ($Part) {
    'layout' {
      $null = Fixture 'layout'
      Drive-Rows | Sort-Object Y | ForEach-Object { Drive-Log ("row    '{0}' at {1},{2} {3}x{4}" -f $_.Name, $_.X, $_.Y, $_.W, $_.H) }
      Drive-Rows 'Button' | Sort-Object Y | ForEach-Object { Drive-Log ("button '{0}' at {1},{2}" -f $_.Name, $_.X, $_.Y) }
      Drive-Rows 'Edit' | ForEach-Object { Drive-Log ("edit   '{0}' at {1},{2}" -f $_.Name, $_.X, $_.Y) }
      if (-not (ClickButton '*tabs (Ctrl+S)*')) { $null = Drive-Keys 'ctrl+s' }
      Start-Sleep -Seconds 2; Away
      $null = Drive-Shot 'layout-rail'
      Drive-Rows | Sort-Object Y | ForEach-Object { Drive-Log ("rail   '{0}' at {1},{2} {3}x{4}" -f $_.Name, $_.X, $_.Y, $_.W, $_.H) }
      Drive-Rows 'Button' | Sort-Object Y | ForEach-Object { Drive-Log ("rail button '{0}' at {1},{2}" -f $_.Name, $_.X, $_.Y) }
      Drive-Stop
    }
    'tst6' { Tst6 }
    'tst7' { Tst7 }
    'tst9' { Tst9 }
    'all' { Tst6; Tst7; Tst9 }
  }
} catch {
  Add-Content -Path $results -Value "ERROR $_" -Encoding UTF8
  Drive-Log "error: $_"
  try { Drive-Stop } catch {}
}
Add-Content -Path $results -Value ('steps not checked (NOT-CHECKED above): {0}' -f $script:NotChecked) -Encoding UTF8
Add-Content -Path $results -Value ('calls that gave no answer in time (TIMEOUT in progress.log): {0}' -f $script:Drive.Timeouts) -Encoding UTF8
Drive-Log "results: $results; progress: $($script:Drive.LogFile)"
