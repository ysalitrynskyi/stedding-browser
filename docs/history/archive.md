# Closed backlog items

Every item that left [BACKLOG.md](../../BACKLOG.md), with how it closed. Ids are never reused;
specs, patches and notes cite them, and `tooling/check-repo` resolves every id cited in the
docs here or in the backlog. What each feature does now is its spec under
[features/](../features/); the 2026-09-26 audit, whose ids the code cites, is
[plan-2026-09-26.md](plan-2026-09-26.md).

| Id | Item | Closed by |
|---|---|---|
| S-552 | ⌃⇥ lists essentials and pins that are asleep, and stopping on one wakes it (GitHub issue 126) | Shipped in 0.7.1 (switcher X1; tabs R33): the five places after the history take only rows that are awake, so an essential or a pin asleep, or never opened, is not in the run and stepping on it opens nothing. `SpaceWindowTest.TheRunFillsOnlyWithRowsAwake` red then green on Windows. Closed 2026-11-23. |
| S-556 | Settings' Languages section and the live-caption menu asked Google for Translate's language list | Shipped in 0.7.1 (a patch of its own): without an API key the list is never asked for and the built-in list answers (`docs/PRIVACY.md`). `TranslateLanguageListTest.NoFetchWithoutAnApiKey` red then green on Windows. Closed 2026-11-23. |
| S-557 | Collapse All Folders and Expand All Folders in a folder's own menu (discussion 128) | Shipped in 0.7.1 (folders F30; menus M7): Collapse All Folders and Expand All Folders under Collapse Folder in a folder's menu, named for what ⇧⌘E (Ctrl+Shift+E) would do in that window. `FolderTabsTest.TheHeaderMenuFoldsEveryFolder` red then green on Windows. Closed 2026-11-23. |
| S-555 | The other Spaces' icons were too faint | Shipped in 0.7.1 (spaces B11): the other Spaces' icons grey at 50% (the owner's pick A of four renders). `SpaceSwitchTest.OnlyTheSpaceOnScreenIsInColour` red then green on Windows. Closed 2026-11-23. |
| S-553 | Switching Spaces did not keep each Space's list scroll | Shipped in 0.7.1 (spaces B48): each Space's list offset kept per Space and window and put back, clamped, before the slide. `SidebarClickTest.EachSpaceKeepsItsListsScroll` red then green on Windows. Closed 2026-11-23. |
| S-554 | A Space switch read as one Space taken away and another popping up | Shipped in 0.7.1 (spaces B32, B35, B37): the new list pushes the old one out, joined a whole width apart, unfaded, 260 ms, the Space's title row moving with its list on every switch (the owner, 2026-11-22: "Slide the name too"); a switch under a panel shows the new Space at once. Frames shown to the owner ("Looks good"). `SpaceSwitchTest.TheSpaceLeftSlidesOutAsTheNewOneComesIn`, `ASwitchUnderAPanelShowsTheSpaceAtOnce` red then green on Windows; the swipe on the Mac. Closed 2026-11-23. |
| S-551 | On the Mac, the ⌃ shortcuts do nothing under a keyboard layout whose ⌃ keys type non-Latin letters | Shipped in 0.7.1 (shortcuts; tabs R29): a ⌃ chord whose typed letter is not Latin falls back to the key's place, so ⌃M mutes under a Cyrillic layout; a Latin layout keeps the letter it types. `GlobalKeyboardShortcuts.AControlChordUnderANonLatinLayoutMatchesByItsKey` red then green on the Mac. Closed 2026-11-23. |
| S-548 | The Spaces you are not in stand back further in the switcher (GitHub issue 122) | Shipped in 0.7.0 (patch 0194; spaces B11, B38): the other Spaces' icons grey and at 35% in the open sidebar and the rail, the session badge in its colour above the grey, and a Space under a dragged tab in colour; the owner picked the look from four rendered options. Closed 2026-11-20. |
| S-547 | ⌃⇥ changes the tab only when ⌃ is let go (GitHub issue 123) | Shipped in 0.7.0 (patch 0193; switcher X2, X3): a step moves the strip's highlight, letting go of ⌃ or the window losing activation shows the tab, Escape keeps the tab the run began on, and a tap still goes to the previous tab; TST-9 passed on both platforms. Closed 2026-11-20. |
| S-358 | Sparkle 2.10.1 | Shipped in 0.7.0: pinned with its archive's digest in `tooling/fetch-sparkle`; the update from the installed 0.6.1 (Sparkle 2.10.0) and one installed by 2.10.1 both passed from a local signed feed. Closed 2026-11-20. |
| S-549 | A download started just before moving off a full-screen window flies and rings on the next Space | Shipped in 0.6.1 (patch 0123): the flight, the ring and the toast start only while their window is on the screen, and a window that leaves takes them with it. On the Mac's real system, a copy with a window on the desktop Space and one in full screen, the desktop window raised mid-flight: 0.6.0 rang the full-screen window's button on the desktop Space, 0.6.1 showed nothing of that window there. Closed 2026-11-19. |
| S-546 | A new window of a profile with hundreds of pins opens slowly | Shipped in 0.6.1 (patch 0190): the window's own Space and the essentials first, the other Spaces one at a time, the sidebar's passes deferred to the end of a bulk filing. `PinsEveryWindowTest.ANewWindowWithManyPinsOpensSoon` at 443 records on the release builds of both platforms. Closed 2026-11-19. |
| S-545 | With many Spaces the Space chips sit nearer the "+" than the downloads button | Shipped in 0.6.1 (patch 0104): the chips centre between the downloads icon and the "+"; within 1 DIP in the captures of both platforms with nine Spaces. Closed 2026-11-19. |
| S-496 | A tab of a pin made asleep in another window, and a live folder's row, draws the generic globe | Shipped in 0.6.1 (patch 0190): an asleep tab shows the icon history keeps for its page, or its site, until it loads; seen in the captures of a new window on both platforms. Closed 2026-11-19. |
| S-422 | Where someone from Arc looks | Built 2026-11-05 (patches 0135–0139) and in every release since: one list of routes in Settings with "Route sites here…" on the Space menu, Arc's words as search terms in the command bar and Settings, a page after an Arc import saying where each thing went, and Arc's routes imported. Closed 2026-11-18 in the docs pass. |
| S-126 | Routing's second pass | Built with S-422 (patch 0136): "Route sites here…" on the Space menu and "Sort open tabs by these rules now"; routing D5 is closed by D12–D16. Closed 2026-11-18. |
| S-477 | How a Space's session shows (GitHub issue 99) | Shipped in 0.5.0 (patch 0182): a line in the session's colour under its Spaces' chips, a disc in that colour, and new words in the menus, Settings and the command bar; the Mac ran in that release's gate. Closed 2026-11-18. |
| S-464 | Mac browser tests leave windows in WindowServer until the person logs out | Done 2026-11-11: `tooling/dev` refuses a Mac browser leg over 12,000 windows and names the largest owners after a run that leaves more than 500 (trap 147); a full `mac-checks` leg then took the count from 166 to 169, under the row's 100. Closed 2026-11-18. |
| S-278 | The pin moves to Chrome 157 | Released 2026-10-28 in 0.4.0 beta 1 on M157's stable cut (trap 134); the pin then followed M157's point releases to 157.0.8103.79. The next move is S-335. Closed 2026-11-18. |
| S-543 | The address row's menu button sat 1 DIP past the row's end, under the window's corner buttons | Fixed 2026-11-17, for 0.6.0 (patch 0113, its test in 0193): what sits past the field now moves back inside the row, the spacer or else the field giving up the room. |
| S-534 | Two browser tests crashed at shutdown on the DCHECK build: "StoragePartitionMap is not shut down properly" | Fixed 2026-11-16 night, for 0.6.0 (patch 0182): a Space's jar wipe that finished after the profile had begun to shut down still asked for the partition; it now answers false and leaves it. |
| S-542 | Compact mode hides the title bar too (GitHub issue 120) | Built 2026-11-16, for 0.6.0 (PLAN.md decision 24; patch 0193; toolbar T64, settings T75, sidebar Y54): an optional setting hides the address row with the sidebar closed; a rest at the top edge shows it. Unbuilt on the Mac. |
| S-540 | The window's corner buttons showed over the page's corner (GitHub issues 118, 119) | Built 2026-11-16, for 0.6.0 (PLAN.md decision 24; patch 0126, its test in 0157; sidebar Y54): on Windows, with the address in the sidebar, they now show only from a thin strip along the window's top edge. |
| S-541 | Closing a Space's last tab woke an unopened essential (GitHub issue 121) | Built 2026-11-16, for 0.6.0, option B (PLAN.md decision 24; patch 0124; tabs R37, R34, R5, R66, spaces B3, B4): closing it, or switching to an empty Space, shows only an awake pin or essential, else the Space's page. |
| S-533 | A bookmarks page in an unzipped Safari export was read whole, past its 32 MB limit, if it grew after its size was taken | Fixed 2026-11-16, for 0.6.0 (patch 0097; import I35): the page is now read once, up to the limit, and the parser is given that copy. |
| S-532 | Undo on a routed tab's notice could file a tab an extension had moved to another window in this window's Spaces | Fixed 2026-11-16, for 0.6.0 (patch 0182; routing D4): a tab leaving the window clears its remembered route, and Undo ignores a tab no longer here (as S-338 for a drop). |
| S-531 | A host-suffix route with an international domain, or an unbracketed IPv6 address, never routed anything | Fixed 2026-11-16, for 0.6.0 (patch 0066, its test in 0135; routing D8): the suffix is put in an address's form when matched, as a host rule's host is, so stored and synced rules route. |
| S-530 | After a clock that ran ahead was put right, the blocker's lists were not fetched again until the date the wrong clock had set | Fixed 2026-11-16, for 0.6.0 (patch 0098; blocker Bk2): a stored next fetch further away than the list's expiry is brought back to the expiry. |
| S-529 | Export Space failed for a Space with a long name | Fixed 2026-11-16, for 0.6.0 (patch 0101, its test in 0179; import I20): the name in the file's name, too long past about 220 characters, is cut to 100 bytes on a character's boundary; the Space keeps its whole name. |
| S-528 | A screenshot of a site with a very long host name was never saved | Fixed 2026-11-16, for 0.6.0 (patch 0057, its test in 0064; screenshot C1): the host in the file's name is now cut to 100 bytes. |
| S-527 | In a narrow window with the sidebar open, the ⌃⇥ strip ran past the window's edge | Fixed 2026-11-16, for 0.6.0 (patch 0023, its test in 0127; switcher X7): the strip is never wider than the page less 16 DIP each side, as the command bar (K20). |
| S-526 | Two computers' folder moves could nest folders deeper than five, so every computer refused the sync file | Fixed 2026-11-16, for 0.6.0 (patch 0191; sidebar-file Sf15, Sf33): a folder past the fifth level now goes, with its contents, to the end of its Space's pinned run on every computer. |
| S-525 | A computer's name cut inside a character made every other computer refuse its sync file | Fixed 2026-11-16, for 0.6.0 (patch 0191; sidebar-file Sf33): the name is now cut between characters, when changed and when read, and both name fields in Settings take at most 85 characters. |
| S-524 | A sidebar past a sync file's caps was written anyway, refused everywhere, and rewritten every few seconds | Fixed 2026-11-16, for 0.6.0 (patch 0191; sidebar-file Sf31): it is no longer written; the last file stays and Settings says the sidebar is too large. What to drop is the owner's call. |
| S-523 | With tidy names on, a file from a typed address, bookmark or dropped link took the title of the page the tab still showed | Fixed 2026-11-16, for 0.6.0 (patch 0121; sidebar-panels Pn17): the title is used only when the tab's address as the download began is the page it shows. |
| S-522 | Move to Trash on an old download could trash a newer download's file of the same name | Fixed 2026-11-16, for 0.6.0 (patch 0189; sidebar-panels Pn11, Pn19): the file moves only while it is still the download's and unchanged since it finished; otherwise the row says it could not be moved. |
| S-521 | ⇧⌘O in a small-window peek whose pinned tab had gone split the page with an unrelated tab | Fixed 2026-11-16, for 0.6.0 (patch 0126, its test in 0141; peek P9): a peek offering no split now gets its own tab from the key, as Open as Tab does. |
| S-520 | A link for a new tab waiting behind a small-window peek's "Leave site?" showed a blank peek after Leave | Fixed 2026-11-16, for 0.6.0 (patch 0141; peek P13): the link's page, while still there, is handed back to the new-window code and loads; a gone page never is (S-504). |
| S-519 | A link from another app that arrived while a peek asked "Leave site?" opened twice | Fixed 2026-11-16, for 0.6.0 (patches 0126 and 0119; little E11, peek P13): the link now waits for the answer, as a pin's link does, and that peek comes to the front; Stay drops the link. |
| S-518 | Turn Bookmarks into Pinned Tabs stayed offered for bookmarks left in a folder the person had removed | Fixed 2026-11-16, for 0.6.0 (patches 0169 and 0145; import I16): the count now follows the conversion's rules, which skip such a folder (I12); whether to remake it is the owner's question. |
| S-517 | A computer that stopped syncing through WebDAV or S3 stayed listed as present, its extensions still offered | Fixed 2026-11-16, for 0.6.0 (patch 0164; sidebar-file Sf52, Sf64): a file missing from the list is asked for once more and leaves the local mirror only if the server says it is gone. |
| S-516 | Arc lists or bookmark folders nested over five deep came in as loose tabs at the Space's end | Fixed 2026-11-16, for 0.6.0 (patch 0145; import I3): what such a list holds, its own lists' tabs included, now goes into the fifth folder in Arc's order, and later additions join it. |
| S-515 | A notification from a shared-session site opened its page in the on-screen Space's session | Fixed 2026-11-16, for 0.6.0 (patches 0067 and 0072; sessions S30): the window now opens in the shared jar, filed in the on-screen Space if it is on the shared session, else the first such Space (Wa14). |
| S-514 | After a Space's session changed under unsaved changes, Back could show the earlier page in the old session | Fixed 2026-11-16, for 0.6.0 (patch 0182; sessions S21): that tab's pages kept for Back and Forward, and those made ahead, are now dropped, as S-502 did for Clear Session Data. |
| S-513 | In a Space with its own session, address-bar prerenders carried the shared session's cookies | Fixed 2026-11-16, for 0.6.0 (patch 0083, its test in 0182; sessions S20, S21): pages are now made ahead only in the tab's own jar, and only when the page needs no other jar. |
| S-512 | Turn Bookmarks into Pinned Tabs left a folder's bookmarks as plain tabs under the Clear line | Fixed 2026-11-16, for 0.6.0 (patch 0145; import I13): a bookmark folder now becomes a pinned folder and each bookmark in it a pin with its home, in the tree's order. |
| S-511 | Reloading or leaving a Settings page cancelled the sync setup another Settings page was in the middle of | Fixed 2026-11-16, for 0.6.0 (patch 0191; sidebar-file Sf49): each page now carries its own token, and only what it set going is cancelled. |
| S-510 | Back or Forward between a web page and a browser page did nothing in a Space with its own session | Fixed 2026-11-16, for 0.6.0 (patch 0182; sessions S20): the jar check now judges a step by the page it leads to, remaking the tab in that jar. |
| S-509 | The page's top corners were square under an address row with no page colour (GitHub issue 118) | Fixed 2026-11-16, for 0.6.0 (patch 0120; toolbar T16, T19, T61, splits J7): the top is square only where the row is painted in the page's colour, pane by pane in a split. |
| S-508 | An Arc import overwrote a password saved in Stedding with Arc's older one, and counted blocked sites as passwords | Fixed 2026-11-16, for 0.6.0 (patch 0097; import I23): logins now go through the Safari and Chromium-family imports' writer (I39), which keeps a saved login; blocked sites are not counted. |
| S-507 | A sidebar sync backup made while five others carried a later time was deleted as it was written | Fixed 2026-11-16, for 0.6.0 (patch 0191; sidebar-file Sf35): the backup just written is now always one of the five kept. |
| S-506 | Two computers' folder moves could make a folder its own ancestor, and every computer refused the file | Fixed 2026-11-16, for 0.6.0 (patch 0191; sidebar-file Sf15, Sf33): each cycle is now cut alike everywhere, the folder placed first moving to the first Space's pinned run; nesting past five went to S-526. |
| S-505 | A message with no argument from a Space's own page (`chrome://stedding-space`) stopped the browser | Fixed 2026-11-16, for 0.6.0 (patch 0156; tabs R66): `getSpace` now drops a message of the wrong shape, S-188's rule. |
| S-504 | A peek over the page closed as it first showed could crash the browser when the link had made its own page | Fixed 2026-11-16, for 0.6.0 (patch 0141; tabs R67): only a page that is still there is handed back to the new-window code, as the plain-link path already did. |
| S-503 | Turning automatic updates off on Windows while a scheduled check ran still downloaded the installer | Fixed 2026-11-16, for 0.6.0 (patch 0078; updates Up20): turning it off now stops the request under way, and the feed's answer and the download each check the setting again before the next step. |
| S-502 | Clear Session Data left the pages kept for Back signed in, live | Fixed 2026-11-16, for 0.6.0 (patch 0182; sessions S13): pages kept for Back in that jar are now dropped as the clear starts and when it ends, as Chromium's own clear of browsing data does. |
| S-501 | ⌘L sent the page's address to the search engine for suggestions before a key was pressed | Fixed 2026-11-16, for 0.6.0 (patch 0115; commandbar K12): until the text is edited the providers answer from this computer alone; the first edit asks as typing does. |
| S-500 | A script address pasted or dropped into ⌘L's bar ran in the page | Fixed 2026-11-16, for 0.6.0 (patch 0115; commandbar K46): a paste is now cleaned as the address bar cleans one, and a drop from outside takes the whole field, cleaned the same way. |
| S-499 | A tab let go by pins in every window, then pinned again, stopped this computer's sync | Fixed 2026-11-16, for 0.6.0 (patches 0090, 0101, 0190, 0192; windows G15, G19, live-folders Lf8): its token was not a lower-case UUID, so other computers refused the file. Every tab token now comes from `stedding::NewTabToken`. |
| S-498 | Joining sync from Settings did nothing | Fixed 2026-11-16, for 0.6.0 (patch 0191; sidebar-file Sf9, Sf58): the join sheet sent six arguments and the handler still took exactly three, so Combine and Keep never reached the service. It now takes three or six; three alone join with both boxes on. |
| S-495 | A third review of 0.6.0's fixes found eight faults | Fixed 2026-11-16, for 0.6.0 (patches 0179, 0190–0192; windows G13, sidebar-file Sf35, Sf60, Sf69, live-folders Lf8): pin order and merges across windows, sync's record of applied values, folder actions that left the live folder on, and an old backup importing with copies. |
| S-493 | Sync made a second Space when a join combined two Spaces under the other computer's id | Fixed 2026-11-16, for 0.6.0 (patches 0101, 0106, 0179; sidebar-file Sf10, Sf35): lookups go through the join's aliases, and backups use this computer's ids. Released from 0.3.0 beta 16 to 0.5.1; its leftovers are S-494. |
| S-492 | `CommandBarKeysTest` crashed in its own wait under a parallel run | Fixed 2026-11-16, for 0.6.0, in the tests: two waits held the bar as a raw pointer, and the bar closes when its window loses focus. Each wait now looks the bar up again. |
| S-489 | The download toast's menu: Move to Trash and Remove from List (GitHub discussion 116) | Built 2026-11-14, released in 0.5.1 (patch 0189; sidebar-panels Pn19), Move to Recycle Bin on Windows. A crash at Move to Trash, from the bubble's menu, was fixed in the same patch. |
| S-488 | Shift-click on any link opens a peek (GitHub discussion 115) | Built 2026-11-14, released in 0.5.1 (patch 0188; peek P27, settings T63): from any tab to any site, `target=_blank` links too. "Shift-click a link to peek at it" is on by default; turned off, Shift-click opens a window again. |
| S-487 | The address row kept a page's declared colour that the page never showed | Fixed 2026-11-14, released in 0.5.1 (patch 0160; toolbar T63): a declared colour is now the row's only where a third of the page's top edge shows it, and a ruled-out colour leaves the row. |
| S-486 | On the Mac, a right-click on a link or tab ended 0.5.0 when another Space had its own session | Fixed 2026-11-14, released in 0.5.1 (patch 0182; sessions S32, menus M1, M14): the Mac's native menus refuse S-477's session disc as an image generator; it is now an `NSImage`. |
| S-480 | On Windows the sidebar list sometimes never scrolled to a row made active | Fixed 2026-11-14, for 0.5.0 (sidebar Y58; the sidebar-on-the-right patch): Chromium scrolls only after a window's first showing, learned from a visibility change Windows did not always send. A window already visible now counts as shown. |
| S-484 | The sidebar expanded on hover, or slid in when hidden, ignored the width the user had set (GitHub discussion 117) | Fixed 2026-11-14, for 0.5.0 (sidebar Y57; the patch that hides the sidebar completely): the strip took Chromium's default 352 DIP on hover; it now takes the open sidebar's width. |
| S-483 | Past four Spaces the rail's Space dots took a column, 18 DIP a dot | Built 2026-11-13, for 0.5.0 (patch 0187; sidebar Y56), in the form the owner chose from renders: the active Space's chip leads and the other Spaces' dots stand two to a line under it. |
| S-481 | The WebDAV sync restart tests bound one fixed port and failed together in a whole Windows suite | Fixed 2026-11-13 (the WebDAV and S3 patch): each restart test takes its own port from its name, the same across its PRE_ steps, between 40001 and 49000, below Windows' dynamic ports. |
| S-482 | A renamed pin lost its name through a sidebar file Stedding wrote (GitHub issue 114) | Fixed 2026-11-13, for the next release (import I3, I18): the name is now the item's `title`, as in Arc's file, beside `savedTitle`, in the sync file too. Older exports hold it as the page's title. |
| S-159 | Archive clock, scope and page | Closed 2026-11-13 (patch 0184; archive A1, A9, A17): the audit's list was found done or decided, Clear archive emptying the whole list by design. The rest of Arc's archive is built: a link closed in a little window is a row of its own. |
| S-471 | In macOS full screen the address row started 8 DIP left of the page under it | Fixed 2026-11-13, for the next release (patch 0120; toolbar T32): the overlay's painted bar (S-454's code) ran to the edge of `MultiContentsView` instead of the inset page card; it now starts at the card. |
| S-476 | Under a peek, an extension's button showed the pinned tab's state (GitHub issue 102) | Fixed 2026-11-13, for the next release, on the owner's word (patch 0176; peek P26): the button reads every per-page state through the page shown over the tab, and repaints when a peek opens or closes. |
| S-475 | No keyboard way to bookmark, and a welcome that needed the pointer (GitHub issue 112) | Built 2026-11-13, for the next release (patches 0057, 0087; commandbar K44, shortcuts Z25, welcome W21): Bookmark This Tab is in the bar and can take a chord in Settings; the welcome works from the keyboard. |
| S-473 | In a peek, an extension's popup-less click and its keys still named the pinned tab | Fixed 2026-11-13, for the next release (patch 0176; peek P26), left from S-469: `action.onClicked`, `commands.onCommand` and their activeTab grant now act on the peek's page. The button's state followed in S-476. |
| S-474 | On Windows a rename ended by a key sometimes left the keys on a sidebar row | Fixed 2026-11-13, for the next release (patch 0103; tabs R14): the element tracker could miss the page's view, so focus fell to a row. The view is now found whatever the tracker says. |
| S-472 | On Windows a passkey check pending at shutdown crashed the quitting browser | Fixed 2026-11-12, for the next release (patch 0180): Chromium's `CredentialPresenceCacher` held the profile raw and never registered as its observer, so a pending check read freed memory. It now registers; Chromium 158 has the same code. |
| S-469 | Password managers acted on the pinned tab, not its peek (GitHub issue 102) | Fixed 2026-11-12, for the next release, as the owner chose (patch 0176; peek P24–P26): to extensions an open peek is the window's active tab, which `scripting.executeScript` reaches, and reload keys reload it. Toolbar clicks: S-473. |
| S-470 | Copy Link on a split's empty "Choose a tab" pane copied an internal address | Fixed 2026-11-12 (patches 0057, 0123; copy-link L9): a page whose address the row does not show has no link, so Copy Link leaves the clipboard alone and shows no toast. |
| S-468 | The address row turned grey when a page dimmed itself under a dialog (GitHub issue 101) | Fixed 2026-11-11, released in 0.4.0 beta 18 (patch 0160; toolbar T62): as the owner chose, a read of the row's colour evenly darkened, the page's own colours unchanged, is not taken. |
| S-467 | The close toast's Undo read as a group, not a button, on the Mac | Fixed 2026-11-11, released in 0.4.0 beta 18 (patch 0124; tabs R25): the Mac maps the alert role Chromium gives the button to a group; it is now a button, and the toast's window stays the alert. |
| S-341 | Two first launches can delete a moved profile | Fixed in the series (`chrome/common/chrome_paths_mac.mm`) and checked on the Mac's release build with S-272, 2026-11-11: a lock on a file beside the target is held from the first look to the rename, and a profile that cannot be read is asked about. |
| S-340 | A pin's Leave-site question can wedge closing and quitting | Fixed in the series (pins H3, H4) and checked with real input on both release builds with S-272, 2026-11-11: while the question shows, no quit or close begins; Leave sends the pin home asleep, and nothing wedges after it. |
| S-272 | Spaces that share one session (GitHub issues 8 and 99) | Done 2026-11-11, for the next release (patches 0177–0179; ADR 0034; sessions S37–S52): Spaces can share a named session, wiped only when no Space names it. Edit Space and Settings choose it; export, import and sync carry it by id. |
| S-466 | `ScreenshotCaptureTest.AFailedCaptureSaysSo` timed out once in a Windows sweep | Not reproduced, 2026-11-11 (screenshot C10), alone or in parallel. If it fails again, look first at whether the capture after the tab's crash reads the surface the crash left. |
| S-461 | A dragged row's copy went while the button was held, on Windows | Fixed 2026-11-11 (pins H27), in the tests: two drag tests ask which window is under the pointer, and in the parallel leg another test's window could be there. Both now run in the serial leg (trap 88). |
| S-92 | Child tabs, the rest | Closed 2026-11-10 (tabs R57, R60; patch 0173): built 2026-11-07 and seen on both platforms. The last fault, a pinned parent's children with favicons cut on the left, was the row's clip left at the old indent; it now follows the indent. |
| S-157 | Little windows, the rest | Closed 2026-11-10 (little E13, shortcuts Z24; patch 0170): built 2026-11-07 and checked with the real keyboard on both platforms. ⌘D in a private window did nothing, its menu row being enabled only with Spaces; it now bookmarks the page. |
| S-93 | Peek, the leftovers | Closed 2026-11-10 (peek P22, P23), seen on both platforms: a pin's link redirected to another site opens a peek at the destination, ⇧⌘2 captures the peek's page, and Escape closes the peek. |
| S-463 | A Space switch's slide failed alone on the PC | Fixed 2026-11-10 (patch 0158; spaces B32), in the test: it took only a layer with the list's exact bounds, and a Space with fewer rows makes a shorter list on the PC. It now matches the list's place and width. |
| S-462 | The bookmarks bar kept the window's colour under a row in the page's (GitHub issue 98) | Fixed 2026-11-10, released in 0.4.0 beta 17 (patch 0120; toolbar T61): the bar takes the row's surface, text and icons, and with the row hidden is itself the strip in the page's colour. |
| S-456 | Two Windows browser tests failed on the PC, with or without the change in hand | Fixed 2026-11-09, for the next release (little E12, archive A1): a restored little window grew by its frame each launch; its session now keeps the window's bounds. The other failure was the tests' own timing. |
| S-457 | The History page and menu offered Google sync and a sign-in for other devices' tabs | Fixed 2026-11-09, for the next release (privacy Q16, Q18): without browser sign-in, the side bar's item is hidden, `chrome://history/syncedTabs` opens history, and the menu has no part for other devices. |
| S-459 | `TabDropTest.RailDropsJoinTheFolderAndMoveToTheChip` failed on the PC's DCHECK and ASan builds at 150% | Fixed 2026-11-10, for the next release (spaces B12), in the test: it aimed at rows while a Space switch still slid the list in. The steps after a switch now wait for it to come to rest. |
| S-460 | On the Mac's DCHECK build a page's full screen stopped at a check | Fixed 2026-11-10, for the next release (sidebar Y17): since S-454 the title bar's controller can come back to a window already holding our delegate. The check now allows our own delegate; release builds skip it. |
| S-452 | The first computer got copies of every pin and essential when the second was used (GitHub issue 89) | Fixed 2026-11-09, for the next release (sidebar-file Sf2): a restored tab's sync id was missing from the new session log, so it took a new id. The id is now rewritten. |
| S-454 | In macOS full screen the traffic lights had a strip of their own above the row | Fixed 2026-11-09, for the next release, as the owner chose (sidebar Y17): with the row always shown, the overlay is the title bar's row; a hidden row keeps the old placement. |
| S-453 | On the Mac the traffic lights drew over the page with sidebar and row hidden (GitHub issue 93) | Fixed 2026-11-09, for the next release, as the owner chose (sidebar Y55): out of full screen, over the page alone, the lights hide until the pointer rests at the window's top. |
| S-449 | Sync between two computers showed every pin twice (GitHub issue 89) | Fixed 2026-11-08, for the next release (sidebar-file Sf10, Sf23): at a join a Space never named pairs by its shown name, so fresh installs combine their first Spaces. Earlier copies stay until the extra Space is deleted by hand. |
| S-451 | The peek's card had no motion (GitHub issue 91) | Done 2026-11-08, for the next release (motion O10, peek P20): the card fades in over 160 ms, under "Animate the sidebar and overlays" and Reduce Motion, with no setting of its own (the owner's choice). |
| S-446 | A pin closed came back after the next close (GitHub issue 85) | Fixed 2026-11-07, for the next release (tabs R33): a row the user puts away, a pin closed or a tab put to sleep, leaves the Space's history, so a later close shows the row used before it. |
| S-447 | Copy Link over a peek copied the pinned tab (GitHub issue 86) | Fixed 2026-11-07, for the next release (copy-link L8, peek P20): the window's Copy Link takes the peek's page while it is open, and the peek's bar has a Copy Link button. |
| S-448 | ⌘Q could quit at once only from a menu people did not find (GitHub issue 88) | Done 2026-11-07, for the next release (settings T60): "Hold ⌘Q to quit" in Settings, the same switch as the Stedding menu's Warn Before Quitting. |
| S-127 | The command bar's two partial rows | Done 2026-11-07 (commandbar K12, tabs R22): the bar's Move Tab row takes the selection, as its other rows do. A click on the address keeps editing in place, which K12 records as the decision unless the owner wants Arc's way. |
| S-251 | Tabs given on the command line sometimes never load | Fixed in patches 0077 (http) and 0148 (https) (tabs R46): certificate-verifier updates at launch dropped every idle socket, and the reconnecting tabs overflowed a short accept queue. The same certificates no longer reach the verifier again, and a network time within 45 seconds of the clock no longer reaches the client. |
| S-443 | `accounts.google.com/ListAccounts` seen once in a browser test | A fault of the test, not the browser (privacy Q12): the test suite pretends an OAuth client exists, so sign-in was allowed in `DrmNoticeTest`. The test now runs with sign-in off, as a Stedding build does. |
| S-435 | A quit during a pin's Leave-site question was lost on the Mac | Not a fault of Stedding, 2026-11-06 (pins H3): on the Mac no quit begins while a dialog is up, as in any Mac app, and H3 says so. A quit that does begin takes a window close's path. |
| S-438 | Smaller things seen on the real builds of 0.4.0 beta 11 | Settled (tabs R14, peek P20): Enter and Escape in a rename fixed in patch 0161; the quit during Delete Space is S-435; the teardown watchdog fired only under a build's load; the peek prompt's shadow is the system's. |
| S-434 | An address typed on a Space's own page got no row | Fixed in patch 0156 (tabs R66): the page had no row until the Space was left and shown again. |
| S-437 | The DRM notice was cut short in a narrow window and held back by another bar | Fixed in patch 0162, closed 2026-11-06 (drm-notice Dn1): a shorter sentence, "Stedding can't play this site's DRM video yet.", and the notice takes priority with room for two bars. |
| S-423 | The lit circle behind the shield and the moon was too big and too bright | Fixed in patches 0132 and 0160, closed 2026-11-06 (toolbar): the circle is 21 DIP in the 32 DIP row, the size of the chips beside it, where it was 26, with a dimmer fill. |
| S-440 | Raising a Space's name during a layout stopped the browser | Fixed in patch 0158, closed 2026-11-06 (spaces): a hover synthesized inside a closing tab's layout reordered the sidebar's children mid-walk, a CHECK in every build; the name is now raised a turn later. |
| S-424 | A selected folder touched the selected tab under it | Built 2026-11-05 in patch 0133 (folders): a folder's rows stand 2 DIP apart, as the list's do. |
| S-425 | A folder's − button (GitHub issue 78) | Built 2026-11-05 in patch 0134 (folders F43–F46), at the owner's yes: a − on a folder of pins, shown while the pointer is on its header, sleeps the open pins and collapses the folder. |
| S-429 | A crash when a tab with a dialog came to the front (GitHub issue 82) | Fixed in patch 0141 (tabs R67): a widget's show, the tab dialog manager and the peek stop when the widget is destroyed during the show. What closed the dialog, likely the peek, is not known. |
| S-430 | Space ended a rename of a pin that was not on screen (GitHub issue 81) | Fixed in patch 0142 (tabs R14): the Space key's release bubbled from the field to the row, which opened, and toggled a folder header the same way. |
| S-326 | A little window came back as a plain popup | Closed on 0.4.0 beta 11 (little E1, E8): after a restart a little window comes back as one, with its row, Copy Link and Open in Stedding. |
| S-336 | A double-click whose first press landed off the sidebar's edge might reset the width | Done 2026-11-05 in patch 0130 (sidebar Y22): both presses must land on the edge. No reset was ever reported. |
| S-162 | The routes editor | Done 2026-11-05 in patch 0129 (routing D5): a deleted Space's rules and its links default go with it, and a rule naming no Space hides no later one. The second pass is S-126. |
| S-376 | Permission prompts in a peek over the page | Built in patch 0151 (peek P20): the peek has a tab's permission request manager, and the prompt hangs from the card's bar. A `<permission>` element in a peek still gets no prompt. |
| S-402 | A site's device picker never opened (GitHub issue 73) | Done 2026-11-04 (spaces B47): only in a Space with its own session, since Chromium refuses the device and file pickers outside the profile's default storage partition; a Space's jar now counts as the profile's for those checks. Confirmed by the reporter. |
| S-420 | A stalled update download ended in an error with no way to try again | Fixed for the release after 0.4.0 beta 10 (updates Up5, Up25): a failed or stalled download starts over by itself, three tries in all, and the failure line says how to try again. |
| S-416 | On Windows a second window's corner buttons never showed (GitHub issue 45, a comment on beta 8) | Done 2026-11-04 (sidebar Y54): the corner read the pointer's screen coordinates as the window's, so a window away from the screen's top-left missed its corner; the pointer is now converted from the screen. |
| S-417 | Links from other apps as a peek (GitHub issue 74) | Done 2026-11-04 (little E11, settings T54), the owner's choice: "Open links from other apps as a peek", off by default, opens such a link as a peek over the active tab and brings the window to the front. |
| S-418 | Which pins a collapsed folder keeps out (GitHub issue 78) | Done 2026-11-04 (folders F3, settings T55), the owner's choice: a collapse puts the folder away, as in Arc, but the pins selected in it stay out; a setting, off by default, keeps every awake pin out. |
| S-414 | Back, Forward and Reload in the site panel when the sidebar's top line drops them (GitHub issue 45, a comment on beta 8) | Done 2026-11-04 (sidebar Y51, site-controls Si15): the site panel's strip starts with the three while the window shows no Back of its own. |
| S-415 | Sidebar icons a pixel off their hover circles on Windows (GitHub issue 45, a comment on beta 8) | Done 2026-11-04 (sidebar Y51): each top-line button centres its icon instead of placing it at its border's inset. 18 DIP icons still land half a pixel off at 125% and 175%. |
| S-419 | A new window on Windows opened too close to the one it came from | Done 2026-11-04 (windows G11): a new window steps 22 DIP clear of the first on both platforms, where Chromium stepped 10 on Windows. |
| S-408 | An empty Space showed a New Tab row, and an extension's tab group a chip on the New Tab page | Shipped in 0.4.0 beta 9 (patches 0124, 0125; tabs R66, new-tab N9): an empty Space shows its own page, and "Show tab groups" on the bookmarks bar starts off. |
| S-409 | A pinned folder could not be collapsed (GitHub issue 76) | Shipped in 0.4.0 beta 9 (patches 0124, 0125; folders F3): a collapse folds every row but the one on screen; a pin left while the folder is collapsed stays listed while awake. |
| S-410 | The peek settings seemed not to apply (GitHub issue 74) | Shipped in 0.4.0 beta 9 (patches 0124, 0125; settings T3, T46): the window was a little window, for a link from another app, which the peek settings never change; the settings' lines now say so. |
| S-411 | Open Link in Space (GitHub issue 75) | Shipped in 0.4.0 beta 9 (patches 0124, 0125; menus M14, spaces B46): a link's page menu lists the window's other Spaces, and a row opens the link in that Space's jar and goes there. |
| S-412 | Pinned extensions never showed in the sidebar's address field (GitHub issue 45, a comment on beta 8) | Shipped in 0.4.0 beta 9 (patches 0124, 0125; sidebar Y49, Y51): the field offers the extensions' row its whole room less the site name's minimum. The comment's other points are S-414 and S-415. |
| S-413 | Chromium's Install chip in the toolbar's address field | Shipped in 0.4.0 beta 9 (patches 0124, 0125; site-controls Si14): neither address field shows it; Install as an app is in the site panel (S-403). |
| S-407 | The little window is too small | Closed 2026-11-04, 0.4.0 beta 8 (patch 0122; little E1): four fifths of the window it opens over, centred, and a resize is kept. |
| S-406 | An important update is shown as one | Closed 2026-11-04, 0.4.0 beta 8 (patch 0121; updates Up23, Up24): shown strongly and never forced, the bar retrying when its window comes to the front. No release had been marked important. |
| S-405 | Main and side releases | Closed 2026-11-04, 0.4.0 beta 8 (ADR 0031; `tooling/publish-side`). No side release had been published then. |
| S-403 | Issue 45 after beta 7: the sidebar's top line | Closed 2026-11-04, 0.4.0 beta 8 (patch 0119; sidebar Y48–Y54, site-controls Si14): on Windows the window's buttons sit at the corner, shown on hover; on the Mac the traffic lights always show. |
| S-401 | Launching with `--incognito` crashes at startup | Closed 2026-11-04, 0.4.0 beta 8 (patch 0119; windows G10): the launch opens a private window. |
| S-400 | The download's animation is easy to miss | Closed 2026-11-04, 0.4.0 beta 8 (patch 0123; sidebar-panels Pn18): a 48 DIP chip flies to the sidebar's downloads button, which rings. Chosen by the maintainers, as the owner asked. |
| S-398 | Tidy names for pinned tabs and downloads, as local rules | Closed 2026-11-04, 0.4.0 beta 8 (patch 0121; tabs R65, sidebar-panels Pn17, settings T52, T53): a pin titled "Inbox (3) – you@example.com – Mail" reads "Inbox", and download names keep their meaning and pass Chromium's file-name checks. |
| S-396 | A Space with no row awake shows no page (GitHub issue 72) | Closed 2026-11-04, 0.4.0 beta 8 (patch 0123; tabs R66): a stand-in the sidebar does not list shows `chrome://stedding-space`, version A of the owner's mockups. |
| S-392 | The top row beside the camera housing | Closed 2026-11-04, 0.4.0 beta 8 (patch 0120; toolbar T55–T59, settings T51), off by default: the row sits beside the camera, a video's full screen is macOS's, and Esc brings the row back covering the screen. |
| S-397 | A tab opened in the background is the next one ⌃⇥ reaches (GitHub issue 71) | Closed 2026-11-03, 0.4.0 beta 7 (patch 0119; switcher X6, settings T50), on by default. |
| S-390 | The sidebar's width across a real update (GitHub issue 65) | Closed 2026-11-03, 0.4.0 beta 7: an installed beta 6 on Windows with a 300 DIP sidebar updated itself to beta 7 and kept the width. |
| S-377 | An edge round the peek over the page | Closed 2026-11-02, after 0.4.0 beta 6, for the next release (peek P21, settings T47). The owner chose the frosted rim from four rendered styles; a soft glow or none is a setting. |
| S-378 | The address in the sidebar in macOS full screen | Closed 2026-11-02, after 0.4.0 beta 6, for the next release (toolbar T8, T10, T32): in macOS full screen a row hidden with the sidebar does not slide in, ⇧⌘D works, and no empty band or grey strip is left. |
| S-379 | "Address field" defaults to wide and centred | Closed 2026-11-02, after 0.4.0 beta 6, for the next release (toolbar T48, PLAN.md decision 19). |
| S-380 | Chips in the address row sit off centre | Closed 2026-11-02, after 0.4.0 beta 6, for the next release (toolbar T52). |
| S-381 | Pinned tabs whose title starts with "/" | Closed 2026-11-02, after 0.4.0 beta 6, for the next release (pins H28): the slash follows the drift setting, off by default. |
| S-382 | "Mark pinned tabs that left their page" | Closed 2026-11-02, after 0.4.0 beta 6, for the next release (pins H12, settings): "Show when a pinned tab leaves its page", with a line saying what it marks. |
| S-383 | The Undo after closing tabs | Closed 2026-11-02, after 0.4.0 beta 6, for the next release (toolbar T53). |
| S-384 | Spaces in settings | Closed 2026-11-02, after 0.4.0 beta 6, for the next release (settings T48). |
| S-385 | A full collapse slides the sidebar out | Closed 2026-11-02, after 0.4.0 beta 6, for the next release (sidebar Y50). |
| S-386 | The wheel in a sidebar shown at the edge | Closed 2026-11-02, not reproduced: the list scrolls by wheel and trackpad in a sidebar shown at the edge and in a hover-expanded rail, on both platforms. A layout that put the toggle on the traffic lights' row was fixed (sidebar Y52). |
| S-387 | Privacy choices in the welcome flow | Closed 2026-11-02, after 0.4.0 beta 6, for the next release (welcome W19, PLAN.md decision 20): link cleaning is off by default. |
| S-388 | "Ad topics, site-suggested ads and ad measurement" | Closed 2026-11-02, after 0.4.0 beta 6, for the next release (settings T49). |
| S-389 | Folder icons and even gaps (GitHub issue 68) | Closed 2026-11-02, after 0.4.0 beta 6, for the next release (folders F41, F42). The icon in the sidebar file and sync is S-393. |
| S-391 | The address in the sidebar, version B (GitHub issue 45) | Closed 2026-11-02, after 0.4.0 beta 6, for the next release (sidebar Y51, Y53, site-controls Si13): the reporter's version B, the traffic lights on hover on the Mac included. |
| S-360 | Peek attached to its tab, as Arc's (GitHub issue 62) | Closed 2026-11-02, 0.4.0 beta 6 (patch 0119; peek P20, settings T46): "Over the page", the default, shows a peek on a card over the pinned tab's page; "In a small window" keeps the little window. Prompts in it are S-376. |
| S-359 | Three sidebar ideas from GitHub issue 45 | Closed 2026-11-01, 0.4.0 beta 5 (patches 0116 to 0118), at the owner's word: Show a hidden sidebar, Sidebar animation and hover delays (settings T11, T37, T38); the address in the sidebar and Essentials per row (sidebar Y33, Y46); an Appearance card (settings T41–T43). |
| S-327 | Copy Link's check mark lasts about a tenth of a second | Closed 2026-11-01, not a fault (copy-link L7; `docs/HANDOFF.md` trap 142): the check mark lasts 1.5 seconds; the stills that showed less were taken later than their steps' waits said. |
| S-370 | In a narrow Windows window a split's address field ran across both panes | Closed 2026-11-01, kept (the owner: "keep what is looking better"; toolbar T49): about 1040 pixels wide the field spans both panes, since buttons following the focus jumped; from about 1300 it sits over the active pane. |
| S-361 | Favicons in the command bar's rows (GitHub issue 58) | Closed 2026-11-01, 0.4.0 beta 5 (patch 0115; commandbar K38): each tabs-mode row starts with its site's icon, a search with the magnifier, and the row's other text, "Switch to Tab" among it, sits at its right end. |
| S-357 | In a centred address field the buttons at its end did not respond on Windows (GitHub issue 14) | Closed 2026-10-31, 0.4.0 beta 3 (patch 0113): the right spacer stayed over the field's moved end and took the press. |
| S-364 | In a side-by-side split the address field spanned both panes (GitHub issue 14) | Closed 2026-10-31, 0.4.0 beta 3 (patch 0113): the field sits over the active pane. A window about 1040 pixels wide is S-370. |
| S-334 | `AddressBandTest.TheAddressKeepsItsPlaceWhenEdited` and three more timed out on Windows beside other tests | Closed 2026-10-31: the four run in the Windows serial leg (`tooling/dev`), which ran clean. |
| S-365 | `CertificateReportsTest.NoCertificateIsReported` failed once in the Mac sweep | Closed 2026-10-31, the test's own race (patch 0074): a late `/favicon.ico` request's report took the next site's place in the cache; the test now waits for it before switching reporting on. No report went out before the switch. |
| S-366 | `MotionFramesTest.HiddenOmniboxPopupsFollowTheSidebarOnceAMotion` is flaky on the Mac | Closed 2026-10-31, the test's own count (patch 0077): the extra move was the hidden popup's height alone, the page's late answer; the counter now counts places, not heights. |
| S-367 | `WelcomeFirstRunTest.TheFlowOpensOnceAndNotAfterFinish` failed once on Windows | Closed 2026-10-31, the test's own choice of window (patch 0104): after the restart `browser()` could be the PRE step's popup, which has no Spaces; the test reads the first tabbed window. |
| S-369 | Windows browser tests that fail four at a time and pass alone | Closed 2026-10-31 (`tooling/dev`): six such tests, of drags, bubbles and keys, moved to the Windows serial leg, which runs two at a time. |
| S-355 | ⇧⌘T does not reopen a closed little window | Closed 2026-10-30, declined (the owner): a little window is meant to be thrown away, and Chromium records no closed popup for ⇧⌘T (S-354). |
| S-362 | Manifest V2 extensions (GitHub issue 59) | Closed 2026-10-30, declined for now (the owner): Chromium 157 still has the code, but turning it back on would be a patch every Chromium update could break, kept for one kind of extension. `docs/FAQ.md` points to uBlock Origin Lite and the built-in blocker. |
| S-363 | Duplicate in the short tab menu (GitHub issue 63) | Closed 2026-10-30, after 0.4.0 beta 2 (patch 0110; tabs R64, menus M1): Duplicate sits above Copy Link on every row; a copy of an essential or a Space pin is a plain tab where new tabs open (the owner's choice). |
| S-356 | A slept pin stayed listed in a collapsed folder (GitHub issue 35) | Closed 2026-10-29, after 0.4.0 beta 2 (patch 0112; folders F3): the rows redraw when a tab in a collapsed folder changes as a whole, as on a sleep, so the slept pin folds away. |
| S-352 | An extension's keyword in the command bar is not handed to the extension | Closed 2026-10-29 (patch 0109; commandbar K18): the bar's typed row hands "keyword query" to the extension through `chrome.omnibox.onInputEntered`, from a handler in a target with no dependencies. |
| S-354 | A little window brought back with ⇧⌘T comes back as a plain popup | Not reproduced 2026-10-29: nothing came back, since a popup leaves no entry for ⇧⌘T at all. Whether it should is S-355, for the owner. |
| S-309 | Docs brought up to date and trimmed | Done 2026-10-28: every document checked against the patches and rewritten, the records cut (`docs/PROJECT-LOG.md`, 2026-10-28). |
| S-304 | A pinned tab in a folder stays listed while it is open (issue 35) | Built 2026-10-28 on the owner's word: a collapsed folder keeps a pin that is awake listed (folders F3, patch 0112). |
| S-332 | A pinned tab's x removes it, after asking (issue 50) | Released 2026-10-28 in 0.3.0 beta 22: an x that asks before removing a pin off screen, a minus that sleeps the one on screen. Patch 0110 (pins H29) then put a minus on every awake pin, an x once asleep. |
| S-316 | Sidebar row text shifted when a page's colour arrived | Fixed in patch 0105 (`SteddingColorMixerTest.APagesColourLeavesTheRowsTextAlone`); closed 2026-10-28. |
| S-313 | Settings › Stedding reorganised | Built in patch 0109: a card for each group, with jump buttons (settings T13); closed 2026-10-28. |
| S-312 | Sync through a folder says what to pick (issue 38's follow-up) | Built in patch 0106 (sidebar-file Sf42), released in 0.3.0 beta 18. |
| S-311 | The command bar's rows show the pointer | Built in patch 0105 (commandbar K37); closed 2026-10-28. |
| S-310 | A neutral palette, no amber | Built in patch 0105: the Space colour on the sidebar's ground, a slate scale for the light ground and the welcome page; closed 2026-10-28. |
| S-308 | Peek, explained | Built in patch 0106: the first-peek note and the welcome line (peek P19), released in 0.3.0 beta 18. |
| S-307 | A read-only review of all code and tests (2026-10-26) | Done 2026-10-26; its open findings are S-314 and S-315, the rest landed in patches 0105, 0106, 0108 and 0109. |
| S-256 | The pin moves to Chrome 156's stable release | Done 2026-10-21 (156.0.8078.48, first shipped in 0.3.0 beta 1); the pin has since moved to 157.0.8103.31 (S-278). |
| S-106 | An ASan run of patches 0058 to 0063 | Covered by the later `win-asan` run on patch 0071: no AddressSanitizer report, DCHECK or dangling pointer; closed 2026-10-28. |
| S-99 | Space colours and icons, freely chosen | Built: spaces B41 to B44 (any emoji, one colour or a light and dark pair); closed 2026-10-28. |
| S-89 | Clean links on every page opened | Built in patch 0089 (clean-links Cl1 to Cl14), released in 0.3.0 beta 16. |
| S-321 | Numbered Space keys on ⌘ (issue 13) | Released 2026-10-28 in 0.3.0 beta 22 (shortcuts Z23, patch 0100). |
| S-325 | Copy Link in the little window (issue 48) | Released 2026-10-28 in 0.3.0 beta 22 (copy-link L7, little E8, patch 0083). |
| S-324 | ⌘T on a folder’s last tab joined the folder | Fixed 2026-10-27 in patch 0057 (folders F25): that ⌘T stays out of the folder. |
| S-322 | Crash after ⌘Y, then ⌘S (issue 44) | Fixed 2026-10-27 (sidebar-panels Pn4): ⌘S waits until the panel has gone. |
| S-319 | Two Peek findings from the fifth review | Closed 2026-10-26: a key ends a held press (peek P18, patch 0102); Open as Tab follows P7. |
| S-305 | Hide a drifted pin’s dot and reset (issue 36) | Built 2026-10-26, off by default (pins H28, settings T36). The menu’s Reset stays. |
| S-317 | Which row a pin’s ⌘W and Sleep Tab show | Decided 2026-10-26: both show the row a close would (pins H3, tabs R5). |
| S-301 | A close skipped the essential (issue 30) | Changed 2026-10-24 (tabs R33): the essential used last can come back. |
| S-298 | A link from an essential shoved the pins (issue 29) | Fixed 2026-10-24 in patch 0070 (pins H14): the new tab passes a pinned folder. |
| S-299 | No drop on the first row under Clear (issue 26) | Fixed 2026-10-24 in patch 0083 (tabs R63): that drop stays under the line. |
| S-300 | No drop between a folder’s rows (issue 27) | Fixed 2026-10-24 in patch 0083 (folders F40): the pointer’s place is kept. |
| S-81 | Import from Arc on Windows | Shipped in 0.3.0 beta 13 (import I27); seen on Arc for Windows, 2026-10-24. |
| S-296 | Google Pay used the shared session (issue 25) | Fixed 2026-10-24 in patch 0067 (sessions S36): an own session is offered no payment app. |
| S-289 | Animated drag into the essentials (issue 16) | Built 2026-10-24 in patch 0086 (pins H27): the drag becomes a card, then a row. |
| S-292 | The restore bar’s close did nothing (issue 24) | Fixed 2026-10-24 (sidebar Y29): an infobar there takes its own press. |
| S-293 | The address field changed width (issue 14) | Fixed 2026-10-24 (toolbar T34): hovered, focused and edited, the field is the whole row. |
| S-294 | The site chip looked hovered at rest | Fixed 2026-10-24 (toolbar T44): an icon-only chip has no capsule until hover. |
| S-295 | The “Not Secure” icon sat low | Fixed 2026-10-24 (toolbar T44): a short chip lays its icon and text out in its own height. |
| S-290 | A tab drag moved the address row with it | Fixed 2026-10-24 (tabs R61): during the drag the row stays on the page on screen. |
| S-287 | The top essentials row moved the window (issue 23) | Fixed 2026-10-23 in patch 0077 (sidebar Y29). Released in 0.3.0 beta 11. |
| S-275 | The address jumped left on focus (issue 14) | Fixed 2026-10-23 in patch 0078 (toolbar T18). Released in 0.3.0 beta 11. |
| S-285 | A press to drag opened the tab first | Fixed 2026-10-23 (tabs R61, splits J10): the press waits; the page stays. Released in 0.3.0 beta 11. |
| S-288 | New tabs at the top of the list (issue 22) | Built 2026-10-23 in patch 0087, off by default (tabs R62, settings T30). Released in 0.3.0 beta 11. |
| S-281 | A pinned-run drag test tore the tab off | Fixed 2026-10-23 in the tests (patch 0077): the window stays above others. No product change. |
| S-280 | A chip test timed out under AddressSanitizer | Fixed 2026-10-23 in the test (patch 0079). Passed in 0.3.0 beta 10’s Windows ASan run. |
| S-277 | Drag a tab into the essentials and out (issue 16) | Built 2026-10-22 in patch 0086 (pins H27). |
| S-276 | Essentials shrink as more are added (issue 15) | Built 2026-10-22 in patch 0085 (sidebar Y33): up to four, then two rows. |
| S-274 | Every new Space can have its own session (issue 8) | Built 2026-10-22 in patch 0084, off by default (sessions S35, settings T29). |
| S-273 | Copy Link kept its hover after a click (issue 11) | Fixed 2026-10-22 in patch 0083 (copy-link L7): the press ends when the copy runs. |
| S-271 | A drop among pins unpinned the last pin | Fixed 2026-10-22 in patch 0083 (pins H14): a row takes the pin of the side it is dropped on. |
| S-269 | A tab group crashed with animations off | Fixed 2026-10-22 in patch 0071 (spaces B33): the callback exists before layout. |
| S-268 | A hover state on the New Tab row (issue 12) | Built 2026-10-22 in patch 0083 (sidebar Y32). |
| S-259 | A Copy Link button in the address field (issue 11) | Built 2026-10-22 in patch 0083 (copy-link L7, settings T28). On by default. |
| S-260 | A held drag onto a Space chip switches | Built 2026-10-22 in patch 0083 (spaces B12): half a second on the chip switches. |
| S-261 | A folder dragged into another folder | Built 2026-10-22 in patch 0083 (folders F38, F39). |
| S-262 | The tab list ended against the sidebar’s edge | Built 2026-10-22 in patch 0083 (sidebar Y30): a long list scrolls half the list’s height past the end. |
| S-263 | A pin sent home kept the last page’s title | Fixed 2026-10-22 in patch 0083 (pins H1, H3): the row shows the home at once. |
| S-264 | A link’s tab sat a level to the right | Changed 2026-10-22 in patch 0083 (settings T26, tabs R57): nesting is off by default. |
| S-265 | Every folder looked grey | Fixed 2026-10-22 in patch 0083 (tabs R7, folders F12): a header is never drawn asleep. |
| S-266 | A link from a nested pinned folder unpinned it | Fixed 2026-10-22 in patch 0083 (folders F38): the new tab leaves for under the line. |
| S-267 | Memory, CPU and network in the hover card | Built 2026-10-22 in patch 0083 (pins H25): the line appears after 2 seconds. |
| S-230 | The command bar listed an open tab as archived | Done 2026-10-20 in patch 0072 (archive A13). Passed on Windows with 0.3.0 beta 2. |
| S-220 | A test left a profile in the real data folder | Fixed 2026-10-19 in patch 0072: tests use a temporary data folder, and tooling/dev warns. |
| S-254 | Essentials per Space (issue 8) | Built 2026-10-22 in patch 0083 (ADR 0028, spaces B6): an own session has its own essentials. |
| S-252 | A drag test read the machine’s real pointer | Closed 2026-10-22 in patch 0077: the test window stays clear of that pointer. |
| S-253 | Turning vertical tabs on as a drag ended crashed | Fixed 2026-10-21 in patch 0077. Passed in 0.3.0 beta 2’s Mac and Windows sweeps. |
| S-104 | Hidden address-row controls in the command bar | Built 2026-10-20 in patch 0075 (toolbar T39, T40, commandbar K31–K33). |
| S-110 | At launch, only the selected tab loads | Built 2026-10-20 in patch 0075 (tabs R45–R48, settings T22). |
| S-111 | Tabs sleep on a timer and under memory pressure | Built 2026-10-20 in patch 0075 (tabs R39–R44, settings T21). |
| S-112 | Which tab is selected after a close | Settled 2026-10-22 (tabs R33): the row used last, while it is in view. |
| S-113 | Make a split by dropping a tab on the page | Built 2026-10-20 (splits J10–J15, issue 7). |
| S-115 | A picture of the page in the hover card | Built 2026-10-20 in patch 0075 (pins H19–H23): in memory only. |
| S-214 | A label painted on a layer that was not opaque | Fixed 2026-10-18 (folders F36, spaces B17). Checked on 0.2.0 beta 20, 2026-10-20. |
| S-144 | Badges hide, and one list for ⌘1–9 | Fixed 2026-10-18 (tabs R10, R11); chord chips widened 2026-10-20 (patch 0072). |
| S-143 | A slept row lost its dim, and hover rebuilt it | Fixed 2026-10-18 (tabs R4, R7). A false hover was fixed 2026-10-20 (patch 0072). |
| S-222 | Deleting a Space another window showed stopped the browser | Fixed 2026-10-18 (spaces B5). Checked on 0.2.0 beta 20, 2026-10-20. |
| S-139 | Move to Space on a tab inside a folder | Fixed 2026-10-18 (folders F37): the tab leaves every folder. Checked 2026-10-20. |
| S-223 | A one-pixel line under the address row in full screen | Fixed 2026-10-18 (toolbar T32). Gone on 0.2.0 beta 20, checked 2026-10-20. |
| S-224 | The Clear line sat under the traffic lights | Fixed 2026-10-18 (sidebar Y17). The sidebar keeps its top row. Checked 2026-10-20. |
| S-229 | A restored tab’s row lost its title | Fixed 2026-10-19 in patch 0072 (tabs R31). Held on 0.2.0 beta 20. |
| S-232 | A rail drop on a folder glyph landed after it | Fixed 2026-10-19 in patch 0072. The drop joins the folder on 0.2.0 beta 20. |
| S-149 | Rename in the title row and on the rail | Done 2026-10-18 (spaces B16): each rename edits where it was asked. |
| S-250 | Mac checks: a dangling tab pointer, two slow tests | Fixed 2026-10-20 in patch 0071: a closed tab is told of its detach once. |
| S-236 | Chrome’s launched defaults that Stedding lacked | Done 2026-10-20 in patch 0074. TcpPortRandomizationMac left off; its fix was not in that pin. |
| S-237 | Certificate Transparency enforcement | Done 2026-10-20 in patch 0074 (docs/PRIVACY.md): enforced, audit reports off. |
| S-240 | Read Chrome’s field trials at every pin move | Done 2026-10-19: tooling/field-trials, a standing step (docs/AGENT-LOOP.md). |
| S-71 | Uninstall left the PDF handler’s ProgId | Fixed 2026-10-19 in patch 0073 (windows N6): the uninstaller deletes that key. |
| S-249 | Windows updater leftovers from the beta 19 review | Fixed 2026-10-19 in patch 0073 (updates Up14–Up22). |
| S-212 | A tab pinned while selected restored unselected | Fixed 2026-10-18 (pins H18). Shipped in 0.2.0 beta 20. |
| S-213 | The welcome test hook missed the Windows checks build | Closed 2026-10-19: 0.2.0 beta 20’s checks build passed WelcomeFlowTest. |
| S-66 | Crashes, triaged from macOS crash reports | Closed 2026-10-19: 0.2.0 beta 20 carried the last fix the reports tied to (S-134). |
| S-134 | Skipping the engine step opened Chromium’s chooser | Fixed 2026-10-18 (welcome W2): skip records DuckDuckGo. 0.2.0 beta 18 Windows, beta 20 Mac. |
| S-79 | Arc, while it runs, takes ⌥⌘N | Fixed 2026-10-18 (shortcuts Z3): on the Mac the split is ⌃⌘N. Shipped in 0.2.0 beta 20. |
| S-55 | Network service restarted at startup | Closed 2026-10-18: the line came from an old Windows build configuration, not the series. |
| S-138 | The Clear line when nothing is pinned | Fixed 2026-10-18 (spaces B17): the line shows whenever rows follow it. Shipped in 0.2.0 beta 20. |
| S-219 | The sidebar slid out again after the toggle | Fixed 2026-10-18 (sidebar Y11). Shipped to the Mac in 0.2.0 beta 20. |
| S-221 | A right-hand sidebar test was flaky on Windows | Closed 2026-10-19 in patch 0072. Passed in 0.2.0 beta 20’s three Windows runs. |
| S-226 | A private window’s row never took the page colour | Fixed 2026-10-18 (toolbar T21): a transparent sample is no colour. Passed on 0.2.0 beta 20’s ASan run. |
| S-227 | The infobar container kept its height | Fixed 2026-10-19 in patch 0072. Passed in 0.2.0 beta 20’s Windows runs. |
| S-225 | A replaced split came back apart after Restore | Fixed 2026-10-18 (splits J1, sessions S12). Shipped in 0.2.0 beta 20. |
| S-248 | Later Windows acceptance parts started behind other apps | Tooling, 2026-10-19: the fixture brings the window forward before it waits. |
| S-215 | The Windows updater | Built 2026-10-19 in patch 0073 (updates Up14–Up22, ADR 0023). First in 0.2.0 beta 19. |
| S-72 | A second Windows release on one pin installed as a repair | Fixed 2026-10-19 in patch 0073 (updates Up22): each build carries Stedding’s own version. |
| S-245 | Turning dark pages on stopped a checks build | Fixed 2026-10-19 in patch 0072: a page with no edge read is left alone. |
| S-246 | The horizontal strip’s spinner was coloured against black | Fixed 2026-10-19 in patch 0072 (tabs R23): the strip’s ground is the frame. |
| S-244 | A toast covered an infobar’s text | Fixed 2026-10-19 in patch 0072 (toolbar T38): a window toast sits under the infobars. |
| S-242 | This round’s features failed ten Windows browser tests | Fixed 2026-10-19 in patch 0072: the failures were in the tests (HANDOFF traps 113–115). |
| S-228 | Escape cannot cancel Ctrl+Tab on Windows | Decided 2026-10-19 (switcher X3): no system-wide hook; Ctrl+Esc keeps the Start menu. |
| S-231 | A hidden address row left a one-pixel line on Windows | Fixed 2026-10-19 in patch 0072: the hidden row is laid out at no height. |
| S-233 | The Windows acceptance runner stalled at its pin step | Tooling, 2026-10-19: each DevTools call has a three-second limit. |
| S-243 | The essentials cards had a coloured edge | Fixed 2026-10-19 in patch 0072 (tabs R32): a card is a frosted tile with no edge. |
| S-154 | Full screen, two looks still missing | Fixed 2026-10-18 in patch 0071 (toolbar T32): a tab switch re-themes the row. |
| S-47 | An input-free settings probe | Tooling, 2026-10-18: tooling/capture-state opens chrome://settings/stedding with no pointer (settings T13). |
| S-218 | Ctrl+Alt+arrows from the address bar on Windows | Fixed 2026-10-18 in the driver (spaces B19, windows N7): the arrow is the extended key. |
| S-74 | Automatic updates, the Mac first | Built 2026-10-16 in patch 0068 (ADR 0022, updates.md). 0.2.0 beta 17 was the first offered. |
| S-217 | Take 156.0.8078.36 | Pinned 2026-10-16 (ADR 0007). Main moved to 157.0.8103.31 on 2026-10-28; that pin is not released. |
| S-211 | The default favicon was Chromium’s grey globe | Branding, 2026-10-15: Tabler’s world-www globe (branding/README.md). |
| S-179 | sessionStorage lost, and a crash restore dropped Spaces | Fixed 2026-10-15 in patch 0067 (sessions S28, S29). |
| S-180 | A Space’s workers acted in the wrong jar | Fixed 2026-10-15 in patch 0067 (sessions S30). |
| S-181 | A restored tab’s Space came back on a window move | Fixed 2026-10-15 in patch 0067 (spaces B2): the saved Space is read once. |
| S-182 | A Space-pinned split sat under the Clear line | Fixed 2026-10-15 in patch 0067 (pins H14). |
| S-183 | The Arc import’s edge cases | Fixed 2026-10-15 in patch 0067 (import I3, I22, I23): a repeated Space name is one Space. |
| S-184 | The welcome behaviour step redrew over a click | Fixed 2026-10-15 in patch 0067 (welcome W12): a late answer keeps the click. |
| S-185 | Sleep and the archive could drop unseen edits | Fixed 2026-10-15 in patch 0067 (tabs R6, archive A12, sessions S21). |
| S-186 | The welcome bookmarks-file row did nothing | Fixed 2026-10-15 in patch 0067 (welcome W3): the row opens the file chooser. |
| S-187 | The archive page and the welcome swatch read the wrong things | Fixed 2026-10-15 in patch 0067 (archive A9, welcome W7). |
| S-188 | WebUI handlers trusted the page’s message shape | Fixed 2026-10-15 in patch 0067: a message of the wrong shape is dropped. |
| S-189 | Two Ctrl+Alt chords did nothing on an AltGr layout | Fixed 2026-10-15 in patch 0067 (windows N13, N14). |
| S-210 | An unnamed tab group showed a blank bar | Fixed 2026-10-15 in patch 0066 (folders F36): the header shows the tab count. |
| S-201 | A typed address took another app’s open mark | Fixed 2026-10-15 in patch 0066 (routing D3): only the other app’s tab spends the mark. |
| S-202 | A Chrome shortcut file opened as a file URL | Fixed 2026-10-15 in patch 0066 (routing D3, little E1): the shortcut’s target is what opens. |
| S-203 | A host route missed IPv6 and the default port | Fixed 2026-10-15 in patch 0066 (routing D1). |
| S-204 | The welcome flow dropped focus when a label changed | Fixed 2026-10-15 in patch 0066 (welcome W12): each control keeps a stable key. |
| S-205 | Clear was out of reach of Tab and VoiceOver | Fixed 2026-10-15 in patch 0066 (spaces B17): Clear is a button while its label shows. |
| S-206 | A deleted Space’s jar could stay after a quit | Fixed 2026-10-15 in patch 0066 (sessions S17): the next window finishes the wipe. |
| S-207 | Undo of a folder’s last tab could enter a group | Fixed 2026-10-15 in patch 0066 (tabs R27): a tab from no group comes back in none. |
| S-208 | A failed profile move reused Chromium’s keychain key | Fixed 2026-10-15 in patch 0066 (windows N8): the empty profile makes its own key. |
| S-209 | Tests that passed without what they check | Fixed 2026-10-15 in patch 0066: each step fails on its own. |
| S-190 | Closing one pane of a split crashed | Fixed 2026-10-15 in patch 0065 (splits J9): the row’s layer is made once it has a parent. |
| S-191 | Grouping a tab inside a folder crashed | Fixed 2026-10-15 in patch 0065 (folders F35): the group goes after the outermost folder. |
| S-192 | The Arc import crashed on a blocked login | Fixed 2026-10-15 in patch 0065 (import I22, I23): a blocked row is saved bare. |
| S-193 | Deleting a Space wiped its jar under open pages | Fixed 2026-10-15 in patch 0065 (sessions S17): the wipe waits for those pages. |
| S-194 | Autofill asked Google about every form | Fixed 2026-10-15 in patch 0065 (privacy Q14): server communication is off. |
| S-195 | The command bar opened scopes it refuses | Fixed 2026-10-15 in patch 0065 (commandbar K7, K17, K18). |
| S-196 | Shift ignored by History’s Restore Folder | Fixed 2026-10-15 in patch 0065 (folders F19): Shift restores into a new window. |
| S-197 | A split switched to stacked kept side-by-side corners | Fixed 2026-10-15 in patch 0065 (splits J7): the corners redraw with the layout. |
| S-198 | Export Space could write outside its folder | Fixed 2026-10-15 in patch 0065 (import I20): the file name is made safe. |
| S-199 | A slept tab lost its place in a folder close | Fixed 2026-10-15 in patch 0065 (folders F19): the place goes with the replaced contents. |
| S-200 | Tests read a freed command bar | Fixed 2026-10-15 in patch 0065: those tests run where the bar cannot close under them. |
| S-137 | A folder closed in part came back at its end | Fixed 2026-10-14 in patch 0063 (folders F19, F20): each row returns to its slot. |
| S-135 | A restored folder came back in reverse order | Fixed 2026-10-14 in patch 0063 (folders F19, spaces B12). |
| S-136 | Splitting two tabs in a folder took them out | Fixed 2026-10-14 in patch 0063 (folders F34, splits J8): the split keeps the folder. |
| S-69 | The restore bar and the gutter stayed in full screen | The gutter in patch 0059; the bar in patch 0063, 2026-10-14 (toolbar T33). |
| S-70 | A Space chip showed its name twice | Fixed 2026-10-14 in patch 0063 (sidebar Y14): the open chip has no tooltip. |
| S-54 | Google’s push service at startup | Fixed 2026-10-12 in patch 0030 (privacy Q11): no token unless a policy can arrive. |
| S-67 | Google’s account list at startup | Fixed 2026-10-12 in patch 0030 (privacy Q12): no ListAccounts while sign-in is off. |
| S-105 | The macOS image of betas 13 and 14 | 0.2.0 beta 14’s Mac image, 2026-10-12 (sidebar Y19, Y20). 0.2.0 beta 13 has none. |
| S-109 | Site Search: Tab makes a site’s name a chip | Built in patch 0061, 0.2.0 beta 14 (commandbar K27). |
| S-114 | Collapse Pinned Tabs | Built in patch 0061, 0.2.0 beta 14 (pins H17): per Space, kept across a restart. |
| S-116 | New Documents | Built in patch 0061, 0.2.0 beta 14 (commandbar K28): eleven services, a fixed list. |
| S-130 | Auto-archive is Never by default | Set in patch 0060, 0.2.0 beta 14 (archive A6, settings T8). |
| S-131 | A welcome step for how Stedding behaves | Built in patch 0060, 0.2.0 beta 14 (welcome W12). |
| S-132 | The address hover cut the first letter | Fixed in patch 0060, 0.2.0 beta 14 (toolbar T34): the field stays whole when hovered, and the address paints no background of its own. |
| S-133 | Toasts covered the address row | Fixed in patch 0060, 0.2.0 beta 14 (toolbar T35): a toast sits under the row. |
| S-77 | Every search engine showed a globe in welcome | Fixed in patch 0060, 0.2.0 beta 14 (welcome W2): each prepopulated engine shows its own mark, and an engine without one shows its initial. |
| S-124 | The page flush against the window | Built in patch 0060, 0.2.0 beta 14, off by default (sidebar Y23, settings T15). |
| S-123 | The sidebar edge shows where to drag | Built in patch 0060, 0.2.0 beta 14 (sidebar Y22): a double click restores the width. |
| S-122 | Mute and picture in picture by key | Built in patch 0060, 0.2.0 beta 14 (tabs R29, commandbar K25, player Mp5). |
| S-120 | Folder verbs: expand, collapse, sort, new tab | Built in patch 0060, 0.2.0 beta 14 (folders F30–F33, menus M7). |
| S-121 | Edit a pin’s home; a middle click sends it home | Built in patch 0060, 0.2.0 beta 14 (pins H15, H16). |
| S-119 | Clear the site’s cookies and reload | Built in patch 0060, 0.2.0 beta 14 (commandbar K24, sessions S27). |
| S-108 | Inline completion in the command bar | Built in patch 0060, 0.2.0 beta 14 (commandbar K23): a history host completes the field. |
| S-97 | Undo after closing tabs | Built in patch 0060, 0.2.0 beta 14 (tabs R25–R28): a toast for 8 seconds. |
| S-84 | New pins landed on top and unpinned under the line | Fixed 2026-10-10 in patch 0059 (pins H14): a pin joins the end of the run. |
| S-85 | The sidebar resized only inside its edge | Fixed 2026-10-10 in patch 0059 (sidebar Y18): the handle reaches the card’s edge. |
| S-86 | A third sidebar form: hidden | Built 2026-10-11 in patch 0059 (sidebar Y19, Y20): hide completely, page to the edge. |
| S-87 | The toggle and the bar named Ctrl+Shift+L | Fixed 2026-10-10 in patch 0059 (windows N7): the chord is Ctrl+S. |
| S-73 | The default globe was nearly invisible in dark mode | Fixed 2026-10-11 in patch 0059 (sidebar Y21): a translucent row is read over the frame. |
| S-82 | The in-browser shortcut list was behind the product | Updated 2026-10-10 in patch 0059 (shortcuts Z1). Peek’s rows are listed (Z1, peek P7). |
| S-83 | The screenshot toast said “Show in Finder” on Windows | Fixed 2026-10-10 in patch 0059 (screenshot C5, windows N10): “Show in folder” off the Mac. |
| S-17 | Signing and notarisation on the Mac | 0.2.0 beta 10’s Mac image, 2026-10-01, was the first signed and notarized (HANDOFF trap 49). |
| S-80 | Incoming rows opened from collapsed during a switch | Fixed 2026-10-02 in patch 0058 (spaces B37): the switch snaps the rows into place. |
| S-78 | ⌘T from an empty New Tab page left that page | Fixed 2026-10-02 in patch 0058 (commandbar K21): an untouched New Tab takes what the bar opens. |
| S-76 | The welcome steps ran under the footer | Fixed 2026-10-02 in patch 0058 (welcome W11): a long step fades until it is scrolled to the end. |
| S-63 | The address row’s colour in full screen | Fixed in patch 0058 (toolbar T32, 2026-10-01): the row is the page’s colour, with one hairline. |
| S-68 | The command bar ran past a narrow window | Fixed 2026-09-30 in patch 0057 (commandbar K20): the bar stays inside the page card. |
| S-64 | Take 155.0.8059.12 | Pinned 2026-09-24 (ADR 0007), from 153.0.8010.53. |
| S-62 | Take 153.0.8010.53 | Pinned 2026-09-18, 49 patches (ADR 0007). Mac image v0.2.0-beta.8. |
| S-52 | Take 153.0.8010.48 | Pinned with 46 patches. Mac image v0.2.0-beta.7 (2026-09-16). |
| S-60 | Independent Space sessions | Built 2026-09-16 in patch 0046 (sessions S1–S12, ADR 0019). Own essentials are spaces B6. |
| S-45 | Google’s new tab page when Google is the engine | Fixed 2026-09-10 in patch 0044 (new-tab N1): every engine opens the local page. |
| S-53 | The rail’s tab pill | Second pass 2026-09-08 (patch 0039). The square now follows density (sidebar Y8). |
| S-46 | Round 7: the operator’s look at beta 3 | Closed 2026-09-05 in patches 0037 and 0038 (toolbar T15, sidebar Y6). Shipped in v0.2.0-beta.4. |
| S-42 | Space colour on the welcome flow | Built in patch 0018 (welcome W7): the swatches tint the first Space at once. |
| S-41 | Download progress on the sidebar button | Built (toolbar T14): the sidebar button shows the ring. The test is in patches 0071 and 0099. |
| S-44 | Round 6: Zen mods and beyond | Landed 2026-09-05 as patches 0016–0036. |
| S-43 | About page version label | Built in patch 0018 (settings T10): About names Stedding’s version and the Chromium pin. Verified 2026-09-05. |
| S-40 | Capture toast | Built in patch 0017 (screenshot C5), verified 2026-09-05. Off the Mac the button says “Show in folder” (S-83). |
| S-38 | Full-screen toolbar over the sidebar | Closed 2026-09-02 in patch 0002 (operator round 4): the toolbar is inset by the sidebar. |
| S-18 | Proprietary-codecs licensing decision | Decided 2026-08-31 (ADR 0008): ship H.264 and AAC. The licence is a 1.0 checklist item. |
| S-36 | Sidebar and Spaces settings rows | Built in patches 0010–0012 (settings T6–T9): hover, width, archive, and the Spaces list. |
| S-37 | Perf budgets on the first vanilla pair | Measured 2026-09-02, local list: cold +2.3%, warm −2.0%, memory +0.0% (docs/perf/README.md). No later measurement. |
| S-39 | Space tint on the sidebar, neutral new tab page | Built in patch 0007 (spaces B11): the active Space tints the sidebar ground only. |
| S-9 | Operator retest: full-screen URL width | Retested 2026-09-02. Since 0.2.0 beta 10 the field takes the row (toolbar T28–T30). |
| S-10 | Operator retest: pill site icon | Retested 2026-09-02: the pill’s site icon rendered clean at 2×. |
| S-31 | Vanilla official build, measured with the same harness | Compared 2026-09-02 (docs/perf/README.md, tooling/args/vanilla.gn). No later measurement. |
| S-35 | Promote a peek into a split | Built in patch 0009 (peek P9). On with Peek since 2026-10-25 (PLAN.md decision 2). |
| S-8 | Popup windows have no Spaces | Covered by PopupSpaceTest (spaces B14). |
| S-34 | Peek for a new tab from a pinned tab | Built in patch 0009 (peek P8). On with Peek since 2026-10-25 (PLAN.md decision 2). |
| S-15 | Settings surface | Built in patch 0010: chrome://settings/stedding (docs/features/settings.md). |
| S-33 | A setting to hide the new-tab shortcut row | Built (new-tab N5, settings T5): a switch hides the most-visited shortcut row. |
| S-14 | Peek | Built in patch 0009. Withdrawn 2026-09-26; on by default since 2026-10-25 (PLAN.md decision 2). |
| S-28 | A Stedding new tab page | Built in patch 0003 (docs/features/new-tab.md): a local page, no Web Store tile. |
| S-32 | Branding leftovers in chrome://settings | “About Stedding”, and the Stedding mark in the chip, app menu and WebUI. |
| S-4 | Folder variant in the tab-strip mojom | Built in patch 0008: a folder is id, title and collapsed, and was verified live. |
| S-29 | De-Google chrome://settings | Built in patch 0003: “You and Google” and “AI in Chrome” are hidden. |
| S-30 | Import entry in the app menu | Present (menus M3, import I14): Import Bookmarks and Settings stays in the app menu. |
| S-13 | Performance baselines from the official build | Recorded 2026-09-02: cold 0.63 s, warm 0.77 s, 5.7 GB, 107 processes (docs/perf/README.md). Not current. |
| S-20 | Folder drop highlight | The hovered header paints its highlight, and the drop lands inside (folders F7). |
| S-16 | Import from Chrome, Arc and Firefox | Closed 2026-09-01. On the Mac, Chromium’s importer brings in Safari and Firefox. Chrome, Brave and Edge stay undocumented until that importer exists (PLAN.md decision 8, S-101). Stedding’s own importer brings in Arc. |
| S-27 | Sidebar collapse button | Kept: it is the sidebar toggle. The tab-group and tab-search combo was removed (patch 0002). |
| S-7 | Command bar across Spaces | Covered by CommandBarViewTest (spaces B13). |
| S-26 | First-run search engine chooser | Chromium’s chooser shipped in patch 0003. Skipping the welcome step records DuckDuckGo (welcome W2, 2026-10-18). |
| S-12 | capture --assert | tooling/assert-capture and tooling/probes/window.json, 23 probes. |
| S-21 | De-Google the new tab page and omnibox | Built in patch 0003 (new-tab N1): DuckDuckGo is the default, and the new tab page is local. |
| S-22 | Essentials as a grid of cards | Built in patch 0002. Since 2026-10-22, up to four cards, then two rows (sidebar Y33). |
| S-23 | Sidebar top row | Built in patch 0002: the tab-group combo, its hairline and the profile avatar are gone. |
| S-24 | Default Space chip glyph | Built in patch 0004: a Space with no icon shows a default glyph, a dot in its colour (spaces B11, B42). The Space menu does not list a fixed set of icons. |
| S-5 | New Tab row | Built in patch 0002: above the unpinned tabs, under Clear. The row opens the command bar. |
| S-25 | The typed text as a command bar row | Built in patch 0005: the bar shows the typed text as an Open or Search row. |
| S-3 | Live restart check for Spaces and folders | tooling/drive quits and relaunches; the list stays (spaces B9). |
| S-6 | Session-compaction audit | The rebuild dropped Stedding’s extra data; a provider registry writes it back. |
| S-19 | Live drag, click and key harness | tooling/drive and tooling/drive-window.py. |
| S-11 | Squash the patch series into per-feature patches | Squashed 2026-09-01 from 45 patches to one per feature (patches/README.md). 111 patches on 2026-10-28. |
| S-2 | Drag a tab onto a folder header to move it in | Built in patch 0008 (folders F7–F9), verified with a synthetic drag. |
| S-1 | Spaces core semantics: membership on insert, active tab follows the switch, empty Space opens a tab, delete moves tabs | patch 0004, `space_model_window_unittest.cc` (spaces B1–B8) |
