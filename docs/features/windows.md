# Feature: One sidebar for every window

Status: **G0, G1, G3–G5 built, G2 a gap** (round 6, `docs/ROUND6-PLAN.md` R6-31; ADR 0016).
Owner docs: `docs/decisions/0016-space-registry.md`, `docs/PRODUCT.md` §10. Patch: 0036.

A second window shows the same Spaces, essentials and pins as the first. The Space list
lives in a profile-level registry; each window keeps only its active Space and which of
its tabs is in which Space. A pinned tab is a real tab in one window at a time and a
ghost row everywhere else.

## Behaviours

| Id | Behaviour | Test | State |
|---|---|---|---|
| G0 | ADR 0016 beside 0015: the Space list, order, metadata, essentials and per-Space pinned entries move to a profile-level `SpaceRegistry` (KeyedService); `SpaceModel` stays per window with only the active Space and tab membership, observing the registry. Written and accepted before code. | `docs/decisions/0016-space-registry.md` | built |
| G1 | ⌘N (and a tab dragged out) opens a window showing the same Spaces, essentials and pinned rows. | `SpaceWindowTest.SecondWindowSeesTheSameSpaces`; live: `w4_windows` (⌘N shows the same Spaces) | built |
| G2 | A pinned tab is a real tab in one window at a time; other windows show its row as a ghost (muted favicon, "in another window" on hover); a click moves the WebContents here (detach, then insert, no reload), ⌥-click focuses the window that has it. | none yet | gap · the next pass: a pinned tab is still a tab of one window with no ghost row elsewhere |
| G3 | The registry serialises to profile prefs (`stedding.spaces.registry`); per-window extra data keeps the active Space and memberships so the B9 rebuild path is unchanged; the settings page reads the registry. | `SpaceRegistryTest.RoundTrip`; the session's per-window data is unchanged (`SessionRebuildTest.*` still green) | built |
| G4 | "New Blank Window" (⌥⇧⌘N, the app menu) opens a window that opts out of the registry: Arc's Blank Window. | `SpaceWindowTest.BlankWindowHasItsOwnSpaces`; live: `w4_blank_window` | built |
| G5 | The registry's Space carries a profile id, empty in round 6, so per-Space profiles need no second migration (critic #9). | `SpaceRegistryTest.RoundTrip` (the empty profile id survives the round trip) | built |

## Notes

- Order of work, from the ADR: the registry and its round trip first (G3, G5), then the
  model observing it (G1), then the ghost rows and the move (G2), then the Blank Window
  (G4). Every step keeps every existing `SpaceWindowTest` green, since the model's
  surface does not change.
- Routing (R6-23) and the little window (R6-30) ask "which window": the last-active
  normal window that shares the registry; a Blank Window is never the answer.
- This cut shares the Space list, its order and metadata (G1, G3) and keeps a
  window's tabs, pins and essentials per window: a pinned tab is a real tab of the
  window it was pinned in, with no ghost row elsewhere yet (G2). The registry seeds
  itself from the first window's session and merges later windows' Spaces by id,
  so an upgrade loses nothing. The backup scheduler stays per window for now.
