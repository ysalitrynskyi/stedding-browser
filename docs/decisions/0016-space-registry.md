# 0016 — One sidebar for every window: the SpaceRegistry

Status: Accepted. What `profile_id` means is [0019](0019-space-sessions-are-storage-partitions.md). Essentials in a Space with its own session are [0028](0028-a-spaces-own-essentials.md). The rule that a pinned tab is a tab of one window is superseded by [0035](0035-pins-in-every-window.md) (option B, released in 0.6.0): pins and essentials are the profile's, with a tab in each window.
Date: 2026-09-05

## Context

[0015](0015-spaces-filter-one-tab-strip.md) made Spaces a filter over one window's tab strip, with a `SpaceModel` per window. A second window then started with a default Space and none of the user's. The sidebar is one list per profile. Copying every tab into every window would leave two of each and no real one; a shared list, with each tab living in one window, is the other shape.

## Decision

- A profile-level **`SpaceRegistry`** (a `KeyedService`) owns the Space list and its order: each entry's name, icon, colour (and whether it was chosen), optional dark colour, profile id, isolation flag, and whether its pinned run is collapsed (windows G0). It is the preference `stedding.spaces.registry`, written on every change (patch 0036; pins H17).
- **`SpaceModel` stays per window.** It keeps the active Space and each open tab's membership, observes the registry, and forwards every change to it.
- **A pinned tab is a tab of one window**, with no ghost row in the other windows (windows G1). Superseded by 0035. Choosing a page open in another window asks Show Here, Go to Window or Cancel since 2026-11-07 (windows G12).
- **The session stays per window.** Extra data keeps the active Space and the memberships. A window that brings a Space the registry does not know adds it (patch 0036).
- **A registry Space carries `profile_id`.** What the field means is 0019.
- **New Blank Window** does not follow the registry and keeps a Space list of its own (windows G4). A private window has no `SpaceModel` ([private.md](../features/private.md) V3).

## Consequences

Every normal window shows the same Spaces, and a rename in one is a rename in all. The first window of a profile seeds the registry from the Spaces in its session; later windows read it (windows G3). The settings page reads the registry.
