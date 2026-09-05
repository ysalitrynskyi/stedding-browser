# Feature: Spaces

Status: **B1–B17 built and tested** (patches 0004, 0005, 0013); **B18–B30 planned** (round 6, `docs/ROUND6-PLAN.md` R6-02, R6-18).
Owner docs: `docs/decisions/0015-spaces-filter-one-tab-strip.md` (model), `docs/UI-SPEC.md`
(pixels). Patch: `0004` (the whole feature, since the series was squashed per feature, `S-11`).

This file is the definition of done. A behaviour is shipped when its test id is green,
not when a capture looks right. Every behaviour below is phrased so it can be checked
without a human looking at a screenshot.

## What a Space is

A Space is a named, coloured set of tabs inside one window. Every tab in the window
belongs to exactly one Space, except Chromium-pinned tabs (the essentials row), which are
in every Space. Only the active Space's tabs are visible; the rest stay in the one tab
strip, hidden (ADR 0015). The content pane always shows a tab the user can see in the
sidebar.

## Behaviours

| Id | Behaviour | Test | State |
|---|---|---|---|
| B1 | A tab opened while Space S is active belongs to S and is visible only in S. | `SpaceWindowTest.NewTabJoinsTheActiveSpace`, `SpaceWindowTest.ATabIsVisibleOnlyInItsSpace` | built |
| B2 | A tab restored from a session returns to the Space it was in. If that Space did not come back, it joins the active Space. | `SpaceWindowTest.RestoredTabReturnsToItsSpace`, `SpaceWindowTest.RestoredTabWhoseSpaceIsGoneJoinsTheActiveSpace` | built |
| B3 | Switching to Space S activates the tab that was last active in S, else the first tab in S. Non-essential tabs win over essentials. If S has no tab at all, a new tab opens in S. | `SpaceWindowTest.SwitchingActivatesATabInTheTargetSpace`, `SpaceWindowTest.SwitchingToAnEmptySpaceOpensANewTabThere` | built |
| B4 | When the last visible tab of the active Space closes and the window stays open, a new tab opens in that Space. The active tab is never one the user cannot see. | `SpaceWindowTest.ClosingTheLastTabOfASpaceOpensANewTabThere` | built |
| B5 | Deleting a Space moves its tabs into the active Space. No tab is lost. The active Space and the last Space cannot be deleted. | `SpaceWindowTest.DeletingASpaceMovesItsTabsToTheActiveSpace`, `SpaceModelTest.RefusesToRemove*` | built |
| B6 | Chromium-pinned (essentials) tabs are visible in every Space and are never moved by Space operations. | `SpaceWindowTest.EssentialsTabsAreInEverySpace` | built |
| B7 | Tab traversal (Ctrl+Tab, Ctrl+Shift+Tab, next-tab-after-close) skips tabs in other Spaces. | `SpaceWindowTest.NextTabSkipsOtherSpaces` | built |
| B8 | Moving a tab to another Space hides it here, shows it there, and observers are told so views refresh without a Space switch. | `SpaceWindowTest.MovingATabNotifiesObservers` | built |
| B9 | Space list, active Space, per-tab membership and per-Space pins survive a real quit and relaunch, including relaunches in which nothing about Spaces changed (the session log is rebuilt from scratch and must be re-fed). The incremental writes and the rebuild emit the same extra data through one helper, `SpaceModel::SessionExtraDataForTab`; a pin used to survive one relaunch only (found 2026-09-03). | `SessionRebuildTest.*`; live: `tooling/drive` pin a tab, then quit and relaunch three times with no changes; list, tint and the pinned run intact | built |
| B10 | Per-Space pin: a tab pinned in its Space sits above the Clear line there and survives Clear. | `SpaceModelTest.SpacePin*` (patch 0004) | built |
| B11 | The switcher row is downloads at the left, the Space chips together in the middle with a 12 DIP gap, "+" at the right (chips spread across the row read as "weirdly centred", 2026-09-04). Space metadata (name, icon, colour) edits persist and repaint the switcher and the window tint: with two or more Spaces the active one's colour tints the sidebar ground (30% dark, 22% light) and never the page; the new tab page stays neutral. A Space with no icon shows a default glyph, never a blank disc. | `SpaceModelTest.*Metadata*`; capture (dark and light, two Spaces, 2026-09-02) | built |
| B12 | Drag a tab onto a Space chip moves it there and switches to that Space. Dropping nowhere changes nothing. | `SpaceDragTargetTest.*` | built |
| B13 | ⌘T command bar lists tabs from every Space; choosing one switches Space and activates it. | `CommandBarViewTest.*` | built |
| B15 | A two-finger horizontal swipe across the sidebar activates the next (swipe left) or previous Space; the ends do not wrap. | `SpaceModelTest.SwitchToNeighbourWalksTheSwitcherOrderWithoutWrapping`; live | built |
| B16 | With two or more Spaces the active Space's icon and name head the tab list, above its pinned tabs; pressing the row opens the Space menu (icon, colour, rename, delete). | live: `tooling/drive` 2026-09-03 | built |
| B17 | Space-pinned tabs sit under the title with the Clear line beneath them, then "+ New Tab", then the rest; pinning moves the tab into that run at once and the line appears only when both a pinned run and unpinned tabs exist. | live: `tooling/drive` 2026-09-03 (pin from the context menu) | built |
| B14 | Popup and app windows have no Spaces and no switcher. | `PopupSpaceTest.PopupWindowsHaveNoSpaces`; live: `tooling/drive` opens a popup from a page button; no switcher in it | built |
| B18 | ⌃1…⌃9 activate Space N in switcher order (`SpaceModel::SetActiveSpace(spaces()[n-1]->id())`); N past `size()` is a no-op. | `SpaceModelTest.SetActiveSpaceByIndexIgnoresOutOfRange`; `SpaceCommandTest.SpaceNIsDisabledPastTheCount` | built |
| B19 | ⌥⌘← / ⌥⌘→ activate the previous / next Space through `SwitchToNeighbour` (no wrap, the swipe's path, B15); tab traversal moves to ⌥⌘↑ / ⌥⌘↓ (⇧⌘] / ⇧⌘[ kept); pane focus takes F6 / ⇧F6, as on the other platforms (Chromium's Mac build had it on ⌥⌘↑/↓ only). | `SpaceModelTest.SwitchToNeighbour*` (exists); `ShortcutReferenceTest.EverySteddingCommandWithAnAcceleratorIsListed` (the chords resolve through the accelerator tables); live: `tooling/drive` key ⌥⌘→ then read the switcher | built |
| B20 | ⇧⌘K runs Clear on the active Space through `SpaceModel::ClearUnpinnedTabs`, the collector moved out of `VerticalTabStripRegionView::ClearCurrentSpaceTabs` so the line and the key share one path; Space-pinned tabs survive. | `SpaceWindowTest.ClearUnpinnedTabsKeepsPins` | built |
| B21 | ⌘D toggles Pin to This Space; Bookmark This Tab and Bookmark All Tabs keep their menu rows and lose their chords (a divergence row in the shortcut reference, Z2: pinned tabs replace bookmarks, `docs/PRODUCT.md` §1). | `SpaceWindowTest.CmdDTogglesSpacePin` | built |
| B22 | ⌥⇧⌘← / ⌥⇧⌘→ move the active tab one Space over and follow it (`SetSpaceForTab` then `SetActiveSpace`). | `SpaceWindowTest.MoveTabToNeighbourSpaceFollowsIt` | built |
| B23 | A "Spaces" menu in the menu bar lists Next Space, Previous Space, Clear This Space and Space 1…Space 9 with their chords; Space N is enabled only when N ≤ `size()`. | capture of the menu; welcome step 5 and the settings hint list ⌃1–9 and ⇧⌘K | built |
| B28 | ⌘D on an essentials (Chromium-pinned) tab is a no-op and the menu row is disabled (plan D4; folders F8 refuses folders for pins the same way). | `SpaceWindowTest.CmdDOnAnEssentialIsANoOp` | built |
| B29 | ⌃1–⌃9, ⇧⌘K, ⌥⌘←/→, ⌥⇧⌘←/→ and the Spaces menu rows are disabled in private and popup windows (no Spaces there: B14). | `SpaceCommandTest.SpaceCommandsAreDisabledInPopupAndPrivateWindows` | built |
| B30 | ⌃1–⌃9 collide with macOS Mission Control "Switch to Desktop N" once a second desktop exists; the Spaces menu (B23) keeps the commands reachable and the shortcut reference notes it (Z3); no remap in round 6 (plan D5). | spec row; Z3 | built |
| B31 | A colour the user chose for a Space (switcher menu, settings, the welcome swatches) tints the sidebar ground even while it is the window's only Space; a Space that was never given a colour keeps the plain ground until a second Space exists (the lone-Space rule from B11). The choice survives restart with the colour. | `SpaceModelTest.AChosenColourOnALoneSpaceIsRemembered`; live: welcome swatch, sidebar-ground probe | built |
| B24 | When the chips (24 DIP, kChipGap 12) would exceed the row, inactive chips shrink to 6 DIP dots in their Space colour while the active chip keeps its glyph; the '+' and downloads button never move. Confirm against the Arc reference first (unsure whether Arc collapses to dots at overflow; fix the dot size after the capture). | SpaceSwitcherViewTest.OverflowShrinksInactiveChips on measured widths at 352 and 126 with 12 Spaces. | planned |
| B25 | Hovering the row grows them back while the pointer is there, with no layout shift outside the row; the name pill and the swipe (B15) keep working. | SpaceSwitcherViewTest.HoverRestoresChipsWithinTheRow; live capture at 12 Spaces. | planned |
| B26 | Below the overflow threshold nothing changes (B11 holds). | existing B11 capture unchanged. | planned |
| B27 | A Space chip dragged along the row reorders the switcher; the Space menu offers Move Left / Move Right as the keyboard path (SpaceModel gains MoveSpace); the order persists (B9) and ⌃N follows it (B18). PRODUCT §2 [1.0]; critic #10. | SpaceModelTest.MoveSpaceReordersAndPersists; live: tooling/drive drags a chip past its neighbour, reads the switcher | planned · critic #10 |

"built" means the test exists in the series and passes on the pinned tree. "gap" is a
behaviour we ship without a test — each one is a backlog item.

## Out of scope here

Sync across devices (`docs/PRODUCT.md`, needs a decision), Space-level themes beyond one
colour, and a per-Space new-tab page.

## Running the tests

```bash
tooling/dev test spaces
```

which is `autoninja -C out/release unit_tests` followed by a `--gtest_filter` over
`SpaceWindowTest.*:SpaceModelTest.*:SpaceDragTargetTest.*`.
