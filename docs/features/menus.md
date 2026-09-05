# Feature: Menus

Status: **M1–M7 planned** (round 6, `docs/ROUND6-PLAN.md` R6-14).
Owner docs: `docs/PRODUCT.md`, `docs/PRIVACY.md`. Patch: TBD.

Stedding's verbs first, Google's gone: the tab, page and app menus carry what
this browser does, in Arc's order, with every chord drawn; a setting brings
Chromium's set back.

## Behaviours

| Id | Behaviour | Test | State |
|---|---|---|---|
| M1 | Tab menu order: Pin to This Space / Add to Essentials / Rename… / Move to Space ▸ / Move to Folder ▸ (existing folders, then New Folder) / Add to Split / Sleep Tab / Mute Site — Copy Link / Copy as Markdown — Close / Close Others / Clear Below; every item shows its chord. Send to your devices, Glic, reading list, tab groups and move-to-window are gone unless the setting says otherwise. | TabMenuModelTest.SteddingOrder asserts the exact command list for both states of the toggle, so a rebase cannot reintroduce CommandSendTabToSelf, CommandAddToReadLater or CommandGlic*. Chromium's extension tab-context rows are not in the short menu yet (TBD: a row here when they are). | built |
| M2 | Page menu loses Lens, Search Google for image/video frame, Generate QR code, Reading mode and Glic; 'Search <default engine> for …' stays. | RenderViewContextMenuTest row set (a later pass if the file's size argues for it; judges accepted keeping the page menu for a second round). | planned |
| M3 | App menu loses Manage Google account, Open Glic, Send tab to self, Customize Chrome and Payment methods; gains Import…, Screenshot ▸ (the three captures) and Spaces ▸. The Bookmarks and lists submenu keeps Import Bookmarks and Settings and the manager, loses the bookmarks-bar submenu and the side-panel entry. | AppMenuModelTest.SteddingRows. | planned |
| M4 | The Chromium set returns with the toggle (on = Stedding's short menu; the row is worded so 'on' is the default per settings T2). | TabMenuModelTest.SteddingOrder (off branch). | built |
| M5 | Close Others and Clear Below act inside the active Space and skip tabs inside collapsed folders: TabStripModel::GetIndicesClosedByCommand never asks IsTabHidden today, so both would close tabs in other Spaces (critic #1; same family as R10). | TabStripModelTest.CloseOthersStaysInsideTheSpace, TabStripModelTest.ClearBelowSkipsHiddenTabs | built |
| M6 | The tab-group chords (⌃⌘C/P/W/X/Z, global_keyboard_shortcuts_mac.mm:166-174; the synthesis and critic #14 wrote ⌥⌘, but the entries set command_key and cntrl_key in global_keyboard_shortcuts_mac.h) are removed in the same hunk that hides the group rows, so a rebase cannot re-expose a hidden feature by keyboard (critic #14; item 1 called them "untouched"). | the tab-group chords are gone from the table with the rows (Z2 records it); `ShortcutReferenceTest.*` reads the table | built |
| M7 | Beyond the plain row (M1), four more menus: the essentials card (Remove from Essentials; no Move to Space, no folder), the folder header, the split row (R6-19), the Space-pinned row (Unpin, Reset to Pinned Page, Make This the Pinned Page). With a multi-selection every label takes the plural ("Close 3 Tabs", "Move 3 Tabs to ▸", R6-20). | TabMenuModelTest.SteddingOrder asserts all five command lists and the plural labels | planned · critic #15, D3 |
