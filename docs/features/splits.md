# Feature: Splits

Status: **J1–J6 planned** (round 6, `docs/ROUND6-PLAN.md` R6-19).
Owner docs: `docs/PRODUCT.md` §4. Patch: none of its own; each row lands with the item that implements it.

A split is one row and one unit for every sidebar verb; the model is Chromium
153's split view.

## Behaviours

| Id | Behaviour | Test | State |
|---|---|---|---|
| J1 | A split is one row in the sidebar and one unit for the sidebar's verbs: it pins, Space-pins, renames (R6-17) and restores as one row, both pages coming back paired. | SplitRowTest.PinRenameAndRestoreKeepThePair (name TBD) | planned · draft |
| J2 | ⌘1–9 (R6-13 R19) and the ⌃⇥ strip (R6-12 X3) count a split as one; activating it activates the pane that was last active. | SpaceWindowTest.RecentTabsCountASplitOnce (the recent list; the pane that was last active is the one recorded); SpaceWindowTest.NumberedTabCountsASplitOnce (⌘1–9, still planned) | partial · the ⌃⇥ half is built |
| J3 | ⌘W on a split: TBD. Check first what Chromium 153 does to the other pane, then decide whether a pinned split's pane sleeps instead (R6-16 H3) and record it here before H3 is built. | TBD | planned · draft |
| J4 | Move to Space, Sleep and ⌘D act on both panes together (the split is one selection under R6-20). | SpaceWindowTest.MoveToSpaceMovesBothPanes; TabStripModelTest.SleepAppliesToBothPanes | planned · draft |
| J5 | A Space-pinned tab that joins a split leaves the pinned run for the split's row (noted, not changed, in the round-5 audit): keep or fix is TBD; the answer is a row here. | TBD | planned · draft |
| J6 | No ring around the panes (R6-05 U6–U7); Chromium's split browsertests stay green. | existing split browsertests; the U6 probe | planned · draft |
