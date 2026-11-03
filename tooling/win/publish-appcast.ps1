<#
Offers this release's Windows installer to installed copies of Stedding: signs it with the Windows
update key and puts it first in updates/appcast-windows.xml, signed too (ADR 0023, ADR 0026,
docs/features/updates.md Up18). The Mac's counterpart is tooling/publish-appcast.

Usage (PowerShell, after tooling/publish-release and once the release was tried the way a user
gets it, trap 47):
  tooling\win\publish-appcast.ps1 -Check        what would be offered; changes nothing
  tooling\win\publish-appcast.ps1               sign, write the feed, sign it, commit it
  tooling\win\publish-appcast.ps1 -Push         the same, then push the commit to main
  tooling\win\publish-appcast.ps1 -Important "<reason>"
                                                an important update (updates Up23, ADR 0031):
                                                shown strongly with its reason, never forced
  tooling\win\publish-appcast.ps1 -Feed <file> -Url <installer url>
                                                the update test's local feed (docs/HANDOFF.md,
                                                "The updater"): writes <file> only

A pushed feed is the moment every installed Stedding with automatic updates on starts
downloading the installer, within a day: pushing is the release's own step and needs the
operator's yes for that release, like publishing it.

What it refuses:
  * an installer that is not the release's: dist\Stedding-<VERSION>-win-x64.exe must match the
    .sha256 the GitHub release carries (not checked for a local feed);
  * an installer whose version resource is not VERSION's Windows version (S-72): an installer
    of Chromium's number could not update a copy that runs;
  * a signature that does not verify against the public key the builds carry;
  * a feed with uncommitted changes of its own (the commit holds the feed alone), and a push
    from a branch other than main (the feed is read from main), as tooling/publish-appcast does.
#>
param(
  [switch]$Check,
  [switch]$Push,
  [string]$Feed = '',
  [string]$Url = '',
  [string]$Installer = '',
  [string]$Important = '',
  [string]$Repo = (Split-Path -Parent (Split-Path -Parent $PSScriptRoot))
)
$ErrorActionPreference = 'Stop'
$version = (Get-Content (Join-Path $Repo 'VERSION') -Raw).Trim()
if ($version -notmatch '^(\d+)\.(\d+)\.(\d+)(-beta\.(\d+))?$') { throw "VERSION '$version' is not a Stedding version" }
$beta = if ($Matches[5]) { [int]$Matches[5] } else { 999 }
$product = 100 * [int]$Matches[1] + [int]$Matches[2]
$patch = [int]$Matches[3]
$pin = (Get-Content (Join-Path $Repo 'tooling\chromium-version') | Where-Object { $_ -match '^CHROMIUM_TAG=' }) -replace '^CHROMIUM_TAG=', ''
$milestone = ($pin.Trim() -split '\.')[0]
$windowsVersion = "$milestone.$product.$patch.$beta"

if (-not $Installer) { $Installer = Join-Path $Repo "dist\Stedding-$version-win-x64.exe" }
if (-not (Test-Path $Installer)) { throw "no installer at $Installer (tooling\win\package-installer.ps1)" }
$local = [bool]$Feed
if (-not $Feed) { $Feed = Join-Path $Repo 'updates\appcast-windows.xml' }
# The repository comes from the remote, as in tooling/publish-release: a hardcoded owner would
# publish to somebody else's project from a fork.
$github = ([string](git -C $Repo remote get-url origin)).Trim() -replace '^git@github\.com:', 'https://github.com/'
$github = $github -replace '\.git$', '' -replace '^https://github\.com/', ''
if ($github -notmatch '^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+$') { throw "cannot read owner/name from the origin remote of $Repo" }

function Report([string]$what, [string]$value) { '  {0,-16} {1}' -f $what, $value }

$fileVersion = (Get-Item $Installer).VersionInfo.FileVersion
Report 'version' "$version (Windows $windowsVersion)"
Report 'installer' "$Installer ($([math]::Round((Get-Item $Installer).Length / 1MB, 1)) MB), file version $fileVersion"
if ($fileVersion -ne $windowsVersion) { throw "the installer's file version is $fileVersion, not ${windowsVersion}: built before S-72, or for another VERSION" }

$hash = (Get-FileHash $Installer -Algorithm SHA256).Hash.ToLower()
if (-not $local) {
  $tag = "v$version"
  $releaseSha = (& gh release download $tag --repo $github --pattern "Stedding-$version-win-x64.exe.sha256" --output - 2>$null)
  if (-not $releaseSha) { throw "the release $tag carries no Windows installer checksum: publish it first (tooling/publish-release)" }
  if (($releaseSha -split '\s+')[0].ToLower() -ne $hash) { throw "dist's installer is not the one the release $tag carries" }
  Report 'release' "$tag on $github carries this installer"
  if (-not $Url) { $Url = "https://github.com/$github/releases/download/$tag/Stedding-$version-win-x64.exe" }
  # The installer as installed copies fetch it, from that address, is this one: what the feed
  # is about to offer is checked as users will get it.
  $probe = Join-Path ([IO.Path]::GetTempPath()) "stedding-release-probe-$version.exe"
  Remove-Item $probe -ErrorAction SilentlyContinue
  $took = Measure-Command { & curl.exe -sSfL --retry 3 -o $probe $Url 2>$null }
  $probeHash = if (Test-Path $probe) { (Get-FileHash $probe -Algorithm SHA256).Hash.ToLower() } else { '' }
  Remove-Item $probe -ErrorAction SilentlyContinue
  if ($probeHash -ne $hash) { throw "$Url does not give this installer (curl exit $LASTEXITCODE)" }
  Report 'download' "the release's address gives this installer ($([int]$took.TotalSeconds) s)"
}
if (-not $Url) { throw '-Url is needed for a local feed' }

$key = Join-Path $PSScriptRoot 'update-key.ps1'
$publicKey = (& powershell -NoProfile -ExecutionPolicy Bypass -File $key -PublicKey).Trim()
# The key the builds carry: update_feed.h in the patch series, or, before the change is folded
# into a patch, in the checkout (STEDDING_CHROMIUM_SRC).
$carried = @(Get-ChildItem (Join-Path $Repo 'patches') -Filter *.patch -ErrorAction SilentlyContinue |
  Select-String -Pattern 'kWindowsUpdatePublicKey\[\] *=' -Context 0, 1 |
  ForEach-Object { $_.Line; $_.Context.PostContext })
if (-not $carried -and $env:STEDDING_CHROMIUM_SRC) {
  $carried = @(Get-Content (Join-Path $env:STEDDING_CHROMIUM_SRC 'chrome\browser\ui\stedding\update_feed.h') -ErrorAction SilentlyContinue)
}
if (-not $carried) { throw 'no update_feed.h in patches\ or in the checkout (STEDDING_CHROMIUM_SRC): which key do the builds carry?' }
if (-not (($carried -join "`n").Contains($publicKey))) { throw "the builds carry another public key than $publicKey (update_feed.h)" }
Report 'key' $publicKey
if (-not $local) {
  if (git -C $Repo status --porcelain -- updates/appcast-windows.xml) {
    throw 'updates\appcast-windows.xml has uncommitted changes: commit or restore them first'
  }
  $branch = (git -C $Repo rev-parse --abbrev-ref HEAD)
  if ($Push -and $branch -ne 'main') { throw "on $branch; the feed is read from main" }
  Report 'feed' 'updates\appcast-windows.xml, clean'
}
if ($Check) { 'ready to offer'; exit 0 }

$signature = (& powershell -NoProfile -ExecutionPolicy Bypass -File $key -Sign $Installer).Trim()
& powershell -NoProfile -ExecutionPolicy Bypass -File $key -Verify $Installer -Signature $signature
if ($LASTEXITCODE -ne 0) { throw 'the installer signature does not verify' }
Report 'signed' 'installer'

$python = (Get-Command python -ErrorAction Stop).Source
$date = [DateTime]::UtcNow.ToString('ddd, dd MMM yyyy HH:mm:ss +0000', [Globalization.CultureInfo]::InvariantCulture)
$length = (Get-Item $Installer).Length
$importantArgs = @()
if ($Important) { $importantArgs = @('--important', $Important) }
& $python -I (Join-Path $Repo 'tooling\appcast.py') write --platform windows --feed $Feed --repo $github `
  --version $version --bundle-version $windowsVersion --minimum-system 10.0 --length $length `
  --signature $signature --date $date --url $Url @importantArgs
if ($LASTEXITCODE -ne 0) { throw 'appcast.py write failed' }
$feedSignature = (& powershell -NoProfile -ExecutionPolicy Bypass -File $key -Sign $Feed).Trim()
& $python -I (Join-Path $Repo 'tooling\appcast.py') attach-signature --feed $Feed --signature $feedSignature
if ($LASTEXITCODE -ne 0) { throw 'appcast.py attach-signature failed' }
Report 'feed' "$Feed, signed"
if ($local) { exit 0 }

Push-Location $Repo
try {
  git add -- updates/appcast-windows.xml
  git commit -q -m "release: offer $version to installed copies on Windows" -- updates/appcast-windows.xml
  if ($LASTEXITCODE -ne 0) { throw 'git commit failed' }
  Report 'commit' (git log -1 --format=%h)
  if ($Push) {
    git push origin HEAD:main
    if ($LASTEXITCODE -ne 0) { throw 'git push failed' }
    Report 'pushed' 'main'
  }
} finally { Pop-Location }
