# Project log

What was built, newest first. Nothing here is needed to do a task: `AGENTS.md` carries what is true now, `BACKLOG.md` the order of work, `PLAN.md` the owner's decisions. This file was the "State of the project" section of `AGENTS.md` until 2026-09-30. The log starts at 2026-10-15; closed work from before that is the table in [docs/history/archive.md](history/archive.md). Entries before 2026-11-10 are short summaries; their full text is in the repository's history.

## 2026-11-18 -- 0.6.1: a quick new window, asleep pins' icons, centred chips, a download that stays

Three faults the owner met on 0.6.0, fixed the day they were reported, and one seen in 0.6.0's
own captures. The Mac was in use until the afternoon, so every build and test ran on the Windows
PC until then; the Mac's checks ran that night, and the release went out on 2026-11-19.

- S-546 (patch 0190; windows G16): with 443 pins in nine Spaces a new window made a tab of every
  record in one task, and each insert had the sidebar redo its whole list, about 10 s on the PC.
  A Space pin now comes in filed, as a restored tab does; a bulk filing defers the sidebar's
  visibility pass, folder paths and layout to its end; past 40 records the window makes its own
  Space and the essentials first and the other Spaces one at a time. The timing test asserts its
  clock only on the release build: at 443 pins it ran the DCHECK build out of time and the ASan
  build out of memory, so those builds make two Spaces of it.
- S-496 (windows G2, G16; live-folders Lf3): a pin made asleep, and a live folder's row, showed
  the generic globe; it now shows the icon history keeps for its page, or for its site.
- S-545 (patch 0104; sidebar Y44): with many Spaces the chips stood 7 DIP right of the middle;
  they now centre between the downloads button and the "+".
- S-549 (patch 0123; sidebar-panels Pn18): a download clicked in a full-screen window just before
  moving to another Space flew, and rang the button, on the Space the owner moved to. Chromium
  orders a popup made for a window off the active Space onto the active one; its own check,
  `platform_util::IsVisible`, is true for a window on another Space. The flight, the ring and
  the toast now start only while the window is on the screen (shown, not minimised, on the active
  Space), and a window that leaves mid-flight takes the chip with it.

The process, from this round's costs:
- `tooling/dev` runs every browser-leg failure again alone at the end of the sweep and says which
  fail alone, some of the time, or only among the others; all stay failures.
- `tooling/win/release-gate.sh` is the Windows gate as one detached job: the builds, the release
  suites, the installer, the update from the last release with pins in two windows, the
  installer's cycle, the acceptance scripts, then the DCHECK and ASan suites, in one log.
  `run-in-session.ps1` starts it in the operator's session; `quiet-desktop.ps1` minimises what
  would hold the foreground. `tooling/test-copy` makes and launches the Mac's test copy.
- The working docs were cut by more than a quarter (this log, HANDOFF, BACKLOG, the archive, the
  ADRs, the product docs), and PRIVACY now says what the browser keeps, as it keeps it.
- A morning lost to a false regression: hover-card and row tests failed alone on the PC's 4K
  console all morning and passed on both trees after a Remote Desktop connect; trees are now
  compared only back to back, in one job.

S-549 was found on the real system only the third way of trying: a Space change made by opening
another app, or by Control-Left Arrow, left the copy without a window on the Space it moved to,
and nothing showed there on 0.6.0 either. The owner's case has a second window of the browser on
the desktop Space, so the browser stays the active app; raising that window during the flight put
0.6.0's ring on the desktop Space, at the full-screen window's button. 0.6.1 showed nothing of the
full-screen window there. A download that starts after the move shows its toast in the window in
front, at that window's own button: Chromium shows a download's details in the last active
window, and that is where the person is.

Checked: on the Mac, the release and DCHECK builds' whole suites (1,622 unit, 1,133 browser and
224 one-at-a-time tests, 56 components tests and the content test on each; the release build's
parallel browser leg ran before `VERSION` moved to 0.6.1, which changed only the version); no
DCHECK or dangling-pointer report; the signed and notarized image; acceptance TST-6, TST-7 and
TST-9 on a copy of it; S-549 on the real system as above, 0.6.0 then 0.6.1; a new window of a
profile with nine Spaces, light and dark, its asleep pins with their icons and the chips within
1 DIP of the middle. On the PC, at the 4K display's 150%: the release build's whole suites
(1,612 unit and 1,078 browser tests, 240 of them one at a time); the update from 0.6.0 with pins
in two windows; the installer's cycle; acceptance TST-6, TST-7 and TST-9, TST-6's steps 11 and 12
included; the DCHECK and ASan builds' unit suites, and their browser suites with S-458's twelve
failing at 150%, which pass at scale 1, twice, on both, and `MotionFramesTest`'s frame wait on
ASan (S-458); no DCHECK, dangling-pointer or ASan report; the same new window, light and dark.
Not checked: a pass at 100% on Windows; a new window of the owner's own profile (the timing test
makes 443 records, as theirs holds).

## 2026-11-17 -- 0.6.0: the row's buttons inside the row, the Mac's lights with the row, and the release

The night of 2026-11-16 ran on both machines until a power cut stopped them, and the release
round finished on the evening of 2026-11-17. 0.6.0 ships on Chromium 157.0.8103.79, the owner's
choice: 157.0.8103.80 and M158 came out on 2026-11-12, and a rebase is due by 2026-11-26.

- S-543 (patch 0113, its test in 0193): with the address row over the page, the toolbar's flex
  layout laid the clusters out as for a row the field's margins wider than the toolbar, so the
  menu ended 1 DIP past the row, under the window's buttons at the corner on Windows; maximized,
  with Chromium's edge extension, a press on one pixel of the menu minimized the window. Found by
  the corner test at 150% on the PC, and the same at scale 1 at that window's width. What sits
  past the field now moves back inside the row.
- The Mac's traffic lights with the row (patch 0193): with the sidebar hidden, the row brought
  in over the page left the lights hidden until the pointer moved again; found in the captures.
  The window now asks again when it lays the row out.
- S-534 (patch 0182): a Space's jar wipe that finished after shutdown began asked for the
  partition again, and two tests crashed at teardown on the DCHECK build.
- The Mac's Dock keeps an app's tile while another profile still has the app (patch 0072).
- Tests: the bookmarks bar going with the row; S-494's Space made twice; the S-542 tests'
  pointer on the Mac; the pin mirror off in time-skipping unit fixtures; a title too narrow to
  read. `SidebarSyncPlaceTest`'s reload case runs one at a time: on the Mac the parallel leg ran
  it out of time on both builds, and alone it passed every time.

Checked: on the Mac, the release and DCHECK builds' whole suites (1,615 unit, 1,129 browser and
222 one-at-a-time tests on each); the captures of every 0.6.0 state, light and dark; the signed
and notarized image; acceptance TST-6, TST-7 and TST-9 on a copy of it; 0.5.1's pins in two
windows merged on the first launch of 0.6.0; a session with the real pointer and keyboard on a
fresh profile. On the PC, at the 4K display's 150%: the release build's whole suites; the DCHECK
and ASan builds' unit suites, and their browser suites with BACKLOG S-458's list failing at 150%,
which pass at scale 1 on the DCHECK build, twice, and on the ASan build but for
`MotionFramesTest`'s frame wait, which ASan slows (S-458); no DCHECK, dangling-pointer or ASan report; the update from 0.5.1 with
pins in two windows; the installer's cycle; acceptance TST-7 and TST-9, and TST-6 but for steps 11 and 12 after
its relaunch (S-544: the released 0.5.1 fails them the same way at the console, and the same code
passed them that morning over Remote Desktop); the release build's installer built again from the
final tree came out byte for byte the same;
the real build driven at 150% for S-540's strip and S-542's buttons with the row.
Not checked: a pass at 100% on Windows (the PC ran at its own 150% all evening).

## 2026-11-16 -- settings and extensions in sync, Live Folders, and three reviews

The owner gave the day to finishing 0.6.0's items, with the Mac in use: every build and test ran
on the Windows PC. Each item was reviewed by readers who had not written it, each claim checked by a
second reader trying to refute it, and every fault that survived was fixed with a test; then the
fixes were reviewed the same way, twice, and the eight faults the last review found (S-495) were fixed
the same day.

- S-479 (ADR 0037; patch 0191; sidebar-file Sf58-Sf69, settings T73, T74; GitHub issue 109):
  Stedding's own settings and the sites routed to Spaces travel with sync, each keeping its later
  edit; settings that belong to one computer stay (the table in `sidebar_sync_parts.cc`, and a test
  that fails for a preference in neither list). The list of Chrome Web Store extensions travels by
  id and name; another computer offers the ones it lacks, in Settings and once in a bar, each through
  Chromium's own confirmation; a decline or an uninstall here is not offered again, and nothing is
  ever removed elsewhere. Each part is a box, on for a new join and off for a computer that already
  syncs until it is ticked. An older version ignores both parts. The review found 14 faults, among
  them a route stamped before a join's pair lost on both computers, a browser-wide edit made while
  the profile was closed reverted, and two profiles' syncs trading a value; all are fixed.
- S-478 (ADR 0036, option B; patch 0192; `docs/features/live-folders.md` Lf1-Lf13, settings
  T70-T72; GitHub discussion 106): a pinned folder of the person's open pull requests, from GitHub's
  search API with a read-only token sealed by the system's key store, refreshed when made, every 10
  minutes, when a window comes to the front and on Refresh, never more than once a minute. Its rows
  are pin records, so every window shows them, and sync never carries them. The review found 17
  faults, among them a pin of the person's own taken for a live row, the last row's removal turning
  the folder off, and no way to paste a new token; all are fixed.
- S-94 (patch 0190): the review of pins in every window found 15 faults, among them a window a tab
  drag tears off taking every pin, and a window with a publish pending writing its old copy back over
  another window's removal or rename. Each is fixed with a test that failed on a build without its
  fix; a window now sends only what changed in it since it last followed the store.
- S-493 (patches 0101, 0106, 0179; Sf10, Sf35): found while building S-479. Since 0.3.0 beta 16,
  combining two Spaces at a join made a second Space here whenever the other computer's id was the
  smaller, and the other computer's pins, renames and deletions went to it; importing a backup taken
  after such a pair did the same. Fixed; each test failed first for those reasons. A second Space
  already made on an earlier version stays (S-494).
- S-353: its three sync faults were found fixed since 0.4.0 beta 2; their four tests passed again on
  the 0.6.0 series and failed with the fixes taken out. The check on a real build is still owed.
- S-492: the command bar tests' waits look the bar up again; folded into patch 0115.
- S-95's Mp1: three options for the player inside the window, rendered from the Windows release
  build in light and dark (the card grows, a compact card, a video over the page's corner), wait for
  the owner's choice.

Checked on Windows (the release build's whole suites, the DCHECK build and ASan): the release build's whole suites (1,581 unit and 1,027 browser tests, 229 of them one at a time), and after the last fixes its changed suites again (146 unit, 250 browser and 40 one-at-a-time tests), with the same suites on the DCHECK build; ASan passed the changed suites (144 unit, 244 browser, 40 one at a time) on the series before the last review's fixes.
Not checked: anything on the Mac, and a pass on a real build with the pointer and keyboard.

## 2026-11-16 -- pins and essentials in every window; a title runs to the row's end

The owner planned 0.6.0 on 2026-11-15, one decision at a time (`BACKLOG.md`, "The next
release"), and said "Yes, start" to its first item.

- S-94's second slice (windows G2, G13-G22; ADR 0035, option B; GitHub issue 111; patch 0190):
  pins and essentials are the profile's. `PinStore`, a profile service, keeps one record per pin
  and essential in `stedding.pins.store`; a `PinMirror` per registry window publishes what changed
  there and gives the window a tab of each record, asleep until chosen, in its Space, its pinned
  folder and its place. A pinned folder is one folder in every window, by id, with its name, icon
  and open or closed state. A pin removed in one window closes the asleep copies elsewhere without
  a trace and leaves an open one as a loose tab. The first launch fills the store from every
  restored window after a backup of each sidebar. "Switch to this tab" for a pin's page goes to
  this window's own tab of it, and the command bar no longer lists another window's tab of a pin.
  The DCHECK build found the store's factory registered after the profile's services were built
  (98 tests stopped at one check); it is now registered beside the Space registry. Checked on
  Windows: the release build's 22 pin, import and bar tests three of three and 615 related browser
  tests (one crash in a parallel run, S-492, passed three of three alone), the DCHECK build's 102
  and ASan's 111. Owed: the Mac and a pass on a real build in two windows.
- S-491 (tabs R2; patches 0173 and 0182): the owner found the fade at the end of a tab's title far
  from the sidebar's edge. The row kept the close button's place even when the button was hidden.
  Of three rendered options the owner chose "room on hover": at rest the title runs to the row's
  end, and the row under the pointer, or with its close button focused, makes room for it.
  `SidebarClickTest.ATitleRunsToTheEndUntilThePointerComes` failed on the old layout and passed
  three of three with the change; 119 related tests passed. The Mac is owed.

## 2026-11-14 -- 0.5.1: the Mac's right-click, a row in a colour the page never shows, Shift-click for a peek, a menu on the download toast

The owner, on the signed 0.5.0: a right-click on a link closed the browser, and the first tab at
launch, their start.me page, had a blue address row that never changed. The owner asked for the
new issues and discussions to be reviewed for the next release, and chose to ship the crash fix
fast with what else was ready, leaving the bigger items for a release after.

- S-486 (sessions S32, menus M1, M14; patch 0182): on the Mac every context menu is the system's
  own, and it refuses an image generator, which S-477 had given the session disc in Open Link in
  Space, Move to Space and Always Open; the browser stopped at `SetMenuItemIcon` whenever a Space
  had a session of its own. The disc is now an `NSImage` drawn in the menu's light or dark.
  `SessionMenusMacTest.TheMacsOwnMenusDrawTheSessionsDisc` builds the native menus as a
  right-click does and crashes where the report did without the fix. On the release build, a
  right-click on a link and on a tab showed the disc, and the browser went on.
- S-487 (toolbar T63; patch 0160): start.me declares `#0093d5` and the top of its start page is a
  dark photograph, so the row fell back to the declared blue and the reload rule kept it. A
  declared colour is now the row's only where a third of the page's top edge shows it.
- S-488 (peek P27, settings T63; patch 0188; GitHub discussion 115): Shift-click on any link, from
  any tab, opens a peek, as Arc's did; a setting, on by default, gives Shift-click its window
  back.
- S-489 (sidebar panels Pn19; patch 0189; GitHub discussion 116): the download toast's menu on a
  finished download has Move to Trash (Move to Recycle Bin on Windows) and Remove from List. The
  first real right-click on the Mac's release build ended the browser at Move to Trash: the
  bubble's menu counted its commands in a table of Chromium's and read past it for Stedding's id.
  Fixed in the same patch, with `DownloadUiContextMenuViewSteddingTest.ThePanelsVerbsRunFromTheBubble`.
- S-490, the window left without its address row after a full-screen pair, was not reproduced
  in any order of quitting, killing or closing the other app; it waits for the owner's steps.
- The pin stays on 157.0.8103.79: 157.0.8103.80 and Chromium 158 were at 0.5% of users or less.
- The gate, on one tree on both machines (the product's code; later commits changed tests only).
  On the Mac the release build's 1,548 unit and 1,023 browser tests passed but two:
  `SidebarSyncTest.TheSidebarKeepsItsIdsWhenTheSessionComesBack` timed out once under load and
  passed three of three alone, and `PageColourRowTest.TheRowFollowsADarkenedPage` read no colour:
  its header did not show the colour the page declared, which T63 now rightly leaves alone; its
  header shows it now, and the 16 row-colour tests passed three times. The DCHECK build's suites
  passed whole. On Windows the release build's 1,536 unit tests passed; of 966 browser tests,
  `SiteControlsTest.TheRowsUnderTheStripDoWhatTheyName` failed once and passed three of three
  alone, and the three below failed. No DCHECK, dangling pointer or AddressSanitizer report.
- Three tests raced the page they acted on, on Windows, and are fixed in the tests: Chromium
  holds input to a page just loaded until its first frame (paint holding) and routes a click by
  the compositor's hit-test data, so on the ASan build the Shift-click test's clicks never
  reached the page, and the welcome flow's first Enter was lost now and then; the welcome test
  also read the focus before an arrow key had reached the page; and the screenshot of a peek was
  taken before the page had a frame to copy, one run in four on the release build. With the fixes, on the tree
  that went out: the Shift-click test passed five of five on the ASan and release builds and
  three of three on the DCHECK build, the screenshot test 20 of 20 on the release build, the
  welcome test every run on all three, and the peek and welcome suites (35 tests) whole on each.
  On the Mac these tests had passed before the fixes, which only wait longer.
- On Windows, 0.5.0 updated itself to 0.5.1 from a signed local feed and kept the sidebar's
  width; upgrade, uninstall and reinstall passed. Acceptance on both (docs/features/acceptance.md).
- With the real pointer and keys on the release builds: on the Mac, the right-click menus with
  the disc, Shift-click's peek, and the toast's Move to Trash, Remove from List, and Move to
  Trash greyed for a file already gone; on Windows, on the installed 0.5.1, in light and in
  dark, Shift-click opened a peek and no window and Escape closed it, the toast's Move to Recycle
  Bin put the file in the Recycle Bin and the row read "Removed", Remove from List took the row
  away and left the file, and Settings showed the new row on. Each state was captured from the
  release builds and looked at; the site's entry for the page after an update is pushed and stays
  hidden until the release.

Released as `v0.5.1` on 2026-11-14.

## 2026-11-14 -- 0.5.0: the rail's dots in a grid, the sidebar's width on hover, a list that scrolls in every window

The owner chose the rail's dot grid from the renders ("C") and, going to sleep, asked for the
release to be prepared fully. The Mac was free for the night.

- S-483 (sidebar Y56, patch 0187): past four Spaces the rail's stack is the active Space's chip,
  then the other Spaces as dots two to a line in their order, then the "+". Six Spaces take 98
  DIP from the chip to the "+" where the column of dots took 150. A tab dragged over the grid
  lights the dot under the pointer in its cell, and the stack keeps its lead until the drag
  leaves, so a switch on a rest does not move the Space switched to from under the pointer.
- S-484 (sidebar Y57, GitHub discussion 117): expanded on hover from the rail, or slid in when
  hidden, the sidebar took Chromium's default width of 352 DIP; it takes the width it has open.
- S-480 (sidebar Y58), found by the gate: the list test failed 6 of 20 runs alone on the PC.
  Logging showed why: Chromium scrolls a row into view only after the window's first showing,
  which it learns from the widget's visibility change, and on Windows that call did not always
  come; in such a window no row made active was ever scrolled into view. A visible widget now
  counts as shown. A new test fails 3 of 3 without the fix and passes with it; the list test
  then passed 50 of 50.
- The pin stays on 157.0.8103.79: 157.0.8103.80 was still at 0.5% of users.
- The gate, built as 0.5.0 on one tree on both machines, and again after S-480's fix
  (`cbdbf9b`): on the Mac the release build's 1,545 unit and 1,020 browser tests (and 211
  serial) passed but one timeout under load, which passed five of five alone (S-485); the DCHECK
  build's passed whole. On Windows the release build's 1,533 unit and 964 browser tests (and 226
  serial) passed whole. The DCHECK and ASan sweeps failed S-458's two corner tests, which read
  the real pointer, as before beta 19; on the DCHECK build one of them also failed once in three
  runs alone. The DCHECK sweep lost one sync test to Windows' socket exhaustion ("connect failed:
  10055"), which passed three of three alone. No DCHECK, dangling pointer or AddressSanitizer
  report.
- On Windows, beta 19 updated itself to 0.5.0 from a signed local feed and kept the sidebar's
  width; upgrade, uninstall and reinstall passed. Acceptance on both (docs/features/acceptance.md).
- Captures of every changed state from the release build on both platforms, light and dark,
  were looked at; the site's entry for the page after an update is pushed and stays hidden
  until the release.

Apple's notary service refused requests until the owner accepted an updated agreement in the
morning; the Mac image was then signed, notarized and stapled from the same build, and
`verify-build` and `syspolicy_check` passed. Released as `v0.5.0` on 2026-11-14.

## 2026-11-13 -- Renamed pins keep their names through a file; the archive keeps little windows' links; the command bar finds any script (GitHub issue 114, S-159, S-158, S-164)

The owner, the same evening: carry on with the plan, and the next release is 0.5.0 (`PLAN.md`
decision 22). M157's newest point release, 157.0.8103.80, was at 0.5% of users, so the pin stays
at .79 until it passes 1% (ADR 0007).

- S-159, the archive's audit leftovers, was mostly done already: the idle clock survives a
  restart (A1), the page keeps its place (A9), and its messages are checked (S-188). Arc's own
  archive opens on every Space with filters, so Stedding's does too. What was left of Arc's is
  built (patch 0184, archive A17): a link closed in a little window is a row that says "from a
  little window", with a "Little windows" filter, as Arc keeps Little Arc's links. A closed
  window or group of one tab no longer reads "of 1 tabs".
- The command bar folded ASCII case alone, so a Cyrillic or accented title typed in another case
  was not found; titles and words now fold in any script (K2, K10). "@Work Stuff rust" now picks
  the Space named "Work Stuff" whole, and matches it alone (K19). Patch 0185: its lines belong to
  four earlier patches.
- GitHub issue 114, reported that afternoon on Windows: names given to pinned tabs came back from
  an imported sidebar file and went when the tab was clicked. The export wrote the name as the
  page's saved title, so the import showed it only until the page loaded. The name is now the
  item's `title`, as Arc's file has it, apart from the page's title; the sync folder's file the
  same (import I3, I18; S-482). Folded into the patches that own the export and the sync file.
- The nine WebDAV sync restart tests that failed in each whole suite bound one fixed port; each
  now takes its own from its name, the same across its restart (S-481).
- On win-release: the unit tests around the archive and the bar (128), the new archive test three
  times of three, 106 related browser tests; the whole suite ran 960, all passed but the nine
  WebDAV tests, which passed alone (98); on win-checks, 56. With the issue 114 and port fixes: unit 151; the 98 sync tests four at a time, twice, all passed; the import and sidebar file tests (12); on win-checks 119 unit and 25 browser.
- A separator above a row now travels in the sidebar file too (S-286, Y45, patch 0186).

Not done here: the Mac (not free).

## 2026-11-13 -- What's playing, at the sidebar's foot (S-95, Mp3)

Arc kept the tab playing sound in the background at the foot of its sidebar. Four forms were
rendered from a real Windows build, light and dark; the owner chose the card: "B, Card".

- A tab of the window that plays sound while it is not on screen shows a card above Archived:
  its favicon and title, play or pause, and stop. The card's body shows the tab in its Space.
  A paused card stays until its tab is shown or stopped; the newest player takes the card. In
  the rail the card is the favicon above History, with a pause or play badge, and a click
  pauses or plays (player Mp3, Mp7, Mp8; patch 0183).
- ⌥⇧⌘M (Ctrl+Alt+Shift+M) goes to the tab; the command bar lists Go to, Pause or Play, and
  Stop while a card shows; Settings › Pages and menus has the switch, on by default (Mp9,
  Mp10, settings T62, commandbar K45).
- Each tab's media session is watched through its observer; the rules that pick the card's tab
  are a pure function with unit tests (`AudioStripRulesTest.*`). The pause and play glyphs are
  Chromium's filled ones, as its picture-in-picture window draws them: the outlined pause read
  as "00".
- On win-release `AudioStripTest.*` (9) passed three times of three; the unit tests around it
  (104) and the DCHECK build's 32 passed. The whole browser suite ran 959: all passed but the
  nine WebDAV sync restart tests, which could not bind their fixed port (48089) beside the
  suite's other jobs; alone, all 98 sync tests passed twice of two.
- Captures of the real card, light and dark, playing, paused, focused, with a long title and in
  the rail, were checked before release.

Not done here: the Mac (not free).

## 2026-11-13 -- An extension's button in a peek shows the peek's page (S-476, GitHub issue 102)

The reporter of issue 102 confirmed beta 19 and sent a capture: Bitwarden's button counted the
pinned Gmail tab's logins under a peek of another site. S-473 had sent the click to the peek's
page and left the button on the pinned tab's state. The owner: "Yes, fix the count".

- The button now reads every per-page state through the page shown over the tab: icon and badge,
  title, enabled, tooltip and hover card. It repaints when a peek opens or closes over its
  window's tab; after Open as Tab the page is the active tab and the button follows it as any tab
  switch (patch 0176, peek P26).
- `PeekOverPageTest.AnActionsButtonShowsThePeeksPage` failed before the change and passed three
  times of three after it, on win-release and win-checks. The whole browser suite (940) passed
  on win-release.

Not done here: the Mac (not free).

## 2026-11-13 -- Bookmarks and the welcome flow from the keyboard (S-475, GitHub issue 112)

A new user asked for a keyboard way to bookmark and to go through the welcome flow without the
pointer. The owner said yes. ⌘D (Ctrl+D) pins the tab, as in Arc, so Bookmark This Tab had no
key, and Settings › Shortcuts lists only commands a shipped chord reaches, so it could not get
one. The Mac was not free; everything was built and tested on the PC.

- The command bar's actions mode lists "Bookmark This Tab" (commandbar K44). It bookmarks the
  page and opens the bubble with the address row shown, with it hidden, and with the star gone
  after Turn Bookmarks into Pinned Tabs.
- The Shortcuts block has a row for it under Page, with no chord, that takes one as any row does
  (shortcuts Z25). A catalog flag keeps such a row listed.
- The welcome flow opens with its main button focused, so Enter goes from Get started to Finish,
  and the arrows move within a group of choices; the button is not drawn as focused until a key
  is pressed, so the flow looks as it did (welcome W21).
- Five new or changed tests failed before the change and passed after it, three times of three,
  on win-release and win-checks. The whole unit (1,512) and browser (939) suites passed on
  win-release, and 41 command bar, welcome and shortcut tests on win-checks.

Not done here: the Mac, where the Bookmarks menu's row should show a chord given to it, and the
flow there.

## 2026-11-13 -- A Space's session shows as a line in its colour (S-477)

Issue 99's comment said the "Independent session" cookie no longer fits now that Spaces share
named sessions. The owner picked from rendered options: a colour per session, a line under the
chips of a session's Spaces, and a faint bridge across the Spaces between them.

- Each named session keeps one of six colours as sessions are added. In the open sidebar the
  line runs under its Spaces' chips; a second session that crosses the first runs a row lower.
  In the rail, the title row, menus, the command bar, page info, Settings and the archive page a
  disc in the colour takes the cookie's place (patch 0182).
- Review before committing found the first palette too faint on light sidebars (1.2:1 for amber on
  a light blue Space). Each colour now has a shade for light grounds and one for dark, each at
  least 3:1, and a test holds it.
- On win-release 174 unit tests and 111 browser tests passed, and the mark's tests on win-checks.

- The words followed, once the owner had read them: "Own session" or "Session: Clients" after a
  Space's name, a Session submenu on the Space menu, Clear Session Data…, and the command bar's
  Choose This Space's Session…, which opens Edit Space. 206 unit tests and 100 browser tests passed;
  the whole browser suite ran 950 with one failure, a sidebar scroll test that passed 3 of 3 alone
  with and without the change.

Not done here: the Mac.

## 2026-11-13 -- The mini player's first slice (S-95)

The owner asked for the next release to bring more of Arc, and chose to start the mini player with
Chromium's own picture-in-picture window.

- With Settings › Stedding › Pages and menus › "Pop out a playing video when you leave its tab" on
  (off by default), leaving a tab, or showing another Space, while its video plays with sound puts
  the video in picture in picture; showing the tab again puts it back, playing on. The window's way
  back to the tab shows the tab in its Space. A muted or paused video, sound alone and a split's
  other pane stay put. The command bar has the switch, and "mini player" finds it (patch 0181).
- Chromium's automatic picture in picture never fired for an ordinary video here: it waits for a
  Safe Browsing check of the page, and Stedding has none (S-75).
- On win-release the seven `MiniPlayerTest` tests passed three times of three, and the whole
  browser suite (947) passed. The first run caught two faults of the change, both fixed: "picture
  in picture" as a search word gave the bar a second row beside the key's, and the Settings page
  could not read the new preference until it was on settingsPrivate's list.

Not done here: the Mac, and a look on a real build with a real video.

## 2026-11-13 -- The row's bar in macOS full screen (S-471)

The owner sent a full-screen capture from beta 19: the address row's bar still started left of the
page. From it and the owner's layout (sidebar on the left at 352, the row shown) the offset was
6 pt, the card's gutter. The row's view was right all along; the bar the full-screen overlay
paints ran to the edge of the view that holds the page's card, not to the card. Beta 19's change
to the row's column had guessed another cause, and its test checked the row's view, so it passed
either way.

- The bar now starts at the card (patch 0120). A new test measures the painted bar against the
  card in full screen: on the Mac's release build it failed before (352 against 358) and passed
  three times of three after; the 16 window button tests passed.

Not done here: a look at the real build in real full screen, which comes with the next release.

## 2026-11-13 -- After beta 19: the page's focus after a rename on Windows (S-474), and extensions' clicks and keys in a peek (S-473)

The release's after-steps were checked first: the site's download section and the Homebrew cask
name beta 19 with the release's checksums, and both machines are clear of the round's leftovers.
The Mac was not free, so every build and test ran on the PC.

- S-474: on Windows a rename ended by Enter or Escape left the keys on a sidebar row about one
  run in seven. Logging in the rename's end showed the cause in every failing run: the page was
  focusable, the window active, and Chromium's lookup of the page's view, which goes through the
  element tracker, found nothing, because the tracker had not counted the window as shown. The
  view is now found whatever the tracker says (patch 0103). The test failed 12 of 80 runs alone
  before and passed 150 of 150 after, on win-release; 29 sidebar, rename and focus tests passed.
- S-473: while a peek over the page shows, a click on an extension's toolbar button, its popup and
  its own keys act on the peek's page, with the activeTab grant they bring; they named the pinned
  tab under it (patch 0176). Two new tests, each with an extension that has activeTab alone, failed
  before the change (the pinned tab, a.test) and passed three times of three after it (the peek's
  page, b.test); 75 related browser tests and 64 unit tests passed.
- With both, on the PC: win-release's whole unit suite (1,511) and browser suite (936) passed, and
  41 peek and sidebar tests on win-checks. The DCHECK build caught the new click test pinning an
  extension Chromium had already pinned; the test now pins it only when it is not.

Not done here: the Mac (not free), and a look at either fix on a real build.

## 2026-11-13 -- 0.4.0 beta 19: Chromium 157.0.8103.79, and password managers in a peek

The owner, on the evening of 2026-11-12: "you can use mac now, finish all and release". The Mac
moved to the pin the PC had proved, both checkouts held one tree, and the gate ran on both
machines overnight.

- The Mac's half of the pin move: the point release synced and the series applied with no
  conflict; the full release build took three hours twenty minutes at the Mac's own pace, past
  `tooling/build-chromium`'s fifteen-minute budget, which the owner's "finish all" allowed. The pin
  is its own commit (`85cfa61`, channel now stable) and the re-export another (`2120925`: only
  index lines and offsets moved).
- The DCHECK build on the PC caught a fault of patch 0176: closing a peek asked
  `IsObservingSource()` about a favicon driver the peek's page does not have. Fixed and folded
  (`fdd072e`); both machines rebuilt everything from that tree (`b46595c`).
- Release suites: the Mac 1,523 unit and 989 browser tests passed; Windows 1,511 and 934 passed.
  mac-checks: unit passed; four `AddressBandTest` tests timed out as the first of the parallel leg
  and passed alone twice; no DCHECK. win-checks and win-asan: only S-458's two corner tests at
  150%; no DCHECK, no dangling pointer, no AddressSanitizer report.
- The Mac image signed, notarized and stapled; `verify-build` and `syspolicy_check` passed. On
  Windows, beta 18 updated itself to beta 19 from a signed local feed and kept the sidebar's width;
  upgrade, uninstall and reinstall passed. Acceptance on both (docs/features/acceptance.md).
- S-470 on the Mac, through the menu bar on the signed copy: the "Choose a tab" pane left the
  clipboard as it was; a page copied its link.
- S-471 could not be proven: its test passed with and without the change, in fake and in real
  full screen. Reopened; not in the notes.
- S-474 found: on Windows a rename ended by a key leaves focus on a sidebar row about one run in
  ten alone, with the window active. The code is the same as beta 18's; recorded, not fixed.
- The site's entry for the page after an update shows a peek over a pinned page with a sign-in
  form, taken from the release build over HTTPS with the address mapped to a free port.

Not checked: Bitwarden itself (a test extension that fills as Bitwarden does was).

## 2026-11-12 -- The pin move's Windows half, and a crash at shutdown (S-472)

The owner approved moving the pin to 157.0.8103.79 (GitHub issue 110) for when the Mac is
free, and asked for everything to be prepared meanwhile. The PC went first.

- `tooling/update-pin --to 157.0.8103.79 --apply` in the PC's repo copy synced the point
  release in about three minutes, and the whole series applied to it with no conflict. The pin
  change stays uncommitted there until the Mac's own move. `apply-patches` first refused: the
  series had come to the PC by bundle, so its record of the last export was stale. The branch
  was checked to be the exported tip and the apply forced.
- A full win-release build took 149 minutes. Its unit suite passed (1,511 tests). Of the
  browser suite (934 tests), the serial leg passed, and two tests did not in the parallel leg:
  `SidebarPanelsTest.TheDownloadsPanelFollowsAndActsOnEachDownload`, which waits for a copied
  file on the clipboard and then passed five times of five alone, and
  `FindWordsTest.ArcsWordsFindASpacesSession`, which crashed at shutdown.
- That crash was S-472, in Chromium itself: a passkey check left pending when the profile went
  away, by an object that handles the profile's destruction but never registered for it (patch
  0180). It crashed 8 times in 22 runs on .79 and had once on .51, on 2026-11-10; with the fix,
  0 times in 20.

- With 0180 in, the whole browser suite ran again on .79: everything passed but
  `SidebarSyncPlaceTest.AnOwnFileGoneIsWrittenAgain/WebDav`, which timed out at 31 seconds in
  the parallel leg, had passed in the run before, and passed five times of five alone (0.7
  seconds each).

Not done here: the Mac's half of the move, its suites, and the release.

## 2026-11-12 -- After beta 18: password managers in a peek (S-469), and the row in full screen (S-471)

The owner asked for the open issues, discussions and new comments to be reviewed and their bugs
fixed, with a screenshot of the address row in macOS full screen starting left of the page under
it, while they used the Mac. So everything was built and tested on the PC and folded on the Mac
with git alone.

- S-469, GitHub issue 102's second report, on beta 18: Bitwarden still listed and filled the
  pinned page under a peek; after Open as Tab its key filled nothing until a reload; F5 reloaded
  the pinned page. The owner chose, that day, that an open peek is the window's active tab to
  extensions (peek P26): the tabs API announces it when it opens and when it closes, Open as Tab
  attaches it, and a query for the active tab finds it in the pinned tab's place. The page also
  gets the extension helpers a tab's page has: without them `scripting.executeScript` answered
  that no tab had its id. F5, Cmd-R, the row's button and the page's menu reload the peek (P25).
  All in patch 0176.
- `PeekOverPageTest.AReloadTakesThePeekNotThePin` and
  `PeekOverPageTest.APasswordManagerFillsThePeeksPage` failed first on Windows' release build, as
  the reporter saw it. Each fix was then seen to move the failure on: the menu's Reload needed no
  tab's helper, the tabs API needed no favicon driver, the script needed the extension helpers,
  and the test's own extension shadowed a function with an array. With all of it both tests passed
  three times of three, with 143 browser tests of the peek, address-row, sidebar and Space suites
  at scale 1 and 28 unit tests of the tabs API. Two of those browser tests,
  `SidebarAddressTest`'s corner buttons, fail at the PC's own 150% scale, as S-458 says.
- S-471 (patch 0071, toolbar T32): in full screen the row is in an overlay laid out before the
  window, and it took the sidebar's width from the last layout, so after a change of that width it
  stayed that many DIPs off the page. It now takes the column this layout gives the page.
  `WindowButtonsTest.InFullScreenTheRowFollowsTheSidebarsWidthAtOnce` (patch 0120) runs on the Mac
  alone and has not run yet.

Not checked: Bitwarden itself; S-471's test, the Mac's build and its keys, which wait for the Mac.
Not covered: `action.onClicked` and `commands.onCommand` still name the pinned tab.

## 2026-11-12 -- After beta 18: Copy Link on a page with no address (S-470)

The owner asked for S-470, found that morning in beta 18's Mac acceptance, while they used the Mac,
so it was built and tested on the PC and folded on the Mac with git alone. Copy Link took the
address of whatever page had the focus, and three pages have an address the address row never
shows: a split's "Choose a tab" pane, the new tab page (a private window's split opens one), and a
Space's own page (tabs R66). On each, ⇧⌘C and ⌥⇧⌘C put that internal address on the clipboard and
said "Link copied". Now such a page has no link (copy-link L9): the clipboard keeps what it held and
no toast shows.

- `CopyLinkTest.APageWithNoAddressHasNoLink` and `PinnedRunTest.ASpacesPageHasNoLinkToCopy` failed
  first on Windows' release build, at every one of those pages, and passed three times of three
  with the fix. The first version's check for no toast passed even before the fix, since a copy's
  toast comes up after the copy; it now waits a second for one.
- 55 browser tests that copy a link or use the same rows (`CopyLinkTest`, `PeekOverPageCopyTest`,
  `PinnedRunTest`, `SidebarSelectionTest`, `CommandBarActionsTest`) and 31 unit tests passed.
- Real keys on that build, through `tooling\win\drive.ps1`: Alt+Shift+N split the tab, and
  Ctrl+Shift+C on the "Choose a tab" pane left the clipboard as it was; on a page it copied the
  page's link. The same keys on the installed beta 18 copied
  `chrome://tab-search.top-chrome/split_new_tab_page.html`. The first try was hollow: a fresh
  profile's search engine choice took the keys. The rerun launched with
  `--disable-search-engine-choice-screen`, as `run-mac.sh` does.
- The fold into copy-link's own patch, 0016, conflicted with later patches on the same lines, so
  the code is in 0057, with the Space page's part in 0123, and the tests in 0083 and 0156.

Not checked: the Mac's build and its real keys, which wait for the Mac.

## 2026-11-12 -- 0.4.0 beta 18: Spaces that share a session, and four fixes

The owner asked on the evening of 2026-11-11 for the optional fixes on the PC while they used the
Mac, and for the release overnight, the Mac untouched until midnight. Each fix was built on the PC
first, its test seen failing on `win-release` before the fix and passing after, then folded on the
Mac's checkout with git alone, so the PC tested the series' own tree; the one change after it is a
test's (below).

- S-342, the sync review's last fault (patch 0121): a pin that applying a Space deletion brought on
  screen, then removed on the other computer, stayed open instead of going to Recently Closed.
- S-467 (patch 0124, tabs R25): Chromium gives the toast's action button the alert role, which the
  Mac reads as a group, so VoiceOver did not call Undo a button. It is a button again with
  Stedding's window; the toast's window stays the alert.
- S-468, GitHub issue 101 (patch 0160, toolbar T62): a page that lays a dark layer over itself
  under its own dialog no longer greys the address row. Reproduced on Windows: the header's blue
  went to rgb(10, 47, 84). The owner chose to hold the colour. A read that finds the row's colour
  darkened evenly, with the page's theme colour and background unchanged, is not taken.
- S-469, GitHub issue 102, the page half (patch 0176, peek P24): an extension's answer to a
  content script in a peek over the page found no tab, since no tab strip holds the peek's page.
  Extensions now reach that page by its tab id, the way Chromium lets them reach a prerendered
  page. The toolbar half, a toolbar button acting on the pinned tab under the peek, waits on the
  owner.

S-458 waits for the PC's own 4K display at 150%: over Remote Desktop the PC runs at 100%.

The Mac took over at midnight, when the owner went to sleep:

- The Mac's release build passed every suite. On its DCHECK build,
  `SidebarSyncPlaceTest.AnErrorChangesNothing` timed out once in the parallel run and passed five
  times of five alone. The test raced the service: a read the service had begun by itself, with
  the 30-second timeout, reached the fake place just after the test set it to hang, and the
  test's scan waited behind it (Sf13). One more scan after the short timeout is set, before the
  hang, closes the race (patch 0164, the test only); the 44 tests of `SidebarSyncPlaceTest` then
  passed three runs in a row.
- On Windows' DCHECK build `CommandBarActionsTest.EveryListedRowRuns` failed once, late in the
  serial leg, when a private window's navigation could not connect (`connect failed: 10055`, no
  buffer space); it passed three times of three alone. AddressSanitizer found nothing.
- S-467 on the Mac's release build, through the accessibility API, with Offer Undo turned on in a
  test profile: the toast that reads "“Inbox” closed" holds an `AXButton` named Undo. The first
  tries found no toast: ⌘T opens the command bar, so ⌘W closed the window's only tab; the check
  now opens two pages at launch.
- The first Mac acceptance run's copy, at a new path, asked the firewall about Chromium's time
  query to clients2.google.com (trap 85), and the prompt over the screen stopped the driver at
  the setup step. `run-mac.sh` now launches every part with that query and background
  networking off, and the rerun used the one test-copy folder and id. The prompt itself was left
  for the owner.

- The rerun began at 06:46, once the prompt had been answered and the Mac left idle: the core
  loop, the drags and the keyboard script, every part exit 0, on the notarized build. The captures
  read as the steps say, but for the keyboard script's ⇧⌘C and the ⌃⌘N after it. A clipboard
  manager running on the Mac takes ⇧⌘C from every app (trap 94): its window opened, and the ⌃⌘N
  went to that window. Alone on the same copy, ⌃⌘N opened a split, and Copy Link in the menu
  bar, whose key there reads ⇧⌘C, showed "Link copied". With the split's empty "Choose a tab"
  pane in front, that copy was `chrome://tab-search.top-chrome/split_new_tab_page.html`, an
  internal page's address: S-470, opened. Copying a link works as it did in beta 17.

Checked: 1523 unit and 984 browser tests on the Mac, release and DCHECK; 1511 unit and 930
browser tests on Windows, release, DCHECK and ASan. Acceptance on a copy of the notarized Mac
build and on the installed Windows copy; the update from beta 17 through a local feed on both, and
the Windows installer's upgrade, uninstall and fresh install.

## 2026-11-11 -- Spaces that share a session join the series (S-272)

Several Spaces can now be on one named session, as several Arc Spaces are on one profile
(GitHub issues 8 and 99; ADR 0034, accepted by the owner on 2026-11-10 once every check passed).
It is patches 0177–0179 on Chromium 157.0.8103.51, for the next release.

The checks, on the branch's final tree: the unit tests and the whole browser suite on the Mac's
release and DCHECK builds (979 browser tests); on the PC the whole suite on release, DCHECK and
ASan, whose only failures were S-458's at 150% and a test helper that looked for the cookie
store where Windows does not keep it, fixed; then the session, jar, sync and mark tests twice on
each build. Acceptance SS1–SS6 ran with real input on both platforms (`docs/features/acceptance.md`).
On Windows it found the title row's tooltip calling a shared session's essentials "this Space's
own"; it now says they are the session's, in each of its Spaces, and the new test was seen red
without the fix. The Mac's run went to a narrow window, since two firewall alerts for the test
copy's connections sat over the middle of the screen and the driver will not press through
another app's window.

The same night: S-461 was the tests', two drags across windows that ran in the parallel leg, now
in the serial one; a screenshot test's single time-out did not reproduce in 50 runs (S-466); the
PC driver now presses only where the browser under test is, after a click on a row scrolled out
of view landed on the taskbar; and after the person logged out and in, a full Mac browser leg left
three windows in WindowServer, not thousands (S-464). GitHub issue 100 became S-465 for the owner,
and issue 90's new report is in S-450.

After the merge, on the final tree: the PC's DCHECK and ASan builds at 100% scale each passed 925
browser tests and, with the merged list of unit-test fixtures, 1,510 unit tests; the Mac's release
build passed 1,522 unit and 979 browser tests, and its DCHECK build 1,522 unit tests. S-340 closed on the release builds with
real input: while a pin asks *Leave site?*, the Mac begins no quit and Windows, which disables the
window, begins no close; Leave sends the pin home, the next close or quit goes through at once,
and nothing wedged. On the Mac, S-338's reopened tab, blob page and View Source stayed in their
Space's session.

## 2026-11-10 -- The Mac's login session went down under the tests' windows

At 20:31, during the `mac-checks` browser leg for shared sessions (S-272), WindowServer
restarted with no crash report. That logs the person out, and every app on the owner's Mac quit.
The Mac had not rebooted: it had been up 19 days. WindowServer's own count stood at 17,903
windows. It had sat near 14,250 from 18:00 to 19:40, from earlier days' runs, and the release
browser leg added about 2,400. Test processes closed owning 0 to 5 windows each, so something
else keeps them (S-464). After logging back in the count was 151 and the owner's lag was gone.

`tooling/window-count` reads the count without opening a window. `tooling/dev` refuses a Mac
browser leg over 12,000, checks again before the serial leg, and says what each run added
(trap 147). `tooling/leftovers` and `tooling\win\leftovers.ps1` list and clear what jobs left:
that night 2.8 GB of siso logs on the Mac and 8 GB on the PC, three local servers alive for up
to 17 days, test temp, and the one-time scheduled tasks old jobs had left on the PC. Running it also found 64
empty mount folders that `tooling/publish-appcast` left, one per run; it now removes its own.
Both machines ended with "nothing left over". The guard was seen refusing a leg at a limit of
100 and running none of its tests. A full browser leg has not run through it yet.

## 2026-11-10 -- after beta 17: the Mac's owed checks, Cmd-D in a private window, S-463

The plan's second and third items, with the machines free for the evening. On the Mac, with the
real keyboard and pointer on the release build: little windows (S-157) and a pin's redirected link
with the screenshot keys over its peek (S-93) behaved as on Windows, and both rows closed. The
first found that ⌘D in a private window did nothing on the Mac, though it bookmarks on Windows:
the Spaces menu's pin row carries the chord and was enabled only in a window with Spaces. The
tests had run the command directly; the new one presses the key through the application's event
queue and the main menu, and failed first. Fixed in patch 0170 (shortcuts Z24).

S-463, the Space switch's slide that failed alone on the PC, was the test's: the layers beside the
list showed the snapshot of the Space left, sliding out, 180 DIP tall over a list of 158, and the
test took only a layer of the list's exact bounds. It now matches place and width, and passed 15
of 15 on the PC (patch 0158).

Later the same evening: on the PC, `AddressBandTest.TheRowsEmptyPartsAreTheCaption` (S-458) turned
out to be the Windows frame's hit test. The system's caption-button rectangle, which DWM gives in
pixels converted at the system's scale, ran past Stedding's drawn buttons (2 DIP at 150%, 34 with the
scale forced to 1), and that strip of the row answered "nowhere", so a drag there did not move the
window. The rule now holds over the drawn buttons only (patch 0119); the test passed 5 of 5 at each
scale. And shared sessions (S-272) were rebased from patch 0139 onto the series after beta 17 on a
local branch, `s272`, with its ADR renumbered 0034: two textual conflicts, and one test helper that
left its cookie page so a Space's move did not set the cookie again in the jar it moved to. It waits
for the owner's read of the ADR.
Last, S-92's leftover on the Mac: a pinned parent's children had their favicons cut on the left.
The row's clip followed its bounds, not its indent; it now follows the indent (patch 0173), and
S-92 closes.

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

The pin moved from 157.0.8103.39 to 157.0.8103.51, the stable point release; the series applied
unchanged and Windows built it. Where browser sign-in is not allowed, History no longer offers "Tabs
from other devices" or a sign-in, and `chrome://history/syncedTabs` opens the history list (privacy
Q16, Q18, S-457). `BrowserSigninTest.NothingOffersTabsFromOtherDevices` failed before the fix and
passes with it. Still owed then: the Mac's move to .51 and the suites on both platforms.

## 2026-11-09 -- Issue 89's cause: a tab's sync id lasted one restart

A pin or essential restored at one launch, or a tab whose page a sleep or a Space's own session
replaced, took a new sync id at the next launch, and the other computer added it as a copy. The id
is now written with the tab's Space, pin and home (sidebar-file Sf2, S-452); eight cases keep it
(patch 0164). On Windows, tests with two restarts made 7 copies before the fix. Not yet run on the
Mac.

## 2026-11-09 -- Issue 89's answers, not reproduced yet

The reporter's steps (two copies, shown only on the Mac, after Windows syncs through WebDAV) did not
reproduce with two profiles on Windows. Four browser tests keep those steps (patch 0164); S-452
lists what was ruled out.

## 2026-11-09 -- The traffic lights: issue 93 and full screen

Issue 93 (S-453, sidebar Y55): with the sidebar and the address row hidden, the Mac's traffic lights
hide, and show on hover at the window's top or when anything of the window's is under them (patch
0119, test in 0120). In full screen with the row shown, the lights sit in the row as Chromium places
its tab strip, not on a strip of their own (S-454, sidebar Y17, patch 0120), measured in real full
screen. A failing Shift-click range (S-455, tabs R20) did not reproduce; two tests keep it (patch
0165).

## 2026-11-09 -- Issue 89's second report

Copies came whenever the Windows computer was used. Two new restart tests, on the New Tab page and
on Continue where you left off, kept every id on both platforms. Not reproduced (S-452).

## 2026-11-08 -- 0.4.0 beta 15: issues 89 and 91

The two fixes of the entry below, released. Checked: 1492 unit and 915 browser tests on the Mac and
the unit and browser suites on Windows, on the release and DCHECK builds; AddressSanitizer on
Windows with no report; acceptance on both; the update from beta 14 through a local feed.

## 2026-11-08 -- After beta 14: issues 89, 90 and 91

Issue 89: at a join with Combine, a Space never named was skipped, so two fresh installs sent each
other their pins as copies; such a Space now pairs by the name the sidebar shows (sidebar-file
Sf10). Issue 90, missing downloads, waits on the reporter (S-450). Issue 91: the peek's card fades
in over 160 ms under the motion settings (motion O10, patch 0176). The new tests failed with their
fixes taken out, and the full suites passed on both platforms.

## 2026-11-08 -- 0.4.0 beta 14: issues 85, 86 and 88

The three fixes of the entry below, released, plus ⇧⌘C and ⌥⇧⌘C in a peek's page on the Mac, which
the peek now runs itself (copy-link L8, folded into 0119, test in 0171). Checked: 1491 unit and 908
browser tests on the Mac and 1479 and 858 on Windows, on the release and DCHECK builds;
AddressSanitizer on Windows with no report; acceptance on both; the update from beta 13.

## 2026-11-07 -- After beta 13: issues 85, 86 and 88, and the issue labels

Issue 85: a pin closed with its − or put to sleep by Sleep Tab leaves the Space's history (tabs R33,
folded into 0123). Issue 86: Copy Link over a peek copies the peek's page, and the peek's bar has
its own (copy-link L8). Issue 88: Settings has the Warn Before Quitting switch (settings T60, patch
0175). Issue 87 is S-445, for later. The issues are labelled by kind, area, platform and status
(`PLAN.md` decision 16).

## 2026-11-07 -- 0.4.0 beta 13: Touch ID passkeys, split view's last rows, child tabs, another window

Patches 0165 to 0174. Passkeys (S-239, ADR 0033): a signed build offers pages a platform
authenticator. Also split view's last rows (S-102), the rest of little windows (S-157), the peek's
redirected link and screenshot (S-93), Move Tab on a selection (S-127), the rest of child tabs
(S-92), and the question when a page is open in another window (S-94's first slice). A read of the
commits found six faults and the real build a seventh (a plain click on a `target=_blank` link made
no child), each with a test. Checked: 1490 unit and 907 browser tests on the Mac and 1478 and 857 on
Windows, AddressSanitizer, acceptance on both, the update from beta 12. Not checked: a real passkey.

## 2026-11-06 -- 0.4.0 beta 12: sync through WebDAV or S3 storage, and what the real builds left

Patches 0161 to 0164. Sync can go through WebDAV or S3 storage beside the folder, through a mirror
the service reads as its folder (S-426, ADR 0032, patch 0164); a separate read found nine faults,
fixed with tests. Also a folder's − (S-442), a little window's size through a second restart
(S-436), a shorter DRM notice (S-437), and the keys back after a rename (S-438). Checked: 1484 unit
and 891 browser tests on the Mac and 1472 and 840 on Windows, AddressSanitizer, acceptance on both,
the update from beta 11, sync against a real WebDAV server on both and an S3 server on Windows.

## 2026-11-06 -- After beta 11: private windows, the Space name, the − buttons, the lit circle

Patches 0157 to 0160, on Windows: a private or Guest window follows the settings that hide the
address row (S-439, issue 83); the Space name's crash during a layout, found by AddressSanitizer, is
fixed (S-440); the − glyph sits on its circle's centre (S-441), and the lit circle is 21 DIP
(S-423). 1432 unit and 794 browser tests passed on `win-release` and `win-checks`. Not checked: the
Mac.

## 2026-11-06 -- 0.4.0 beta 11

On Chromium 157.0.8103.39: GitHub issues 79 to 82, a notice on sites that need DRM, a folder's − on
hover, one list of routes and a page after an Arc import, more of Arc in the import, import from
Opera, permission prompts in a peek, and moving a folder to another Space (S-433). A popup opened
while another popup is in front of a full-screen window now shows (S-427, windows G8); whether that
is Bitwarden's own path was still to see. The real-build pass found S-434 (patch 0156) and S-435 to
S-438. S-272 was left out. AddressSanitizer on Windows found no memory error; one CHECK crash became
S-440. The browser suite is 792 tests on Windows and 843 on the Mac, not the 978 and 1015 the first
notes said.

## 2026-11-05 -- Where someone from Arc looks (S-422, S-126)

Five commits on `stedding-work`, not yet in `patches/`. Settings has one card of routes, "Sites
routed to Spaces", edited in place; the Space menu has "Route sites here…" and "Sort open tabs by
these rules now"; Arc's words find things in the command bar and in Settings' search; an Arc import
ends on a page saying where each thing went, and Arc's routes that name one Space come across. Each
test was seen red first. Checked on the real build on the Mac, light and dark, which found three
more bugs, each now tested. Not run: `mac-checks`, Windows.

## 2026-11-05 -- A six-hour test no longer takes 50 seconds on the Mac

`IdleWindowsTest.NothingSweepsAPopupOrALittleWindow` ran six hours of mock time, 51 seconds on the
Mac; it now jumps the clock and takes 1.4 seconds (patch 0071). No product bug.

## 2026-11-05 -- Update downloads try again, and About says how to retry (S-420)

A failed or stalled update download starts over ten seconds later, three tries in all (updates
Up25); the Windows updater has a stall timer; About's failure line says that a reload tries again
(Up5). Patch 0128. Checked with a signed test copy and a local feed that stalls at 38%. Not checked:
a stall on an installed Windows copy.

## 2026-11-05 -- 0.4.0 beta 10: Chromium 157.0.8103.39, issues 78, 73 and 45, links from other apps as a peek

The pin moved to 157.0.8103.39. A collapse keeps selected pins listed, with a setting to keep every
awake pin (S-418, issue 78); device pickers, file pickers, translation and speech work in a Space
with its own session (S-402, issue 73); issue 45's site panel buttons, icon centring and a second
window's buttons (S-414, S-415, S-416); a link from another app can open as a peek (S-417, issue
74); a new window on Windows opens clear of the first (S-419). Checked: the suites on both
platforms, AddressSanitizer, acceptance, the update from beta 9, the Mac image notarized. Not
checked: the device pickers against a real board.

## 2026-11-04 -- 0.4.0 beta 9: an empty Space's page, issues 74, 75 and 76, issue 45 on beta 8

An empty Space shows its own page in every case (S-408, tabs R66); "Show tab groups" on the
bookmarks bar is off at first (new-tab N9); a collapse folds a folder's awake pins but the one on
screen (S-409, issue 76); the sidebar's field shows pinned extension icons (S-412, issue 45) and no
Install chip (S-413); the peek settings say they are for links from pinned tabs (S-410, issue 74); a
link's menu opens it in another Space's jar (S-411, issue 75). Found: S-414, S-415. Checked: the
suites on both platforms, AddressSanitizer, acceptance, the update from beta 8, the Mac image
notarized.

## 2026-11-04 -- 0.4.0 beta 8: the empty Space page, the download's start, the Mac's first run, a review of every change

Released as 0.4.0 beta 8, on Chromium 157.0.8103.31. A Space with no row awake shows its own page,
`chrome://stedding-space` (S-396, tabs R66); a download's start flies a chip to the sidebar's
downloads button (S-400, sidebar-panels Pn18). Three reviewers read every change since beta 7; their
faults, and those the Mac's tests and DCHECK build found (a crash at a quit from full screen, a
dangling pointer at every window's close), were fixed with tests. Checked: Windows updated itself
from beta 7, 1372 unit and 874 browser tests there with AddressSanitizer clean, acceptance in 39
steps; the Mac's notarized image, acceptance twice, 1381 unit and 912 browser tests on `release` and
`mac-checks`.

## 2026-11-03 -- 0.4.0 beta 8, first part: main and side releases, important updates, tidy names, issue 45 on beta 7

Not released then. Side releases (ADR 0031, `tooling/publish-side`) are GitHub pre-releases no
updater offers; a release can be marked important (`tooling/publish-appcast --important`, updates
Up23, Up24). Tidy names for pinned tabs and downloads (S-398), folder icons in the sidebar file and
sync (S-393), the welcome flow looking for browsers only at Import (S-394), issue 45 on beta 7
(S-403), the review's list (S-399), and a bigger little window at four fifths of the main window
(S-407, patch 0122, little E1). Checked on Windows on the round's tests only.

## 2026-11-03 -- 0.4.0 beta 7: the owner's list, issues 71 and 72, and a review of every change

Released as 0.4.0 beta 7, on Chromium 157.0.8103.31: the owner's list of 2026-11-02, issue 71 (a tab
opened in the background is next for Ctrl-Tab, switcher X6) and issue 72 (pins put to sleep no
longer wake each other; tabs R5, pins H3, H11). Four reviewers read every change since beta 6; the
fixes have tests (sidebar Y51, Y53, folders F42, tabs R5) and the rest is S-399. The site's
after-update page shows each release's captures, and `tooling/publish-release` refuses a tag with no
entry there. Checked: Windows updated itself from beta 6, 1362 unit and 858 browser tests on all
three Windows builds, acceptance in 39 steps; the Mac's notarized image, acceptance, 1371 unit and
886 browser tests.

## 2026-11-02, evening -- the Mac's half of the owner's list, and page bars under the page

Full screen on the Mac follows the address row's rules (toolbar T8, T10, T32; S-378); the wheel
scrolls a sidebar shown at the edge (S-386, sidebar Y52); with the address in the open sidebar the
traffic lights show only over its top (Y53, S-391); the lent buttons take the sidebar's colours
(Y51, Y46). Page bars are a pill in the window's colour under the page (toolbar T54, T36, T38).
S-392 and S-394 were filed. The release builds' full sweeps passed on the Mac, and on Windows with
two failures that passed alone after a fix. Nothing released.

## 2026-11-02, later -- the owner's list after beta 6: a peek's edge, the welcome flow's privacy step, issue 45's version B

The owner's sixteen items are S-377 to S-393. In this round, on Windows: a peek's frosted edge (peek
P21, settings T47; S-377); the welcome flow's privacy step, with link cleaning now off by default
(welcome W19; S-387; `PLAN.md` decision 20); settings and address-row changes (S-379 to S-384,
S-388); the sidebar's slide-out and folder icons (sidebar Y50, folders F41, F42; issue 68; S-385,
S-389); issue 45's version B (sidebar Y51, site-controls Si13; S-391).

## 2026-11-02 -- 0.4.0 beta 6: peek over the page, Spaces that loop, the address row in the sidebar

Released as 0.4.0 beta 6, on Chromium 157.0.8103.31, with the round below (patch 0119, issue 65's
fix in 0004). Windows: every suite on the release, checks and AddressSanitizer builds (1349 unit,
666 browser tests), the update from beta 5, the installer, acceptance 39 of 39. The Mac: 1358 unit
and 707 browser tests, one test fixed in the test alone; acceptance, with a clipboard manager taking
⇧⌘C (trap 94); Apple's distribution check.

## 2026-11-01, later -- issues 62, 65 and 66, issue 45's second round, and the import step

Issue 65 (sidebar Y47): the session rebuild keeps the sidebar's width and collapsed state, so an
update no longer opens it at 352 DIP. Issue 66: "Loop around Spaces", on by default (spaces B45,
settings T44). Issue 45's comment: a wider reveal edge, two essentials per row, the address row's
buttons under the sidebar's address (sidebar Y19, Y33, Y48, Y49; toolbar T50, T51; settings T45).
Issue 62: a peek over the page by default, the little window as a setting (peek P20, settings T46).
The import step adds Chrome, Edge, Brave and Vivaldi (import I43 to I45, welcome W3).

## 2026-11-01 -- 0.4.0 beta 5: the command bar's icons, and issue 45's settings

Released as 0.4.0 beta 5, on Chromium 157.0.8103.31: sites' icons in the command bar (issue 58,
patch 0115, commandbar K38); the hidden sidebar's edge and the speed settings (0116, motion O9);
Back, Forward, Reload and the site at the sidebar's top (0117; sidebar Y33, Y46; toolbar T50); an
Appearance card (0118, settings T41 to T43). S-370 was kept on the owner's word; S-327 closed. Both
platforms' sweeps, the installers, the update from beta 4 and acceptance passed.

## 2026-10-31 -- 0.4.0 beta 4: the sidebar comes back whatever On startup says

Released as 0.4.0 beta 4, on Chromium 157.0.8103.31. With On startup on the New Tab page or on
pages, a launch restores each window's essentials, pins, folder tabs and splits (S-323, issue 43,
patch 0114), and those launches' New Tab pages stay out of the archive (archive A16). `tooling/dev
test` builds the directory it runs (trap 141). Both platforms' sweeps, the installers, the update
from beta 3 and acceptance passed.

## 2026-10-31 -- 0.4.0 beta 3

Released as 0.4.0 beta 3, on Chromium 157.0.8103.31: Duplicate in the short tab menu (issue 63), a
split's address field over the active pane and the buttons at a centred field's end on Windows
(issue 14), and a sleeping pin that folds into its collapsed folder (issue 35). Every suite passed
(the Mac 1348 unit and 681 browser tests, Windows 1339 and 639), with acceptance on both. The
real-pointer checks closed S-357 and S-364 and found S-370.

## 2026-10-31 -- Windows on the beta 3 fixes, four tests that were wrong, the Windows leg two at a time

Windows moved onto the series with `tooling/move-series`. Four tests were fixed in the tests alone
(S-365, S-366, S-367, and one that never started its test server, which `mac-checks` had missed:
trap 138). The Windows browser leg runs two at a time (S-369). All 639 browser tests passed on
`win-release` and `win-checks`; S-334 closed.

## 2026-10-30 -- After 0.4.0 beta 2: Duplicate, and a sleeping pin folds away

Duplicate in the short tab menu, where a copy of an essential or a pin is a plain tab (issue 63,
S-363, tabs R64, patch 0110); a pin folds away when put to sleep (issue 35, S-356, patch 0112); a
split's address field follows the active pane (S-364, toolbar T49, patch 0113), which also fixed
S-357. `tooling/move-series` writes only the files that differ (trap 89). The owner decided S-355,
S-358, S-360, S-361, S-362 and S-323.

## 2026-10-29 -- 0.4.0 beta 2: the fixes of the 2026-10-28 review

Released as 0.4.0 beta 2, on Chromium 157.0.8103.31: the review's faults (S-338 to S-351, and
S-326), an extension's omnibox keyword in the command bar (S-352), and sidebar sync's last faults
(S-353). S-354 did not reproduce; issue 43 narrowed to S-323. The Windows sweep had run no test
since the Keychain's component tests joined it; they run on the Mac alone now.

## 2026-10-28 -- 0.4.0 beta 1, and a crash in 0.3.0 beta 22

Released as 0.4.0 beta 1 on Chromium 157.0.8103.31, with issues 14, 35 and 42 and the pinned-folder
drop, and a fix for beta 22's crash at Remove in a pinned tab's question (pins H29, patch 0110). A
read of the whole series confirmed 107 faults of 126 raised, all already in beta 22: S-338 to S-351,
for beta 2.

## 2026-10-28 -- GitHub issues 14, 35 and 42

Issue 42: a return to a Space lands on the essential used there last (spaces B3). Issue 35: a
collapsed folder lists a pin while it is awake (folders F3, patch 0112). Issue 14: an address-field
width setting, and no "Ask Google about this page" (toolbar T48, privacy Q17, patch 0113). Issue 43
needs no code (S-323). A tab that joins a pinned folder becomes one of its pins (folders F38).

## 2026-10-28 -- Every document reviewed

Every document was checked against the patches, the tooling and the releases and rewritten where
false, stale or long. The records were cut to what is cited: the release-notes archive went, the
history archive became the table of closed items, the 2026-09-26 audit an index of its ids, and each
trap its lesson.

## 2026-10-28 -- GitHub issue 50: the minus first

Patch 0110 (pins H29): an awake Space pin shows a minus that puts it to sleep at its home; asleep
there, the button is the x that asks before Remove (trap 135).

## 2026-10-28 -- Chromium 157 prepared, not released

The series moved to Chromium 157.0.8103.31, M157's stable cut, on `main`: 69 of the 110 patches
changed and 0111 was added (trap 134). Patch 0074 turns off `kUseActionsForBrowserCommands` and
`kWebAppInstallDialog`. Open: S-241 (an extension pinned on install) and S-335 (`gn check`). An
installed beta 22 updated into a 157 build on both platforms. The last commit of `main` on the 156
series is `1791465`.

## 2026-10-27 -- 0.3.0 beta 22: GitHub issues 50, 48 and 13, pull request 49

Released 2026-10-28 as
[v0.3.0-beta.22](https://github.com/ysalitrynskyi/stedding-browser/releases/tag/v0.3.0-beta.22), on
Chromium 156.0.8078.48, for macOS and Windows: issue 50 (pins H29), issue 48, issue 13 and pull
request 49, in the two entries below.

## 2026-10-27 -- Pull request 49: ⌘T on a folder's last tab (S-324), released in beta 22

An outside contributor's fix for S-324 (patch 0057, folders F25): the tab ⌘T opens on a folder's
last tab is no longer filed into the folder; links and duplicates still join it. As sent, the change
did not compile and would not have fixed the bug.

## 2026-10-27 -- GitHub issues 48 and 13, released in beta 22

Issue 48 (copy-link L7): Copy Link and its toast in a little window. Issue 13 (shortcuts Z23): the
Spaces and the rows can trade ⌘1–⌘9 and ⌃1–⌃9, or move to ⌃⌘ (Alt+Shift on Windows). Found: S-326,
S-327.

## 2026-10-27 -- 0.3.0 beta 21: GitHub issues 42 to 46

Released as 0.3.0 beta 21, on Chromium 156.0.8078.48: issue 44, a crash from a popup opened in a
folder (folders F25); issue 43, the Dock brings the last window back on the Mac (windows G9, S-323);
issue 42 (spaces B3); issue 46 (blocker Bk9, Bk21); and ⌘S with a sidebar panel open (S-322). S-324
was found here.

## 2026-10-26, late night -- 0.3.0 beta 20

Released as 0.3.0 beta 20, on Chromium 156.0.8078.48, both platforms and both feeds: the Settings
work below, the wording pass, the Shortcuts list's remove buttons, and sync that names any folder.

## 2026-10-26, night -- Settings with room

Settings › Stedding is one long page with short descriptions (settings T13, patch 0109), with a Sync
and import card. Sync works with any folder the computers share (sidebar-file Sf42, patch 0106). On
macOS the build's free-space check counts purgeable space.

## 2026-10-26, evening -- 0.3.0 beta 19

Released as 0.3.0 beta 19, on Chromium 156.0.8078.48: Settings › Stedding as a card per group
(settings T13, patch 0109); "Mark pinned tabs that left their page" off by default (pins H28, issue
36); turning off a Space's own session asks when only apps use it (sessions S10); a key after a held
press is no longer taken for a peek (peek P18); pin drags fixed (issue 41); the sidebar's text stays
put when a page's colour arrives (S-316, patch 0105).

## 2026-10-26 -- 0.3.0 beta 18: the owner's round, a review, then fixes

Released as 0.3.0 beta 18, on Chromium 156.0.8078.48: a Space's colour tints only the sidebar's
ground (patch 0105); the first peeks explain themselves (peek P19, patch 0106); separators from a
row's menu (sidebar Y45, issue 19, patch 0107); fixes from a review. Patch 0108 joined the short
browser tests; the browser tests run four at a time (`tooling/dev`).

## 2026-10-25, night -- 0.3.0 beta 17: issue 38, the sidebar's foot, issue 37

Released as 0.3.0 beta 17, on Chromium 156.0.8078.48: browser sign-in is never offered (privacy Q16,
welcome W18, patch 0104, issue 38); a new sidebar foot (sidebar Y44); the command bar's shadow and
edge (commandbar K36, issue 37); F6 no longer crashes (patch 0103). The AddressSanitizer run owed
from beta 16 passed on Windows.

## 2026-10-25, evening -- 0.3.0 beta 16 released

Released as 0.3.0 beta 16, on Chromium 156.0.8078.48, both platforms and both feeds: the Peek and
sidebar notes and the features in the entry below.

## 2026-10-25, day -- the owner's notes on Peek and the sidebar, wave 1 built

Peek on a click or a held press (peek P18, welcome W16, patch 0102); the sidebar's text at 14
(sidebar Y2, welcome W17); the address row stays in macOS full screen (toolbar T8, patch 0092). The
same day: History and Downloads in the sidebar, the sidebar on the right, clean links, shortcuts the
user can change, site controls, import from Dia and Safari's export, export of all Spaces, sync
through a folder, and ad and tracker blocking, off until turned on.

## 2026-10-25, morning -- Peek on by default

The owner chose Peek on by default (`PLAN.md` decision 2).

## 2026-10-25, night -- Peek rebuilt on the little window

Patch 0088: a peek is a little window over the window, a whole tab in the pin's own jar (peek P6,
P11). Open as Tab (⌘O) and Open in Split View (⇧⌘O) move the page without a reload (P7, P9); Escape
closes it (P14); a redirect is judged by where it leads (P15, P16). S-102 was left undecided.

## 2026-10-25, after midnight -- 0.3.0 beta 15 released

Released as 0.3.0 beta 15, on Chromium 156.0.8078.48: Edit Space, the welcome flow's new look, and
GitHub issues 26, 27, 29 and 30. Both platforms updated from beta 14. From the next release
`tooling/package-dmg` signs, notarizes and staples the disk image.

## 2026-10-24, late -- Edit Space: any emoji, any colour, one for each look

Edit Space is a window of its own (spaces B41 to B44, S-99): any emoji or none, and one colour, or
one for the light look and one for the dark.

## 2026-10-24, night -- three GitHub issues fixed, the issues labelled

Issue 29 (S-298, pins H14), issue 26 (S-299, tabs R63), issue 27 (S-300, folders F40) and issue 30
(S-301, tabs R33, R35). Issue 31 is routing already.

## 2026-10-24, evening -- betas 13 and 14, and the welcome flow's new look

0.3.0 beta 13 and beta 14 went out on 2026-10-24; beta 14 asks to be the default browser with one
button (welcome W5) and gives each step a glyph (W13). Then a welcome screen ahead of step 1 and
drawings for the choices (W4, W5, W14, W15), released as beta 15.

## 2026-10-24 -- after beta 12: the drag into the essentials animated, Google Pay in a Space, Arc import on Windows

0.3.0 beta 11 and beta 12 went out on 2026-10-23 and 2026-10-24. Then, released as beta 13: a drag
across the essentials' edge is a floating copy until the drop (pins H27, issue 16, S-289); a Space
with its own session is offered no payment app (sessions S36, issue 25, S-296); Arc for Windows is
imported, passwords included (import I27, S-81). `tooling/fold-fix` folds a new file into a patch.

## 2026-10-23, before dawn -- the Windows update that never came, 0.3.0 beta 9 and beta 10

0.3.0 beta 9 and beta 10, in patch 0078 (S-279): on Windows a failed update download tries again
within the hour, at a priority the busy browser does not starve, and the publish-appcast scripts
check the release's checksum before writing the feed. S-279 stayed open.

## 2026-10-23, small hours -- a drag into the essentials and out, 0.3.0 beta 8

0.3.0 beta 8 (patch 0086, S-277, GitHub issue 16, pins H27): a tab dragged over the essentials
becomes one, and an essential dragged onto the list stops being one.

## 2026-10-22, late night -- little windows on Windows, essentials that shrink to fit, 0.3.0 beta 7

0.3.0 beta 7 (patch 0085): little windows on Windows (S-56, little E10, routing D3), and up to four
essentials on a row before a second (sidebar Y33, S-276, GitHub issue 15).

## 2026-10-22, night -- after beta 5: a drag across the Clear line, the Copy Link button's hover, a session for every new Space

0.3.0 beta 6: a drag across the Clear line takes the pin of the side it lands on (pins H14, S-271,
patch 0083); the Copy Link button's hover (copy-link L7, S-273); "Give every new Space its own
session", off by default (sessions S35, settings T29, S-274, patch 0084).

## 2026-10-22, day -- the owner's round after beta 4, GitHub issues 8 and 11, 0.3.0 beta 5

0.3.0 beta 5 (patch 0083): the Copy Link button (GitHub issue 11, copy-link L7, settings T28); a
Space with an Independent session has essentials of its own (GitHub issue 8, ADR 0028, spaces B6,
sessions S8, S33); a hover card's memory, CPU and network (pins H25); and sidebar fixes, among them
GitHub issue 12. A crash with animations off was fixed (patch 0071, S-269); Widevine waits on a
licence (S-270).

## 2026-10-22, night -- the owner's three open decisions, the folder header for Narrator, 0.3.0 beta 4

0.3.0 beta 4 (patch 0081): ⌘N opens a window on the Space it is pressed in (windows G6, S-145); a
setting brings back the bookmark bar and the star (settings T27, S-142); a question before more than
50 bookmarks become pins (import I16); Narrator can open and close a folder (folders F4, patch
0070).

## 2026-10-22, small hours -- the checks after beta 2, and 0.3.0 beta 3

0.3.0 beta 3 (patch 0077, toolbar T31): a failed read of the page's top edge is tried again, so the
address row does not keep the page's declared colour on a slow machine.

## 2026-10-21, night -- child tabs, the owner's Arc import checked, 0.3.0 beta 2

0.3.0 beta 2 released patches 0078 to 0080: child tabs under the page that opened them (tabs R56 to
R59, settings T26, patch 0080), and an Arc folder of folders comes across as a folder (S-48).

## 2026-10-21, evening -- after 0.3.0 beta 1: quieter defaults, a split's row, the Space row, folders

Patch 0078 (S-258): quieter defaults and an updater check at launch, then every six hours. Patch
0079: a split's address row ends at each pane (toolbar T41, splits J16), Space chips shrink before
they turn to dots (spaces B24), and a collapsed folder shows no count (folders F33).

## 2026-10-20 night to 2026-10-21 -- the owner's notes on beta 21, the Chrome 156 stable pin, 0.3.0 beta 1

0.3.0 beta 1 (patch 0077), on Chromium 156.0.8078.48 after the pin moved to that stable release (ADR
0007): the first build published as the latest release rather than a pre-release. A GitHub issue is
a suggestion unless it reports a bug (`PLAN.md` decision 16). Closing a pin or essential sends it
home (decision 11); a folder can join the pinned run (decision 12); a sideways scroll steps one
Space (GitHub issue 10, decision 15); the Mac's little window gets Open in Stedding and Open in
Split View (GitHub issue 9, S-157); the sidebar's motions ease out (motion O4 to O8). GitHub issue 8
was declined that night (S-254).

## 2026-10-19 night to 2026-10-20 -- the planned fixes, six features, the owner's look notes, beta 21

0.2.0 beta 21 (patches 0071 to 0076). Patch 0075: a tab dragged onto the page makes a split (S-113,
GitHub issue 7), a close shows the tab used last (S-112), only the selected tab loads at launch
(S-110), tabs sleep on a timer and under memory pressure (S-111), page pictures in the Mac's hover
cards (S-115), the address row's controls in the command bar (S-104). Patch 0076: the split's
address row in each pane's colour, pill tabs on top, the rail's glyphs on one centre line. Patch
0074: Chrome's launched features, key pins and Certificate Transparency, with no certificate reports
(S-236, S-237); `tooling/field-trials` (S-240). Patches 0071 to 0073: fixes, among them S-71, S-143,
S-144, S-230, S-249 and S-250.

## 2026-10-19, evening -- a review of betas 18 and 19, and beta 20 for both platforms

`v0.2.0-beta.20` for macOS and Windows, on Chromium 156.0.8078.36: the first release an installed
Windows copy updated itself into, from beta 19. A restored unloaded tab no longer comes back crashed
(patch 0058, import I26), a toast stays under the infobars (toolbar T38, patch 0072), and the
Windows updater was hardened (patch 0073).

## 2026-10-19, afternoon -- the Windows updater, beta 19

`v0.2.0-beta.19`, Windows only: Stedding updates itself there from `updates/appcast-windows.xml`
with an Ed25519 key of its own (patch 0073, S-215, updates Up14 to Up22, ADR 0026), and Windows gets
a version of Stedding's own, beta 19 being 156.2.0.19 (S-72).

## 2026-10-19, late morning -- beta 18 from the PC

`v0.2.0-beta.18`, Windows only, on Chromium 156.0.8078.36: patch 0072, with S-244, S-245 and S-246
fixed.

## 2026-10-19, morning -- patch 0072 on the PC: the Windows-only failures, the essentials card

The Windows-only failures were faults in the tests (S-242). The essentials card is a frosted tile
with no edge (tabs R32, S-243). S-244 was found and fixed before beta 18.

## 2026-10-18 night to 2026-10-19 -- installed builds, four features and the defects (patch 0072)

Patch 0072: dark pages for every site, a page as an app in its Space's session, a tape on tabs of
this machine's own server, a mark on Spaces with their own session (sessions S32 to S34, spaces
B38), a quieter Archived row (sidebar Y27), and the network service in its own sandbox on Windows
(windows N15). Installed builds found S-229, S-231 and S-232; on Windows Ctrl+Esc stays the Start
menu's (S-228).

## 2026-10-18, evening -- the checks still owed (patch 0071)

Patch 0071: deleting a Space asks first and wipes its jar (S-148); renaming in place (S-149); a
session cookie survives a restart (S-147); fixes S-222 to S-226; the archive counts wall-clock time.

## 2026-10-18, later -- defect round

Patch 0070: S-79, S-134, S-138, S-139 (folders F37), S-142, S-145, S-146, S-212 and S-219. A release
build reports a soft check instead of stopping (patch 0069, ADR 0024).

## 2026-10-18 -- beta 17 released from both platforms, the first update through the feed

`v0.2.0-beta.17` went out for macOS and Windows, on Chromium 156.0.8078.36, the series of 68
patches. A Mac copy of beta 16 updated itself through `updates/appcast.xml`: the first update
through the feed (S-74).

## 2026-10-16, evening -- the pin moves to 156.0.8078.36

The pin moved from 155.0.8059.12 to 156.0.8078.36 (S-217); 27 of the 68 patches needed a hand merge
(trap 92). ADR 0023 sets updates on Windows (S-215, after S-72) and Linux (S-216).

## 2026-10-16, midday -- beta 16 released from both platforms, and the first update feed

`v0.2.0-beta.16` for macOS and Windows, on Chromium 155.0.8059.12, the series through patch 0068:
the first release built with the updater (S-74).

## 2026-10-16 -- Stedding updates itself on the Mac, and says thank you (patch 0068)

Patch 0068 (ADR 0022, updates Up1 to Up13): Sparkle 2.10.0 checks a signed feed in this repository,
and Settings can turn every request off. The Mac's bundle version is Stedding's own (0.2.0-beta.16
is 10020.16). A thank-you page opens on stedding.dev after the welcome flow and on each new
version's first launch. A crash in the Windows AltGr chords was fixed (patch 0067, trap 91).

## 2026-10-15, night -- the review's remaining items, and a new default favicon (patch 0067)

Patch 0067: a Space's sessionStorage, crash restore and notifications in a Space's own jar (sessions
S28 to S30); S-181, S-182, S-183 and S-189; and a new default favicon (S-211).

## 2026-10-15, evening -- beta 15 released, both platforms from the Mac

`v0.2.0-beta.15` went out for macOS and Windows, the series through patch 0066.

## 2026-10-15, afternoon -- the review's filed items fixed, and a tab group's header (patch 0066)

Patch 0066: S-201 to S-208, and an unnamed tab group's header as a row (folders F36, S-210).

## 2026-10-15 -- a code review of the whole series (patch 0065)

Patch 0065: the review's faults S-190 to S-199, among them crashes on closing a split's pane (S-190)
and grouping a tab in a folder (S-191), and Autofill no longer sending forms to its server (S-194).
