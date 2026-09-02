# Feature: Spaces

Status: **B1–B14 built and tested** (patches 0004, 0005).
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
| B9 | Space list, active Space, per-tab membership and per-Space pins survive a real quit and relaunch, including relaunches in which nothing about Spaces changed (the session log is rebuilt from scratch and must be re-fed). | `SessionRebuildTest.*`; live: `tooling/drive` quit and relaunch three times with no changes, list and tint intact | built |
| B10 | Per-Space pin: a tab pinned in its Space sits above the Clear line there and survives Clear. | `SpaceModelTest.SpacePin*` (patch 0004) | built |
| B11 | Space metadata (name, icon, colour) edits persist and repaint the switcher and the window tint: with two or more Spaces the active one's colour tints the sidebar ground (30% dark, 22% light) and never the page; the new tab page stays neutral. A Space with no icon shows a default glyph, never a blank disc. | `SpaceModelTest.*Metadata*`; capture (dark and light, two Spaces, 2026-09-02) | built |
| B12 | Drag a tab onto a Space chip moves it there and switches to that Space. Dropping nowhere changes nothing. | `SpaceDragTargetTest.*` | built |
| B13 | ⌘T command bar lists tabs from every Space; choosing one switches Space and activates it. | `CommandBarViewTest.*` | built |
| B14 | Popup and app windows have no Spaces and no switcher. | `PopupSpaceTest.PopupWindowsHaveNoSpaces`; live: `tooling/drive` opens a popup from a page button; no switcher in it | built |

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
