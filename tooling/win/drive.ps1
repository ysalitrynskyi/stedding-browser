<#
Real pointer and keyboard input for a live check of the Stedding window, and a few
functions to look at what happened. Dot-source it:

  . tooling\win\drive.ps1                       # the build in out\win-release
  . tooling\win\drive.ps1 -Exe C:\...\chrome.exe
  $null = Drive-Launch -Profile scratch -Urls 'http://127.0.0.1:8787/'
  Drive-Click 83 77                             # screen pixels, as Drive-Rows reports them
  Drive-Keys 'ctrl+t'; Drive-Type 'example.org'; Drive-Keys 'enter'
  Drive-Drag 194 306 150 216                    # a person's drag: press, move, hold, release
  Drive-Rows | Format-Table Name, X, Y          # sidebar rows by UI Automation
  Drive-Visible                                 # the page DevTools says is on screen
  Drive-Shot 'after-drop'                       # PNG of the window, not the screen
  Drive-Stop

Why it exists: every automated suite passed while the window's real behaviour had six
visible faults (docs/HANDOFF.md, trap 58). A click, a key and a drag through the real
input path found them in half an hour. Capture-only tools (capture.ps1, cdp.ps1) look
without touching; this one touches, so it is guarded:

  * Input goes only while the foreground window belongs to the browser this script
    started. Anything else in front (the operator's terminal, a dialog): nothing is sent.
    A click, a drag or a wheel goes only where a window of that browser is under the point.
  * The operator's own input is seen through GetLastInputInfo. If the last event was not
    this script's and is under six seconds old, it waits (up to two minutes), then
    refuses. Keys are never mixed into somebody's typing.
  * Screenshots are of the window's rectangle, taken only while the window is in front,
    so the operator's other windows are not in the picture.
  * It kills only a browser it launched, found by its profile path in the command line,
    never by name (trap 40): the operator's own Stedding is not touched.

Whether to use it at all is the operator's call: ask once, at the start of a session,
not after the first long job (docs/AGENT-LOOP.md, "Ask once"). Without a yes, use
capture.ps1, cdp.ps1 and hit-test.ps1, which need neither the keyboard nor the pointer.

Things learned driving it:
  * Drive-Focus activates the main window, which CLOSES an open menu. Between opening a
    context menu and clicking its row call nothing but Drive-Click.
  * A remote-desktop session that is disconnected has no foreground window at all, and
    the tests that need an active window fail in it (trap 59): connect first.
  * Drive-Rows lists a row once per path through the accessibility tree; it is reduced
    to one per place on screen.
  * A first launch shows the welcome flow over the window; seed Preferences
    (-Seed @{ stedding = @{ welcome = @{ shown = $true } } }) to skip it, or click through
    it, which is a test in itself.
  * Nothing here may wait for ever: a call that waits on the browser or the system has a
    clock of its own (Drive-Bounded for UI Automation and the clipboard, Drive-Eval and
    Drive-Pages for DevTools, -OperationTimeoutSec for WMI). A tab put to sleep never
    answers DevTools, and the S-173 run stopped for good at the first step that had one.
    Set $script:Drive.LogFile and $script:Drive.Trace for a log that says, line by line,
    what the run was about to do.
#>
param(
  [string]$Exe = $(if ($env:STEDDING_WIN_EXE) { $env:STEDDING_WIN_EXE }
                   elseif ($env:STEDDING_CHROMIUM_SRC) { Join-Path $env:STEDDING_CHROMIUM_SRC 'out\win-release\chrome.exe' }
                   else { 'chrome.exe' }),
  [int]$DebugPort = 9222
)

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName UIAutomationClient
Add-Type -AssemblyName UIAutomationTypes
if (-not ('StedDrive' -as [type])) {
Add-Type -TypeDefinition @'
using System;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using System.Text;
public static class StedDrive {
  [StructLayout(LayoutKind.Sequential)] public struct RECT { public int Left, Top, Right, Bottom; }
  [StructLayout(LayoutKind.Sequential)] public struct LASTINPUTINFO { public uint cbSize; public uint dwTime; }
  public delegate bool EnumProc(IntPtr h, IntPtr l);
  [DllImport("user32.dll")] public static extern bool SetProcessDPIAware();
  [DllImport("user32.dll")] public static extern bool SetCursorPos(int x, int y);
  [DllImport("user32.dll")] public static extern void mouse_event(uint flags, int dx, int dy, int data, UIntPtr extra);
  [DllImport("user32.dll")] public static extern void keybd_event(byte vk, byte scan, uint flags, UIntPtr extra);
  [DllImport("user32.dll")] public static extern IntPtr GetForegroundWindow();
  [StructLayout(LayoutKind.Sequential)] public struct POINT { public int X, Y; }
  [DllImport("user32.dll")] public static extern IntPtr WindowFromPoint(POINT p);
  [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr h);
  [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr h, int cmd);
  [DllImport("user32.dll")] public static extern bool IsIconic(IntPtr h);
  [DllImport("user32.dll")] public static extern bool GetWindowRect(IntPtr h, out RECT r);
  [DllImport("dwmapi.dll")] public static extern int DwmGetWindowAttribute(IntPtr h, int a, out RECT r, int s);
  [DllImport("user32.dll")] public static extern uint GetWindowThreadProcessId(IntPtr h, out uint pid);
  [DllImport("user32.dll")] public static extern bool EnumWindows(EnumProc p, IntPtr l);
  [DllImport("user32.dll")] public static extern bool IsWindowVisible(IntPtr h);
  [DllImport("user32.dll", CharSet = CharSet.Unicode)] public static extern int GetClassName(IntPtr h, StringBuilder s, int n);
  [DllImport("user32.dll")] public static extern int GetSystemMetrics(int i);
  [DllImport("user32.dll")] public static extern short VkKeyScan(char c);
  [DllImport("user32.dll")] public static extern bool GetLastInputInfo(ref LASTINPUTINFO p);
  [DllImport("kernel32.dll")] public static extern uint GetTickCount();
  public static uint LastInputTick() { var i = new LASTINPUTINFO(); i.cbSize = (uint)Marshal.SizeOf(typeof(LASTINPUTINFO)); GetLastInputInfo(ref i); return i.dwTime; }
  public static List<IntPtr> WindowsOf(uint pid) {
    var list = new List<IntPtr>();
    EnumWindows((h, l) => { uint p; GetWindowThreadProcessId(h, out p); if (p == pid && IsWindowVisible(h)) list.Add(h); return true; }, IntPtr.Zero);
    return list;
  }
}
'@
}
[void][StedDrive]::SetProcessDPIAware()

$script:Drive = @{
  Exe = $Exe; Port = $DebugPort; Pid = 0; Hwnd = [IntPtr]::Zero; Profile = $null
  Shots = (Join-Path $env:TEMP 'stedding-drive'); LastMine = 0; ShotOrigin = @(0, 0)
  # LogFile: every Drive-Log line is appended there at once, so a run that stops leaves its last
  # line on disk (a scheduled task's console output reaches its file late). Trace: each key,
  # click and typed text, and each call that waits on the browser, is logged before it happens.
  LogFile = $null; Trace = $false
  # The runspace UI Automation calls run on (Drive-Bounded), and how many calls were left behind.
  Runspace = $null; Timeouts = 0
}

function Drive-Log([string]$m) {
  $line = '{0} {1}' -f (Get-Date -Format 'HH:mm:ss'), $m
  Write-Host $line
  if ($script:Drive.LogFile) { try { Add-Content -Path $script:Drive.LogFile -Value $line -Encoding UTF8 } catch {} }
}

# A call that waits on another process -- UI Automation, the clipboard -- run on a runspace of its
# own and waited for at most $Seconds. One the other side never answers is left behind, its thread
# blocked, and the answer is $null: the run goes on, and the log says what did not answer. A run
# had stopped for good at its step tst9-11 (a DevTools call to a tab just put to sleep, Drive-Eval).
# UI Automation calls share one runspace, replaced only after a call is left behind on it; -Sta
# gives the call a single-threaded apartment of its own (the clipboard needs one).
function Drive-Bounded([string]$What, [scriptblock]$Body, [object[]]$Arguments = @(), [int]$Seconds = 30, [switch]$Sta) {
  if ($script:Drive.Trace) { Drive-Log "  wait: $What" }
  $rs = $null
  if (-not $Sta) { $rs = $script:Drive.Runspace }
  if (-not $rs) {
    $rs = [runspacefactory]::CreateRunspace()
    if ($Sta) { $rs.ApartmentState = [Threading.ApartmentState]::STA }
    $rs.Open()
    if (-not $Sta) { $script:Drive.Runspace = $rs }
  }
  $ps = [PowerShell]::Create()
  $ps.Runspace = $rs
  [void]$ps.AddScript($Body.ToString())
  foreach ($a in $Arguments) { [void]$ps.AddArgument($a) }
  $started = Get-Date
  $async = $ps.BeginInvoke()
  if (-not $async.AsyncWaitHandle.WaitOne([TimeSpan]::FromSeconds($Seconds))) {
    Drive-Log "TIMEOUT: $What gave no answer in $Seconds s; left behind"
    $script:Drive.Timeouts += 1
    if (-not $Sta) { $script:Drive.Runspace = $null }
    [void]$ps.BeginStop($null, $null)
    return $null
  }
  try {
    $out = $ps.EndInvoke($async)
    $took = ((Get-Date) - $started).TotalSeconds
    if ($took -gt 5) { Drive-Log ('  slow: {0} took {1:N1} s' -f $What, $took) }
    return $out
  } catch {
    Drive-Log "failed: $What -- $($_.Exception.Message)"
    return $null
  } finally {
    $ps.Dispose()
    if ($Sta) { $rs.Dispose() }
  }
}

# ---- the browser under test ------------------------------------------------------------------

# The main window of the browser this script's Exe started with $Profile in its command line.
function Drive-Find([string]$Profile) {
  $procs = Get-CimInstance Win32_Process -Filter "Name='chrome.exe'" -OperationTimeoutSec 15 |
    Where-Object { $_.ExecutablePath -eq $script:Drive.Exe -and $_.CommandLine -notmatch '--type=' -and $_.CommandLine -like "*$Profile*" }
  foreach ($p in $procs) {
    foreach ($h in [StedDrive]::WindowsOf([uint32]$p.ProcessId)) {
      $cls = New-Object Text.StringBuilder 256; [void][StedDrive]::GetClassName($h, $cls, 256)
      if ($cls.ToString() -eq 'Chrome_WidgetWin_1') {
        $r = New-Object StedDrive+RECT; [void][StedDrive]::GetWindowRect($h, [ref]$r)
        if (($r.Right - $r.Left) -gt 300) {
          $script:Drive.Pid = [uint32]$p.ProcessId; $script:Drive.Hwnd = $h; $script:Drive.Profile = $Profile
          return $h
        }
      }
    }
  }
  return [IntPtr]::Zero
}

# A fresh profile (under the temp folder unless -Profile is a path) and a browser on it, waited for.
# -Seed is a hashtable written as Preferences, -LocalState one written as Local State; -Urls open as
# tabs; -Extra are more switches.
function Drive-Launch([string]$Profile = 'scratch', [string[]]$Urls = @(), [hashtable]$Seed = $null, [string[]]$Extra = @(), [hashtable]$LocalState = $null) {
  $dir = if ([IO.Path]::IsPathRooted($Profile)) { $Profile } else { Join-Path (Join-Path $script:Drive.Shots 'profiles') $Profile }
  if (Test-Path $dir) { Remove-Item $dir -Recurse -Force }
  New-Item -ItemType Directory -Force (Join-Path $dir 'Default') | Out-Null
  if ($Seed) {
    [IO.File]::WriteAllText((Join-Path $dir 'Default\Preferences'), ($Seed | ConvertTo-Json -Compress -Depth 8), (New-Object Text.UTF8Encoding $false))
  }
  if ($LocalState) {
    [IO.File]::WriteAllText((Join-Path $dir 'Local State'), ($LocalState | ConvertTo-Json -Compress -Depth 8), (New-Object Text.UTF8Encoding $false))
  }
  $argv = @("--user-data-dir=$dir", "--remote-debugging-port=$($script:Drive.Port)") + $Extra + $Urls
  $null = Start-Process -FilePath $script:Drive.Exe -ArgumentList $argv -PassThru
  $h = [IntPtr]::Zero
  for ($i = 0; $i -lt 60 -and $h -eq [IntPtr]::Zero; $i++) { Start-Sleep -Milliseconds 500; $h = Drive-Find $dir }
  if ($h -eq [IntPtr]::Zero) { throw "no window for the browser started on $dir" }
  return $h
}

# Stops the browser this script launched (found by profile path), and only that one.
function Drive-Stop {
  if (-not $script:Drive.Profile) { return }
  Get-CimInstance Win32_Process -Filter "Name='chrome.exe'" -OperationTimeoutSec 15 |
    Where-Object { $_.CommandLine -like "*$($script:Drive.Profile)*" -and $_.CommandLine -notmatch '--type=' } |
    ForEach-Object { & taskkill /F /T /PID $_.ProcessId | Out-Null }
  if ($script:Drive.Runspace) { try { $script:Drive.Runspace.Dispose() } catch {}; $script:Drive.Runspace = $null }
}

# ---- the guards ------------------------------------------------------------------------------

function Drive-ForegroundIsBrowser {
  $h = [StedDrive]::GetForegroundWindow()
  if ($h -eq [IntPtr]::Zero) { return $false }
  $p = 0; [void][StedDrive]::GetWindowThreadProcessId($h, [ref]$p)
  return ([uint32]$p -eq $script:Drive.Pid)
}

# Brings the browser window forward: the plain call, then the Alt-key nudge Windows allows.
# It closes an open menu: never call it between a menu opening and its row being clicked.
# Windows keeps a new window behind the foreground one when its process did not get the last
# input: a browser launched seconds after this script's own keys opens behind the operator's
# window, its pages hidden, and takes no key (BACKLOG S-248). The nudge is input, so it waits
# for the operator to be idle, and it is marked as this script's.
function Drive-Focus {
  $h = $script:Drive.Hwnd
  if ([StedDrive]::IsIconic($h)) { [void][StedDrive]::ShowWindow($h, 9) }
  for ($i = 0; $i -lt 4; $i++) {
    [void][StedDrive]::SetForegroundWindow($h)
    Start-Sleep -Milliseconds 250
    if (Drive-ForegroundIsBrowser) { return $true }
    if (-not (Drive-WaitOwnerIdle 120)) { return $false }
    [StedDrive]::keybd_event(0x12, 0, 0, [UIntPtr]::Zero); [StedDrive]::keybd_event(0x12, 0, 2, [UIntPtr]::Zero)
    Drive-Mark
  }
  return (Drive-ForegroundIsBrowser)
}

# Input that is not this script's is the operator's: a last event that came after ours and is
# recent means someone is at the keyboard or pointer.
function Drive-OwnerActive {
  $t = [StedDrive]::LastInputTick(); $idle = [int64][StedDrive]::GetTickCount() - [int64]$t
  $mine = ($script:Drive.LastMine -ne 0) -and ([math]::Abs([int64]$t - [int64]$script:Drive.LastMine) -le 60)
  return ((-not $mine) -and ($idle -lt 6000))
}
function Drive-Mark { $script:Drive.LastMine = [StedDrive]::LastInputTick() }
function Drive-WaitOwnerIdle([int]$MaxSeconds = 120) {
  $until = (Get-Date).AddSeconds($MaxSeconds)
  while (Drive-OwnerActive) { if ((Get-Date) -gt $until) { return $false }; Start-Sleep -Milliseconds 500 }
  return $true
}
# Whether the window under a screen point is one of the browser under test's: the main window, a
# menu or a dialog of its process. A point outside them -- an element scrolled out of the page's
# view, whose bounds lie below the screen -- would put the press on whatever is there: on
# 2026-11-10 a click at y 4548 was clamped to the screen's edge and landed on the taskbar.
function Drive-PointIsBrowser([int]$x, [int]$y) {
  $pt = New-Object StedDrive+POINT; $pt.X = $x; $pt.Y = $y
  $h = [StedDrive]::WindowFromPoint($pt)
  if ($h -eq [IntPtr]::Zero) { return $false }
  $p = 0; [void][StedDrive]::GetWindowThreadProcessId($h, [ref]$p)
  return ([uint32]$p -eq $script:Drive.Pid)
}
function Drive-GuardPoint([int]$x, [int]$y) {
  if (Drive-PointIsBrowser $x $y) { return $true }
  Drive-Log "REFUSED: $x,$y is not over the browser under test"
  return $false
}

function Drive-Guard {
  if (-not (Drive-WaitOwnerIdle 120)) { Drive-Log 'REFUSED: the operator has been at the keyboard or pointer for two minutes'; return $false }
  if (-not (Drive-ForegroundIsBrowser)) { Drive-Log 'REFUSED: the foreground window is not the browser under test'; return $false }
  return $true
}

# ---- input -----------------------------------------------------------------------------------

function Drive-Move([int]$x, [int]$y) { [void][StedDrive]::SetCursorPos($x, $y) }

$script:VK = @{ ctrl = 0x11; control = 0x11; shift = 0x10; alt = 0x12; win = 0x5B; enter = 0x0D; return = 0x0D; esc = 0x1B; escape = 0x1B; tab = 0x09; space = 0x20;
  backspace = 0x08; delete = 0x2E; left = 0x25; up = 0x26; right = 0x27; down = 0x28; home = 0x24; end = 0x23; pageup = 0x21; pagedown = 0x22;
  f1 = 0x70; f2 = 0x71; f3 = 0x72; f4 = 0x73; f5 = 0x74; f6 = 0x75; f7 = 0x76; f8 = 0x77; f9 = 0x78; f10 = 0x79; f11 = 0x7A; f12 = 0x7B }
function Drive-ModVks([string]$Mods) {
  $out = @()
  foreach ($m in ($Mods -split '\+' | Where-Object { $_ })) { if ($script:VK.ContainsKey($m.ToLower())) { $out += [byte]$script:VK[$m.ToLower()] } }
  return ,$out
}
function Drive-VkOf([string]$k) {
  $l = $k.ToLower()
  if ($script:VK.ContainsKey($l)) { return [byte]$script:VK[$l] }
  if ($k.Length -eq 1) { $s = [StedDrive]::VkKeyScan($k[0]); return [byte]($s -band 0xFF) }
  throw "unknown key '$k'"
}
# The keys a keyboard sends with the extended flag: PgUp, PgDn, End, Home, the arrows, Insert,
# Delete and Win. Without it an arrow is the numeric keypad's with NumLock off, which a text
# field takes for an Alt code while Alt is held: Ctrl+Alt+Right in the address bar did nothing
# (BACKLOG S-218), where the arrow key itself changes Space.
$script:ExtendedVks = @(0x21, 0x22, 0x23, 0x24, 0x25, 0x26, 0x27, 0x28, 0x2D, 0x2E, 0x5B)
function Drive-Key([byte]$Vk, [switch]$Up) {
  $flags = 0
  if ($script:ExtendedVks -contains [int]$Vk) { $flags = $flags -bor 0x0001 }  # KEYEVENTF_EXTENDEDKEY
  if ($Up) { $flags = $flags -bor 0x0002 }  # KEYEVENTF_KEYUP
  [StedDrive]::keybd_event($Vk, 0, [uint32]$flags, [UIntPtr]::Zero)
}

# Button 'left' or 'right'; $Mods is a chord of modifiers held through the click ('ctrl', 'shift+ctrl').
function Drive-Click([int]$x, [int]$y, [string]$Button = 'left', [string]$Mods = '') {
  if ($script:Drive.Trace) { Drive-Log "  click $Button at $x,$y $Mods" }
  if (-not (Drive-Guard)) { return $false }
  if (-not (Drive-GuardPoint $x $y)) { return $false }
  Drive-Move $x $y; Start-Sleep -Milliseconds 120
  $down = if ($Button -eq 'right') { 0x0008 } else { 0x0002 }
  $up = if ($Button -eq 'right') { 0x0010 } else { 0x0004 }
  $vks = Drive-ModVks $Mods
  foreach ($v in $vks) { Drive-Key $v }
  [StedDrive]::mouse_event($down, 0, 0, 0, [UIntPtr]::Zero); Start-Sleep -Milliseconds 70
  [StedDrive]::mouse_event($up, 0, 0, 0, [UIntPtr]::Zero)
  [array]::Reverse($vks); foreach ($v in $vks) { Drive-Key $v -Up }
  Start-Sleep -Milliseconds 350
  Drive-Mark
  return $true
}

# A person's drag: press, small steps to pass the threshold and on to the target, a hold, release.
function Drive-Drag([int]$x1, [int]$y1, [int]$x2, [int]$y2, [int]$Steps = 25, [int]$HoldMs = 350) {
  if ($script:Drive.Trace) { Drive-Log "  drag $x1,$y1 to $x2,$y2" }
  if (-not (Drive-Guard)) { return $false }
  if (-not (Drive-GuardPoint $x1 $y1) -or -not (Drive-GuardPoint $x2 $y2)) { return $false }
  Drive-Move $x1 $y1; Start-Sleep -Milliseconds 150
  [StedDrive]::mouse_event(0x0002, 0, 0, 0, [UIntPtr]::Zero); Start-Sleep -Milliseconds 120
  for ($i = 1; $i -le $Steps; $i++) {
    if (-not (Drive-ForegroundIsBrowser)) { [StedDrive]::mouse_event(0x0004, 0, 0, 0, [UIntPtr]::Zero); Drive-Log 'REFUSED mid-drag: released'; return $false }
    Drive-Move ([int]($x1 + ($x2 - $x1) * $i / $Steps)) ([int]($y1 + ($y2 - $y1) * $i / $Steps))
    Start-Sleep -Milliseconds 18
  }
  Start-Sleep -Milliseconds $HoldMs
  [StedDrive]::mouse_event(0x0004, 0, 0, 0, [UIntPtr]::Zero)
  Start-Sleep -Milliseconds 600
  Drive-Mark
  return $true
}

function Drive-Scroll([int]$x, [int]$y, [int]$Clicks) {
  if (-not (Drive-Guard)) { return $false }
  if (-not (Drive-GuardPoint $x $y)) { return $false }
  Drive-Move $x $y; Start-Sleep -Milliseconds 100
  [StedDrive]::mouse_event(0x0800, 0, 0, (120 * $Clicks), [UIntPtr]::Zero)
  Start-Sleep -Milliseconds 300
  Drive-Mark
  return $true
}

# "ctrl+shift+c", "alt+1", "enter", "f11": modifiers down in order, the key, modifiers up in reverse.
function Drive-Keys([string]$Chord) {
  if ($script:Drive.Trace) { Drive-Log "  keys $Chord" }
  if (-not (Drive-Guard)) { return $false }
  $parts = $Chord -split '\+'
  $mods = @(); for ($i = 0; $i -lt $parts.Count - 1; $i++) { $mods += Drive-VkOf $parts[$i] }
  $key = Drive-VkOf $parts[-1]
  foreach ($m in $mods) { Drive-Key ([byte]$m); Start-Sleep -Milliseconds 30 }
  Drive-Key ([byte]$key); Start-Sleep -Milliseconds 50
  Drive-Key ([byte]$key) -Up; Start-Sleep -Milliseconds 30
  for ($i = $mods.Count - 1; $i -ge 0; $i--) { Drive-Key ([byte]$mods[$i]) -Up; Start-Sleep -Milliseconds 20 }
  Start-Sleep -Milliseconds 300
  Drive-Mark
  return $true
}

# Text typed as characters (each through VkKeyScan, shifted ones with Shift).
function Drive-Type([string]$Text) {
  if ($script:Drive.Trace) { Drive-Log "  type '$Text'" }
  if (-not (Drive-Guard)) { return $false }
  foreach ($c in $Text.ToCharArray()) {
    $s = [StedDrive]::VkKeyScan($c)
    if ($s -eq -1) { Drive-Log "cannot type '$c'"; continue }
    $vk = [byte]($s -band 0xFF); $shift = (($s -shr 8) -band 1) -eq 1
    if ($shift) { [StedDrive]::keybd_event(0x10, 0, 0, [UIntPtr]::Zero) }
    [StedDrive]::keybd_event($vk, 0, 0, [UIntPtr]::Zero); Start-Sleep -Milliseconds 12
    [StedDrive]::keybd_event($vk, 0, 2, [UIntPtr]::Zero)
    if ($shift) { [StedDrive]::keybd_event(0x10, 0, 2, [UIntPtr]::Zero) }
    Start-Sleep -Milliseconds 18
  }
  Start-Sleep -Milliseconds 250
  Drive-Mark
  return $true
}

# ---- looking ---------------------------------------------------------------------------------

function Drive-WindowRect { $r = New-Object StedDrive+RECT; [void][StedDrive]::GetWindowRect($script:Drive.Hwnd, [ref]$r); return $r }
# The window as it is drawn. GetWindowRect includes the invisible resize border, about 7 px on
# each side on Windows 10 and 11: a pointer at its edge + 1 is on that border, where no view
# hears it (docs/HANDOFF.md, trap 69). Aim at the window's own edges with these bounds.
function Drive-VisibleRect {
  $r = New-Object StedDrive+RECT
  if ([StedDrive]::DwmGetWindowAttribute($script:Drive.Hwnd, 9, [ref]$r, 16) -ne 0) { return (Drive-WindowRect) }
  return $r
}

# A PNG of the window's rectangle (and the menus and bubbles beside it), only while the browser is in
# front. A view crop of a picture: screen x = $script:Drive.ShotOrigin[0] + x in the picture.
function Drive-Shot([string]$Name, [switch]$Wide) {
  New-Item -ItemType Directory -Force $script:Drive.Shots | Out-Null
  if (-not (Drive-ForegroundIsBrowser)) { Drive-Log "no shot '$Name': the browser is not in front"; return $null }
  $r = Drive-WindowRect
  $pad = if ($Wide) { 120 } else { 24 }
  $sx = [StedDrive]::GetSystemMetrics(76); $sy = [StedDrive]::GetSystemMetrics(77)
  $sw = [StedDrive]::GetSystemMetrics(78); $sh = [StedDrive]::GetSystemMetrics(79)
  $x0 = [math]::Max($sx, $r.Left - $pad); $y0 = [math]::Max($sy, $r.Top - $pad)
  $x1 = [math]::Min($sx + $sw, $r.Right + $pad); $y1 = [math]::Min($sy + $sh, $r.Bottom + $pad)
  if (($x1 - $x0) -lt 50 -or ($y1 - $y0) -lt 50) { Drive-Log "no shot '$Name': the window is not on screen"; return $null }
  $bmp = New-Object Drawing.Bitmap ($x1 - $x0), ($y1 - $y0)
  $g = [Drawing.Graphics]::FromImage($bmp)
  $g.CopyFromScreen($x0, $y0, 0, 0, $bmp.Size)
  $path = Join-Path $script:Drive.Shots "$Name.png"
  $bmp.Save($path, [Drawing.Imaging.ImageFormat]::Png)
  $g.Dispose(); $bmp.Dispose()
  $script:Drive.ShotOrigin = @($x0, $y0)
  return $path
}

# UI Automation elements of the window by control type, bounds in screen pixels (DPI aware), one per
# place on screen. Types: TabItem (sidebar rows), Button, MenuItem, Edit, Document (the page), ...
# X, Y are the centre, L, T the top left corner. Focusable is UI Automation's IsKeyboardFocusable:
# a control of a hidden view stays in Chromium's tree with its last bounds, and only this tells it
# from a shown one (the address field of a hidden address row, toolbar T36). FindAll waits on the
# browser's UI thread: it runs through Drive-Bounded, and a window that does not answer in 30 s
# reads as one with no such elements.
$script:UiaFindAll = {
  param([IntPtr]$Hwnd, [string]$Type)
  $root = [Windows.Automation.AutomationElement]::FromHandle($Hwnd)
  $ct = [Windows.Automation.ControlType]::($Type)
  $cond = New-Object Windows.Automation.PropertyCondition([Windows.Automation.AutomationElement]::ControlTypeProperty, $ct)
  foreach ($e in $root.FindAll([Windows.Automation.TreeScope]::Descendants, $cond)) {
    $c = $e.Current
    $r = $c.BoundingRectangle
    if ([double]::IsInfinity($r.X) -or $r.Width -lt 1) { continue }
    [pscustomobject]@{ Name = $c.Name; X = [int]($r.X + $r.Width / 2); Y = [int]($r.Y + $r.Height / 2); W = [int]$r.Width; H = [int]$r.Height
      L = [int]$r.X; T = [int]$r.Y; Class = $c.ClassName; Focusable = [bool]$c.IsKeyboardFocusable }
  }
}
function Drive-Rows([string]$Type = 'TabItem') {
  $found = Drive-Bounded "UI Automation $Type" $script:UiaFindAll @($script:Drive.Hwnd, $Type) 30
  return @($found | Where-Object { $_ } | Sort-Object Name, X, Y -Unique)
}

# DevTools (the browser is started with --remote-debugging-port): the titles of the pages that say they
# are visible, which is how a click on a row is proved to have selected its tab.
# Every wait is bounded by a clock of its own, not by a cancellation the socket may not honour. A
# page that cannot answer -- a tab put to sleep, a frozen or discarded one -- held the run for ever
# at tst9-11, the first step with a tab asleep (Ctrl+W on a pin): each page now has three seconds,
# and one that has not answered by then is not visible.
function Drive-MsLeft([datetime]$Until) { return [int][math]::Max(1, ($Until - (Get-Date)).TotalMilliseconds) }
function Drive-Eval([string]$WsUrl, [string]$Expr, [int]$TimeoutMs = 3000) {
  $until = (Get-Date).AddMilliseconds($TimeoutMs)
  $ws = New-Object System.Net.WebSockets.ClientWebSocket
  $cts = New-Object Threading.CancellationTokenSource
  try {
    if (-not $ws.ConnectAsync([Uri]$WsUrl, $cts.Token).Wait((Drive-MsLeft $until))) { return $null }
    $msg = @{ id = 1; method = 'Runtime.evaluate'; params = @{ expression = $Expr; returnByValue = $true } } | ConvertTo-Json -Compress -Depth 4
    $bytes = [Text.Encoding]::UTF8.GetBytes($msg)
    $send = $ws.SendAsync((New-Object ArraySegment[byte] -ArgumentList @(,$bytes)), [Net.WebSockets.WebSocketMessageType]::Text, $true, $cts.Token)
    if (-not $send.Wait((Drive-MsLeft $until))) { return $null }
    $buf = New-Object byte[] (1024 * 1024)
    for ($n = 0; $n -lt 50; $n++) {
      $ms = New-Object IO.MemoryStream
      do {
        $receive = $ws.ReceiveAsync((New-Object ArraySegment[byte] -ArgumentList @(,$buf)), $cts.Token)
        if (-not $receive.Wait((Drive-MsLeft $until))) { return $null }
        $r = $receive.Result
        $ms.Write($buf, 0, $r.Count)
      } while (-not $r.EndOfMessage)
      $o = [Text.Encoding]::UTF8.GetString($ms.ToArray()) | ConvertFrom-Json
      if ($o.id -eq 1) { return $o.result.result.value }
    }
    return $null
  } catch {
    return $null
  } finally {
    try { $cts.Cancel(); $ws.Abort() } catch {}
    $ws.Dispose(); $cts.Dispose()
  }
}
# The pages DevTools lists, each with its debugger's address; none when DevTools has not answered in
# five seconds. Invoke-RestMethod's -TimeoutSec does not bound reading the answer; these timeouts do.
function Drive-Pages {
  if ($script:Drive.Trace) { Drive-Log '  wait: DevTools page list' }
  try {
    $request = [Net.HttpWebRequest]::Create("http://127.0.0.1:$($script:Drive.Port)/json/list")
    $request.Timeout = 5000
    $request.ReadWriteTimeout = 5000
    $request.Proxy = $null
    $response = $request.GetResponse()
    try {
      $reader = New-Object IO.StreamReader($response.GetResponseStream())
      $text = $reader.ReadToEnd()
    } finally { $response.Close() }
    # Into a variable first: Windows PowerShell's ConvertFrom-Json sends an array down a pipe as one object.
    $all = ConvertFrom-Json -InputObject $text
    return @($all | Where-Object { $_.type -eq 'page' -and $_.webSocketDebuggerUrl })
  } catch {
    Drive-Log "DevTools gave no page list: $($_.Exception.Message)"
    return @()
  }
}
function Drive-Visible {
  $vis = @()
  foreach ($t in (Drive-Pages)) { if ((Drive-Eval $t.webSocketDebuggerUrl 'document.visibilityState') -eq 'visible') { $vis += $t.title } }
  return ($vis -join ' | ')
}

# The clipboard's text, read on a thread of its own: a clipboard another program holds open would
# hold the run. Empty when it does not answer in ten seconds.
function Drive-Clipboard {
  $text = Drive-Bounded 'the clipboard' { [Windows.Forms.Clipboard]::GetText() } @() 10 -Sta
  return [string]($text | Select-Object -First 1)
}
