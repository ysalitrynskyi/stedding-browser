# Feature: Share coat

Status: **Sc1 built**; **Sc2–Sc3 planned**. Owner: spaces. Patch: 0048.

While this window is captured (or the user asks), other Space chips are not
painted. No Connect, no intern, no model.

## Behaviours

| Id | Behaviour | Test | State |
|---|---|---|---|
| Sc1 | With the coat on, the switcher draws only the active chip. No "+" and no inactive names. The command bar's **Hide Other Spaces** / **Show Other Spaces** row puts it on and takes it off. | `SwitcherRulesTest.ShareCoatHidesOtherChips`; live: the bar's row | built |
| Sc2 | Auto-arm when a tab in this window captures a window or display; disarm when capture ends. Setting `stedding.spaces.hide_others_while_sharing` default on. | `ShareCoatControllerTest.CaptureArmsAndDisarms` | planned |
| Sc3 | Command bar "Hide other Spaces" / "Show other Spaces" always works. Switching Space while coated updates the single chip. | `CommandBarViewTest.ShareCoatFiltersToTheActiveSpace` | planned |
