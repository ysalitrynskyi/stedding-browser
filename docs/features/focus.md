# Feature: Focus this Space

Status: **Fc1–Fc3 planned**. Owner: spaces. Patch: none yet.

One Space, one world, user-started. Not a therapist. No model.

## Behaviours

| Id | Behaviour | Test | State |
|---|---|---|---|
| Fc1 | Focus hides every other Space chip and the "+". Swipe and ⌃2–9 no-op. Essentials stay. | `SpaceWindowTest.FocusHidesOtherSpaces` | planned |
| Fc2 | The same chord, the Space menu, or choosing a tab in another Space from ⌘T leaves Focus. A routing hit leaves Focus and follows the rule. | `SpaceWindowTest.ChoosingATabInAnotherSpaceLeavesFocus` | planned |
| Fc3 | Focus is per-window session extra data; it does not start on. Private and popup windows have no Focus. | `SessionRebuildTest.FocusSurvivesRebuild` | planned |
