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
  [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr h);
  [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr h, int cmd);
  [DllImport("user32.dll")] public static extern bool IsIconic(IntPtr h);
  [DllImport("user32.dll")] public static extern bool GetWindowRect(IntPtr h, out RECT r);
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
}

function Drive-Log([string]$m) { Write-Host $m }

# ---- the browser under test ------------------------------------------------------------------

# The main window of the browser this script's Exe started with $Profile in its command line.
function Drive-Find([string]$Profile) {
  $procs = Get-CimInstance Win32_Process -Filter "Name='chrome.exe'" |
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
# -Seed is a hashtable written as Preferences; -Urls open as tabs; -Extra are more switches.
function Drive-Launch([string]$Profile = 'scratch', [string[]]$Urls = @(), [hashtable]$Seed = $null, [string[]]$Extra = @()) {
  $dir = if ([IO.Path]::IsPathRooted($Profile)) { $Profile } else { Join-Path (Join-Path $script:Drive.Shots 'profiles') $Profile }
  if (Test-Path $dir) { Remove-Item $dir -Recurse -Force }
  New-Item -ItemType Directory -Force (Join-Path $dir 'Default') | Out-Null
  if ($Seed) {
    [IO.File]::WriteAllText((Join-Path $dir 'Default\Preferences'), ($Seed | ConvertTo-Json -Compress -Depth 8), (New-Object Text.UTF8Encoding $false))
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
  Get-CimInstance Win32_Process -Filter "Name='chrome.exe'" |
    Where-Object { $_.CommandLine -like "*$($script:Drive.Profile)*" -and $_.CommandLine -notmatch '--type=' } |
    ForEach-Object { & taskkill /F /T /PID $_.ProcessId | Out-Null }
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
function Drive-Focus {
  $h = $script:Drive.Hwnd
  if ([StedDrive]::IsIconic($h)) { [void][StedDrive]::ShowWindow($h, 9) }
  for ($i = 0; $i -lt 4; $i++) {
    [void][StedDrive]::SetForegroundWindow($h)
    Start-Sleep -Milliseconds 250
    if (Drive-ForegroundIsBrowser) { return $true }
    [StedDrive]::keybd_event(0x12, 0, 0, [UIntPtr]::Zero); [StedDrive]::keybd_event(0x12, 0, 2, [UIntPtr]::Zero)
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

# Button 'left' or 'right'; $Mods is a chord of modifiers held through the click ('ctrl', 'shift+ctrl').
function Drive-Click([int]$x, [int]$y, [string]$Button = 'left', [string]$Mods = '') {
  if (-not (Drive-Guard)) { return $false }
  Drive-Move $x $y; Start-Sleep -Milliseconds 120
  $down = if ($Button -eq 'right') { 0x0008 } else { 0x0002 }
  $up = if ($Button -eq 'right') { 0x0010 } else { 0x0004 }
  $vks = Drive-ModVks $Mods
  foreach ($v in $vks) { [StedDrive]::keybd_event($v, 0, 0, [UIntPtr]::Zero) }
  [StedDrive]::mouse_event($down, 0, 0, 0, [UIntPtr]::Zero); Start-Sleep -Milliseconds 70
  [StedDrive]::mouse_event($up, 0, 0, 0, [UIntPtr]::Zero)
  [array]::Reverse($vks); foreach ($v in $vks) { [StedDrive]::keybd_event($v, 0, 2, [UIntPtr]::Zero) }
  Start-Sleep -Milliseconds 350
  Drive-Mark
  return $true
}

# A person's drag: press, small steps to pass the threshold and on to the target, a hold, release.
function Drive-Drag([int]$x1, [int]$y1, [int]$x2, [int]$y2, [int]$Steps = 25, [int]$HoldMs = 350) {
  if (-not (Drive-Guard)) { return $false }
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
  Drive-Move $x $y; Start-Sleep -Milliseconds 100
  [StedDrive]::mouse_event(0x0800, 0, 0, (120 * $Clicks), [UIntPtr]::Zero)
  Start-Sleep -Milliseconds 300
  Drive-Mark
  return $true
}

# "ctrl+shift+c", "alt+1", "enter", "f11": modifiers down in order, the key, modifiers up in reverse.
function Drive-Keys([string]$Chord) {
  if (-not (Drive-Guard)) { return $false }
  $parts = $Chord -split '\+'
  $mods = @(); for ($i = 0; $i -lt $parts.Count - 1; $i++) { $mods += Drive-VkOf $parts[$i] }
  $key = Drive-VkOf $parts[-1]
  foreach ($m in $mods) { [StedDrive]::keybd_event([byte]$m, 0, 0, [UIntPtr]::Zero); Start-Sleep -Milliseconds 30 }
  [StedDrive]::keybd_event([byte]$key, 0, 0, [UIntPtr]::Zero); Start-Sleep -Milliseconds 50
  [StedDrive]::keybd_event([byte]$key, 0, 2, [UIntPtr]::Zero); Start-Sleep -Milliseconds 30
  for ($i = $mods.Count - 1; $i -ge 0; $i--) { [StedDrive]::keybd_event([byte]$mods[$i], 0, 2, [UIntPtr]::Zero); Start-Sleep -Milliseconds 20 }
  Start-Sleep -Milliseconds 300
  Drive-Mark
  return $true
}

# Text typed as characters (each through VkKeyScan, shifted ones with Shift).
function Drive-Type([string]$Text) {
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
# place on screen. Types: TabItem (sidebar rows), Button, MenuItem, Edit, ...
function Drive-Rows([string]$Type = 'TabItem') {
  $root = [Windows.Automation.AutomationElement]::FromHandle($script:Drive.Hwnd)
  $ct = [Windows.Automation.ControlType]::($Type)
  $cond = New-Object Windows.Automation.PropertyCondition([Windows.Automation.AutomationElement]::ControlTypeProperty, $ct)
  $out = @()
  foreach ($e in $root.FindAll([Windows.Automation.TreeScope]::Descendants, $cond)) {
    $r = $e.Current.BoundingRectangle
    if ([double]::IsInfinity($r.X) -or $r.Width -lt 1) { continue }
    $out += [pscustomobject]@{ Name = $e.Current.Name; X = [int]($r.X + $r.Width / 2); Y = [int]($r.Y + $r.Height / 2); W = [int]$r.Width; H = [int]$r.Height; Class = $e.Current.ClassName }
  }
  return @($out | Sort-Object Name, X, Y -Unique)
}

# DevTools (the browser is started with --remote-debugging-port): the titles of the pages that say they
# are visible, which is how a click on a row is proved to have selected its tab.
function Drive-Eval([string]$WsUrl, [string]$Expr) {
  $ws = New-Object System.Net.WebSockets.ClientWebSocket
  $ws.ConnectAsync([Uri]$WsUrl, [Threading.CancellationToken]::None).Wait()
  try {
    $msg = @{ id = 1; method = 'Runtime.evaluate'; params = @{ expression = $Expr; returnByValue = $true } } | ConvertTo-Json -Compress -Depth 4
    $bytes = [Text.Encoding]::UTF8.GetBytes($msg)
    $ws.SendAsync((New-Object ArraySegment[byte] -ArgumentList @(,$bytes)), [Net.WebSockets.WebSocketMessageType]::Text, $true, [Threading.CancellationToken]::None).Wait()
    $buf = New-Object byte[] (1024 * 1024)
    for ($n = 0; $n -lt 50; $n++) {
      $ms = New-Object IO.MemoryStream
      do { $r = $ws.ReceiveAsync((New-Object ArraySegment[byte] -ArgumentList @(,$buf)), [Threading.CancellationToken]::None).Result; $ms.Write($buf, 0, $r.Count) } while (-not $r.EndOfMessage)
      $o = [Text.Encoding]::UTF8.GetString($ms.ToArray()) | ConvertFrom-Json
      if ($o.id -eq 1) { return $o.result.result.value }
    }
  } finally { $ws.Dispose() }
}
function Drive-Visible {
  $pages = try { Invoke-RestMethod -Uri "http://127.0.0.1:$($script:Drive.Port)/json/list" -TimeoutSec 5 | Where-Object { $_.type -eq 'page' -and $_.webSocketDebuggerUrl } } catch { @() }
  $vis = @()
  foreach ($t in $pages) { if ((Drive-Eval $t.webSocketDebuggerUrl 'document.visibilityState') -eq 'visible') { $vis += $t.title } }
  return ($vis -join ' | ')
}
