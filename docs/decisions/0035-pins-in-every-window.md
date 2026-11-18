# 0035 — Pins and essentials in every window

Status: Accepted, option B (the owner, 2026-11-15: "Yes, option B"). Proposed 2026-11-13 (BACKLOG S-94, GitHub issue 111). Built 2026-11-16 (`docs/features/windows.md` G2, G13-G22) and released in 0.6.0 (2026-11-18).
Date: 2026-11-13

## Context

A second window of a profile shares the Space list (`docs/features/windows.md` G1, ADR 0016), but not its pinned tabs and essentials: a pin was a real tab of the window that held it, and a new window started with none. GitHub issue 111 reports this as the first thing a person from Arc notices: "When opening a new window on macOS, all pins and tabs from the original window are missing."

Arc shows the same pinned tabs in every window; its release notes for macOS of 2023-05-31 say "Pinned tabs will still sync across Windows and devices" (resources.arc.net, "Arc for macOS - 2023 Release Notes"). Arc's later behaviour for unpinned tabs is not part of this decision.

A pin's record (home address, own name, folder, place in the pinned run) lived in the window's session. Choosing a page open in another window already asks Show Here, Go to Window or Cancel (G12), so a page is never shown in two windows at once.

## Decision

**B**, the owner's choice on 2026-11-15. Options considered:

- **A. Ghost rows.** Every window lists every pin, but a pin stays one tab in one window; elsewhere its row asks, as G12 does, to bring it here or go there. Moving it takes the page from the window that had it, which is not what Arc does.
- **B. One pin, a tab in each window.** The pinned run and the essentials become the profile's, kept beside the Space registry, one record per pin (Space, home address, own name, folder, place). Every window shows every pin, with its own tab for it, asleep until chosen there; a pin chosen in two windows is two pages, each with its own history, as in Arc. Pinning, unpinning, renaming, moving and sending a pin home change the record, and every window follows at once. Unpinned tabs stay each window's own.
- **C. B, and unpinned tabs shared too,** as Arc's August 2023 change. Every window would show every tab, which is what a second window is usually opened to avoid; the reports ask for pins.

Why B: it is what someone leaving Arc expects of a second window, and it keeps G12 for loose tabs. The pinned run already behaves as a record with a home (pins H3, H16, decision 11); B gives that record one home for the profile instead of one per window.

## Consequences

- The pin and essential records move from each window's session into a profile store beside `stedding.spaces.registry` (ADR 0016). On the first launch the pins of every restored window merge into it, the same address in the same Space counted once.
- Each window's `SpaceModel` reconciles its tab strip with the store: an asleep tab for each pin it lacks, the tab of a pin removed elsewhere dropped, a wandered pin's tab kept, as before.
- Closing a pin's tab in one window (decision 11) sends that window's tab home; the record stays.
- A Blank Window keeps its own Spaces and pins (G4); a private window has none (private V3).
- Sync (ADR 0029) carries the pinned run per Space (sidebar-file Sf36) from one source instead of the window that wrote last.
- An asleep tab costs no renderer; a window with many pins holds that many asleep tabs.
- The behaviour and its tests are windows G2 and G13–G22.
