# 0016 — One sidebar for every window: the SpaceRegistry

Status: accepted
Date: 2026-09-05

## Context

ADR 0015 made Spaces a filter over one window's tab strip: the `SpaceModel` is per
window and owns the Space list, order, metadata, the essentials and the per-Space
pinned entries. A second window (⌘N, a tab dragged out) therefore starts with its own
default Space and none of the user's Spaces, which is not what Arc does and not what
anyone expects of a sidebar. Round 6 (`docs/ROUND6-PLAN.md` R6-31) makes the sidebar
one thing per profile.

Two designs were weighed. A shared model that every window observes with tabs living in
one window at a time (Arc's model); or a synchronised copy per window with tabs
duplicated across windows. The second doubles memory and makes "which one is the real
tab" a question with no answer.

Other rows depend on what the registry is: routing names Spaces by id across windows
(R6-23), the importer and the backups read one sidebar (R6-22, R6-29), the little window
asks "the last-active window's Spaces" (R6-30), and PRODUCT §2's per-Space profiles need
a Space to be able to carry a profile id.

## Decision

- A profile-level **`SpaceRegistry`** (a KeyedService) owns the Space list and its
  order, each Space's name, icon and colour, the essentials, and the per-Space pinned
  entries (home URL, title). It serialises to the profile preference
  `stedding.spaces.registry`, written on every change.
- **`SpaceModel` stays per window** and keeps only what is per window: the active Space
  and each open tab's membership. It observes the registry and re-lays the sidebar out on
  every change. Its public surface (`AddSpace`, `SetSpaceName`, `MoveSpace`, the observer)
  stays, so every caller keeps working; the calls forward to the registry.
- **A pinned tab is a real tab in one window at a time.** Other windows show its row as
  a ghost: muted favicon, "in another window" on hover. A click moves the WebContents to
  the clicking window (detach then insert, no reload); ⌥-click brings the window that
  has it to the front.
- **The session stays as it is.** Per-window extra data keeps the active Space and the
  memberships (ADR 0015's rebuild path); the registry is read from the preference, and a
  window that carries Spaces the registry does not know (an old session) adds them once.
- **A registry Space can carry a profile id**, empty today. Nothing binds a profile in
  round 6; the field exists so PRODUCT §2's per-Space profiles (the Container Halo and
  Colored container tab mods are the demand signal) need no second migration.
- **A Blank Window** (⌥⇧⌘N, the app menu) opts out: it has a registry of its own, in
  memory, one default Space, nothing shared. Arc's Blank Window.

## Consequences

- Every window shows the same Spaces, essentials and pins; a Space renamed in one is
  renamed in all. The switcher, the settings page, the importer, the backups and routing
  read the registry through `SpaceModel`, unchanged at their call sites.
- The migration is one-way and automatic: the first window of a profile after the upgrade
  seeds the registry from its session; later windows read it. A profile that never had
  Spaces gets the default one.
- The window-level backup scheduler (R6-29) becomes a profile-level one in the same
  change, since there is one sidebar to snapshot.
- Rebases carry one more KeyedService and one preference; ADR 0015's patches shrink by
  the code that moves.
