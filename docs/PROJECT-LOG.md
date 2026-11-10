# Project log

What was built, newest first. Nothing here is needed to do a task: `AGENTS.md` carries what is true now, `BACKLOG.md` the order of work, `PLAN.md` the owner's decisions. This file was the "State of the project" section of `AGENTS.md` until 2026-09-30. This log starts at 2026-10-15. Closed work from before that is the table in [docs/history/archive.md](history/archive.md).

## 2026-11-10 -- 0.4.0 beta 17: the bookmarks bar under a coloured row (issue 98)

The owner asked for the next release while away for the evening, with one rule from earlier that
day (`PLAN.md` decision 21): nothing goes out until every check has passed and nothing published
with it is in doubt. Beta 16's site capture had just made a planned look read as a bug: it kept
the home page's hero band under the window buttons. It was retaken from a test window over plain
page and put live first.

GitHub issue 98 (S-462), reported that day from Windows: with a page-coloured address row the
bookmarks bar kept Material's own surface, a grey band, and on the Mac its text was #474747 on a
dark page's row. The bar now paints nothing of its own; the window paints the row's surface under
it, the full-screen overlay too, and its text and icons are the row's (toolbar T61, patch 0120).
The look on the release build found a second fault the tests had missed: with the address row
hidden or in the sidebar the bar's buttons were centred against the hidden row's address field,
18 DIP low, and the page cut them in half. Beta 16 did the same. The browser test now lays the bar
out afresh in that state and failed first; the fix counts the toolbar's margin only while the
toolbar shows.

Checked: 1493 unit and 949 browser tests on the Mac, release and DCHECK, the DCHECK build's one
timeout passing three of three alone; 1481 unit and 896 browser tests on Windows, release, DCHECK
and ASan. On Windows the failures were beta 16's: S-458's geometry at 150%, S-461's drag (5 of 5
alone) and a frame-timing test, plus a Space switch's slide that failed 3 of 5 alone, as it had on
beta 16 there (S-463, opened). A private window's drag (DCHECK), a folder's hover and two
tests of Settings' search for Arc's words (ASan, the sanitizer's allocator out of memory in the parallel run) each passed
every time alone, the last with no AddressSanitizer report. Acceptance on a copy of the notarized Mac build and on the installed Windows
copy; the update from beta 16 through a local feed on both; the bar looked at on both release
builds in every state its spec names. Items 2 to 4 of the day's plan (S-272, the Mac's real-input
checks, S-461 and S-458) carry to the next release.

## 2026-11-10 -- 0.4.0 beta 16: Chromium .51, issues 89 and 93, History

The entries below, released: the sync id that lasts every restart (issue 89), the window buttons
off the page and in full screen (issue 93, S-454), History without Google sync (S-457), the little
window that grew at 150% (S-456), and Chromium 157.0.8103.51. The Mac's checkout moved to .51
that night and built the release, signed and notarized, and its DCHECK build.

The sweeps found three more. On the Mac's DCHECK build a page's full screen stopped at a check
that the full-screen change had made untrue (S-460); release builds leave the check out, so the
DMG built before the fix behaves the same, and the fix is in that patch. On the PC, whose display
is 4K at 150% since 2026-11-09, a rail drop test aimed while a Space switch still slid (S-459, a
test fix), and a dragged row's copy went once while the button was held (S-461, open; the test
now fails instead of crashing). The release sweeps on Windows force scale 1; the DCHECK and ASan
sweeps keep the display's own, where S-458's geometry tests read a DIP off.

Checked: 1492 unit and 948 browser tests on the Mac, release and DCHECK, the DCHECK build's
crashes and timeouts passing twice alone after S-460; 1480 unit and 895 browser tests on Windows,
release and DCHECK, and ASan with no report and no dangling pointer, with S-458's tests and
S-461's once as the failures; acceptance on a copy of the notarized Mac build and on the installed
Windows copy (TST-6 alone after the installer cycle); the update from beta 15 through a local feed
on both. The tag's series has the three fixes; the released builds were made just before them,
and differ only in that check and in tests.

## 2026-11-09 -- Chromium 157.0.8103.51, and no "Tabs from other devices"

The owner: move the pin, and fix the History page, which offered to sync. The pin moved from
157.0.8103.39 to 157.0.8103.51, the stable point release on the Mac and Windows; the series
applies to it unchanged and Windows built it (win-release, the browser, the installer and both
test binaries). The History page had "Tabs from other devices", a page that asked to sync
history, and the History menu offered a sign-in that went nowhere: those tabs come only through
Google sync, which no Stedding profile may turn on (privacy Q16). Where browser sign-in is not
allowed, the side bar's item is hidden, `chrome://history/syncedTabs` opens the history list, and
the menu has no part for other devices (privacy Q18, S-457, in the patch that turned sign-in
off). `BrowserSigninTest.NothingOffersTabsFromOtherDevices` failed on Chromium's own files and
passes with the fix, twice. On the real Windows build, a fresh profile's
`chrome://history/syncedTabs` opened `chrome://history/` with "Stedding history" and "Delete
browsing data" alone. Not yet: the Mac checkout's move to .51, its build, and the suites on both
platforms.

## 2026-11-09 -- Issue 89's cause: a tab's sync id lasted one restart

The copies came from the computer that restarts, not the one that shows them. A tab's sync id
reached the session when it was made and when the whole log was rewritten, and each launch starts
a new log: a pin or essential restored at one launch had no id in it, and a tab whose page a sleep
or a Space's own session replaced kept its id under its old session id only. At the next launch
such tabs took new ids, and the other computer took each for a new pin or essential, a copy beside
its own, while the restarted one showed one of each. Windows, quit and opened most days, sent
copies; the Mac, rarely quit, received them. The earlier tests restarted once, which keeps every
id. On the Windows PC (the Mac was in use), with the browser's own profile as the second computer
so its session comes back as a real launch brings it: two restarts made 7 copies on the first
computer, a sleep and one restart 6, in tests that failed first. The id is now written with the
tab's Space, pin and home (sidebar-file Sf2, S-452), in the patch that writes those. Eight cases
keep it (patch 0164). The restart tests now run one at a time: they keep their place on a fixed
port. Not yet run on the Mac.

## 2026-11-09 -- Issue 89's answers, not reproduced yet

The reporter answered: the copies stay at two, only the Mac (the first computer) shows them, after
Windows is used and syncs; both were on beta 15 at the join; the place is WebDAV on Koofr. On the
Windows PC (the Mac was in use), two profiles through a WebDAV place took those steps with pins and
essentials: a fresh second computer and one with the same pins, combined, then used (every pin and
essential opened, one navigated away and back, all put to sleep), and the first computer restarted
from the New Tab page and with its session while the join's pairs were in force. One of each on
both sides every time. Four new browser tests keep those steps (patch 0164); they have not run on
the Mac yet. S-452 lists what was ruled out and what the reporter is asked next.

## 2026-11-09 -- The traffic lights: issue 93 and full screen

Issue 93 (S-453, sidebar Y55): with the sidebar hidden and the address row hidden, only the page
lay under the Mac's traffic lights, and they covered its top left corner. They now hide there and
show while the pointer rests at the window's top over them, or when anything of the window's comes
under them (the row, the open sidebar, the rail, a slide-in). The owner chose the reporter's first
option. Patch 0119, with the lights' other rule (Y53); the test is in patch 0120.

The owner's report from full screen (S-454, sidebar Y17): pointing at the screen's top brought the
lights in on a strip of their own above the address row, and the row dropped under it. A window
that draws its tabs in the sidebar took Chromium's full-screen mode without a tab strip in the
title bar, so AppKit's title bar held the lights alone. With the row always shown the overlay that
holds the row is now the title bar's own row, as Chromium places its tab strip: the lights at the
row's left, the sidebar's toggle after them on their centre (as in a window), the rail's own toggle
kept under them, and a hidden sidebar's row past them on a bar that runs under them. Always Show
Toolbar off and the row hidden keep the old placement. Measured in real full screen in a test
window, at rest and with the menu bar in; a real full-screen test failed first. Patch 0120.

A Shift-click range in the sidebar (S-455, tabs R20), which the owner saw fail perhaps in full
screen: not reproduced, for plain rows, pins, sleeping rows and essentials, after a Space switch,
and in real full screen with the event generator's clicks. Two tests keep it (patch 0165).

## 2026-11-09 -- Issue 89's second report

The reporter says the copies came whenever the Windows computer was used, not once at the join.
A pin or essential that came back from a restart without its id would do that: the next write
would send it under a new one. Two new tests restart with On startup on the New Tab page and on
Continue where you left off, with synced and own pins and essentials; every id survives, on the
Mac and on Windows. Not reproduced; S-452 holds what was ruled out and what was asked.

## 2026-11-08 -- 0.4.0 beta 15: issues 89 and 91

The two fixes of the entry below, released. Checked on the final tree, the same on both machines:
1492 unit and 915 browser tests on the Mac and the unit and browser suites on Windows, each on the
release build and the DCHECK build, with one restore test and one Space session test on the Mac's
DCHECK build timing out once among the others and passing alone; AddressSanitizer on Windows with
no report and no dangling pointer; acceptance on an installed Windows copy, TST-6 again alone after
the installer cycle, and on a copy of the notarized Mac build; the update from beta 14 through a
local feed on both. The site's capture is a frame of a recording of the signed build halfway
through the peek's fade, with the window's buttons from a still of the same window (a recording
of a window draws them as a badge) and the pointer taken out.

## 2026-11-08 -- After beta 14: issues 89, 90 and 91

Issue 89, sync showing every pin twice: at a join with **Combine**, Spaces pair by name, and a Space
never named was skipped. A fresh install's first Space has no name (the sidebar shows "Space 1"),
so two fresh installs never paired it, and each one's pins came to the other as a second copy.
Such a Space now pairs by the name the sidebar shows it by, its place in the list, the same text
on every computer (sidebar-file Sf10, folded into the sync patch). A test with two profiles through
a WebDAV and an S3 place takes the report's steps and failed first: two of each pin on the second
computer. Restarts and a Space with its own session were looked at first and keep a synced pin's
id; a test holds that. Copies already made stay until the extra Space is deleted on one computer.

Issue 90, finished downloads gone from the list: no steps yet. A download from a Space with its
own session is written to history and listed after a restart, as one from a shared Space is; a
test holds that, and nothing in the series removes a download. It waits on the reporter (S-450).

Issue 91, the peek's card: it fades in over 160 ms when the peek opens, under "Animate the sidebar
and overlays" and Reduce Motion, with no setting of its own (motion O10, patch 0176). A recording
of the window on the real build shows the card coming in over four frames.

Checked on one tree, the same on both machines: 1492 unit and 915 browser tests on the Mac and the
unit and browser suites on Windows, each on the release build and the DCHECK build. The pairing
unit test, the two-computer test and the peek's test failed with their fix taken out; the restart
and download tests guard what was ruled out and passed before any change. The peek's test had
looked for the motion while it ran, and under the full run's load it had ended by then; it now
asks whether the motion ran, and passed six times over under load. Once each among the others, and
each passing alone: a routes card test on the Mac's release build, a screenshot test on its DCHECK
build, and a child tabs test on Windows that lost its connection to the test server (no socket
buffers). Not run: AddressSanitizer, acceptance, the update test.

## 2026-11-08 -- 0.4.0 beta 14: issues 85, 86 and 88

The three fixes of the entry below, released. Using the signed build found one more fault before it
went out: with the focus in a peek's page, ⇧⌘C and ⌥⇧⌘C did nothing on the Mac. The page hands a
key it does not take to the peek's own widget, and the window's menu never sees it there; the
browser test had run the commands, not the keys. The peek now runs the two keys itself, as it does
⌘W (copy-link L8, folded into 0119, its test into 0171). The test presses them in the page and
failed without the fix.

Checked on the final tree, the same on both machines: 1491 unit and 908 browser tests on the Mac
and 1479 and 858 on Windows, each on the release build and the DCHECK build. Four Copy Link tests
timed out once among the others on the Mac's release build and passed alone; they had passed in the
sweep before the fix and on the DCHECK build. AddressSanitizer on Windows, both suites, with no
report and no dangling pointer. Acceptance on an installed Windows copy, TST-6 again alone after the
installer cycle, and on a copy of the notarized Mac build; the update from beta 13 through a local
feed on both. On the signed Mac build, each of the four copies from a peek (the two keys and the
bar's button, plain and Option) took the peek's page, and the three on Windows did on the installed
copy, light and dark. Not checked: a real ⌘Q with the new switch off, which the tests cover through
the setting.

## 2026-11-07 -- After beta 13: issues 85, 86 and 88, and the issue labels

Issue 85: a pin closed with its − was put to sleep but stayed in the Space's history, so the next
close showed it again and woke it, rather than the essential used before (tabs R33). Issue 72's fix
had covered a sleep, not a close after one. A row the user puts away, a pin closed or a row put to
sleep by Sleep Tab, now leaves the history; one asleep by the timers keeps its place. Folded into
0123, which owns issue 72's rule. Issue 86: Copy Link over a peek copied the pin under it. The
window's copies take the peek's page while it is open, and the peek's bar has its own Copy Link
(copy-link L8), folded into 0119 and its test into 0171. Issue 88: ⌘Q quitting at once was the
Stedding menu's Warn Before Quitting alone; Settings has the same switch now (settings T60, patch
0175). Issue 87, a Space's own essentials on a shared session, is S-445, for later.

Evidence, on the Mac's release build: 152 unit tests and 59 browser tests around these rows pass,
and the two new tests fail with their fix taken out, the way the issues describe. On a test copy,
the peek's bar shows the link first and Settings shows the switch; the app menu holds Warn Before
Quitting (⌘Q). On Windows, win-release on the same tree: the same unit tests and 61 browser tests
pass. Not run yet: the full suites, the checks builds and ASan.

The issues have labels throughout: a kind, an area, a platform where it is one platform's, and a
status (`PLAN.md` decision 16). New: `crash`, `regression`, `good first issue`, seven areas,
`platform: linux`, and `status: later`, `in progress` and `fixed on main`; `done` became
`status: released` and its verify twin `status: verify`.

## 2026-11-07 -- 0.4.0 beta 13: Touch ID passkeys, split view's last rows, child tabs, another window

Patches 0165 to 0174, one night, two tracks. The Mac held the items that needed it, the PC the rest,
and the trees were matched by hash at each merge.

Passkeys (S-239, ADR 0033): the owner made the App ID and a Developer ID profile, and asked Apple for
the browser entitlement. The team id, three keychain groups and the profile go into a signed build,
and a page sees a platform authenticator where released beta 12 sees none. A look at the real dialog
found "Your Chrome profile", literal text the product-name rewrite does not reach. Real keychain on the
signed build: no prompt, and a cookie read back after a restart. A real passkey wants a finger.

The stray Google request of beta 12 (S-443) was the test's: the suite pretends an OAuth client exists,
so sign-in was allowed there, and a fresh real profile asked nothing in 75 seconds. A quit during a
dialog (S-435, S-438) never begins on the Mac, as with any app with a dialog up, and H3 now says so.
Split view (S-102): one number for a split, the key to the pane used last, and a pin that keeps its
run when a tab joins it. The PC built little windows' rest (S-157), the redirected link in a peek and
a screenshot of a peek (S-93), Move Tab on a selection (S-127), child tabs' rest (S-92) and the question
when a page is open in another window (S-94's first slice). The bar's small rows are S-158.

A read of the eleven commits found six faults, none a crash: a Mac swipe that closed a child, Back
that closed a pin, a fold that hid pins and could strand children, ⌘W on a little window not recorded,
Show Here leaving a pin under the line, and half a pin after a swap. Using the Mac's real build found a
seventh: a plain click on a `target=_blank` link, the commonest new tab there is, was nobody's child,
since it comes to the front with no opener and has not started loading when it reaches the strip. The
tests had all opened links in the background. Each has a test, seen red but for the swap, which passes
either way.

Checked on the final tree, the same on both machines: 1490 unit and 907 browser tests on the Mac and
1478 and 857 on Windows, each on the release build and the DCHECK build, with one sync test on the
Mac's release build and one drag test on Windows timing out once among the others and passing alone;
AddressSanitizer on Windows with no report and no dangling pointer, one peek test timing out and
passing twice alone; acceptance on an installed Windows copy, TST-6 again alone after the installer
cycle, and on a copy of the notarized Mac build; the update from beta 12 through a local feed on both;
on the notarized build, Touch ID offered to a page, the dialog's words, the real keychain with no
prompt, and a cookie read back after a restart. The new states were looked at on the Mac's real
build, light and dark. Not checked: a real passkey, ghost pins (not built), and the child rows'
favicons clipped on one side after their parent is pinned (in S-92).

## 2026-11-06 -- 0.4.0 beta 12: sync through WebDAV or S3 storage, and what the real builds left

Patches 0161 to 0164. Sync can go through WebDAV or S3 storage the user sets up, beside the folder
(S-426, ADR 0032, patch 0164): a bridge keeps a mirror in the profile and the service reads it as its
folder, so the merge and the ledger did not change. A separate read of the patch found nine faults
before any user saw them, all fixed with tests; the row names them. A press on a folder's − no longer
sends a long list to the row that comes forward (S-442), a little window keeps its size through a
second restart (S-436, seen only on a real quit, since a browser test's quit writes the bounds), the
DRM notice is shorter and shows beside another bar (S-437), and a rename gives the keys back (S-438).

Checked on the final tree, the same on both machines: 1484 unit and 891 browser tests on the Mac and
1472 and 840 on Windows, each on the release build and the DCHECK build, with no rerun on the last
pass; AddressSanitizer on Windows with no report and no dangling pointer, where one test saw a
`ListAccounts` request and passed alone (S-443); acceptance on an installed Windows copy and on a copy
of the notarized Mac build; the update from beta 11 through a local feed on both; sync through Settings
against a real WebDAV server on both and an S3 server on Windows. Not checked: a commercial WebDAV or
S3 service, the row beside the camera in a private window, each density for the − buttons.

## 2026-11-06 -- After beta 11: private windows, the Space name, the − buttons, the lit circle

Patches 0157 to 0160, on Windows alone: the owner had the Mac. A private or Guest window has no Space
model, which is what made the address row's rules, so it ignored every setting that hides the row
(S-439, issue 83); the window makes its own now. The Space name no longer reorders the sidebar's
children during a layout, the crash the AddressSanitizer run found (S-440); its new test crashed on
the same CHECK before the fix. The − buttons have their glyph on the centre of a 20 DIP circle
(S-441, a comment on issue 78). The owner looked at the lit shield and moon on the Mac and asked for
a pixel more, so the circle is 21 DIP, the size of the chips beside it (S-423).

Checked: 1432 unit tests and 794 browser tests on `win-release` and `win-checks`; a private window
with the address in the sidebar and Ctrl+Shift+D on the real build; the − on a folder and a pin
measured at twice the size, light and dark. For the circle, the last of them: the 39 tests of the
blocker, dark pages and the row's colour on both builds, not the whole suites, and a look on the real
build at 1× and 2×, on a light row and a dark one. Not checked: the Mac, AddressSanitizer on these
patches.

## 2026-11-06 -- 0.4.0 beta 11

On Chromium 157.0.8103.39. The bugs reported on beta 10
(GitHub issues 79 to 82), the notice on sites that need DRM, a folder's − on hover, one list of
routes and a page after an Arc import, more of Arc in the import (pinned folders, splits, the
archive, names), import from Opera, permission prompts in a peek, and moving a folder to another
Space (S-433, the owner's last request).

The owner's Bitwarden window on the Mac (S-427) came down to a popup opened with another popup in
front of the full-screen window: G8 looked only at the window in front. A stand-in extension
making Bitwarden's call in real full screen showed it, and shows it gone. Whether Bitwarden's own
flow is that path is still to see. S-428, no logins until a restart, did not reproduce.

The real-build pass found one bug the suites had not: an address typed on a Space's own page got
no row until the Space was left (S-434, patch 0156). What else it found is S-435 to S-438.

Three lessons about the machines. A browser sweep on the Mac beside a build, even one at nice 12,
fails by the hundred ("CompleteShutdown took more than 30 seconds"), so the build is paused with
SIGSTOP for the sweep. A win-asan build at 16 jobs took the PC with 32 GB to its commit limit and
stopped it answering; 10 jobs hold. FindWordsTest passes on win-checks only with the launcher's
limit raised while anything else runs.

S-272, spaces that share a named session, is not in this release. Its docs and commits are on the
`s272-wip` branch.

Released with Windows' AddressSanitizer build still running: at 10 jobs it needed until the morning,
so the two update feeds waited for it. It gave no memory error and no dangling pointer on 1432 unit
tests and 792 browser tests. One test crashed on a CHECK in `View::ReorderChildView` (S-440), older
code that a hover during a layout reaches; it passed six of six alone, and beta 10 has the same
path, so the feeds went out. The first notes counted the serial leg's tests twice: the browser suite
is 792 tests on Windows and 843 on the Mac, not 978 and 1015.

## 2026-11-05 -- Where someone from Arc looks (S-422, S-126)

A comment on r/Stedding asked for Arc's Air Traffic Control, which Stedding has as routes. The
features were there and people did not find them. Five commits on `stedding-work`, not yet in
`patches/`.

Settings has one list of routes: a card, "Sites routed to Spaces", with every rule in the order
that decides, each edited where it is listed, an add row for a site or text in the address, and
the Space for links from other apps, which moved there. A rule naming no Space is listed as "No
Space"; `RoutesFromValue` used to drop one with an empty Space, and the next write lost it. The
Space menu has "Route sites here…", which opens the card on that Space, and "Sort open tabs by
these rules now". Arc's words find things in the command bar and in Settings' search box, from one
table, and no label takes one. An Arc import ends on a page that says where each thing is and what
did not come across, and Arc's routes come across where a rule names one Space
(`StorableLinkRouting.json`).

Each test was seen red first. On the real build, in light and dark, on a test copy with a made-up
Arc under a made-up home: the import from Settings and from the welcome flow, Show to the card, the
menu's two rows with the real pointer, the bar and Settings' search. That found three bugs the
first tests passed: an apostrophe written as `&#39;` in a line of the card, the page after an
import ending in a white band under the setup flow's arch, and the search not scrolling to a mark
inside another element's shadow root. Each has a test now. The Mac's native menu draws no note, so
a disabled sort row does not say why there. Not run: `mac-checks`, and anything on Windows.

## 2026-11-05 -- A six-hour test no longer takes 50 seconds on the Mac

`IdleWindowsTest.NothingSweepsAPopupOrALittleWindow` went over the launcher's 45-second limit twice
on a busy Mac. It ran six hours of mock time, and on the Mac each timer's wake-up runs NSApplication
for real, so it took 51 seconds there and 2 on Windows. A count of the tasks found no product bug:
the busiest timers are stock Chromium's, on periods of 10 and 15 seconds, and Stedding's own fired
20 and 74 times in the six hours. The test now jumps the clock six hours, which leaves every timer
due in them overdue, and runs the two sweeps: 1.4 seconds on the Mac, what it asserts unchanged. Its
fix is in patch 0071, the slowest unit test on the Mac is now under 5 seconds, and all 1391 pass.

## 2026-11-05 -- Update downloads try again, and About says how to retry (S-420)

The owner, updating their Mac from beta 9 to beta 10: About stopped at 38% and then said the
download had failed. The log showed GitHub's connection going quiet after 73 MB of 190 MB and
CFNetwork giving up a minute later. Nothing was wrong with the release: six more downloads came
down whole, and a reload installed it. The owner asked for an automatic retry, and for the
failure to say that a reload tries again.

Built. A download that fails, or gets no byte for a minute, starts over ten seconds later, three
tries in all, before the failure is said (Up25). On the Mac a try is a new check, because Sparkle
downloads only in a session of its own. On Windows the updater got a stall timer of its own: the
request's two-hour timeout was all there was. About's failure line now says how to try again
(Up5), and the Mac says Stedding's own sentence for a failed download, because Sparkle's ends in
"Please try again later". Patch 0128.

The evidence. A test copy of the signed build, signed with the Developer ID and given a local feed
whose server sends 38% of the image and goes quiet, on real Sparkle. With every try stalled, About
said Updating through three tries, 71 seconds apart, then "The new version could not be downloaded.
Reload this page to try again."; a reload downloaded the image, and a quit installed it. With one
stall and About closed, the scheduled download tried again 70 seconds later, with nothing on
screen, and installed at the quit. Unit tests: `AppUpdaterMacTest` 13 and `WinAppUpdaterTest` and
`WinUpdateInstallerTest` 22, on the builds with DCHECKs. `UpdatesTest` on the Mac (release and
DCHECKs) and on Windows (DCHECKs). Every unit test on Windows with DCHECKs (1379). On the Mac
release build, every unit test (1391), after the fix below.

Not checked: a stall on an installed Windows copy. The next release's Windows n-1 check owes that
run, against a server that goes quiet. A real stall from GitHub was seen once and not repeated.

## 2026-11-05 -- 0.4.0 beta 10: Chromium 157.0.8103.39, issues 78, 73 and 45, links from other apps as a peek

The owner, after testing beta 9's fixes on the PC: a new window opens too close to the first;
issue 78 as they commented on it, issues 73 and 45, whatever else is fast, then a release, with
the pin moved to the latest point release of 157.

Built, each with a test. The pin moved to 157.0.8103.39, and the series applied unchanged. A
collapse keeps the pins selected in a folder listed, and a setting, off by default, keeps every
awake pin (S-418, issue 78). The device pickers, a site's file pickers and on-device translation
and speech work in a Space with an independent session; Chromium refuses them in any storage
partition that is not the profile's own, and an independent session is one (S-402, issue 73). A
site's permissions stay the profile's in every Space. The site panel's strip starts with Back,
Forward and Reload when the sidebar's top line has no room for them (S-414), icons sit centred in
their hover circles at 125% on Windows (S-415), and a second window has its corner buttons on
Windows (S-416, all issue 45). A link from another app can open as a peek (S-417, issue 74), and
a new window on Windows steps 22 points clear of the first (S-419).

Found on the way. The build with DCHECKs stopped on a link from another app opened as a peek: it
was marked as a page's navigation with no initiator, which a release build lets through. A link
with no initiator is now the browser's own, as it is in the little window
(`LittleWindowTest.ALinkAsAPeekKeepsItsTrust`). The peek's new row in the command bar broke K9
and was taken out. Two tests failed once each among their neighbours in the last runs, the device
picker because a bubble closes when its window loses the activation, and passed five of five
alone; they now run one at a time.

Checked: the suites on both platforms, release and DCHECK builds, and ASan on Windows; acceptance
on both, with a clipboard manager holding ⇧⌘C on the Mac, so Copy Link's toast was not seen in
that run; the update from beta 9 and the installer cycle on Windows; the Mac image notarized. Not
checked: the device pickers against a real board, which waits on the reporter of issue 73. The
owner gave the release its go-ahead overnight, before seeing the review folder, which holds both
platforms' captures.

## 2026-11-04 -- 0.4.0 beta 9: an empty Space's page, issues 74, 75 and 76, issue 45 on beta 8

The owner, in the morning: a screenshot of an empty Space beside an AI extension's tab group, a
look at the open issues, the Install chip still in the address bar, and a release fast; the pin
moves to beta 10.

Built, each with a test. An empty Space -- a switch to one, its last row closed, a Clear that
leaves nothing -- shows its own page rather than a New Tab row (S-408, tabs R66), and the page
says nothing of tabs asleep when the Space has none. "Show tab groups" on the bookmarks bar is
off at first: every saved group, the extension's included, had brought a chip and the bar to
each New Tab page (new-tab N9). A collapse folds a folder's awake pins but the one on screen;
the issue 35 rule had kept every awake pin listed, so a pinned folder seemed never to collapse
(S-409, issue 76). The sidebar's address field offers the extensions' row its whole room, so
pinned icons come back (S-412, issue 45). The toolbar's field shows no Install chip (S-413). The
peek settings say they are for links from pinned tabs; issue 74's recording showed the little
window, which they never change (S-410). A link's menu opens it in another Space, in that
Space's jar from the first request (S-411, issue 75).

Found and not fixed: at 125% on Windows the sidebar's icons sit a pixel left of their hover
circles, a rounding to pixels (S-415). Page buttons in the site panel when the top line has no
room for them waits (S-414).

Checked: the suites on both platforms, release and DCHECK builds, and ASan on Windows;
acceptance on both; the update from beta 8 on Windows; the Mac image notarized. Tests found
test-only dangling pointers to the empty Space's page, which closes itself, in three tests.

## 2026-11-04 -- 0.4.0 beta 8: the empty Space page, the download's start, the Mac's first run, a review of every change

The owner, overnight: finish everything planned for beta 8, have separate reviewers read the
changes, fix what they find, test both machines with a look at every changed state, and release.

Built. A Space with no row awake shows its own page (S-396, tabs R66): a stand-in tab the
sidebar does not list, on `chrome://stedding-space`, version A of the owner's mockups with six
tips drawn by the page rather than screenshots; it closes when another row shows and becomes an
ordinary row when an address is typed on it, and the session keeps none. A download's start
flies a 48 DIP chip from the page to the sidebar's downloads button, which rings once
(S-400, sidebar-panels Pn18); Chromium's flew a 26 DIP icon to the toolbar's button, which the
sidebar keeps hidden.

Reviewed. Three reviewers read every change since beta 7 (the Mac's window code; the sidebar's
top line, toolbar, toasts and site panel; updates, tidy names, the little window, imports and
sync). Fixed, each with a test: tidied download names pass Chromium's own file-name checks (a
right-to-left override, a name Windows reserves, a title's dot as an extension) and meaningful
names such as "annual-report-2026" stay; a year in a title is not a count; the important-update
bar retries when its window comes to the front, in the window in front; an empty folder icon
from before icons synced no longer erases another computer's; the welcome screen looks for Arc
and the Chromium family again, leaving only Chromium's importer list for the Import step; the
address field lays itself out when Copy Link is turned off; on Windows a shown address row ends
before the corner's window buttons; the camera row's mode keeps Close Window, a reachable frame
after a screen change, the window still under a tab drag, a torn-out tab's size, and kiosk mode.

The Mac. The round's Mac tests ran for the first time and found, all fixed: a crash at a quit
from full screen (the camera row's destructor read the freed browser); the row beside the
camera coming back 50 points down after a page's own full screen (seen on the real screen; the
menu bar is now hidden before the frame is set); on a 126 DIP sidebar the line showing the
address stacked as the rail's, hiding the field and the window's menu; and four camera-row
tests that waited too little or tested the wrong thing. The owner's question about the little
window over a full-screen Stedding: with a test copy full screen in its own Space and a Finder
window on another, a link handed over opened the little window on Finder's Space with no
switch, exactly as beta 7 does; only its size differs (1382×836 against 1000×700).

Not moved: the pin. Chromium 157.0.8103.39 is the stable point release on both platforms; a
move rebuilds most of the tree on both machines, which did not fit the night with the tests
after it. It is the first item for the next release.

The Mac's build with DCHECKs then found the camera row holding the BrowserView past its free at
every window's close (the dangling-pointer detector, in most browser tests); it now goes with the
widget, as the widget's own pointer does, and the Mac's image was signed again after it.

Released as 0.4.0 beta 8, on Chromium 157.0.8103.31, for both platforms. Checked: on Windows the
installed beta 7 updated itself to beta 8 from a signed copy of the feed (the update test's feed
server had stopped at its first line when run from a scheduled task, fixed in the tool) and kept a
300 DIP sidebar; the installer's upgrade, uninstall keeping the profile, and install; acceptance
on the installed copy, 39 steps; every suite on `win-release` and `win-checks` (1372 unit, 874
browser), and the same under ASan, with no report. On the Mac the signed and notarized image passed
`syspolicy_check distribution` and `verify-build`, acceptance on a test copy of it passed twice
(before and after the last fix), and every suite passed on `release` (1381 unit, 912 browser)
and on `mac-checks` (1381 unit, 912 browser, after the dangling pointer above was fixed; a toast test read the toast while it was still sliding in, and now waits for it). The captures are in `dist/review-2026-11-04/` (not in the
repository); the site's after-update page shows tidy names, the empty Space page and the bigger
little window. Not checked: S-394's notice (a look at the unified log could not see it on beta 7
either), S-393 with two computers, and S-399's last two tests.

## 2026-11-03 -- 0.4.0 beta 8, first part: main and side releases, important updates, tidy names, issue 45 on beta 7

Not released. The owner's final order for beta 8 (BACKLOG), done on the Windows PC while the
owner used the Mac.

Releases (ADR 0031). Any release that is not the main line -- Linux, Windows on ARM, a test
build for the Mac or Windows -- is a side release: `tooling/publish-side` makes it a GitHub
pre-release that is never latest, tagged `side-<kind>-<version>`, its files named
`Stedding-side-...`, and refuses anything that could pass for a main release. The updaters read
only the two feeds on main, so no installed copy is offered one; the site shows main tags only.
A release can be marked important (`tooling/publish-appcast --important "<reason>"`): the
sidebar's pill turns red and a bar under the page says why, once per launch, with Restart Now;
nothing restarts by itself (updates Up23, Up24).

Tidy names, promised for this release (S-398): pinned tabs' titles without the site's name,
counts and account, and downloads whose names say nothing saved under their page's title, two
switches off by default, rules on the device. Folder icons travel in the sidebar file and sync
(S-393). The welcome flow looks for other browsers only at its Import step, and the Mac no
longer probes Safari's data (S-394).

Issue 45's comment on beta 7 (S-403): on Windows the window's buttons go to the window's corner,
shown on hover, when the sidebar is on the left; the Mac's traffic lights always show; Install
App is a row of the site panel; the sidebar's field keeps the site's name and folds extension
icons into their menu instead of letting them run out of the field. The review's list (S-399):
a toast is centred when it is made, popups' and apps' bars are Chromium's band, the site's
blocker switch on a sign-in page shows the site's own setting, the menu moves into the field on
a line with no room.

A bigger little window (S-407; the owner, 2026-11-03: on a laptop it took about a third of the
screen, capped at 1000×700). The first cut laid it exactly over the page of the main window's
tab, which read as part of the browser, most of all over a full-screen window; the owner, the
same day: it floats as before, only bigger. It opens centred over the main window at four
fifths of its width and height; once the user resizes one, the next opens at that size; with
no window it is four fifths of the screen, centred (patch 0122, little E1). On the Windows
release build, over a maximised 1728×1036 window, a handed-over link opened at 1381×834 on the
window's centre, the sidebar and page showing round it; resized to 886×613 and closed, the
next link opened at 886×613 on the same centre. Its unit test and browser test pass there,
with the rest of the little window's and the peek's tests (10 unit, 33 browser).

Issue 73 (a site's device picker) did not reproduce on Windows: a browser test asks for a serial
port from a click and sees the picker.

Checked: on Windows, `win-release` built from the series as pushed (patches 0001-0121): 123 unit
tests of the round's areas passed, and 147 browser tests of them, after three tests were fixed in
the tests alone (the welcome and import tests waited for the sources before the Import step, and
the toast test read a toast after it had closed). Not checked: the Mac's tests of this round
(the traffic lights, the camera row, Sparkle's important item), a look on the real screen on
either platform, the full suites, ASan and acceptance, and the owner's review of every changed
state.

## 2026-11-03 -- 0.4.0 beta 7: the owner's list, issues 71 and 72, and a review of every change

Released as 0.4.0 beta 7, on Chromium 157.0.8103.31, for both platforms, with the owner's list of
2026-11-02 (a peek's edge, the welcome flow's privacy step, issue 45's version B, page bars
under the page, folder icons for issue 68, full screen on the Mac) and two issues filed that day:
a tab opened in the background is the next one Ctrl-Tab reaches (issue 71, switcher X6, a setting
on by default), and a sleep shows a row that is awake, so pins put to sleep one by one no longer
wake each other (issue 72, tabs R5, pins H3, H11).

The first final run on Windows found two DCHECKs new in this round, each stopping about a hundred
browser tests on `win-checks`: a page bar's text drawn on a layer that is not opaque with no
background under it, and the rail's layout naming the extensions lent to the address field. Both
were fixed with a test. Its first `win-checks` build had run clang out of memory at 20 jobs and
the sweep ran on stale binaries; the leg runs at 10 jobs now.

Before the release four reviewers read every change since beta 6, each an area. Fixed, each with a
test: the window's menu left the sidebar's top line when the line grew too narrow, and with the
address row gone it could be reached nowhere (sidebar Y51); on the Mac the traffic lights hid
with the sidebar on the right, where nothing could show them (Y53); a folder's icon kept its size
after a text size or density change, and its field kept the name field's accessible name (F42);
Sleep Tab on a New Tab page with every other row asleep opened another each time (R5). Weak
tests were made to fail when they should, and Chromium's infobar unit tests now run in the sweep.
The rest is S-399, for the next release; the owner's note on the download's animation is S-400.
The owner chose the empty Space's design from mockups (S-396), and tidy names for pinned tabs and
downloads, as local rules, are S-398.

The site's page after an update now shows what each release brought, with captures from the
release's own build (`stedding.dev`, `src/data/whats-new.mjs`); `tooling/publish-release`
refuses a tag the site has no entry for.

Checked: on Windows, an installed beta 6 updated itself to beta 7 from a copy of the feed and kept
its sidebar's width (S-390, twice, on two builds); the installer's cycle; every suite on
`win-release`, `win-checks` and `win-asan` (1362 unit tests, 858 browser tests; no DCHECK,
dangling-pointer or AddressSanitizer report), with two new tests fixed in the test alone; the
acceptance scripts, 39 steps, on the installed copy. A run while the PC was busy lost the window's
focus after a Space chip click (the logger showed the Claude desktop app in front) and lost the
fixture's keys after a build; run on a quiet machine every step passed. On the Mac, the signed and
notarized image passed Apple's distribution check, the acceptance run (87 captures, as beta 5's
run), and every suite on the release build and `mac-checks` (1371 unit tests, 886 browser tests).
Issues 71 and 72 were tried with the real pointer and keyboard on the signed build.

## 2026-11-02, evening -- the Mac's half of the owner's list, and page bars under the page

With the Mac free, its items of the owner's list, and what the owner saw on it:

- **Full screen follows the address row's rules** (toolbar T8, T10; S-378): hidden with the
  sidebar, the row no longer slides in with the pointer, the top keeps no empty band, and ⇧⌘D
  works there. The strip over the row is the window's colour, not Chromium's grey (T32).
- **The wheel in a sidebar shown at the edge** (S-386): it scrolls on the Mac too, with a wheel
  and with a trackpad's phased scroll (`tooling/drive`'s new `scroll` step). On the way: a
  layout after the slide, a scroll's among them, put the toggle of a sidebar expanded on hover
  back on the traffic lights' row (sidebar Y52).
- **Version B's last part** (sidebar Y53; S-391): with the address in the open sidebar, the
  traffic lights show only while the pointer is over the sidebar's top.
- **The owner's look at it**: the address row's buttons lent to the sidebar, the window's menu
  among them, in the sidebar's colours, not the row's dark ones (Y51); Back, Forward and Reload a
  size under the toggle, whose ink they now match (Y46).
- **Page bars under the page** (toolbar T54): "Stedding isn't your default browser", the reload
  a site's changed settings ask for and the like were Chromium's grey band over the page. The owner chose from rendered designs a pill in the
  window's colour under the page, rising over its bottom edge with a shadow so it is seen. A
  toast no longer steps under the bars (T38), and the page no longer moves down a point when
  one comes (T36).

Also: a Chromium browser test of the tab strip API did not handle the folder case and stopped
the Mac's `browser_tests` build; the notch row was explored and waits on the owner (S-392);
macOS showed a "tried to access your data from other apps" notice for the test copy (S-394).

Checked: on Windows, the full sweep on win-release (unit_tests 1351, components_unittests 45,
content_unittests 1, stedding_browser_tests 673 and 183 serial): two failures, each passing three
times alone after the fix below (`SidebarFormsTest.TheSlidOutSidebarsEssentialsTakeTheirPress`
needed a new way to lower the title band once bars left the top; `SpaceJarTest` timed out once).
On the Mac, the changed suites on the release build (address row, sidebar address, sidebar forms,
window buttons, rail); one menu test failed under load and passes alone. Every state was captured
on both platforms, dark and light, for the owner's review; nothing is released. Then the Mac's
full sweep on the release build passed: unit_tests 1360, components_unittests 56,
content_unittests 1, stedding_browser_tests 716 and 168 serial.

## 2026-11-02, later -- the owner's list after beta 6: a peek's edge, the welcome flow's privacy step, issue 45's version B

The owner chose the peek's edge from four styles rendered by a real build, then sent sixteen
items for the next version; Windows had them first, since the owner was using the Mac. Each is a
row of `BACKLOG.md`, S-377 to S-393. In this round:

- **A peek's edge** (peek P21, settings T47; S-377): a frosted rim round the card by default, so
  a dark card shows on a dark page; a soft glow or none is a setting.
- **The welcome flow's privacy step** (welcome W19; S-387; `PLAN.md` decision 20): Global Privacy
  Control (on), ad and tracker blocking (off; how it works, and that an extension can block more)
  and link cleaning, now off by default because it can strip the code a site credits a referral
  by. Seven steps.
- **Settings**: wide and centred is the address field's default, and the centred field gives way
  before the buttons at its end in a tight row (toolbar T48; S-379); the drift setting says what
  it does and owns the slash too (pins H12, H28; S-381, S-382); each Space in two lines (settings
  T48; S-384); Chromium's advertising features in plain words (T49; S-388).
- **The address row**: the page-info chip's icon on its label's middle (toolbar T52; S-380); a
  toast on the page's middle, as a card with a plain Undo (T53; S-383).
- **The sidebar**: closing to nothing slides the rows out whole (Y50; S-385); folders line their
  names up with the titles and can take an icon (folders F41, F42; GitHub issue 68; S-389).
- **Issue 45, version B** (sidebar Y51, site-controls Si13; S-391): Back, Forward, Reload and the
  menu at the top line's end; the field with the site button, Install App, Copy Link and the
  extensions; the site panel's ad-blocking switch.

Found on the way: Chromium's install command is on for every page, so Install App follows the
page's installability instead; an observer of a page's install state outlived it (the banner
manager is gone before `WebContentsDestroyed`), and 135 browser tests crashed at teardown until
the field rechecked after loads instead. With the real pointer on Windows, the wheel scrolls a
sidebar shown at the hidden edge, so S-386 is the Mac's. Still owed: the Mac's full screen (S-378),
the wheel there (S-386), the traffic lights on hover (S-391), issue 65 across a real update (S-390),
the notch (S-392), and the folder icon in the sidebar file and sync (S-393).

## 2026-11-02 -- 0.4.0 beta 6: peek over the page, Spaces that loop, the address row in the sidebar

Released as 0.4.0 beta 6, on Chromium 157.0.8103.31, for both platforms, with the round below:
issues 62, 65 and 66, the comment on issue 45 and the import step (patch 0119, and issue 65's fix
in 0004). On Windows the final build passed every suite on the release build, on the build with
DCHECKs and the dangling-pointer detector, and under AddressSanitizer, which found no memory
errors (1349 unit tests, 666 browser tests); the new features were tried there with the real
keyboard and pointer, an installed beta 5 updated itself to beta 6 from a copy of the feed, the
installer's cycle passed, and the acceptance scripts passed on the installed copy (39 of 39). On
the Mac (1358 unit tests, 707 browser tests) one test failed in both sweeps:
`SpaceWheelTest.ASidewaysWheelStepsThroughTheSpaces`, whose new steps for the loop end on a slide
that its reduced-motion step, right after them, found still going. The test now waits for that
slide (0119; 3 of 3 runs on both platforms' release and checks builds); no shipped code changed.
The Mac's acceptance run passed with 80 of its 87 captures as beta 5's: a clipboard manager
(Maccy) ran and took ⇧⌘C and, with its popup, the ⌃⌘N after it (trap 94). On the same signed
build ⌃⌘N alone made the split and Copy Link from the command bar showed its toast, and the
real pointer and keyboard tried looping Spaces, each way a peek closes, ⌘O and ⇧⌘O from a peek,
the hidden sidebar's edge and the import step, which found Arc and Chrome. Apple's distribution
check passed.

## 2026-11-01, later -- issues 62, 65 and 66, issue 45's second round, and the import step

The owner asked for GitHub issue 66 (Spaces that loop), a fix for issue 65 (the sidebar's width
after an update), the comment on issue 45 (a wider reveal edge, two essentials per row, the whole
address row in the sidebar with Windows' buttons on hover), issue 62 (Peek inside the window, the
small window kept as a setting) and a review of the welcome flow's import step.

- **Issue 65** (sidebar Y47): the session log is rebuilt from the live windows at every startup,
  and the rebuild dropped the sidebar's width and collapsed state, which the controller writes
  only when they change. The restore after the next restart -- an update's -- opened the sidebar
  at Chromium's 352 DIP. The rebuild now writes them, and a restored window with no width in its
  log takes the one last set. `RestoreTest.TheSidebarsWidthComesBack`, four launches, forces a
  rebuild and then a log with no width; without the fix both launches after them opened at 352.
- **Issue 66** (spaces B45, settings T44): "Loop around Spaces", on by default, for the keys, the
  swipe, the wheel and moving a tab; a switch round the end slides as the step goes.
- **Issue 45, the comment** (sidebar Y19, Y33, Y48, Y49; toolbar T50, T51; settings T45):
  "Edge that shows a hidden sidebar" (6, 12 or 24 DIP, 12 by default where it was 6); "Up to 2"
  essentials per row; with the address in the sidebar the address row lends its buttons -- the
  extensions, the pinned actions, the menu -- to a row under the sidebar's address, the same
  views, so their popups anchor there; on Windows the caption buttons move to the sidebar's top
  row and show on hover, so the address row goes there too.
- **Issue 62** (peek P20, settings T46): "Show a peek: Over the page", the default, shows the peek
  as a tab-scoped child widget over the pinned tab's page (`tabs::TabDialogManager`), the page
  made as a tab's (tab helpers), with its own dialogs over the card; Open as Tab moves the same
  page in. "In a small window" keeps the little window.
- **The import step** (import I43-I45, welcome W3): Chrome, Edge, Brave and Vivaldi join Dia in
  the Chromium family's table, each with its own block; a running browser is told by its profile
  lock, since Stedding on Windows is `chrome.exe`; Chromium's own importer rows offer only what
  their source can bring, with search engines and autofill where it can; Settings and the command
  bar open the step.
- Found on the way: the hidden sidebar's clip, refreshed only by a layout, could stay on after the
  slide's end under load and hide the edge's shadow (sidebar Y19).

## 2026-11-01 -- 0.4.0 beta 5: the command bar's icons, and issue 45's settings

Released as 0.4.0 beta 5, on Chromium 157.0.8103.31, for both platforms. The owner asked for GitHub
issue 58 and, with no pull request come, for issue 45's three sidebar ideas to be built here, and
for one release once both were in. Patch 0115 gives the command bar's rows their sites' icons and
moves what a row says besides its title to its right end (commandbar K38). Patch 0116 makes the
hidden sidebar's rest at the edge and the sidebar's speed settings: the animation controller runs
a motion over its time scaled on the clock, so every keyframe keeps its place (motion O9). Patch
0117 puts Back, Forward, Reload and the page's site at the top of the sidebar, where the window
feeds them what it feeds the address row, and hides that row while the sidebar is open under its
exceptions; and fixes how many essentials a row holds (sidebar Y33, Y46; toolbar T50). Patch 0118
is an Appearance card, browser-wide: the window's colour, the Space's tint and the rows'
highlight, read by the colour mixer from process-wide values, every window re-themed on a change
(settings T41 to T43). S-370 was kept as it is on the owner's word, the better look; S-327 closed
once a recording showed the check mark for its 1.5 seconds, the stills having been taken late
(trap 142). The first final run found a crash in a test of the sidebar's top, a test window with
no commands, fixed in 0117 before the builds that shipped. The Mac's DCHECK sweep had a
frame-timing check wait 183 ms once (S-372): that build is about twice as slow as the release
build, and its bound is now twice the release's. Both platforms' final sweeps, the Windows DCHECK
sweep, the installers, a beta 4 to beta 5 update on Windows and both acceptance runs passed.

## 2026-10-31 -- 0.4.0 beta 4: the sidebar comes back whatever On startup says

Released as 0.4.0 beta 4, on Chromium 157.0.8103.31, for both platforms. S-323 (issue 43, the
owner's call of 2026-10-30) is patch 0114: with On startup set to the New Tab page or to specific
pages a launch restores the session with `RESTORE_SIDEBAR_ONLY`, which keeps each normal window's
essentials, Space pins, folder tabs and the splits holding one, and then adds the New Tab page or
the pages; the Dock and the no-window restore follow it, and the archive marks only the tabs that
come back, so the loose ones stay rows. Its tests failed first. The sweeps found two tests that
held the old rule (the archive's unit test, and a crash-restore test that used the New Tab page to
stand in for a launch after a crash), and that every launch's New Tab page and every quit's ended
up in the archive: archive A16 keeps them out. A `mac-checks` sweep had run that directory's
binaries from the morning, because `tooling/dev test` built `out/release` whatever
`STEDDING_TEST_OUT` named; it builds the directory it runs now (trap 141). On the Mac's build with
the real pointer, On startup chosen in Settings, a quit and a launch brought back the pin and the
folder and left the rest under Archived. Both platforms' final sweeps, installers, a beta 3 to
beta 4 update on Windows and both acceptance runs passed. S-371 (a compositor DCHECK) and S-372 (a
frame stall) each happened once and not again.

## 2026-10-31 -- 0.4.0 beta 3

Released as 0.4.0 beta 3, on Chromium 157.0.8103.31, for both platforms: Duplicate in the short
tab menu (issue 63), a split's address field over the active pane and the buttons at a centred
field's end on Windows (issue 14), and a sleeping pin that folds back into its collapsed folder
(issue 35). On the final build every suite passed on both platforms (the Mac 1348 unit and 681
browser tests, Windows 1339 and 639). The acceptance scripts passed with the real pointer on the
Mac's signed build, as a copy with its own identity beside the owner's running Stedding, and on
Windows' installed copy, which an installed beta 2 had first updated to through a local feed. The
installer repaired, uninstalled keeping the profile and installed again.

The real-pointer checks closed S-357 (Copy Link and Install answer a click at Compact on both
platforms) and S-364 (the field follows the active pane on the Mac, and on Windows from 1300
pixels wide). They found S-370: in a Windows window about 1040 pixels wide the right pane's part
of the row is mostly the caption buttons, and the field stays over the left pane when the right is
active; the notes list it. S-327, the check mark, shows only on the Mac: on Windows it was up a
second after the click. The Mac image was signed from a worktree of the repository, since the
owner's running Stedding was the app in `dist/signed`, which `tooling/sign-release` empties.

## 2026-10-31 -- Windows on the beta 3 fixes, four tests that were wrong, the Windows leg two at a time

Not released yet. The PC moved onto the series of 2026-10-30 with `tooling/move-series`, which
wrote ten files, and built `win-release` in 2 minutes and `win-checks` in 6. Every unit test
passed on both. The browser tests of Duplicate (S-363), the split's address field (S-364) and
the presses at a centred field's end (S-357) pass on both, the last with the real caption
buttons' reserve; S-357 still owes a real click. S-334's four tests ran clean in the Windows
serial leg in every run, which closes it.

Four tests failed for reasons of their own. Each was logged until the cause showed, fixed in the
test, and seen failing first:

- `CertificateReportsTest.NoCertificateIsReported` (S-365, patch 0074): the first page's
  favicon is fetched after the page has loaded, over a connection of its own, and when that
  came after reporting was switched on, its report took the next site's place, since the cache
  keys a report on its SCTs alone. The test waits for that request now. 5 of 24 runs failed
  four at a time before, 0 of 40 after. No report went out before the switch in any run.
- `MotionFramesTest.HiddenOmniboxPopupsFollowTheSidebarOnceAMotion` (S-366, patch 0077): the
  extra move was the hidden popup's height alone, the page's late answer to the test's own
  show and hide, landing 1 ms into the collapse. The counter counts a window's place, its
  origin and width: 12 of 12 passed, and with the popup's hold taken out it still fails (19
  and 22 moves), so it still catches what motion O8 fixed.
- `FolderTabsTest.AnAwakePinFoldsAwayWhenItSleeps` (patch 0112) crashed on `win-checks`: it
  never started its test server, which a build with DCHECKs refuses and a release build lets
  pass. The `mac-checks` sweep of 2026-10-30 had missed it because its binary was built before
  the round's last four tests (trap 138); `tooling/dev test --no-build` now names a binary
  older than the series. On a current `mac-checks` build the whole sweep passed, with one
  timeout that printed nothing and did not come back in 30 runs (S-368).
- `WelcomeFirstRunTest.TheFlowOpensOnceAndNotAfterFinish` (S-367, patch 0104) failed once on
  Windows: after the restart the fixture's `browser()` is the window last active, which can be
  the popup the step before opened. It reads the first tabbed window now.

On Windows, four at a time, every one of seven runs had a few drags, bubbles or keys that
failed and passed alone, a different few each time (S-369). Six moved to the serial leg, and
others took their place; two at a time, all three runs passed. `tooling/dev` runs the Windows
leg two at a time now, about 70 seconds longer.

After the push the PC moved onto it, rebuilt the browser tests and ran the browser leg on both
builds: all 639 tests passed on `win-release` and on `win-checks`, the four fixed tests among
them, with no DCHECK or dangling-pointer report. That closes S-367 and S-369.

The Mac's release sweep on the fixed tests passed except one more silent timeout
(`HorizontalStripTest.VerticalTabsComeOnAsADragEnds`, 8 of 8 after; S-368). Trap 139: `tooling/dev`
edited while a sweep ran it would have run shifted lines when the sweep returned, so it was put
back until the sweep ended.

## 2026-10-30 -- After 0.4.0 beta 2: Duplicate, and a sleeping pin folds away

Not released yet. The short tab menu offers Duplicate (GitHub issue 63, S-363), and the copy of
an essential or a Space pin is a plain tab where a new tab opens, the owner's choice: Chromium's
copy of an essential had been a second essential (tabs R64, patch 0110). A pin a collapsed folder
keeps listed while it is awake folds away when it is put to sleep (GitHub issue 35, S-356, patch
0112). Issue 14's buttons in a centred address field answer the window's hit test on both
platforms; a real click on Windows is still owed (S-357). `tooling/move-series` moves a checkout
onto a newer series by writing only the files that differ (trap 89). Every GitHub issue was read
again and the open ones labelled.

Issue 14's newest comment showed the address field of a side-by-side split drawn across both
panes. The field is now the active pane's at every width (S-364, toolbar T49, patch 0113), and
the spacers either side of a centred field no longer lie over its end. That was S-357: on Windows
the field moves toward the caption buttons, and the right spacer, still where the layout put it,
took the presses of the buttons at the field's end; the test now lends the Mac's row Windows'
reserve and failed first. Copy Link's check mark
(S-327) stayed its 1.5 seconds in both browser tests, timed now, so the short mark seen with
the real pointer is not reproduced in a test yet. Four Windows browser tests that time out only
four at a time run in the serial leg (S-334).

The owner's calls on the open issues: Manifest V2 stays off, and the FAQ says why (S-362,
closed); a closed little window stays closed (S-355, closed); command-bar favicons are a yes
for after the core-loop gate (S-361); peek attached to its tab is for later (S-360); the
sidebar comes back whatever On startup says, in a later beta (S-323); Sparkle 2.10.1 ships
with the next pin move (S-358).

## 2026-10-29 -- 0.4.0 beta 2: the fixes of the 2026-10-28 review

Released as 0.4.0 beta 2, on Chromium 157.0.8103.31, for macOS and Windows: the faults of the
2026-10-28 review (S-338 to S-351, and S-326's little window brought back by the session), and
three more. An extension's omnibox keyword typed in the command bar reaches the extension
(S-352, closed: a handler the omnibox API sets through a target with no dependencies). Sidebar
sync's last faults (S-353): an own essential moved to the shared row is shared also where every
Space has its own session, and waits for Move now when it is loaded; a shared essential moved to
its own Space's pins stays in that Space; the newer of two backups made in the same second is the
one kept. S-354 did not reproduce: a closed little window leaves nothing for ⇧⌘T at all, and
whether it should is S-355, for the owner. GitHub issue 43 is answered by its reporter: it
happens only with On startup set to the New Tab page or to pages (S-323).

The Windows sweep, `tooling/dev test all`, had run no test since the Keychain's component tests
joined it: their filter matched nothing on Windows and the lister stopped the run. They join on
the Mac alone now. The 2026-10-29 ASan run on Windows ran out of commit charge with four tests at
a time; two at a time it passed. The review's rows stay open until each fix is seen on a real
build. How the release was checked is in its notes.

## 2026-10-28 -- 0.4.0 beta 1, and a crash in 0.3.0 beta 22

The owner found that Remove, in the question a pinned tab's x asks, crashed 0.3.0 beta 22: the
tab's close took its row at once (the animations off), the row closed the question still open
over its x, and that close reached for the x's highlight on a row already out of the window, a
CHECK. The x is no longer lit while the question shows, and Remove closes the tab once the
question has closed (pins H29, patch 0110). Released as 0.4.0 beta 1 on Chromium 157.0.8103.31,
with issues 14, 35 and 42 and the pinned-folder drop.

A read of the whole series, each finding then checked against the code by a second reading
that tried to refute it, confirmed 107 faults out of 126 raised. All were already in 0.3.0
beta 22, so none held the release back. They are S-338 to S-351, by area, in the order they
will be fixed: cookie jars, a private window's Clear, a pin's Leave-site question, the first
launch's profile move, sync, updates and captures first, for 0.4.0 beta 2.

## 2026-10-28 -- GitHub issues 14, 35 and 42

On main, and not in a release; the owner asked for all three.

- Issue 42: coming back to a Space lands on the essential used there last, ahead of the pin
  the Space was entered on (spaces B3, folded into patches 0075 and 0083).
- Issue 35: a collapsed folder keeps listing a pin that is awake; asleep, it folds away
  (folders F3, patch 0112).
- Issue 14: Settings › Stedding › Address field, full width or a field centred on the page at
  800, 640 or 480 DIP, the row beside it moving the window (toolbar T48); and no "Ask Google
  about this page" in the focused field (privacy Q17). Both in patch 0113.
- Issue 43 needs no code: a ⌘Q is restored when On startup is Continue where you left off; the
  report fits the New Tab page setting (BACKLOG S-323).
- Found by the owner: a tab dropped on a collapsed pinned folder joined it loose, and the
  folder, of two kinds then, left the pinned run. A tab that joins a pinned folder now becomes
  one of its pins, from a drop or New Tab in Folder (folders F38; patches 0083 and 0093).

## 2026-10-28 -- Every document reviewed

Every document was checked line by line against the patches, the tooling and the releases,
rewritten where it was false, stale or long, and checked again for errors. The records were
cut to what is cited: the release-notes archive is gone (GitHub keeps every release's notes),
the history archive is the table of closed items, the 2026-09-26 audit is an index of its ids,
and each trap is its lesson.

## 2026-10-28 -- GitHub issue 50: the minus first

On main, and not in a release. Patch 0110 (pins H29) shows a minus on every Space pin that is awake, on screen or not, so the first press only puts it to sleep at its home. Once it is asleep there, the button is the x that asks *Remove this pinned tab?*, with Cancel the default. Remove unpins and closes it, and Reopen Closed Tab brings it back. 0.3.0 beta 22 still asks on an awake pin that is not on screen. A discard tells the row before the tab holds its new contents, so the row decides again once it does (`docs/HANDOFF.md`, trap 135).

## 2026-10-28 -- Chromium 157 prepared, not released

The series sits on Chromium 157.0.8103.31, M157's stable cut, and is merged into `main`. Google's schedule puts M157 on stable on 2026-11-03. It is unreleased: 0.3.0 beta 22, on Chromium 156.0.8078.48, is the latest release, and the next would be 0.3.0 beta 23. The rebase changed 69 of the 110 patches and added 0111, which puts `BrowserWithTestWindowTest`'s browser and window back (`docs/HANDOFF.md`, trap 134). The last commit of `main` on the 156 series is `1791465`.

Patch 0074 turns off `kUseActionsForBrowserCommands`, under which no Stedding command ran, and `kWebAppInstallDialog`. Add to Dock and Install page as app are built on the dialog M156 shows, so M157's new dialog stays off. M157 pins an extension to the toolbar when it is installed, and Stedding follows that until the owner decides (`S-241`). Upstream tests of Chromium's sidebar header are disabled because the window hides its combo button and segmented control, and the group-focus-mode test because the tab menu does not offer that mode. `gn check` is `S-335`. An installed beta 22 updated from a local feed into a 157 build on both platforms and brought its tabs back.

## 2026-10-27 -- 0.3.0 beta 22: GitHub issues 50, 48 and 13, pull request 49

Released 2026-10-28 as [v0.3.0-beta.22](https://github.com/ysalitrynskyi/stedding-browser/releases/tag/v0.3.0-beta.22), on Chromium 156.0.8078.48, for macOS and Windows, with both update feeds. The site and the Homebrew cask follow. Issue 50 (patch 0110, pins H29), as shipped: on a pinned tab that is not on screen the x asks *Remove this pinned tab?* before it unpins and closes it, and on the pin on screen the button stays a minus that sleeps the tab. Issue 48: Copy Link, with its toast, in a little window. Issue 13: Settings › Shortcuts can trade the Space keys and the row keys, or move either set to ⌃⌘ (Alt+Shift on Windows). Pull request 49: ⌘T on a folder's last tab, when it is the window's last, opens below the folder.

## 2026-10-27 -- Pull request 49: ⌘T on a folder's last tab (S-324), released in beta 22

An outside contributor's fix for `S-324`, in patch 0057 (folders F25), released in 0.3.0 beta 22. Chromium marks a tab typed at the end so that closing it goes back (`AddWebContents`), and that tab was filed into the opener's folder. The insert now keeps it out. Links and duplicates still join the folder. As sent, the change did not compile and would not have fixed the bug: it read `add_types`, which the insert does not have, and ⌘T carries `ADD_INHERIT_OPENER` too.

## 2026-10-27 -- GitHub issues 48 and 13, released in beta 22

Built this day and released in 0.3.0 beta 22 for macOS and Windows. Issue 48 (copy-link L7): a little window has Copy Link and the toast that confirms it; a popup has neither. Issue 13 (shortcuts Z23): a menu under the Space row of Settings › Shortcuts lets the Spaces and the rows trade ⌘1–⌘9 and ⌃1–⌃9, or moves either set to ⌃⌘ (Alt+Shift on Windows). Two older defects found the same day stay open: `S-326`, a little window comes back at the next launch as a plain popup, and `S-327`, Copy Link's check mark shows for a fraction of a second.

## 2026-10-27 -- 0.3.0 beta 21: GitHub issues 42 to 46

Released as 0.3.0 beta 21, on Chromium 156.0.8078.48, both platforms and both feeds. Issue 44: a popup or a new window opened from a tab inside a folder is no longer filed into the opener's folder, which had crashed (folders F25). Issue 43: on the Mac, with Continue where you left off, the Dock brings the last window back (windows G9). The reporter's "⌘Q too" is not reproduced (`S-323`). Issue 42: a Space switch lands on the tab used most recently (spaces B3). Issue 46: the blocker's switch says that ads a site serves itself, such as promoted posts, still show (blocker Bk9, Bk21). With the animations off, ⌘S no longer crashes while a sidebar panel is open (sidebar panels Pn4, `S-322`). ⌘T on a folder's last tab was found here (`S-324`) and fixed in beta 22.

## 2026-10-26, late night -- 0.3.0 beta 20

Released as 0.3.0 beta 20, on Chromium 156.0.8078.48, both platforms and both feeds: the Settings work below, the wording pass, the Shortcuts list's remove buttons, and sync that names any folder.

## 2026-10-26, night -- Settings with room

Settings › Stedding stays one long page, with room above and below every row, and the long descriptions cut to one short line (settings T13, patch 0109). Export, sync and the Arc import moved to a Sync and import card, and each Space names its session switch. Sync works with any folder the computers share. The "nothing seems to sync" note no longer shows for Syncthing, Nextcloud, ownCloud, MEGA, Seafile, Synology Drive, Proton Drive, Tresorit, pCloud or Resilio (sidebar-file Sf42, patch 0106). The Shortcuts list's remove buttons show their × again. On macOS the build's free-space check reads the space Finder shows, purgeable space included, where `df` counts only empty blocks (`tooling/lib.sh`).

## 2026-10-26, evening -- 0.3.0 beta 19

Released as 0.3.0 beta 19, on Chromium 156.0.8078.48, both platforms and both feeds. Settings › Stedding is a card per group, with the groups' names at the top (settings T13, patch 0109). "Mark pinned tabs that left their page" is off by default (pins H28, issue 36). Turning off a Space's own session asks when only apps use it, and names them (sessions S10). A key after a held press is no longer taken for a peek (peek P18). From the same day, and in this release: a pin dropped on the New Tab row leaves the pinned run when nothing sits below it, and a tab dragged to the top of a Space with no pin is pinned (issue 41); the sidebar's text stays put when a page's colour arrives (`S-316`, patch 0105); a separator survives a second restart; a search form and a closed essential stay with their own Space's cookies.

## 2026-10-26 -- 0.3.0 beta 18: the owner's round, a review, then fixes

Released as 0.3.0 beta 18, on Chromium 156.0.8078.48, both platforms and both feeds. A Space's colour tints the sidebar's ground and nothing else, and the light ground is a grey (patch 0105). The first peeks carry a one-line note on what a peek is (peek P19, patch 0106), and sync through a folder names the folders that work (sidebar-file Sf42). Separators come from a row's menu (sidebar Y45, issue 19, patch 0107). The command bar's rows light under the pointer. A Shift-click on a Space's own essential uses that Space's cookies; History and Downloads page past the first screen; a tab moved to another Space is the one on screen; a private window does not search history. Patch 0108 joined the short browser tests, and the browser tests run four at a time (`tooling/dev`).

## 2026-10-25, night -- 0.3.0 beta 17: issue 38, the sidebar's foot, issue 37

Released as 0.3.0 beta 17, on Chromium 156.0.8078.48, both platforms and both feeds. Browser sign-in is never offered, and Chromium's first-run sign-in screen does not open, including when Google's OAuth variables are set (privacy Q16, welcome W18, patch 0104, issue 38). History moves to the end of the Archived line, which is smaller and fainter; the bottom row keeps Downloads and "+" at its ends and centres the Space chips (sidebar Y44). The command bar casts a shadow and has a hairline edge (commandbar K36, issue 37). Moving focus with F6 no longer crashes (patch 0103). The AddressSanitizer run owed from beta 16 passed on Windows.

## 2026-10-25, evening -- 0.3.0 beta 16 released

Released as 0.3.0 beta 16, on Chromium 156.0.8078.48, both platforms and both feeds: the Peek and sidebar notes and the features in the entry below. Before it, a blocker's list that arrived twice was fetched once, the right-hand sidebar's toggle lined up with the address row, and the History panel could close while a query was still pending.

## 2026-10-25, day -- the owner's notes on Peek and the sidebar, wave 1 built

Peek can be a click or a press held 0.3 s or 0.5 s, and with a hold a plain click follows the link in the pinned tab (peek P18, welcome W16, patch 0102). The sidebar's text is 14 unless another size is chosen (sidebar Y2, welcome W17). In macOS full screen the address row stays when the sidebar is collapsed (toolbar T8, patch 0092). The same day: History and Downloads in the sidebar, the sidebar on the right, clean links, shortcuts the user can change, site controls in the page info, import from Dia and from Safari's export, export of all Spaces, sync through a folder, and ad and tracker blocking, off until it is turned on.

## 2026-10-25, morning -- Peek on by default

The owner chose Peek on by default (`PLAN.md` decision 2). A fresh profile's pinned tab peeks a link to another site, and Settings › Stedding turns it off.

## 2026-10-25, night -- Peek rebuilt on the little window

Peek is a little window over the window (patch 0088, peek P6): a whole tab, so dialogs, permissions and the address row work, and the page is loaded in the pin's own jar (P11). Only a click from the pin on screen peeks. Open as Tab (⌘O) and Open in Split View (⇧⌘O, beside the pin; Ctrl+Shift+O on Windows, the bookmark manager's chord, which a little window takes) move the page without a reload (P7, P9). An essential's peek offers the tab alone. Escape or a click on the window closes it, and a click on the same link opens it again (P14). A redirect is judged by where it leads, and a sign-in page stays in the pin (P15, P16). The window's size is set once it exists, so a little window and a peek open at their own size, and a peek opens with the page focused. Whether a Space pin that joins a split leaves the pinned run is not decided (splits J5, `S-102`).

## 2026-10-25, after midnight -- 0.3.0 beta 15 released

Released as 0.3.0 beta 15, on Chromium 156.0.8078.48, both platforms and both feeds: Edit Space, the welcome flow's new look, and GitHub issues 26, 27, 29 and 30. Before the release, Edit Space applied its colour inside the theme's walk of the views, and a test helper read a dialog widget Windows had already freed. From the next release `tooling/package-dmg` signs, notarizes and staples the disk image. Both platforms updated from beta 14.

## 2026-10-24, late -- Edit Space: any emoji, any colour, one for each look

Edit Space is a window of its own, from the Space menu and from Settings (spaces B41–B44, `S-99`). The icon sits beside the name. An Icon tab takes any emoji, typed, pasted or from the system's picker, thirty-six to press, or none. A Colour tab takes one colour, or one for the light look and one for the dark, from twelve colours with a deeper and a softer step, or a custom colour. The Space keeps the dark look's colour in the profile, and the window uses the colour for the look it is in.

## 2026-10-24, night -- three GitHub issues fixed, the issues labelled

Issue 29 (`S-298`, pins H14): a link opened from an essential, with the pinned run starting in a pinned folder, stayed above the run and drew every pin under the Clear line. Issue 26 (`S-299`, tabs R63): a row dropped in the first place under the Clear line became a pin. Issue 27 (`S-300`, folders F40): a tab could enter a folder only by its header; a row dragged over an open folder's rows now takes the place the pointer shows. Issue 30 (`S-301`, tabs R33, R35): after a close, the tab used before comes back, an essential included. Issue 31 is routing already (`docs/features/routing.md`); the owner asked what is missing.

## 2026-10-24, evening -- betas 13 and 14, and the welcome flow's new look

0.3.0 beta 13, the three items in the entry below, and beta 14 went out on 2026-10-24. Beta 14 asks to be the default browser with one large button (welcome W5) and gives each step a glyph (W13). Arc for Windows was checked against a real install (import I27). `S-297`'s harness wait runs one at a time on Windows.

After beta 14 the first start opens on a welcome screen ahead of step 1 (welcome W14): the mark, the name, what the six steps set up, a note when Arc is on the computer, and a drawing of the window, with Get started and Skip setup. The header names the six steps (W15). The appearance step's choices are drawings of a window in that look (W4), and the default-browser step draws a link opening in Stedding (W5). Released the next day as 0.3.0 beta 15.

## 2026-10-24 -- after beta 12: the drag into the essentials animated, Google Pay in a Space, Arc import on Windows

0.3.0 beta 11 and beta 12 went out on 2026-10-23 and 2026-10-24. What they changed is on the [Releases page](https://github.com/ysalitrynskyi/stedding-browser/releases). Then, released as 0.3.0 beta 13: a tab dragged across the essentials' edge is a floating copy, a card over the essentials and a row over the list, and nothing is pinned until the drop (pins H27, issue 16, `S-289`). A Space with its own session is offered no payment app, so a payment window cannot use the shared session's accounts (sessions S36, issue 25, `S-296`). Arc for Windows is read from its Store package, and its passwords are unsealed with Local State's DPAPI key and AES-256-GCM (import I27, `S-81`). Before that release, the import looked for Arc in the Mac's folder on every platform and looked up the Store package on the UI thread; the lookup now runs on the pool. `tooling/fold-fix` folds a new file into a patch.
## 2026-10-23, before dawn -- the Windows update that never came, 0.3.0 beta 9 and beta 10

0.3.0 beta 9 and beta 10, both in patch 0078 (`S-279`). On Windows a download that fails tries again within the hour, as a feed that cannot be reached already did. The installer downloads at LOW priority, above the idle priority that starved the write while the browser was busy. Both publish-appcast scripts download the release's file and check its checksum before they write the feed. `S-279` remains open on a failure in the minutes after publishing, with nothing polling the window.

## 2026-10-23, small hours -- a drag into the essentials and out, 0.3.0 beta 8

0.3.0 beta 8 (patch 0086, `S-277`, GitHub issue 16, pins H27). A tab dragged over the essentials, or the room above the Space's title, becomes an essential where it is dropped. An essential dragged onto the list stops being one there: a tab under the Clear line, or a pin of the Space above it.

## 2026-10-22, late night -- little windows on Windows, essentials that shrink to fit, 0.3.0 beta 7

0.3.0 beta 7 (patch 0085). On Windows a link from another app opens in a little window when that setting is on and no route takes the site, and otherwise in the Space set for those links (`S-56`, little E10, routing D3). The window keeps Windows' title bar. Ctrl+O moves the page into the main window, and Ctrl+Shift+O into a split. The essentials put up to four cards on a row, then two rows, the first the fuller, and a third only once a card would be narrower than the rail's square (sidebar Y33, `S-276`, GitHub issue 15).

## 2026-10-22, night -- after beta 5: a drag across the Clear line, the Copy Link button's hover, a session for every new Space

0.3.0 beta 6. A row dragged across the Clear line takes the pin of the side it lands on, and the line moves during the drag to where the drop would leave it (pins H14, `S-271`, patch 0083). The Copy Link button lets go of its press when the pointer leaves, because the action opens no bubble (copy-link L7, `S-273`). "Give every new Space its own session", off by default, starts each new Space with its own session and, when turned on, asks whether the Spaces that already share one should have their own too (sessions S35, settings T29, `S-274`, patch 0084).

## 2026-10-22, day -- the owner's round after beta 4, GitHub issues 8 and 11, 0.3.0 beta 5

0.3.0 beta 5 (patch 0083). Copy Link is a page action before the star (GitHub issue 11, copy-link L7, settings T28): a click copies the clean link, an Option-click or Alt-click the Markdown link, and "Show the Copy Link button" is on by default. A Space with an Independent session has essentials of its own and shows only those (GitHub issue 8, ADR 0028, spaces B6, sessions S8); turning the session off makes them its pins, and the warning that pinning signed a tab out is gone (sessions S33). A hover card shows the tab's memory, CPU and network after 2 seconds (pins H25). A tab held on another Space's chip switches to that Space (spaces B12), and a folder goes into another by its header (folders F39). A close no longer jumps to a row scrolled out of view (tabs R33), a long list scrolls half a row past its end (sidebar Y30), folders are not greyed (tabs R7), a link's tab sits just below its page and "Show tabs under the tab that opened them" is off by default (settings T26), a pin sent home shows its home's title at once and a pin on the New Tab page takes its first page as home (pins H1, H3), and a link from a nested pinned folder no longer unpins it (folders F38). The New Tab row takes a hover (GitHub issue 12, sidebar Y32), a scroll moves the hover to the row under the pointer (sidebar Y31, pins H26), a tab group made with animations off no longer crashes (patch 0071, `S-269`), and `S-270` records Widevine, which waits on the owner's licence application.

## 2026-10-22, night -- the owner's three open decisions, the folder header for Narrator, 0.3.0 beta 4

0.3.0 beta 4 (patch 0081). ⌘N and Ctrl+N open a window on the Space they are pressed in; a window with none to come from still opens the first (windows G6, `S-145`). Settings → Stedding → Tabs → "Show the bookmark bar and the star" brings them back after Turn Bookmarks into Pinned Tabs (settings T27, WIN-15 option B, `S-142`). That command asks first when it would add more than 50 bookmarks (import I16). A folder header answers Expand and Collapse, so Narrator can open and close a folder (folders F4, patch 0070).

## 2026-10-22, small hours -- the checks after beta 2, and 0.3.0 beta 3

0.3.0 beta 3 (patch 0077, toolbar T31). A read of the page's top edge that finds no surface, or whose copy fails, is tried again, so the address row does not keep the page's declared colour on a slow machine, including both parts of a split.

## 2026-10-21, night -- child tabs, the owner's Arc import checked, 0.3.0 beta 2

0.3.0 beta 2 released patches 0078, 0079 and 0080. A link opened in a new tab, or a page's own window, sits under the page that opened it, drawn a level to the right; the tree survives a restart, and a closed parent's children move up (tabs R56–R59, settings T26, patch 0080). The indent was on by default that night. An Arc folder that held only other folders comes across as a folder, in Arc's order (`S-48`).

## 2026-10-21, evening -- after 0.3.0 beta 1: quieter defaults, a split's row, the Space row, folders

Patch 0078, released the same night in 0.3.0 beta 2 (`S-258`): the undo toast, the "Opened in <Space>" notice and the hint for leaving a full screen you started are off until turned on, and the updater checks at launch when the last check is over an hour old, then every six hours. The warning that pinning out of an Independent session signs the tab out stayed on. Patch 0079: each part of a split's address row ends at its pane, with the window's ground in the gap (toolbar T41, splits J16); Space chips shrink to 16 DIP before they turn to dots, and the trailing inset stays 10 DIP (spaces B24); a collapsed folder shows no count of its tabs (folders F33).

## 2026-10-20 night to 2026-10-21 -- the owner's notes on beta 21, the Chrome 156 stable pin, 0.3.0 beta 1

0.3.0 beta 1 (patch 0077) is the first of 0.3, on Chromium 156.0.8078.48 after the pin moved to that stable release (ADR 0007). It is the first build published as the repository's latest release rather than a pre-release, and a GitHub issue is a suggestion unless it reports a bug (PLAN.md decision 16). Essentials stayed shared that night (GitHub issue 8 declined, `S-254`). Closing a pin or an essential unloads it and sends it home (decision 11, pins H3, H9, H16); a folder can join the pinned run and is renamed only from a double click on its name (folders F38, F4, decision 12); the rail follows the row height (sidebar Y8, Y12); a site keeps its favicon on pages that name none (tabs R54); address-row buttons hover in the row's colour, every chip fits, and a newly pinned extension shows at once (toolbar T42, T43, T44); the empty top of the window is the title bar (sidebar Y29); an extension window opens over full screen on the Mac (windows G8). A sideways scroll over the sidebar steps one Space (GitHub issue 10, spaces B39, decision 15), and on the Mac a little window has Open in Stedding and Open in Split View, with no title bar and its traffic lights in the address row (GitHub issue 9, little E7–E9, `S-157`). Tabs given on the command line load (`S-251`: the certificate verifier passes a change on only once it has verified a certificate), and the sidebar's collapse, expand and Space switch ease out, with hidden omnibox popups following the field once a motion ends (motion O4–O8). A drag from the rail splits in place (splits J10, J11); Escape during Ctrl+Alt+E stays in the browser (toolbar T39); restored tabs draw asleep (tabs R46); the rail shows hover cards (pins H19); a double click renames the row it landed on (tabs R14); a playing pin drops its speaker mark when closed (pins H24); the pin's Close item shows its shortcut (menus M1); and vertical tabs coming back on as a drag ends no longer crash (`S-253`, tabs R55).

## 2026-10-19 night to 2026-10-20 -- the planned fixes, six features, the owner's look notes, beta 21

0.2.0 beta 21 (patches 0071 to 0076). Six features in patch 0075: a tab dragged onto the page makes a split (`S-113`, GitHub issue 7, splits J10); a close shows the tab used last (`S-112`, tabs R33); only the selected tab loads at launch (`S-110`, settings T22); tabs sleep on a timer and under memory pressure, with Sleep Other Tabs (`S-111`); the Mac's hover cards show a picture of the page (`S-115`); with the address row hidden, its controls are in the command bar and ⌘E cycles extensions (`S-104`, toolbar T39). Patch 0076: the split's address row takes each pane's colour (toolbar T41), tabs on top are pills (tabs R49–R53), and the rail's glyphs, emoji included, sit on one centre line (sidebar Y28). Patch 0074 turns on the features Chrome has launched for everyone, Google's key pins and Certificate Transparency, and sends none of Chrome's certificate reports (`S-236`, `S-237`); `tooling/field-trials` compares Chrome Stable's seed with the pin (`S-240`). Patches 0071 to 0073 fix a closing tab told of its detach once and the download button measured mid-slide (`S-250`), a moved row's stuck hover (`S-143`), chips' shortcuts drawn whole (`S-144`), quit windows kept in the archive (`S-230`), Return in the Add to Dock box, and the Windows updater's review items plus the uninstaller's PDF key (`S-249`, `S-71`). A background tab no longer puts its old edge colour back after Dark Pages changes (dark-pages Dk8).
## 2026-10-19, evening -- a review of betas 18 and 19, and beta 20 for both platforms

`v0.2.0-beta.20` went out for macOS and Windows, on Chromium 156.0.8078.36. It is the Mac image of betas 18 and 19, which were Windows only, and the first release an installed Windows copy updated itself into, from beta 19. A restored unloaded tab no longer comes back crashed: the page state sent for a commit carries 0 where the entry has −1, and the session keeps −1 (patch 0058, import I26). A toast stays under the infobars, and is not moved while it slides or as the window closes (toolbar T38, patch 0072). The Windows updater checks once at a time, gives up on a stalled request, and does not hold a quit for an install; the Web Store page, image search, Safe Browsing and the root-store rules get Chromium's version (patch 0073).

## 2026-10-19, afternoon -- the Windows updater, beta 19

`v0.2.0-beta.19` went out for Windows only, on Chromium 156.0.8078.36. Stedding updates itself there (patch 0073, S-215, updates Up14 to Up22): it reads `updates/appcast-windows.xml`, checks the feed and the installer with a Windows Ed25519 key of its own (ADR 0026), runs the installer hidden beside the running copy, and offers the restart in the sidebar. The same patch gives Windows a version of Stedding's own (S-72), `<milestone>.<100 × major + minor>.<patch>.<beta, 999 for a release>`, so beta 19 is 156.2.0.19, while the user agent and About's Chromium line stay on Chromium's version. The Mac image is beta 20.

## 2026-10-19, late morning -- beta 18 from the PC

`v0.2.0-beta.18` went out for Windows only, on Chromium 156.0.8078.36: patch 0072's features and fixes. A toast of the whole window sits under the infobars while any is up (toolbar T38, S-244). Dark pages no longer drop an edge colour that was never read (S-245), and with the tabs across the top the strip no longer measures its spinner on a transparent ground (S-246). The Mac image is beta 20.

## 2026-10-19, morning -- patch 0072 on the PC: the Windows-only failures, the essentials card

The failures that showed only on Windows were faults in the tests (S-242). The essentials card is a frosted tile with no edge, white at 35% in light and 9% in dark; the edge had been Chromium's outline, tinted with the Space (tabs R32, S-243). The installed build showed a toast covering an infobar (S-244), fixed in the same patch before beta 18.

## 2026-10-18 night to 2026-10-19 -- installed builds, four features and the defects (patch 0072)

Patch 0072. Dark pages turn every site dark, from a moon button, a shortcut, the command bar or Settings, with a per-site exception either way. A page can become an app, Add to Dock on the Mac and Install page as app on Windows, in the session of the Space it was made from. A tab on this machine's own server wears a dashed tape and shows its host and port. A Space with its own session is marked on its chip, the title, the menus, Settings and the command bar (sessions S32 to S34, spaces B38). The Archived row and the Clear line stay quiet until used (sidebar Y27). On Windows the network service runs in its own sandbox (windows N15). Installed builds found a restored row losing its title, a rail drag missing a folder and a line left by a hidden address row (S-229, S-232, S-231); on Windows Ctrl+Esc stays the Start menu's (S-228).

## 2026-10-18, evening -- the checks still owed (patch 0071)

Patch 0071. Deleting a Space always asks first and names its tabs, and its jar is wiped at once (S-148); renaming edits in the title row, or in a small dialog on the rail (S-149). A session cookie in a Space's jar survives a restart, and a Space pin taken to another window keeps its pin and home (S-147). The archive counts wall-clock time, including a night asleep, and a second Arc import does not record the same history again. Deleting a Space another window was showing no longer stops the browser (S-222), and a split a Space's session replaced comes back as a split (S-225). In full screen on the Mac there is no line under the address row (S-223) and the Clear line is not under the traffic lights (S-224); a read of the page's edge before it has painted no longer turns the row black (S-226). The command bar lists the active Space's tabs first, closing a pin shows a row of that Space, and the product's name is right in every language.

## 2026-10-18, later -- defect round

Patch 0070. An essential taken out of the essentials joins the Space on screen, a switch from an essential lands on that Space's tab, and a tab opened in a new window keeps its Space and jar (S-145). Switching Space slides (S-146), and the sidebar no longer opens again two seconds after a collapse (S-219). The Clear line shows wherever rows follow it, in a private window too (S-138); pins stay above it, and the close command shares the row's close button (S-142). Move to Space takes a tab out of its folder, so a folder never spans two Spaces (folders F37, S-139). On the Mac, splitting with a new tab is ⌃⌘N, and Chromium's ⌥⌘N still splits; the menu's chord on Windows is Alt+Shift+N (S-79). A skipped welcome step keeps DuckDuckGo, so a second pick no longer stops the browser (S-134), and a tab pinned while selected stays selected after a restart (S-212). A release build reports a soft check instead of stopping (patch 0069, ADR 0024).

## 2026-10-18 -- beta 17 released from both platforms, the first update through the feed

`v0.2.0-beta.17` went out for macOS and Windows, on Chromium 156.0.8078.36, the series of 68 patches. A Mac copy of beta 16 updated itself through `updates/appcast.xml` and restarted into it: the first update through the feed (S-74).

## 2026-10-16, evening -- the pin moves to 156.0.8078.36

The pin moved from 155.0.8059.12 to 156.0.8078.36 (S-217). Twenty-seven of the 68 patches needed a hand merge, including the port onto M156's rebuilt sidebar region (`docs/HANDOFF.md`, trap 92). Sidebar labels stopped drawing subpixel text on that region's layer, which also takes the colour fringes off the Archived row on Windows. ADR 0023 sets updates on Windows and Linux: the browser's own updater on Windows (S-215, after S-72), and the distribution's packages on Linux (S-216).

## 2026-10-16, midday -- beta 16 released from both platforms, and the first update feed

`v0.2.0-beta.16` went out for macOS and Windows, still on Chromium 155.0.8059.12, the series through patch 0068. It is the first release built with the updater. `updates/appcast.xml` offers it, so an installed copy finds itself up to date; the first update a copy receives is beta 17 (S-74).

## 2026-10-16 -- Stedding updates itself on the Mac, and says thank you (patch 0068)

Patch 0068 (ADR 0022, updates Up1 to Up13). Sparkle 2.10.0 checks a signed feed in this repository. A new version waits at "New Stedding Version Available" in the sidebar; About, the command bar and Check for Updates… can look, and Settings › Stedding › Updates can turn every request off. Only a team-signed bundle runs it. The Mac's bundle version is Stedding's own: 0.2.0-beta.16 is 10020.16. After the welcome flow, and on the first launch of each later version, one thank-you page opens on stedding.dev. A raw pointer in the Windows AltGr chords, which crashed as a window closed, now holds the widget weakly (folded into patch 0067, trap 91).

## 2026-10-15, night -- the review's remaining items, and a new default favicon (patch 0067)

Patch 0067. A Space's sessionStorage comes back after a restart and with a reopened tab (sessions S28), and Restore from the crash bubble keeps a Blank Window's own Spaces (S29). A site in a Space with its own cookies can show notifications; the window its worker opens is in that jar, and a click reaches that worker (S30). A restored tab's Space is read once (S-181), a pinned split sits above the Clear line (S-182), and the Arc import makes one Space of a name that appears twice (S-183). Sleep and the archive spare drafts, PDFs and DevTools. On Windows a Ctrl+Alt chord made with the left Alt runs on an AltGr layout (S-189). A page with no icon of its own shows Tabler's world-www globe, in Chromium's two greys (S-211, branding).

## 2026-10-15, evening -- beta 15 released, both platforms from the Mac

`v0.2.0-beta.15` went out for macOS and Windows, the series through patch 0066: the signed and notarized Mac image, and the Windows installer built on Windows into the same release.

## 2026-10-15, afternoon -- the review's filed items fixed, and a tab group's header (patch 0066)

Patch 0066. A typed address no longer spends another app's open mark (S-201); a Chrome shortcut opened from Finder opens its target as any link from another app (S-202); a host route takes an IPv6 address and a scheme's default port (S-203). The welcome flow keeps the focus when a redraw changes or disables the focused control (S-204), and Clear is a button (S-205). A deleted Space's jar stays listed until the wipe finishes, and the next window finishes a wipe a quit cut short (S-206). Undo keeps a tab that was in no group out of one (S-207), and a new profile after a failed profile move makes its own keychain key (S-208). An unnamed tab group's header is a row, as a folder's is: a dot in the group's colour and the title, or the tab count when it has no name (folders F36, S-210).

## 2026-10-15 -- a code review of the whole series (patch 0065)

Patch 0065. Closing one pane of a split, or a window that holds one, no longer crashes (S-190), nor does grouping a tab that sits in a folder (S-191). The Arc import no longer saves a blocked login in a way that stops the browser (S-192). Deleting a Space waits to wipe its jar while a page there is still open (S-193). Autofill no longer sends forms to its server (S-194). The command bar opens a typed keyword's engine only when it offers that engine (S-195). On the Mac, Shift on Restore Folder works (S-196); a stacked split redraws its corners (S-197); Export Space writes one file in its folder, whatever the Space is called (S-198, import I20); a tab put back from a closed folder keeps its place when a sleep replaces its page (S-199).
