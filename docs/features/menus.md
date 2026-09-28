# Feature: Menus

Status: **M1–M7 built** (round 6, `docs/ROUND6-PLAN.md` R6-14, patches 0019 and 0024); **M8–M9 partial** (2026-09-28, `PLAN.md` TAB-18, CMD-2 and decision 1: written, not yet built or run).
Owner docs: `docs/PRODUCT.md`, `docs/PRIVACY.md`. Patch: 0019 (M1, M4–M6), 0024 (M2, M3, M7, the Move to Space rows).

Stedding's verbs first, Google's gone: the tab, page and app menus carry what
this browser does, in Arc's order, with every chord drawn; a setting brings
Chromium's set back.

## Behaviours

| Id | Behaviour | Test | State |
|---|---|---|---|
| M1 | Tab menu order: Pin to This Space / Add to Essentials / Rename… / Move to Space ▸ / Move to Folder ▸ (existing folders, then New Folder) / Add to Split / Sleep Tab / Mute Site — Copy Link / Copy as Markdown — Close / Close Others / Clear Below; every item that has a key shows its chord (Pin to This Space, Copy Link and Copy Link as Markdown showed none until 2026-09-10: the verbs were not mapped to the browser commands the menu reads chords from, patch 0043). Send to your devices, Glic, reading list, tab groups and move-to-window are gone unless the setting says otherwise. | TabMenuModelTest.SteddingOrder asserts the exact command list for both states of the toggle, so a rebase cannot reintroduce CommandSendTabToSelf, CommandAddToReadLater or CommandGlic*. Chromium's extension tab-context rows are not in the short menu yet (TBD: a row here when they are). | built |
| M2 | Page menu loses Lens, Search Google for image/video frame, Generate QR code, Reading mode and Glic; 'Search <default engine> for …' stays. | RenderViewContextMenuPrefsTest.SteddingShortMenusHideGoogleRows (the setting on and off), MenuRulesTest.PageMenuHidesGoogleRows (the id set). | built |
| M3 | App menu loses Manage Google account, Open Glic, Send tab to self, Customize Chrome and Payment methods; gains Import…, Screenshot ▸ (the three captures) and Spaces ▸. The Bookmarks and lists submenu keeps Import Bookmarks and Settings and the manager, loses the bookmarks-bar submenu and the side-panel entry. | MenuRulesTest.AppMenuHidesGoogleRows (the id set; the app menu answers `IsCommandIdVisible` with it); live: `w2_appmenu_screen` — Import, Screenshot ▸, Spaces ▸ after Downloads, no Google account, Glic, send-to-self, Customize Chrome or Payment rows. | built |
| M4 | The Chromium set returns with the toggle (on = Stedding's short menu; the row is worded so 'on' is the default per settings T2). | TabMenuModelTest.SteddingOrder (off branch). | built |
| M5 | Close Others and Clear Below act inside the active Space and skip tabs inside collapsed folders: TabStripModel::GetIndicesClosedByCommand never asks IsTabHidden today, so both would close tabs in other Spaces (critic #1; same family as R10). | `SpaceWindowTest.CloseOthersStaysInsideTheSpace` (both commands: it asserts Close Others and the Close-below index list stay inside the Space) | built |
| M6 | The tab-group chords (⌃⌘C/P/W/X/Z, global_keyboard_shortcuts_mac.mm:166-174; the synthesis and critic #14 wrote ⌥⌘, but the entries set command_key and cntrl_key in global_keyboard_shortcuts_mac.h) are removed in the same hunk that hides the group rows, so a rebase cannot re-expose a hidden feature by keyboard (critic #14; item 1 called them "untouched"). On Windows Chromium's Alt+Shift+C/P/X/Z/W group chords were live until patch 0043 made them Linux's alone (windows N7). | the tab-group chords are gone from the table with the rows (Z2 records it); `ShortcutReferenceTest.*` reads the table | built |
| M7 | Beyond the plain row (M1), four more menus: the essentials card (Remove from Essentials; no Move to Space, no folder), the folder header, the split row (R6-19), the Space-pinned row (Unpin, Reset to Pinned Page, Make This the Pinned Page). With a multi-selection every label takes the plural ("Close 3 Tabs", "Move 3 Tabs to ▸", R6-20). | MenuRulesTest.TabMenuRowsByKind (the three kinds), TabMenuModelTest.SteddingMoveToSpaceAndSplitRows (the split row arranges), TabStripModelTest.MoveTabsOutOfFolderDissolvesIt (the folder verb); live: `w2_pinmenu_screen` (the essentials card), `w2_foldermenu_screen` (the folder header). Plural labels: tabs R20–R22. | built |
| M8 | The horizontal tab strip's tab menu has the sidebar's Stedding verbs, and they work there: "Move to Space" and "Always Open <site> in" open their submenus and every entry moves or routes the selection, the window following; Copy Link and Copy as Markdown are the clean copy (copy-link L4), never `chrome::CopyURL`'s verbatim one, which a normal window reached through a web app's command; Pin to This Space, Sleep Tab, Sleep Others, Reset to Pinned Page and Make This the Pinned Page do what they do in the sidebar, the last only while the tab shows a web page (pins H13); Rename shows and is disabled, the strip having no row to rename in; the rows by kind (M7) are the same. One helper, `stedding::tab_menu_verbs`, answers and runs these for both strips: the sidebar's collection controller, and `BrowserTabStripController` through `TabStripModel`'s context-menu API. Every Move to Space and Always Open id is checked against the Spaces the window has, so an id past them is disabled and does nothing: the ids between First and Last reached a fatal `NOTREACHED` from the horizontal strip, and its model answered the two submenu rows disabled (`PLAN.md` TAB-18, CMD-F2, TAB-F46). A web app's window keeps Chromium's Copy URL. | `TabMenuVerbsTest.MoveAndRouteEntriesAreRangeChecked`, `.TheThirdMoveEntryMovesTheTabAndTheWindowFollows`, `.TheThirdRouteEntryWritesTheRuleAndRoutesTheTab`, `.CopyLinkIsTheCleanCopy`, `.SpacePinAndThePinnedPage`, `.RenameNeedsARowToRenameIn`, `.SleepIsOfferedOnAPlainRow`, `.RowsByKind`, `.TheHorizontalMenuOpensItsSubmenus`; `TabMenuVerbsPopupTest.SpaceVerbsAreOffWithoutSpaces`. The interactive_ui_test that right-clicks a tab of the horizontal strip (TAB-18's check) is TBD. | partial · written 2026-09-28, not yet built or run |
| M9 | The horizontal tab strip stays (`PLAN.md` decision 1): the switch to the other strip is in the app menu, the Mac View menu, the tab strip's own menu (Chromium's system menu, in the notes below) and Chromium's long tab menu (M4), whichever strip shows. The short tab menu (M1) keeps Arc's list without it. | `TabMenuVerbsTest.TheLongMenuOffersTheOtherTabStrip`; Chromium's `SystemMenuModelBuilderVerticalTabsTest.VerticalTabsSystemMenu` expects the row in both modes and holds under Stedding again | partial · written 2026-09-28, not yet built or run |

## Notes from the build (2026-09-05)

- The page and app menus keep Chromium's builders and hide rows through the
  delegate's `IsCommandIdVisible`, answered by `stedding::menu_rules` and the
  short-menus setting; no Chromium `Append*` site moves, so a rebase carries
  little. Consecutive separators that a hidden row leaves behind are collapsed by
  the views menu.
- The tab menu's kind rows are hidden the same way: `TabContextMenuController`
  asks its delegate `IsContextMenuCommandVisible`, and the collection controller
  answers from the tab's tier (essentials, Space-pinned, plain).
- The folder header's verbs run through the collection controller: Move Tabs
  Out uses a plain index move to where the folder sits, so a nested folder's tabs
  come out flat; Close Folder's Tabs (TabStripModel::CloseFolderTabs) leaves
  the folder first when it holds the active tab, then closes its tabs of this
  Space in one batch, and the emptied folder leaves the tree on its own.
- Screenshot and Spaces are submenus with ids in the `IDC_STEDDING_` range
  declared on `AppMenuModel`, not in `chrome_command_ids.h`, to spare the rebuild
  a new id costs (HANDOFF trap 19); the rows are literals until the UI is
  localised.
- The sidebar's own background menu (Chromium's system menu on the strip) keeps
  New Tab, Reopen Closed Tab, Name Window, Collapse, the switch to the other tab
  strip (M9, since 2026-09-28) and Task Manager under the setting; Bookmark All
  Tabs, the Tab Search and Glic pins, the auto-expanding toggle and Google's
  vertical-tabs feedback row go (`system_menu_model_builder.cc`).
- The tab menu's Stedding verbs (M8) live in `chrome/browser/ui/stedding/tab_menu_verbs.cc`.
  `TabStripModel::IsContextMenuCommandEnabled` and `ExecuteContextMenuCommand`
  hand every verb to it before their switch, so no strip can send an id the
  switch does not name; the collection controller keeps only Rename, which needs
  the row's view (2026-09-28).
- The short tab menu carries extension rows like Chromium's (`AppendExtensionItems`
  serves both builders); Chromium's `TabMenuModelTest.ExtensionItems` had been red
  since the short menu landed and is green again.
- The Screenshot and Spaces submenus answer their own enabled state: the command
  updater never registers a container id, so the first capture drew them grey.
