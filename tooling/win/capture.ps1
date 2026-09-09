# A Windows capture that needs neither focus nor input (docs/HANDOFF.md, trap 36):
# the window is rendered with PrintWindow, which works while another window is in
# front, so nothing is brought to the foreground and no input is injected while
# someone is at the machine. State comes from launch flags and, where a click is
# unavoidable, from a WM_LBUTTONDOWN/UP pair posted to the window's own queue in
# client coordinates -- never SendInput.
#
# Dot-source this from Windows PowerShell 5.1, then:
#
#   $env:STEDDING_WIN_EXE = "C:\path\to\src\out\win\chrome.exe"   # or -Exe below
#   . tooling\win\capture.ps1
#   $id = Start-Browser -Url "https://example.com"                 # 1400x880 DIP, scale 1
#   Shot-Window "base"                                             # <shots>\base.png
#   Post-Click -X 34 -Y 20                                         # the sidebar's toggle
#   Shot-Window "rail"
#   Scan -Name "rail" -Y 21 -From 0 -To 1399                       # colour runs on a row
#   Zoom -Name "rail" -X 0 -Y 0 -W 70 -H 260 -Factor 4             # a blow-up to look at
#   Stop-Browser
#
# Captures are the client area at scale 1, so they map 1:1 onto tooling/probes/
# coordinates. Chromium stops drawing a window it considers fully occluded, so the
# launch disables occlusion tracking; without that a capture behind the operator's own
# window is stale or black. The window to render is the largest Chrome_WidgetWin_1 of
# the process: bubbles and toasts have the same class, and a console launched with
# redirected output is what MainWindowHandle returns.

param(
  [string]$Exe = $env:STEDDING_WIN_EXE,
  [string]$Profile = $(if ($env:STEDDING_WIN_PROFILE) { $env:STEDDING_WIN_PROFILE } else { Join-Path $env:TEMP "stedding-capture-profile" }),
  [string]$Shots = $(if ($env:STEDDING_WIN_SHOTS) { $env:STEDDING_WIN_SHOTS } else { Join-Path $env:TEMP "stedding-shots" })
)

Add-Type -AssemblyName System.Drawing
Add-Type @"
using System;
using System.Runtime.InteropServices;
public static class SteddingWin {
  [StructLayout(LayoutKind.Sequential)] public struct RECT { public int L, T, R, B; }
  [StructLayout(LayoutKind.Sequential)] public struct POINT { public int X, Y; }
  [DllImport("user32.dll")] public static extern bool SetProcessDPIAware();
  [DllImport("user32.dll")] public static extern bool PrintWindow(IntPtr h, IntPtr hdc, uint flags);
  [DllImport("user32.dll")] public static extern bool GetWindowRect(IntPtr h, out RECT r);
  [DllImport("user32.dll")] public static extern bool GetClientRect(IntPtr h, out RECT r);
  [DllImport("user32.dll")] public static extern bool ClientToScreen(IntPtr h, ref POINT p);
  [DllImport("user32.dll")] public static extern bool IsWindowVisible(IntPtr h);
  [DllImport("user32.dll")] public static extern bool PostMessage(IntPtr h, uint msg, IntPtr w, IntPtr l);
  public delegate bool EnumProc(IntPtr h, IntPtr l);
  [DllImport("user32.dll")] public static extern bool EnumWindows(EnumProc cb, IntPtr l);
  [DllImport("user32.dll")] public static extern int GetClassName(IntPtr h, System.Text.StringBuilder s, int n);
  [DllImport("user32.dll")] public static extern uint GetWindowThreadProcessId(IntPtr h, out uint pid);
  public const uint PW_RENDERFULLCONTENT = 2;
  public const uint WM_MOUSEMOVE = 0x0200, WM_LBUTTONDOWN = 0x0201, WM_LBUTTONUP = 0x0202, MK_LBUTTON = 1;
  public static System.Collections.Generic.List<IntPtr> BrowserWindows(uint pid) {
    var found = new System.Collections.Generic.List<IntPtr>();
    EnumWindows((h, l) => {
      uint p; GetWindowThreadProcessId(h, out p);
      if (p != pid || !IsWindowVisible(h)) return true;
      var sb = new System.Text.StringBuilder(64); GetClassName(h, sb, 64);
      if (sb.ToString() == "Chrome_WidgetWin_1") found.Add(h);
      return true;
    }, IntPtr.Zero);
    return found;
  }
}
"@
[void][SteddingWin]::SetProcessDPIAware()

$script:Exe = $Exe
$script:Profile = $Profile
$script:Shots = $Shots
$script:Hwnd = [IntPtr]::Zero
$script:BrowserPid = 0
New-Item -ItemType Directory -Force $script:Shots | Out-Null

function Find-BrowserWindow {
  param([int]$ProcessId)
  $best = [IntPtr]::Zero
  $area = 0
  foreach ($h in [SteddingWin]::BrowserWindows([uint32]$ProcessId)) {
    $r = New-Object SteddingWin+RECT
    [void][SteddingWin]::GetWindowRect($h, [ref]$r)
    $a = ($r.R - $r.L) * ($r.B - $r.T)
    if ($a -gt $area) { $area = $a; $best = $h }
  }
  return $best
}

# Only the browser launched here: never every chrome.exe on the machine.
function Stop-Browser {
  if ($script:BrowserPid -ne 0) {
    Stop-Process -Id $script:BrowserPid -Force -ErrorAction SilentlyContinue
    Start-Sleep -Milliseconds 800
    $script:BrowserPid = 0
    $script:Hwnd = [IntPtr]::Zero
  }
}

function Start-Browser {
  param([string]$Url = "about:blank", [string[]]$Extra = @(), [double]$Scale = 1, [int]$W = 1400, [int]$H = 880)
  if (-not $script:Exe) { throw "set STEDDING_WIN_EXE or pass -Exe: the built chrome.exe" }
  Stop-Browser
  $b = 8  # Windows' invisible resize border; cancelled so the visible frame is W x H
  $list = @("--user-data-dir=$($script:Profile)", "--no-first-run",
    "--no-default-browser-check", "--force-device-scale-factor=$Scale",
    "--disable-features=CalculateNativeWinOcclusion",
    "--disable-backgrounding-occluded-windows",
    "--window-position=-$b,0", "--window-size=$($W + 2 * $b),$($H + $b)") + $Extra + @($Url)
  $p = Start-Process -FilePath $script:Exe -PassThru -ArgumentList $list
  $script:BrowserPid = $p.Id
  for ($i = 0; $i -lt 40; $i++) {
    Start-Sleep -Milliseconds 500
    if ($p.HasExited) { throw "browser exited early, code $($p.ExitCode)" }
    $h = Find-BrowserWindow -ProcessId $p.Id
    if ($h -ne [IntPtr]::Zero) { $script:Hwnd = $h; break }
  }
  if ($script:Hwnd -eq [IntPtr]::Zero) { throw "no browser window after 20 s" }
  Start-Sleep -Seconds 4
  return $p.Id
}

# The client area, not the DWM frame: the frame bounds start one pixel into the
# invisible border, and that column leaks into every measurement otherwise.
function Shot-Window {
  param([string]$Name)
  $wr = New-Object SteddingWin+RECT
  [void][SteddingWin]::GetWindowRect($script:Hwnd, [ref]$wr)
  $bmp = New-Object Drawing.Bitmap ($wr.R - $wr.L), ($wr.B - $wr.T)
  $g = [Drawing.Graphics]::FromImage($bmp)
  $hdc = $g.GetHdc()
  $ok = [SteddingWin]::PrintWindow($script:Hwnd, $hdc, [SteddingWin]::PW_RENDERFULLCONTENT)
  $g.ReleaseHdc($hdc)
  $g.Dispose()
  $origin = New-Object SteddingWin+POINT
  [void][SteddingWin]::ClientToScreen($script:Hwnd, [ref]$origin)
  $cr = New-Object SteddingWin+RECT
  [void][SteddingWin]::GetClientRect($script:Hwnd, [ref]$cr)
  $rect = New-Object Drawing.Rectangle -ArgumentList @(($origin.X - $wr.L), ($origin.Y - $wr.T), ($cr.R - $cr.L), ($cr.B - $cr.T))
  $crop = $bmp.Clone($rect, $bmp.PixelFormat)
  $out = Join-Path $script:Shots "$Name.png"
  $crop.Save($out)
  $crop.Dispose()
  $bmp.Dispose()
  return "$out printed=$ok client=$($rect.Width)x$($rect.Height)"
}

# A click on the window's own queue, in capture (client) coordinates.
function Post-Click {
  param([int]$X, [int]$Y)
  $l = [IntPtr](($Y -shl 16) -bor ($X -band 0xFFFF))
  [void][SteddingWin]::PostMessage($script:Hwnd, [SteddingWin]::WM_MOUSEMOVE, [IntPtr]::Zero, $l)
  Start-Sleep -Milliseconds 120
  [void][SteddingWin]::PostMessage($script:Hwnd, [SteddingWin]::WM_LBUTTONDOWN, [IntPtr][SteddingWin]::MK_LBUTTON, $l)
  Start-Sleep -Milliseconds 80
  [void][SteddingWin]::PostMessage($script:Hwnd, [SteddingWin]::WM_LBUTTONUP, [IntPtr]::Zero, $l)
  Start-Sleep -Milliseconds 900
}

# Colour runs along one row (Y) or one column (X) of a capture, for measuring.
function Scan {
  param([string]$Name, [int]$Y = -1, [int]$X = -1, [int]$From = 0, [int]$To = 100)
  $bmp = New-Object Drawing.Bitmap (Join-Path $script:Shots "$Name.png")
  $limit = if ($Y -ge 0) { $bmp.Width - 1 } else { $bmp.Height - 1 }
  if ($To -gt $limit) { $To = $limit }
  $prev = ""
  $out = @()
  foreach ($i in $From..$To) {
    if ($Y -ge 0) { $c = $bmp.GetPixel($i, $Y); $k = "x=$i" } else { $c = $bmp.GetPixel($X, $i); $k = "y=$i" }
    $s = "{0:X2}{1:X2}{2:X2}" -f $c.R, $c.G, $c.B
    if ($s -ne $prev) { $out += "$k $s"; $prev = $s }
  }
  $bmp.Dispose()
  return ($out -join " | ")
}

# A nearest-neighbour blow-up of a region, to look at.
function Zoom {
  param([string]$Name, [int]$X, [int]$Y, [int]$W, [int]$H, [int]$Factor = 4, [string]$Out = "")
  $src = New-Object Drawing.Bitmap (Join-Path $script:Shots "$Name.png")
  $dst = New-Object Drawing.Bitmap ($W * $Factor), ($H * $Factor)
  $g = [Drawing.Graphics]::FromImage($dst)
  $g.InterpolationMode = [Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
  $g.PixelOffsetMode = [Drawing.Drawing2D.PixelOffsetMode]::Half
  $g.DrawImage($src, (New-Object Drawing.Rectangle -ArgumentList @(0, 0, ($W * $Factor), ($H * $Factor))), (New-Object Drawing.Rectangle -ArgumentList @($X, $Y, $W, $H)), [Drawing.GraphicsUnit]::Pixel)
  $g.Dispose()
  if ($Out -eq "") { $Out = "$Name-zoom" }
  $path = Join-Path $script:Shots "$Out.png"
  $dst.Save($path)
  $dst.Dispose()
  $src.Dispose()
  return $path
}
