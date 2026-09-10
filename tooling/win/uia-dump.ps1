# Every view of the running Stedding window, with its name and bounds, through UI
# Automation: no focus, no input, no code change. The answer to "where did the
# layout put it" that trap 37 in docs/HANDOFF.md used to need a temporary dump and a
# build for (round 9: the rail's bottom row was 425 DIP tall, which no capture
# could explain).
#
# Windows PowerShell 5.1:
#
#   $env:STEDDING_WIN_EXE = "C:\path\to\src\out\win\chrome.exe"   # or -Exe
#   tooling\win\uia-dump.ps1                       # everything
#   tooling\win\uia-dump.ps1 -MaxX 70              # the rail: elements whose left edge is under 70
#   tooling\win\uia-dump.ps1 -NameLike "*Space*"   # by name
#
# Coordinates are client coordinates of the browser window, the same frame the
# captures and Post-Click use. Only views with an accessible role are listed (a
# plain container is not), so a missing row means an invisible view, not a bug.
param(
  [string]$Exe = $env:STEDDING_WIN_EXE,
  [int]$MaxX = [int]::MaxValue,
  [string]$NameLike = ""
)
$ErrorActionPreference = "Stop"
if (-not $Exe) { throw "set STEDDING_WIN_EXE to the browser to inspect, or pass -Exe" }

Add-Type @"
using System;
using System.Runtime.InteropServices;
public static class SteddingUia {
  [StructLayout(LayoutKind.Sequential)] public struct RECT { public int L, T, R, B; }
  [StructLayout(LayoutKind.Sequential)] public struct POINT { public int X, Y; }
  [DllImport("user32.dll")] public static extern bool GetWindowRect(IntPtr h, out RECT r);
  [DllImport("user32.dll")] public static extern bool IsWindowVisible(IntPtr h);
  [DllImport("user32.dll")] public static extern bool ClientToScreen(IntPtr h, ref POINT p);
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
}
"@

$hwnd = [IntPtr]::Zero
foreach ($p in (Get-Process chrome -ErrorAction SilentlyContinue | Where-Object { $_.Path -eq $Exe })) {
  $h = [SteddingUia]::MainWindow([uint32]$p.Id)
  if ($h -ne [IntPtr]::Zero) { $hwnd = $h; break }
}
if ($hwnd -eq [IntPtr]::Zero) { throw "no window of a running $Exe" }

Add-Type -AssemblyName UIAutomationClient
Add-Type -AssemblyName UIAutomationTypes
$origin = New-Object SteddingUia+POINT
[void][SteddingUia]::ClientToScreen($hwnd, [ref]$origin)
$root = [System.Windows.Automation.AutomationElement]::FromHandle($hwnd)
$all = $root.FindAll([System.Windows.Automation.TreeScope]::Descendants, [System.Windows.Automation.Condition]::TrueCondition)
foreach ($e in $all) {
  try {
    $r = $e.Current.BoundingRectangle
    if ([double]::IsInfinity($r.X) -or [double]::IsNaN($r.X)) { continue }
    $x = [int]($r.X - $origin.X)
    $y = [int]($r.Y - $origin.Y)
    if ($x -ge $MaxX) { continue }
    $name = $e.Current.Name
    if ($NameLike -and ($name -notlike $NameLike)) { continue }
    "{0,-14} {1,-40} x={2,-5} y={3,-5} {4}x{5}" -f $e.Current.ControlType.ProgrammaticName.Replace("ControlType.", ""), ("'" + $name + "'"), $x, $y, [int]$r.Width, [int]$r.Height
  } catch { }
}
