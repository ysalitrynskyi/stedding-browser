# Feature: Splits

Status: **J1, J4 built; J2 partial**; **J3, J5, J6 planned** (round 6, `docs/ROUND6-PLAN.md` R6-19).
Owner docs: `docs/PRODUCT.md` §4. Patch: none of its own; each row lands with the item that implements it.

A split is one row and one unit for every sidebar verb; the model is Chromium
153's split view.

## Behaviours

| Id | Behaviour | Test | State |
|---|---|---|---|
| J1 | A split is one unit for the sidebar's verbs: it Space-pins together (J4) and a rename applies to every pane. Session extra data does not carry a split token, and the pair is not reassembled on restore. | `SpaceWindowTest.SplitDoesNotRestoreFromSessionExtraData` | partial |
| J2 | ⌘1–9 (R6-13 R19) and the ⌃⇥ strip (R6-12 X3) count a split as one; activating it activates the pane that was last active. | SpaceWindowTest.RecentTabsCountASplitOnce (the recent list; the pane that was last active is the one recorded); SpaceWindowTest.NumberedTabCountsASplitOnce (⌘1–9, still planned) | partial · the ⌃⇥ half is built |
| J3 | ⌘W on a split: TBD. Check first what Chromium 153 does to the other pane, then decide whether a pinned split's pane sleeps instead (R6-16 H3) and record it here before H3 is built. | TBD | planned · draft |
| J4 | Move to Space, Sleep and ⌘D act on both panes together (the split is one selection under R6-20). A split sleeps as one row: Sleep Tab on the split on screen activates a visible row outside it, then discards both panes; if either pane is in use (tabs R6), neither sleeps and Sleep Tab on it is greyed. Sleep Other Tabs asked from one pane leaves the other awake, and never takes the split on screen. | SpaceWindowTest.SplitPanesTakeVerbsTogether (Move to Space and ⌘D reach both panes through `SpaceModel::SplitPeers`; the selection carries both panes, so `TabsToSleep` takes both); `SleepTabsTest.SleepTabOnTheActiveSplitSleepsBothPanes`; `SleepTabsTest.APaneInUseKeepsItsSplitAwake`; `SleepTabsTest.SleepOthersKeepsItsOwnRowAndTheScreen`. | built |
| J5 | A Space-pinned tab that joins a split leaves the pinned run for the split's row (noted, not changed, in the round-5 audit): keep or fix is TBD; the answer is a row here. | TBD | planned · draft |
| J6 | No ring around the panes (R6-05 U6–U7); Chromium's split browsertests stay green. | existing split browsertests; the U6 probe | planned · draft |
