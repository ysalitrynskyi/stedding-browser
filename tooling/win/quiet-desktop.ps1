<#
Before driven checks: minimises File Explorer and Task Manager windows in this session, so they
cannot hold the foreground while a script drives the window under test. Nothing is closed. Lists
every visible top-level window, and what it minimised, in -Log (default
%TEMP%\stedding-gate\quiet-desktop.txt). Run it in the operator's session (run-in-session.ps1).
#>
param([string]$Log = (Join-Path $env:TEMP 'stedding-gate\quiet-desktop.txt'))
New-Item -ItemType Directory -Force (Split-Path $Log) | Out-Null
Add-Type @"
using System; using System.Runtime.InteropServices; using System.Text;
public static class QuietDesktop {
  public delegate bool EnumProc(IntPtr h, IntPtr l);
  [DllImport("user32.dll")] public static extern bool EnumWindows(EnumProc p, IntPtr l);
  [DllImport("user32.dll")] public static extern bool IsWindowVisible(IntPtr h);
  [DllImport("user32.dll")] public static extern int GetWindowText(IntPtr h, StringBuilder s, int n);
  [DllImport("user32.dll")] public static extern int GetClassName(IntPtr h, StringBuilder s, int n);
  [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr h, int c);
  [DllImport("user32.dll")] public static extern bool IsIconic(IntPtr h);
}
"@
"$(Get-Date -Format HH:mm:ss)" | Set-Content $Log
[QuietDesktop]::EnumWindows({ param($h, $l)
    if ([QuietDesktop]::IsWindowVisible($h)) {
      $t = New-Object Text.StringBuilder 256; [void][QuietDesktop]::GetWindowText($h, $t, 256)
      $c = New-Object Text.StringBuilder 256; [void][QuietDesktop]::GetClassName($h, $c, 256)
      if ($t.Length -gt 0) {
        $line = "$h [$c] '$t' iconic=$([QuietDesktop]::IsIconic($h))"
        if ("$c" -eq 'CabinetWClass' -or "$c" -eq 'TaskManagerWindow') {
          [void][QuietDesktop]::ShowWindow($h, 6)  # SW_MINIMIZE
          $line += ' -> minimised'
        }
        $line | Add-Content $Log
      }
    }
    return $true
  }, [IntPtr]::Zero) | Out-Null
