# The DevTools protocol over its websocket, against a browser launched with
# --remote-debugging-port: JavaScript in a page -- a chrome:// page, a WebUI dialog
# such as the welcome flow -- and a screenshot of the page's viewport. No focus, no
# input (docs/HANDOFF.md, trap 36); the HTTP endpoint alone can only open a page.
#
# Windows PowerShell 5.1:
#
#   tooling\win\cdp.ps1 -List
#   tooling\win\cdp.ps1 -Target "stedding-welcome" -Eval "document.querySelector('h1').textContent"
#   tooling\win\cdp.ps1 -Target "settings/stedding" -Eval "<js that scrolls>" -Screenshot C:\shots\block.png
#
# -Target is a substring of the page's URL. -Eval is evaluated with returnByValue
# and awaitPromise, so an expression's value (or a promise's) comes back as JSON; an
# exception comes back as EXCEPTION. A WebUI's buttons can be pressed by name:
#
#   (function(){const b=Array.from(document.querySelectorAll('button')).find(x=>x.textContent.trim()==='Next');b.click();return 'ok';})()
#
# The screenshot is the page's viewport (Page.captureScreenshot); a settings page
# scrolls inside its own container, so scroll it with -Eval first -- in one call,
# the evaluation runs before the screenshot.
param(
  [string]$Target = "",
  [string]$Eval = "",
  [string]$Screenshot = "",
  [switch]$List,
  [int]$Port = 9222
)
$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.Drawing
$targets = Invoke-RestMethod -Uri "http://127.0.0.1:$Port/json/list"
if ($List) { $targets | ForEach-Object { "$($_.type) $($_.url)" }; exit 0 }
$t = $targets | Where-Object { $_.url -like "*$Target*" -and $_.webSocketDebuggerUrl } | Select-Object -First 1
if (-not $t) { throw "no page target matching '$Target' on port $Port" }

function Send-Cdp([System.Net.WebSockets.ClientWebSocket]$ws, [string]$json) {
  $bytes = [Text.Encoding]::UTF8.GetBytes($json)
  $seg = New-Object ArraySegment[byte] -ArgumentList @(,$bytes)
  $ws.SendAsync($seg, [System.Net.WebSockets.WebSocketMessageType]::Text, $true, [Threading.CancellationToken]::None).Wait()
}
function Receive-Cdp([System.Net.WebSockets.ClientWebSocket]$ws, [int]$Id) {
  $buf = New-Object byte[] (4 * 1024 * 1024)
  for ($n = 0; $n -lt 50; $n++) {
    $ms = New-Object IO.MemoryStream
    do {
      $seg = New-Object ArraySegment[byte] -ArgumentList @(,$buf)
      $r = $ws.ReceiveAsync($seg, [Threading.CancellationToken]::None).Result
      $ms.Write($buf, 0, $r.Count)
    } while (-not $r.EndOfMessage)
    $obj = [Text.Encoding]::UTF8.GetString($ms.ToArray()) | ConvertFrom-Json
    if ($obj.id -eq $Id) { return $obj }
  }
  throw "no reply for message $Id"
}

$ws = New-Object System.Net.WebSockets.ClientWebSocket
$ws.ConnectAsync([Uri]$t.webSocketDebuggerUrl, [Threading.CancellationToken]::None).Wait()
try {
  if ($Eval) {
    Send-Cdp $ws (@{ id = 1; method = "Runtime.evaluate"; params = @{ expression = $Eval; returnByValue = $true; awaitPromise = $true } } | ConvertTo-Json -Compress -Depth 5)
    $r = Receive-Cdp $ws 1
    if ($r.result.exceptionDetails) { "EXCEPTION: " + ($r.result.exceptionDetails | ConvertTo-Json -Compress -Depth 5) }
    else { $v = $r.result.result.value; if ($null -eq $v) { "(" + $r.result.result.type + ")" } else { $v | ConvertTo-Json -Compress -Depth 5 } }
  }
  if ($Screenshot) {
    Send-Cdp $ws (@{ id = 2; method = "Page.captureScreenshot"; params = @{ format = "png" } } | ConvertTo-Json -Compress -Depth 5)
    $r = Receive-Cdp $ws 2
    if ($r.error) { throw ("screenshot: " + ($r.error | ConvertTo-Json -Compress)) }
    [IO.File]::WriteAllBytes($Screenshot, [Convert]::FromBase64String($r.result.data))
    $img = New-Object Drawing.Bitmap $Screenshot
    "saved $Screenshot $($img.Width)x$($img.Height)"
    $img.Dispose()
  }
} finally {
  $ws.Dispose()
}
