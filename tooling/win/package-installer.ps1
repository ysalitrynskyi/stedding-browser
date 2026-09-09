<#
Package the Windows installer for a release: the mini_installer.exe a win-release
build produced, named for the product version and platform beside its sha256, in
dist/ -- the Windows half of what tooling/package-dmg does on the Mac (ADR 0018).

Usage (PowerShell, from anywhere):
  tooling\win\package-installer.ps1 [-Config win-release] [-Src <checkout src>]

The checksum file is "<sha256>  <name>", the shape shasum writes and
tooling/publish-release reads; paste the number into docs/release-notes/v<VERSION>.md
under Windows, or publish-release refuses the notes.
#>
param(
  [string]$Config = "win-release",
  [string]$Src = $env:STEDDING_CHROMIUM_SRC
)
$ErrorActionPreference = "Stop"
$root = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
if (-not $Src) { throw "set STEDDING_CHROMIUM_SRC to the checkout's src directory, or pass -Src" }
$version = (Get-Content (Join-Path $root "VERSION") -Raw).Trim()
$installer = Join-Path $Src "out\$Config\mini_installer.exe"
if (-not (Test-Path $installer)) { throw "no mini_installer.exe in out\$Config; run tooling\win\build.ps1 -Config $Config" }

$dist = Join-Path $root "dist"
New-Item -ItemType Directory -Force $dist | Out-Null
$name = "Stedding-$version-win-x64.exe"
$target = Join-Path $dist $name
Copy-Item $installer $target -Force
$hash = (Get-FileHash $target -Algorithm SHA256).Hash.ToLower()
[IO.File]::WriteAllText("$target.sha256", "$hash  $name`n", (New-Object Text.UTF8Encoding $false))

$mb = [math]::Round((Get-Item $target).Length / 1MB, 1)
Write-Host "$name  ($mb MB)"
Write-Host "sha256 $hash"
Get-ChildItem $dist -File | Where-Object { $_.Name -ne $name -and $_.Name -ne "$name.sha256" } | ForEach-Object {
  Write-Warning "also in dist/: $($_.Name) -- publish-release takes the image named for this version"
}
