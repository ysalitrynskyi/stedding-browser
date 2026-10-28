# The Windows pictures: docs/images/win-wide.png (the open sidebar) and win-rail.png (the
# rail), light and dark. Each is tooling\win\capture.ps1: PrintWindow, no focus, no input,
# and the pointer parked off the window first (docs/HANDOFF.md, trap 136).
#
# Run it in the signed-in session, not over SSH: what ssh starts runs in session 0, where
# no browser window appears (trap 67). From a remote shell, a one-off scheduled task with
# an interactive token does it; tooling/readme/README.md, "The Windows pictures", has the
# steps. Windows PowerShell 5.1:
#
#   powershell -NoProfile -ExecutionPolicy Bypass -File tooling\readme\win-stills.ps1 `
#     -Exe <src>\out\win-release\chrome.exe -Profiles <seeded> -Out <folder>
#
# -Profiles holds four profiles written by `media.py seed` (the demo fixture):
# wide-light, wide-dark (`--scheme light|dark`) and rail-light, rail-dark (`--collapsed`).
# The capture is the window's full rectangle at scale 1, 1400x880; on screen Windows 11
# rounds its corners, so tooling/readme/round-corners.py clears them afterwards.
param(
  [string]$Exe = $env:STEDDING_WIN_EXE,
  [Parameter(Mandatory = $true)][string]$Profiles,
  [Parameter(Mandatory = $true)][string]$Out
)
$ErrorActionPreference = 'Stop'
# Task Scheduler starts a task below normal priority, and Chromium then holds back (trap 67).
(Get-Process -Id $PID).PriorityClass = 'Normal'
New-Item -ItemType Directory -Force $Out | Out-Null
$log = Join-Path $Out 'run.log'
"start $(Get-Date -Format s)" | Out-File $log
try {
  . (Join-Path $PSScriptRoot '..\win\capture.ps1') -Exe $Exe -Profile (Join-Path $Out 'p') -Shots $Out
  # The stills' Work pages (tooling/readme/common.sh, WORK_URLS) without the sample app,
  # which runs on the Mac. The first is the page on screen.
  $urls = @('https://github.com/trending/swift?since=weekly', 'https://developer.mozilla.org/en-US/',
    'https://duckduckgo.com/', 'https://news.ycombinator.com/', 'https://developer.mozilla.org/en-US/docs/Web/CSS',
    'https://docs.python.org/3/tutorial/', 'https://www.djangoproject.com/', 'https://pypi.org/',
    'https://github.com/ysalitrynskyi/stedding-browser')
  $extra = @('--enable-features=SteddingArcStyleWindow:pin_tabs/4/folder_tabs/6', '--disable-search-engine-choice-screen')
  foreach ($name in @('wide-light', 'wide-dark', 'rail-light', 'rail-dark')) {
    $script:Profile = Join-Path $Profiles $name
    # Start-Browser puts -Url after -Extra: so the pages go in order, the first on screen.
    [void](Start-Browser -Url $urls[-1] -Extra ($extra + $urls[0..($urls.Length - 2)]))
    Start-Sleep -Seconds 14
    "$name $(Shot-Window $name)" | Out-File $log -Append
    Stop-Browser
  }
} catch {
  "error: $($_.Exception.Message)" | Out-File $log -Append
} finally {
  Stop-Browser
  "end $(Get-Date -Format s)" | Out-File $log -Append
}
