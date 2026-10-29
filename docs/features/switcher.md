# Feature: Recent-tabs switcher

Status: **X1–X5 built** on macOS and Windows. Linux is not shipped. KDE's Ctrl+Esc is not checked (X3).

Owner docs: `docs/PRODUCT.md` §1. Patch: `0023`, with the Windows way out in `0072`.

⌃⇥ walks the most recently used tabs of the active Space. A tap goes to the previous tab. A hold shows a strip of the five most recent over the content. ⌥⌘↑/↓ traverse rows. ⌥⇧⌘↑/↓ move the active row.

On Windows every chord below is the Mac's with ⌘ read as Ctrl and ⌥⌘ as Ctrl+Alt (Alt+1–9 for the Spaces). The map is `docs/features/windows.md` N7.

## Behaviours

| Id | Behaviour | Test | State |
|---|---|---|---|
| X1 | `SpaceModel` keeps an activation history per Space. A closed tab leaves it. A Space switch scopes it. ⌃⇥ / ⌃⇧⇥ walk the five most recent tabs of the active Space, essentials included. Chromium's `kCtrlTabMru` stays off: it is global across windows and would activate Space-hidden tabs (spaces B7). | `SpaceWindowTest.ActivationHistoryIsPerSpace`, `SpaceWindowTest.CtrlTabWalksRecentTabsOfTheActiveSpace` | built |
| X2 | A tap switches to the previous tab with no strip. Escape mid-run cancels. | `SpaceWindowTest.CtrlTabTapGoesToPreviousTab` | built |
| X3 | Holding ⌃ past 150 ms (`kHoldDelay`) shows a strip of up to five favicon and title cells, with a Space colour dot, over the content. It is a layered child of `BrowserView`, like the command bar, in the theme's dialog colours. ⇥ / ⇧⇥ move the highlight, releasing ⌃ commits, and Escape cancels. A window that stops being active ends the run on the tab it reached, and the next ⌃⇥ starts a new run (TST-9). A step that ends the run, such as one taken after the run's other tab closed with ⌃ still held, takes the strip down. On Windows, Ctrl+Esc is the Start menu's chord and the shell takes it before the window hears it. Stedding does not install a system-wide keyboard hook. With Ctrl still held, Shift+Tab steps back to the first cell, the tab the run began on, and letting go ends the run there with the recent order as it was before the run. A run's steps are not recorded as uses. Letting go on the tab reached, then tapping Ctrl+Tab, also returns to the first tab, and the tab reached then counts as used (S-228). The Shift+Tab path is the same off the Mac. Under KDE Plasma, Ctrl+Esc opens System Activity; that is not checked. Linux is not shipped. | `RecentTabsSwitcherViewTest.ReleaseCommitsEscapeCancels`, `RecentTabsSwitcherViewTest.SteppingBackToTheFirstTabIsLikeEscape`; browser: `NumberBadgeTest.CtrlTabEndsWithTheKeyOrTheWindow`, `NumberBadgeTest.AStripWhoseRunEndedComesDown` | built · KDE's Ctrl+Esc is not checked; Linux is not shipped |
| X4 | ⌥⌘↑ / ⌥⌘↓ select the previous / next visible row. ⌥⇧⌘↑ / ⌥⇧⌘↓ move the active row within its container (`MoveTabRelative`) and trade places with the next row on screen. Rows the user cannot see are passed over. With only such rows beyond it, the row stays. A collapsed folder or group of the active Space is a header on screen, and a row like any other (TAB-32, S-140). | `TabStripModelTest.MoveTabRelativeStaysInsideItsFolder`, `TabStripModelTest.MoveTabRelativePassesRowsTheUserCannotSee`; browser: `SpaceSwitchTest.MoveUpAndDownPassAnotherSpacesRows` | built |
| X5 | The setting off returns ⌃⇥ to sidebar order (`IDC_CYCLE_TO_NEXT_TAB`). | `SpaceWindowTest.CtrlTabSettingOffUsesStripOrder` | built |

## Notes

The history lives in `SpaceModel` beside `last_active_`: one vector of tab handles per Space, most recent first, capped at 40 (`kHistoryCap`). The strip and ⌃⇥ read the first five (`kCycleLength`) through `RecentTabs()`. A run (`CycleRecent`, `EndCycle`, `CancelCycle`) freezes the list while ⌃ is down. The landing tab becomes the most recent when the run ends. Leaving the Space ends a run where it is.

`RecentTabs()` follows the history with the Space's never-activated tabs in sidebar order (`SpaceWindowTest.RecentTabsFallBackToSidebarOrder`).

The same history picks the row shown after the tab on screen closes, leaves for another window or goes to sleep (tabs R33–R37, S-112): the row a tap would show, without the essentials, which a close shows only once the Space has no row of its own.

Chromium's `kCtrlTabMru` stays off. The command controller asks `spaces::CycleRecentTab()` first, which declines in popup and private windows and when the setting is off.

⌃⇥ while the command bar is open closes the bar on the focus change, and the run proceeds. Tabs inside a collapsed folder stay in the history. The strip shows them like any other cell, and the tab reached keeps its row under the collapsed header (folders F3). Ctrl-Tab offers only the Space's own tabs, and ⌘1–9 reach only rows on screen (`SpaceSwitchTest.NumbersAndCtrlTabReachOnlyRowsOnScreen`, S-139).

The bar's actions mode carries "Go to the Most Recent Tab", a tap (commandbar K9).
