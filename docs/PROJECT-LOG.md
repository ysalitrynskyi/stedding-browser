# Project log

What was built, newest first. Nothing here is needed to do a task: `AGENTS.md` carries what is true now, `BACKLOG.md` the order of work, `PLAN.md` the owner's decisions. This file was the "State of the project" section of `AGENTS.md` until 2026-09-30. This log starts at 2026-10-15. Closed work from before that is the table in [docs/history/archive.md](history/archive.md).

## 2026-10-30 -- After 0.4.0 beta 2: Duplicate, and a sleeping pin folds away

Not released yet. The short tab menu offers Duplicate (GitHub issue 63, S-363), and the copy of
an essential or a Space pin is a plain tab where a new tab opens, the owner's choice: Chromium's
copy of an essential had been a second essential (tabs R64, patch 0110). A pin a collapsed folder
keeps listed while it is awake folds away when it is put to sleep (GitHub issue 35, S-356, patch
0112). Issue 14's buttons in a centred address field answer the window's hit test on both
platforms; a real click on Windows is still owed (S-357). `tooling/move-series` moves a checkout
onto a newer series by writing only the files that differ (trap 89). Every GitHub issue was read
again and the open ones labelled.

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
