# Feature: Focus this Space

Status: **Fc1–Fc2 built**; **Fc3 planned**. Owner: spaces. Patch: 0048.

One Space, one world, user-started. Not a therapist. No model.

## Behaviours

| Id | Behaviour | Test | State |
|---|---|---|---|
| Fc1 | Focus hides every other Space chip and the "+" (the switcher rebuilds with the active chip alone and chip drag is off while it lasts). ⌃1–9 do nothing while it lasts. Essentials stay. The command bar's **Focus This Space** / **Leave Focus** row is the verb. | `SpaceModelTest.FocusHidesOtherSpaces`; `SwitcherRulesTest.ShareCoatHidesOtherChips`; live: the bar's row | built |
| Fc2 | Any Space switch leaves Focus -- choosing a tab in another Space from ⌘T among them -- and so does the bar's row, the only toggle. A routing hit leaves Focus and follows the rule. | `SpaceModelTest.FocusHidesOtherSpaces` | built |
| Fc3 | Focus is per-window session extra data; it does not start on. Private and popup windows have no Focus. | `SessionRebuildTest.FocusSurvivesRebuild` | planned |
