# What the window's frame answers at the centre of every row, the way a real click
# is routed: a click reaches a window as WM_NCHITTEST first, and a frame that calls a
# point HTCAPTION turns the press into a window drag before any view sees it. A posted
# WM_LBUTTONDOWN (tooling\win\capture.ps1's Post-Click) never asks that question, so a
# row that the frame calls caption looks fine to it and dead to a person (PLAN.md
# TAB-1; docs/features/tabs.md R24: "the window treats every row as client area,
# never as caption"). SendMessage of WM_NCHITTEST moves nothing and types nothing:
# it needs neither focus nor input (docs/HANDOFF.md, trap 36).
#
# Windows PowerShell 5.1, against a browser that is already running:
#
#   $env:STEDDING_WIN_EXE = "C:\path\to\src\out\win-release\chrome.exe"   # or -Exe
#   tooling\win\hit-test.ps1                       # every tab row (UI Automation TabItem)
#   tooling\win\hit-test.ps1 -ControlType Button   # another kind of element
#   tooling\win\hit-test.ps1 -At 20,20,300,44      # extra client points, X,Y pairs
#
# The exit code is the number of probed points the frame did not call client area,
# so a script can fail on it. HTTRANSPARENT (-1, click through to a window below) is
# reported but is not counted as caption.
param(
  [string]$Exe = $env:STEDDING_WIN_EXE,
  [string]$ControlType = "TabItem",
  [int[]]$At = @()
)
$ErrorActionPreference = "Stop"
if (-not $Exe) { throw "set STEDDING_WIN_EXE to the browser to probe, or pass -Exe" }
if ($At.Count % 2 -ne 0) { throw "-At takes X,Y pairs" }

Add-Type @"
using System;
using System.Runtime.InteropServices;
public static class SteddingHit {
  [StructLayout(LayoutKind.Sequential)] public struct RECT { public int L, T, R, B; }
  [StructLayout(LayoutKind.Sequential)] public struct POINT { public int X, Y; }
  [DllImport("user32.dll")] public static extern bool SetProcessDPIAware();
  [DllImport("user32.dll")] public static extern bool GetWindowRect(IntPtr h, out RECT r);
  [DllImport("user32.dll")] public static extern bool IsWindowVisible(IntPtr h);
  [DllImport("user32.dll")] public static extern bool ClientToScreen(IntPtr h, ref POINT p);
  [DllImport("user32.dll")] public static extern IntPtr SendMessageTimeout(IntPtr h, uint msg, IntPtr w, IntPtr l, uint flags, uint timeout, out IntPtr result);
  public delegate bool EnumProc(IntPtr h, IntPtr l);
  [DllImport("user32.dll")] public static extern bool EnumWindows(EnumProc cb, IntPtr l);
  [DllImport("user32.dll")] public static extern int GetClassName(IntPtr h, System.Text.StringBuilder s, int n);
  [DllImport("user32.dll")] public static extern uint GetWindowThreadProcessId(IntPtr h, out uint pid);
  // The largest visible Chrome_WidgetWin_1 window of the process: bubbles, menus
  // and dialogs share the class.
  public static IntPtr MainWindow(uint pid) {
    IntPtr best = IntPtr.Zero; long area = 0;
    EnumWindows((h, l) => {
      uint p; GetWindowThreadProcessId(h, out p);
      if (p != pid || !IsWindowVisible(h)) return true;
      var sb = new System.Text.StringBuilder(64); GetClassName(h, sb, 64);
      if (sb.ToString() != "Chrome_WidgetWin_1") return true;
      RECT r; GetWindowRect(h, out r);
      long a = (long)(r.R - r.L) * (r.B - r.T);
      if (a > area) { area = a; best = h; }
      return true;
    }, IntPtr.Zero);
    return best;
  }
  // WM_NCHITTEST at a screen point; int.MinValue when the window did not answer in 2 s.
  public static int HitTest(IntPtr h, int screenX, int screenY) {
    IntPtr result;
    IntPtr lparam = new IntPtr(((screenY & 0xFFFF) << 16) | (screenX & 0xFFFF));
    IntPtr ok = SendMessageTimeout(h, 0x0084, IntPtr.Zero, lparam, 0x2, 2000, out result);
    if (ok == IntPtr.Zero) return int.MinValue;
    return (int)(long)result;
  }
}
"@
[void][SteddingHit]::SetProcessDPIAware()

$names = @{
  -2 = "HTERROR"; -1 = "HTTRANSPARENT"; 0 = "HTNOWHERE"; 1 = "HTCLIENT"; 2 = "HTCAPTION";
  3 = "HTSYSMENU"; 4 = "HTGROWBOX"; 5 = "HTMENU"; 6 = "HTHSCROLL"; 7 = "HTVSCROLL";
  8 = "HTMINBUTTON"; 9 = "HTMAXBUTTON"; 10 = "HTLEFT"; 11 = "HTRIGHT"; 12 = "HTTOP";
  13 = "HTTOPLEFT"; 14 = "HTTOPRIGHT"; 15 = "HTBOTTOM"; 16 = "HTBOTTOMLEFT";
  17 = "HTBOTTOMRIGHT"; 18 = "HTBORDER"; 19 = "HTOBJECT"; 20 = "HTCLOSE"; 21 = "HTHELP"
}

$hwnd = [IntPtr]::Zero
foreach ($p in (Get-Process chrome -ErrorAction SilentlyContinue | Where-Object { $_.Path -eq $Exe })) {
  $h = [SteddingHit]::MainWindow([uint32]$p.Id)
  if ($h -ne [IntPtr]::Zero) { $hwnd = $h; break }
}
if ($hwnd -eq [IntPtr]::Zero) { throw "no window of a running $Exe" }

Add-Type -AssemblyName UIAutomationClient
Add-Type -AssemblyName UIAutomationTypes
$origin = New-Object SteddingHit+POINT
[void][SteddingHit]::ClientToScreen($hwnd, [ref]$origin)

$points = @()   # each: name, client x, client y
$root = [System.Windows.Automation.AutomationElement]::FromHandle($hwnd)
$type = [System.Windows.Automation.ControlType]::$ControlType
if (-not $type) { throw "no UI Automation control type '$ControlType'" }
$cond = New-Object System.Windows.Automation.PropertyCondition([System.Windows.Automation.AutomationElement]::ControlTypeProperty, $type)
foreach ($e in $root.FindAll([System.Windows.Automation.TreeScope]::Descendants, $cond)) {
  try {
    $r = $e.Current.BoundingRectangle
    if ([double]::IsInfinity($r.X) -or [double]::IsNaN($r.X) -or $r.Width -lt 1 -or $r.Height -lt 1) { continue }
    $points += [pscustomobject]@{
      Name = $e.Current.Name
      X = [int]($r.X + $r.Width / 2 - $origin.X)
      Y = [int]($r.Y + $r.Height / 2 - $origin.Y)
    }
  } catch { }
}
for ($i = 0; $i -lt $At.Count; $i += 2) {
  $points += [pscustomobject]@{ Name = "(point)"; X = $At[$i]; Y = $At[$i + 1] }
}
if ($points.Count -eq 0) { throw "nothing to probe: no $ControlType elements and no -At points" }

$bad = 0
foreach ($pt in $points) {
  $code = [SteddingHit]::HitTest($hwnd, $origin.X + $pt.X, $origin.Y + $pt.Y)
  $label = if ($names.ContainsKey($code)) { $names[$code] } elseif ($code -eq [int]::MinValue) { "no answer" } else { "code $code" }
  if ($code -ne 1 -and $code -ne -1) { $bad++ }
  "{0,-16} {1,-40} at ({2},{3})" -f $label, ("'" + $pt.Name + "'"), $pt.X, $pt.Y
}
"{0} point(s) probed, {1} not client area" -f $points.Count, $bad
exit $bad
