# Feature: One sidebar for every window

Status: **G0–G5 planned** (round 6, `docs/ROUND6-PLAN.md` R6-31; ADR 0016 written).
Owner docs: `docs/decisions/0016-space-registry.md`, `docs/PRODUCT.md` §10. Patch: TBD.

A second window shows the same Spaces, essentials and pins as the first. The Space list
lives in a profile-level registry; each window keeps only its active Space and which of
its tabs is in which Space. A pinned tab is a real tab in one window at a time and a
ghost row everywhere else.

## Behaviours

| Id | Behaviour | Test | State |
|---|---|---|---|
| G0 | ADR 0016 beside 0015: the Space list, order, metadata, essentials and per-Space pinned entries move to a profile-level `SpaceRegistry` (KeyedService); `SpaceModel` stays per window with only the active Space and tab membership, observing the registry. Written and accepted before code. | the ADR exists | planned |
| G1 | ⌘N (and a tab dragged out) opens a window showing the same Spaces, essentials and pinned rows. | `SpaceWindowTest.SecondWindowSeesTheSameSpaces` | planned |
| G2 | A pinned tab is a real tab in one window at a time; other windows show its row as a ghost (muted favicon, "in another window" on hover); a click moves the WebContents here (detach, then insert, no reload), ⌥-click focuses the window that has it. | `SpaceWindowTest.PinnedTabMovesBetweenWindowsOnClick` | planned |
| G3 | The registry serialises to profile prefs (`stedding.spaces.registry`); per-window extra data keeps the active Space and memberships so the B9 rebuild path is unchanged; the settings page reads the registry. | `SpaceRegistryTest.RoundTrip`; `SessionRebuildTest` with two windows | planned |
| G4 | "New Blank Window" (⌥⇧⌘N, the app menu) opens a window that opts out of the registry: Arc's Blank Window. | `SpaceWindowTest.BlankWindowHasItsOwnSpaces` | planned |
| G5 | The registry's Space carries a profile id, empty in round 6, so per-Space profiles need no second migration (critic #9). | `SpaceRegistryTest.RoundTrip` carries an empty profile id | planned |

## Notes

- Order of work, from the ADR: the registry and its round trip first (G3, G5), then the
  model observing it (G1), then the ghost rows and the move (G2), then the Blank Window
  (G4). Every step keeps every existing `SpaceWindowTest` green, since the model's
  surface does not change.
- Routing (R6-23) and the little window (R6-30) ask "which window": the last-active
  normal window that shares the registry; a Blank Window is never the answer.
