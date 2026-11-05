# Privacy principles and defaults

Privacy in Stedding is a set of shipped defaults. This page states the
principles, then what the browser does: what is on, what is a choice, and what
is still Chromium's. How Google services in the Chromium base are removed or
replaced is in [ARCHITECTURE.md](ARCHITECTURE.md#de-googling-stance). This page
is the product contract that work must satisfy.

A network connection the shipping browser makes that is not listed here is a
bug. Report it through [SECURITY.md](../SECURITY.md). An endpoint that is not
on this list is a release blocker
([ROADMAP.md](ROADMAP.md#the-quality-bar), "Network conduct").

This is how the browser is built to behave, as a best effort. A build can have
bugs. Stedding comes as is, without warranty, under its BSD-3-Clause licence
([LICENSE](../LICENSE)). Sites you visit, extensions you install, the search
engine you pick, and services such as GitHub, Google's update servers or a
sync tool you choose are run by others, under their own terms. Using them is
your choice.

## Principles

1. **No telemetry by default.** The browser sends no usage metrics, no
   analytics, no experiment data and no unique identifier for that purpose.
   There is no "anonymized" or "aggregated" exception.
2. **Every network connection is listed.** The tables below name each host the
   browser talks to on its own, and why. The aim is a short list: update
   checks, and the user's own browsing. Some rows are still Google's, and are
   marked as such.
3. **Defaults are the product.** Protections ship on. Conveniences that cost
   privacy ship off.
4. **Honesty over purity.** Where a real trade-off exists (Safe Browsing, the
   extension store, the update check), the trade-off is written here and the
   default is the one that can be defended.
5. **Verifiable.** The browser, UI included, is open source (BSD-3-Clause).
   Claims here can be checked against the code and on the wire.

## Network connections the browser makes

### By default

| Connection | To | Contains | Why |
|---|---|---|---|
| Browser update check | GitHub. The feed is on `raw.githubusercontent.com`. A new version's image (the Mac DMG, the Windows installer) is fetched from `github.com`, which redirects to `release-assets.githubusercontent.com`. At launch, ten seconds in, when the last check is more than an hour old, and every six hours while the browser runs. Off in Settings › Stedding › Updates. Detail under "The update check". | A plain HTTPS GET. On the Mac, Sparkle's user agent, which names the browser and its version. On Windows, the browser's own network stack, cache disabled, Chromium's reduced user agent (Chrome's major version and the Windows platform). No cookies, no install id, no machine id. | Security updates for a Chromium fork. |
| Thank-you pages | stedding.dev: `/thanks/` when the welcome flow ends, once per installation; `/thanks/updated/#v`*version* on the first launch of each later version. The second is turned off with "Show a thank-you page after an update". | A plain page request. The version is in the fragment, which the browser does not send. The pages are not on the update path and load nothing from another host ([ADR 0022](decisions/0022-sparkle-updates-the-mac.md)). | The project's thanks, and a link to sponsor it. |
| Security component updates | Google's component updater, `update.googleapis.com`, with downloads from `edgedl.me.gvt1.com`, as in stock Chromium. One component is not registered: Google's Subresource Filter Rules (`features/blocker.md` Bk4). | Component name and version. | Security data Chromium ships as components, certificate revocation among it. Which components to mirror or drop is decided before 1.0 (`BACKLOG.md` S-241). |
| Safe Browsing list updates | `safebrowsing.googleapis.com`. The request is made and refused: these builds carry no API key, so no page is checked. See "Safe Browsing". | The list-update request. Google does not receive your browsing history from it. The request does carry your IP. | The setting is on. The lists stay empty. |
| Download check | `sb-ssl.google.com`, while Safe Browsing is on, for a file Chromium's download check covers. | The check, with the placeholder API key. | Not the page check above. Turning it off is open (`BACKLOG.md` S-238). |
| Password leak check | `passwordsleakcheck-pa.googleapis.com`, when a password is saved. The preference defaults on. | A short hash of the username and an encrypted copy of the username and password, with the placeholder API key. No account. | Chromium's leak check. Turning it off is open (`BACKLOG.md` S-238). |
| Translate | `translate.googleapis.com`, while Translate is on (the default), when a page is offered for translation. | The language list, and the translate script if the page is translated. | Turning it off is still to do. |
| Network time | `clients2.google.com` | A request for the current time. | Chromium judges certificate dates with it. Turning it off is still to do. |
| The user's own browsing | Sites the user visits, including the DNS, TLS (OCSP and certificate transparency) and favicon traffic that browsing implies. | Whatever the user does. | This is a web browser. |
| Extension install and update | Chrome Web Store (Google). | Ordinary store traffic. | Only when the user installs or updates an extension. See "Extensions". |

### Only after the user turns it on

| Connection | To | Contains | Why |
|---|---|---|---|
| Ad and tracker lists | `easylist.to` (`/easylist/easylist.txt` and `/easylist/easyprivacy.txt`), only while Settings › Stedding › Privacy › **Block ads and trackers** is on. It is off by default. Each list is fetched again when its own expiry says so (clamped to between one and fourteen days), and at once on **Update lists now**. | A conditional GET (If-None-Match, If-Modified-Since). No cookies, no cache, no query string, Chromium's own user agent. Nothing about the machine or the pages visited. | The filter lists. Nothing from them is built into the browser ([ADR 0030](decisions/0030-ad-and-tracker-blocking.md)). |

### Never

- No telemetry or metrics endpoint.
- No first-run ping with an installation or user id.
- No field-trial or experiment ("Finch") download. The field-trial testing
  config is off in every build (`features/privacy.md` Q10).
- No new-tab-page network request. The new tab page is local
  (`features/new-tab.md` N1): no sponsored tiles, no news feed, no background
  promotion.
- No search or address-bar keystrokes sent anywhere until the user submits.
  Search suggestions are off by default.
- No Autofill server query or vote. Chromium would ask
  `content-autofill.googleapis.com` about forms and report what was submitted.
  That is off (`features/privacy.md` Q14,
  `PrivacyDefaultsTest.AutofillAsksNoServer`). Autofill fills from its own
  heuristics.
- No certificate report. Chrome can send Google a sample of certificates
  (`safebrowsing.google.com/safebrowsing/clientreport/chrome-sct-auditing`)
  once it enforces certificate transparency, after a lookup at
  `sctauditing-pa.googleapis.com`.
  Stedding enforces certificate transparency and reports nothing, whatever the
  Safe Browsing setting (`S-237`,
  `CertificateReportsTest.NoCertificateIsReported`).
- No check-in with Google's push service (`android.clients.google.com`) at
  start, and no `accounts.google.com/ListAccounts`. A fresh profile does not
  ask either (`features/privacy.md` Q11, Q12;
  `QuietStartTest.AFreshProfileCallsNoGoogleService`). Web Push still works
  when a site the user allows subscribes to it.

An idle capture on a real login keychain is still owed (`BACKLOG.md` S-50).

## Crash reports

Stedding uploads no crash reports. Chromium's upload to Google is absent from
these unbranded builds, and Stedding runs no crash service of its own. A dump
may remain on disk, in the `Crashpad` folder of Stedding's data folder. Adding
an opt-in reporter would need its own ADR and an entry on this page first.

## Certificates

A public authority's certificate must carry proof that it was written to the
public certificate-transparency logs, and Google's own sites accept only the
keys Google pinned for them (`S-236`, `S-237`). Both lists come with the
certificate component update that already brings the root store. Nothing extra
is fetched, and nothing is reported. A pin list more than ten weeks old turns
pinning off. A transparency list more than seventy days old turns that check
off. Either way the browser does not refuse every site for an old list, as in
Chromium. A certificate from a root the user added needs neither check.

## Search

The welcome flow's first step lists search engines in a random order
(`features/welcome.md` W2). No engine has paid for a place. If that ever
changes, this page and the release notes will say so before it ships. Until a
choice is recorded, a search goes to DuckDuckGo, in every region. Skipping the
step, or finishing the welcome flow without a pick, records DuckDuckGo, so
Chromium's own chooser does not open. Settings changes the engine any time.

Search suggestions are off. Settings › Stedding › Privacy › **Send what you
type to the search engine for suggestions** turns them on.

## Safe Browsing

Safe Browsing protects against phishing and malware. The standard (v4)
implementation downloads hashed prefix lists and contacts the server only for
a hash-prefix match. Google does not receive browsing history from that. It
does receive occasional partial-hash queries, and the client's IP.

In these builds the setting is on, and the builds carry no Google API key, so
the list update is refused. The local lists stay empty. No page is checked,
whichever mode is chosen. Settings › Privacy and security › Security says so,
above the modes (`features/privacy.md` Q13,
`SettingsSecurityTest.ThePageSaysSafeBrowsingDoesNotWork`). The requests still
reach Google. A file Chromium's download check covers is still sent to
`sb-ssl.google.com`, and saving a password is still sent to
`passwordsleakcheck-pa.googleapis.com`. Both carry the placeholder API key.
Turning them off is open (`BACKLOG.md` S-238). The route the owner chose,
lists through stedding.dev with the key on the server (`BACKLOG.md` S-75),
is set aside for now.

The stance, once it is settled:

- **By default:** standard hash-prefix Safe Browsing that is shown to work.
  Shipping with phishing protection off is not a defensible default.
- **By choice:** turning it off, one switch, clearly explained.
- **Never by default:** an "Enhanced" mode that sends full URLs or page
  content in real time. Stedding does not turn it on. Chromium's Security page
  still offers it. Removing that choice is open (`BACKLOG.md` S-238).

## Snapshots an early build left on disk

Early builds wrote a snapshot of the sidebar every hour into a `Sidebar
Backups` folder in the profile: every tab's address and title, in plain JSON.
Current builds do not write it
(`SidebarNoBackupTest.AnHourOfAWindowWritesNoBackup`). Clear browsing data
does not remove a folder already there. Delete the folder by hand, or import
one of its files with **Import sidebar…** in Settings › Stedding › Sync and
import.

## A Space's own cookies

A Space with an independent session keeps its cookies, cache and site data in
its own jar on this disk (`features/sessions.md`). **Delete browsing data**,
`chrome.browsingData` and deleting one site's data reach every Space's jar,
with the same time range and the same sites (sessions S24). **Clear
Independent Session** empties that Space's jar. Deleting the Space deletes
the jar.

An independent session keeps sign-ins apart, not permissions. A site's
permissions are the profile's, in every Space: camera, location and
notifications, and the devices and files a site was allowed to use (a serial
port, a USB or HID device, a Bluetooth device, a folder). A device a site
may use in one Space it may use in the others (`features/spaces.md` B47).

**Clear Site Cookies and Reload** (⌥⇧⌘R, Ctrl+Alt+Shift+R, or the command
bar) deletes the cookies of the page's site from the jar that tab uses, and
from no other jar, then reloads the tab. Site storage, cache, history and
passwords stay (`features/commandbar.md` K24).

## Dark pages

**Dark pages** (`features/dark-pages.md`) makes no network request and sends
nothing. The profile's `Preferences` file holds the switch, whether the
address-row button is shown, and the mode and the two site lists (Chromium's
content setting `AUTO_DARK_WEB_CONTENT`, which Stedding registers on desktop).
The lists name sites the user chose, as bookmarks do. Delete browsing data
with "Site settings" ticked, and Reset settings, clear them (read in the code,
not yet run). A site chosen from a private window is kept in memory for that
session only. A page can learn that the reader prefers dark, the same signal a
dark window already gives, and, through a trick Chrome documents, that
automatic darkening is on. It cannot read the lists.

## History and Downloads in the sidebar

The History and Downloads panels (`features/sidebar-panels.md`) make no
network request. The page is built into the browser. Site icons come from the
profile's favicon cache, never from a favicon server; a site with no icon
there shows the default globe. File icons come from the system. The History
panel reads local history through Chromium's own handler, which could read
Google's web history only for a profile signed in with history sync. Stedding
does not offer that (below). Copy File puts a downloaded file on the clipboard
only when the user chooses it. Move to Trash moves a file to the system's
Trash or Recycle Bin and does not delete it outright.

## Pictures of pages in hover cards

Hovering a tab that is not on screen shows a small picture of its page
(`features/pins.md` H19–H23). Chromium's tab-preview images are on in Windows
builds, as in Chrome there, and Stedding turns them on for the Mac as well.
The picture is taken from the tab when the tab leaves the screen, and
refreshed while the card of an awake tab is open. It is a JPEG in the
browser's memory. It is never written to disk, never put in the saved session
and never sent. It goes when the tab closes or the browser quits, so none
comes back after a restart. A tab put to sleep keeps a picture it already had.
A tab that has not been shown in this run has none. Private windows work the
same way. Settings › Appearance › **Show tab preview images** turns the
pictures off.

## Apps made from pages

Making an app of a page (**Add to Dock…** on the Mac, **Install page as
app…** on Windows; `features/web-apps.md`) fetches only what the page names,
in the page's own session: its manifest (which may sit on another host), the
icons the manifest lists, its favicons, and the manifest's screenshots for the
larger dialog. A later page of the app can cause the manifest to be read
again. No Google service is on the path: no install model, no web-app sync, no
preinstalled Google apps. The launcher, its signature, its icon and the
Windows shortcuts are made on this machine. The profile's `Preferences` file
holds the cookie jar of the Space the app was made in (`stedding.apps.jars`)
and, on the Mac, the launcher its Dock tile points at
(`stedding.apps.dock_tiles`). Both go when the app is removed.

## Imports from Dia and from Safari's export file

Nothing looks at another app's data before you ask for an import. The welcome
flow looks for other browsers only when you reach its Import step, and on the
Mac Stedding never looks at Safari's data, which macOS keeps for Safari alone;
Safari's export file is the way in (`features/import.md` I46).

Importing from Dia (welcome step 2) reads Dia's files on this computer: its
bookmarks, and copies of its history and logins, made in a temporary folder
that is deleted when the read ends. Passwords are unsealed only after
Passwords is ticked and the button is pressed. On the Mac, macOS asks before
it hands over Dia's key. On Windows, the key is the one in Dia's Local State.
The summary before that reads no key. Safari's export file is read where you
chose it. Stedding neither copies nor deletes it. Passwords in that file are
plain text, so Passwords starts unticked. Ticked, they are held in memory
until they are saved in the profile's password store, and a saved password is
never replaced. Payment cards are never imported: the file is read only far
enough to see that it holds them. The bookmarks page is parsed in a utility
process, and the passwords file by the sandboxed CSV parser. Nothing an import
reads is sent (`features/import.md` I28–I42).

## Sync

Stedding does not offer to sign the browser in to Google, including on a
computer where `GOOGLE_DEFAULT_CLIENT_ID` and `GOOGLE_DEFAULT_CLIENT_SECRET`
are set (`features/privacy.md` Q16,
`BrowserSigninTest.NoOAuthClientTurnsSignInOn`). Signing in to Google websites
works as in any browser. There is no Stedding account or server. A sync
service of our own is out of scope on the way to 1.0
([ROADMAP.md](ROADMAP.md), "Out of scope for this ladder").

The sidebar travels as a file (`features/sidebar-file.md`). **Export Space…**
writes one Space and **Export all Spaces…** writes every Space, to Downloads.
**Import sidebar…** reads either file. The file holds each Space's name, icon,
colours and whether it has its own session, and the addresses and titles of
its pins, folders, essentials and open tabs. It never holds history, cookies,
passwords, extensions or anything in a Space's own session. Stedding sends the
file nowhere.

Sync through a folder is off by default. It is not a sync service. Each
computer writes a file into a folder the user picks and reads the other
computers' files from it. The user's own sync tool or shared drive carries
them. Stedding makes no network request for it. The file holds Spaces (name,
icon, colours, order, whether the Space has its own session), pins (home
address and the user's own name), pinned folders, essentials, a random install
id (16 hex characters) and the computer's name ("Mac" or "Windows PC" plus
four characters of that id, or a name the user typed). It never holds open
tabs, history, cookies, passwords, jars or the host name (Sf36). In its own
profile, each computer also keeps a record of the merged sidebar, the last ten
batches for Undo, and five backups (Sf7–Sf41, [ADR 0029](decisions/0029-sidebar-sync-through-a-folder.md)).
**Stop syncing** leaves the sidebar as it is. This computer's file in the
folder is removed only if that box is ticked.

## WebRTC

Chromium's default mDNS obfuscation of local IP addresses is kept. Sites using
WebRTC see mDNS hostnames rather than LAN addresses, and calls still work.
There is no setting for the stricter policies VPN users want ("public
interface only", "disable non-proxied UDP"). An extension that sets Chromium's
WebRTC IP-handling policy can apply them.

## Global Privacy Control

Stedding sends the GPC signal (`Sec-GPC: 1` and `navigator.globalPrivacyControl`)
by default. It is a legally meaningful opt-out in several jurisdictions.
Settings › Stedding › Privacy › **Send Global Privacy Control** turns it off.
A change takes effect after a restart (`features/privacy.md` Q4).

## Links you open

Off until you turn it on, in Settings or in the welcome flow's privacy step:
the same parameters are how some sites credit a referral, so removing them is
your choice, not a default (the owner, 2026-11-02). When it is on, a page you
open, from a link, a new tab, the address field, a bookmark or another app,
loads without the tracking parameters a copied link loses
(`utm_*`, `fbclid`, `gclid` and the rest of one table, `features/copy-link.md`
L2). History keeps the clean address. A link through a redirect page that
carries its target in its own address (Google's `/url`, Facebook's and
Messenger's `l.php`, Instagram's `l.`, Reddit's `out.`, YouTube's `/redirect`)
goes straight to the target, and the redirect page is never requested. Both
tables are compiled in. Nothing is fetched. A shortener such as `t.co` is not
asked for its target, so it is followed as any link is. Only the first address
of a top-level page is rewritten. A page's own requests, frames, forms,
reloads, back and forward, and a server's redirects are left as they are, so a
page that needs a parameter can still ask for it. The tab's navigation entry
keeps the address the navigation started with, and session restore writes that
to disk. History does not. Settings › Stedding › Privacy › **Remove tracking
from links you open** turns it on or off, and **Sites that keep their links**
exempts a site (`features/clean-links.md`; `features/privacy.md` Q15).

## Ad and tracker blocking

**Block ads and trackers** (Settings › Stedding › Privacy;
`features/blocker.md`, [ADR 0030](decisions/0030-ad-and-tracker-blocking.md))
is off until the user turns it on. Then Stedding downloads EasyList and
EasyPrivacy from `easylist.to`, each again when it says it expires, and
converts them on this computer into rules Chromium's subresource filter blocks
by. The request carries nothing about the user (the row above). The lists, the
rules made from them and a LICENSE file naming each list stay in the `Stedding
Blocker` folder of the data folder. Fetch times are in local state. Blocking
keeps no per-site record of pages visited: the "ads blocked" icon is not
shown, and Chromium's per-site ads data is not written. The only thing stored
for a site is an exception the user made (the ADS content setting, in the
profile's `Preferences` file). One made in a private window stays in that
window's memory. Delete browsing data with "Site settings" ticked clears the
exceptions. Turning blocking off stops the fetches. The downloaded lists stay
on disk.

## Extensions

Full Chrome extension compatibility is a core feature, and it has privacy
consequences:

- Installing and updating extensions talks to the Chrome Web Store. That
  traffic exists only when you use extensions.
- Stedding does not read Chrome's external-extensions list (on Windows,
  `Software\Google\Chrome\Extensions`; on the Mac, Chrome's External
  Extensions folder), so it does not fetch an extension a Chrome installer
  registered there (`features/privacy.md` Q9). Stedding's own per-user
  External Extensions folder, policy-forced extensions and extensions the user
  installs are unaffected.
- An extension is third-party code running with the permissions you grant. It
  can read and transmit anything those permissions allow. Stedding does not
  audit extensions beyond what Chromium does. Review permissions before
  installing.

## Defaults at a glance

| Behaviour | By default | By choice |
|---|---|---|
| Telemetry / metrics | None | — |
| Crash reports | None uploaded | — |
| Update checks | On, on the Mac and on Windows. See "The update check". | Settings › Stedding › Updates |
| Search engine | DuckDuckGo until the user chooses, at the welcome step or in Settings | Change any time |
| Cookies per Space | Every Space shares the profile's jar | An independent session keeps its own cookies, cache and site data on this disk. Clear Independent Session empties it. Deleting the Space deletes it. Delete browsing data reaches it (`features/sessions.md`) |
| Search suggestions | Off | Opt in |
| Show Stedding's own error pages | On. A failed navigation does not ask a web service what to show | Turn off |
| Third-party cookies | Blocked in normal windows | Allow per site, from the eye icon in the address row |
| Try HTTPS first | On (balanced mode) | Turn off |
| Quiet notification and location prompts | On | Turn off |
| Ad topics, site-suggested ads and ad measurement | Off, with no switch to turn them on | — |
| Safe Browsing | The setting is on (hash-prefix only). Page checks are not active: list updates are refused without an API key. A checked download and a saved password are still sent | Turn off. Enhanced mode is still offered; see above |
| Google sync | Not available | — |
| Sidebar sync through a folder | Off. See "Sync" for what the file holds | Settings › Stedding › Sync and import |
| WebRTC local IPs | Hidden (mDNS) | Stricter policies through an extension |
| Global Privacy Control | On | Turn off. Takes effect after a restart |
| Tracking parameters on links you open | Left as written. Nothing fetched | Turn on, in Settings or the welcome flow: they are removed and known redirect pages skipped. Keep a site's links in Settings |
| Ad and tracker blocking | Off. Nothing fetched | Turn on (lists from easylist.to). Then off or on for any site |
| New-tab sponsored content | None. The new tab page makes no request | — |
| Extensions | None installed | The user installs them. Store traffic follows |

Settings › Stedding › Privacy holds the rows Stedding changes from Chromium,
one control each (`features/privacy.md`). A change to a default in this table
needs an ADR in [decisions/](decisions/) and a release-notes entry.

## Still to do

An unbranded build with no Google API key already leaves out metrics, crash
upload to Google, RLZ, the variations seed, Google sign-in and Sync, and
Google's own updater. Stedding's update check is separate, and is described
below. No patch has changed these yet:

| Still to do | Today |
|---|---|
| Network time queries off | On by default on desktop, and not gated on branding |
| Translate off by default | `translate.enabled` defaults to true |
| No navigation prediction or preconnect | `net.network_prediction_options` defaults to standard preloading |
| Component updates from our infrastructure | The component updater talks to Google. It needs an endpoint swap and a component allowlist |
| No placeholder API keys in request URLs | The placeholder key is still appended to some Google requests |

## The update check

On the Mac, Stedding updates itself with Sparkle 2 from a signed feed in this
repository ([ADR 0022](decisions/0022-sparkle-updates-the-mac.md), which partly
supersedes [ADR 0014](decisions/0014-github-releases-as-update-channel.md); the
site stays off the update path; `features/updates.md`). It is the one endpoint
this project deliberately adds, so it is described exactly. On Windows the
browser reads a feed of its own and runs the installer it downloads
([ADR 0023](decisions/0023-updates-on-windows-and-linux.md),
[ADR 0026](decisions/0026-a-windows-update-key.md)). The rows below say where
the two differ.

| | |
|---|---|
| Feed | Mac: `https://raw.githubusercontent.com/ysalitrynskyi/stedding-browser/main/updates/appcast.xml`, written by `tooling/publish-appcast` after a release. Windows: `updates/appcast-windows.xml` on the same host, written by `tooling/win/publish-appcast.ps1`. |
| Download | The release's own image, `https://github.com/ysalitrynskyi/stedding-browser/releases/download/v`*version*`/Stedding-`*version*`-arm64.dmg` (Mac) or `Stedding-`*version*`-win-x64.exe` (Windows), only when the feed lists a later version. On both platforms `github.com` redirects to `release-assets.githubusercontent.com`, which serves the file. |
| Sends | A plain HTTPS GET. On the Mac it carries Sparkle's user agent, which names the browser and its version. On Windows it goes through the browser's own network stack with the cache disabled and Chromium's reduced user agent, which names Chrome's major version and the Windows platform. No cookies, no account, no install id, no machine id, no system profile (`SUEnableSystemProfiling` is off and the browser adds no parameters), nothing in the query. |
| Receives | The feed: each release's version, minimum system, size, and signature. |
| Frequency | Ten seconds after a launch when the last check is more than an hour old, or there has been none, then every six hours while the browser runs. However often it is launched, a check the server answered is not repeated within the hour. On Windows a check that could not reach the feed does not count: the next comes within the hour, and a later launch checks at once. An update download that fails, or gets no byte for a minute, starts over ten seconds later, three tries in all; on the Mac each try reads the feed again. A check the user asks for (Stedding › Check for Updates… on the Mac, or Check for Updates in the command bar) runs when asked. Opening the About page checks only while automatic updates are on. |
| Default | On, with "Update Stedding automatically" in Settings › Stedding › Updates. |
| Verified | On the Mac, the image against the project's EdDSA public key before it is unpacked, and the feed's own signature; Sparkle then checks the new app's code signature. On Windows, the feed and the installer are checked against the Ed25519 update key the build carries before either is used, and only a copy the installer put in place runs the updater. On the Mac only a bundle signed by a team starts the updater. A build signed ad hoc never runs it. |

**What GitHub can see.** An IP address, a user agent (on the Mac, one that
names Stedding's version; on Windows, Chrome's major version and the
platform), and a timing pattern. Over time that is enough to infer roughly
where an installation is, which version it runs, and that it is still running.
That cost is written here. Calling the check "no telemetry" would be
misleading.

**What it is not.** It is not a check-in, a licence check, or an analytics
event. Nothing identifies the installation. The response is the same for
everybody.

**Why GitHub.** The release files already live on GitHub, so the download is
the release's own image. Running an update service of our own would mean
infrastructure that sees who is asking. If GitHub ever becomes unacceptable,
the feed is one URL to move.

**Turning it off.** With "Update Stedding automatically" off, the Mac does not
start Sparkle at all: no request to GitHub until the user chooses Check for
Updates. A version already downloaded before the switch went off still
installs when the browser quits. On Windows the same setting stops the
scheduled checks. A check the user asks for still runs.

**The thank-you pages.** When the welcome flow ends, the browser opens
`https://stedding.dev/thanks/` once per installation. On the first launch of
each later version it opens `https://stedding.dev/thanks/updated/#v`*version*.
The fragment is not sent. The pages are not on the update path: if the site is
down, the update still installs. "Show a thank-you page after an update" turns
the second page off. The first has no switch.
