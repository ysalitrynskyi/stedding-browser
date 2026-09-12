# Frequently asked questions

## About the project

**What is Stedding?**
An open-source desktop browser with Arc's way of working: a sidebar with vertical
tabs, Spaces, pinned tabs and folders, and a command bar. It is Chromium plus a series
of patches, built for people who want that interface without trusting a company's
roadmap or servers. See the [README](../README.md).

**Is it a fork of Arc?**
No. Arc is closed source, so nothing of it can be reused. Stedding is built on
Chromium's open-source code; the sidebar, Spaces, the command bar and everything else
were written for this project as a documented patch series (`patches/`).

**Why does it exist when Arc still runs?**
Arc's maker announced in 2025 that Arc would receive only security and Chromium
updates while the company moved on to another product, and the company was later
acquired. Arc users are on a maintenance-mode product owned by someone else. Stedding's
core is BSD-licensed and forkable, so no pivot or acquisition can take it away.
Details and the other browsers in this space: [COMPETITORS.md](COMPETITORS.md).

**What does the name mean?**
A *stedding* is a place in Robert Jordan's Wheel of Time where the One Power cannot
reach — a haven. The word stands for using the web outside anyone's surveillance or
control. Only the word is used; no artwork, trademarks or affiliation are claimed
([NAMING.md](NAMING.md)).

**Who makes it?**
One maintainer, in the open, on this repository. Most of the work follows feedback
from real use recorded in [ARC-ROUND2.md](ARC-ROUND2.md).

## Installing and updating

**Why is the build unsigned, and is it safe?**
Code signing needs an Apple Developer ID certificate (and, on Windows, a code-signing
certificate); the Apple account exists and the certificate is the next step. Until
then macOS warns on the first launch and right-click → Open gets past it once. Every
release is built from the tagged commit in this repository, and its SHA-256 checksum
is published beside the file so you can check what you downloaded
([INSTALL.md](INSTALL.md)).

**Will it update itself?**
Not yet. New versions appear on the Releases page. The in-app updater is designed
(it checks GitHub Releases, sends no identifier) and lands together with signing.

**Does it run on Intel Macs? On Linux?**
Not yet. Today: macOS on Apple silicon and Windows x64 (a preview). Linux is the next
platform after the Windows port is complete ([ROADMAP.md](ROADMAP.md)).

**Can it be my default browser?**
Yes. The welcome flow offers it, and it is in Settings → Stedding at any time.

## Using it

**How do I move from Arc?**
Start Stedding: the welcome flow's **Move everything from Arc** brings over Spaces,
the essentials row, pinned tabs, folders, tabs, history and passwords, from Arc's
files on your disk. Passwords need one macOS keychain prompt. You can run it again
later from Settings → Stedding → Import from Arc…; nothing is duplicated.

**Where did the bookmark bar go?**
Stedding has no bookmark bar; pinned tabs are the bookmarks. Bookmarks you import
become pinned tabs and folders in your first Space, and an existing bookmark tree can
be converted at any time from the command bar ("Turn Bookmarks into Pinned Tabs").

**What happens to tabs I do not close?**
Unpinned tabs nobody has looked at for 12 hours (a setting) move to the Archived view
at the bottom of the sidebar, grouped by day and Space; restore any of them with a
click. Pinned tabs never archive; ⌘W puts a pinned tab to sleep instead of closing it.

**Is there sync?**
No service, by design: there is no account anywhere in the product. Instead the
sidebar is backed up to a file every hour, a Space can be exported as a file and
imported on another machine, and a snapshot can be restored.

**Do my extensions work?**
Yes. It is Chromium; extensions install from the Chrome Web Store as in Chrome.

**Why does ⌃1 switch desktops instead of Spaces?**
macOS Mission Control takes ⌃1–⌃9 for "Switch to Desktop N" once you have a second
desktop, before the browser sees them. The Spaces menu in the menu bar keeps every
command reachable. Full list of collisions: [SHORTCUTS.md](SHORTCUTS.md).

**How do I get the old Chromium tab menu back?**
Settings → Stedding has a switch for Chromium's full context menus. Stedding's short
menus are the default.

## Privacy

**Does it send anything to Google, or to you?**
No telemetry, no crash reports, no experiment downloads, no identifiers. Google's
sign-in and services are removed from the interface. The Chrome Web Store is contacted
only when you install or update an extension. Every connection the browser makes is
listed in [PRIVACY.md](PRIVACY.md); anything not on that list is a bug.

**What is on by default?**
Third-party cookies blocked, HTTPS-first, Global Privacy Control, quiet permission
prompts, Chromium's ad-measurement APIs off, search suggestions off, DuckDuckGo as the
search engine. Each is one switch in Settings → Stedding → Privacy.

**Where is my data?**
On your machine only: `~/Library/Application Support/Stedding` on macOS,
`%LOCALAPPDATA%\Stedding` on Windows.

## Contributing

**How can I help?**
Use a beta for a day and open an issue for each thing that is worse than what you use
now; that feedback is what most of the work follows. Documentation fixes and Chromium
fork experience are welcome too. See [CONTRIBUTING.md](../CONTRIBUTING.md).

**I found a security problem.**
Use GitHub's private vulnerability reporting on the repository's Security tab
([SECURITY.md](../SECURITY.md)). Please do not open a public issue for it.

**I am an AI agent or a new contributor. Where do I start?**
[AGENTS.md](../AGENTS.md), then [HANDOFF.md](HANDOFF.md).
