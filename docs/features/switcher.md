# Feature: Recent-tabs switcher

Status: **X1–X5 planned** (round 6, `docs/ROUND6-PLAN.md` R6-12).
Owner docs: `docs/PRODUCT.md` §1. Patch: TBD.

⌃⇥ walks the most recently used tabs of the active Space; a tap goes to the
previous tab, a hold shows a strip of the five most recent over the content.
⌥⌘↑/↓ traverse rows, ⌥⇧⌘↑/↓ move the active row.

## Behaviours

| Id | Behaviour | Test | State |
|---|---|---|---|
| X1 | SpaceModel keeps an activation history per Space (a closed tab leaves it; a Space switch scopes it); ⌃⇥ / ⌃⇧⇥ walk the five most recent tabs of the active Space, essentials included; Chromium's kCtrlTabMru stays off (it is global across windows and would activate Space-hidden tabs, breaking B7). | SpaceModelTest.ActivationHistoryIsPerSpace, SpaceWindowTest.CtrlTabWalksRecentTabsOfTheActiveSpace (beside NextTabSkipsOtherSpaces). | planned |
| X2 | A tap switches to the previous tab silently. | SpaceWindowTest.CtrlTabTapGoesToPreviousTab. | planned |
| X3 | Holding ⌃ past 150 ms shows a strip of up to five favicon+title cells (Space colour dot) over the content, a layered child of BrowserView like the command bar, in the theme's dialog colours; ⇥/⇧⇥ move the highlight, releasing ⌃ commits, Escape cancels. The ⌃-release detection (flagsChanged arriving as a modifier key event) is prototyped first. | RecentTabsSwitcherViewTest.ReleaseCommitsEscapeCancels; live: tooling/drive holds the key, shot, releases. | planned |
| X4 | ⌥⌘↑ / ⌥⌘↓ select the previous / next visible row (SelectRelativeTab already skips hidden tabs); ⌥⇧⌘↑ / ⌥⇧⌘↓ move the active row within its container, folder-aware (MoveTabRelative). | TabStripModelTest.MoveTabRelativeStaysInsideItsFolder. | planned |
| X5 | Setting off returns ⌃⇥ to sidebar order (IDC_CYCLE_TO_NEXT_TAB as today). | SpaceWindowTest.CtrlTabSettingOffUsesStripOrder. | planned |
