# 0035 — Pins and essentials in every window

Status: Proposed, for the owner's decision (BACKLOG S-94, GitHub issue 111). Nothing is built until the owner chooses.
Date: 2026-11-13

## Context

A second window of a profile shares the Space list: names, icons, colours and order (`docs/features/windows.md` G1, ADR 0016). Its pinned tabs and essentials do not follow. A pin is a real tab of the window that holds it, and a new window starts with none (G2). GitHub issue 111 reports this as the first thing a person from Arc notices: "When opening a new window on macOS, all pins and tabs from the original window are missing."

Arc shows the same pinned tabs in every window. Its release notes for macOS say so twice: on 2023-05-31, "Windows in Arc now have unique Unpinned Tabs. Pinned tabs will still sync across Windows and devices", and on 2023-08-24, "Unpinned tabs will now sync across all windows and all devices. Back by popular demand!" (resources.arc.net, "Arc for macOS - 2023 Release Notes"). Arc's later behaviour for unpinned tabs is not part of this decision.

Today a pin's record (its home address, its own name, its folder, its place in the pinned run) lives in the window's session: each tab carries its Space and pin as session extra data, and a rebuild writes them back (G3). Choosing a page open in another window already asks Show Here, Go to Window or Cancel (G12), so a page is never shown in two windows at once.

## Decision

Proposed: **B**, below, once the owner agrees. The three ways considered:

**A. Ghost rows.** Every window lists every pin, but a pin stays one tab in one window. In the other windows its row is a ghost: choosing it asks, as G12 does, to show it here (the tab moves) or go to its window. One page per pin, so nothing is loaded twice, and the session format barely changes. A pin still lives in one window at a time, and moving it moves the page out of the window that had it, which is not what Arc does.

**B. One pin, a tab in each window.** The pinned run and the essentials become the profile's, kept beside the Space registry: each pin is one record (Space, home address, own name, folder, place). Every window shows every pin, and each window has its own tab for it, asleep until chosen in that window. Choosing a pin in two windows loads it in both, as two pages, each with its own history, as Arc does. Pinning, unpinning, renaming, moving a pin or a folder of pins, and sending a pin home change the record, and every window follows at once. Unpinned tabs stay each window's own.

**C. B, and unpinned tabs shared too.** As Arc's August 2023 change. Every window would show every tab, which is what a second window is usually opened to avoid; the reports Stedding has had (issue 111) ask for pins, not loose tabs.

Why B: it is what someone leaving Arc expects of a second window, and it keeps G12 for loose tabs. The pinned run already behaves as a record with a home (pins H3, H16, decision 11); B gives that record one home for the profile instead of one per window.

## Consequences

If B is chosen:

- The pin and essential records move from each window's session into a profile store beside `stedding.spaces.registry` (ADR 0016), with a migration: on first launch the pins of every restored window merge into it, the same address in the same Space counted once.
- Each window's `SpaceModel` reconciles its tab strip with the store: it makes an asleep tab for each pin it lacks, drops the tab of a pin removed elsewhere, and keeps a pin's tab that is open and has wandered from its home, as today (pins H-rows).
- Closing a pin's tab in one window (decision 11) sends that window's tab home; the record stays.
- A Blank Window keeps its own Spaces and its own pins (G4); a private window has none (private V3).
- Sync through a folder (ADR 0029) already carries the pinned run per Space (sidebar-file Sf36); with one store per profile it has one source instead of the window that wrote last.
- Memory: an asleep tab costs no renderer; a window with many pins holds that many asleep tabs, as the first window does today.
- Tests to come with it: a second window shows the first window's pins and essentials; a pin renamed, moved, unpinned or added in one window changes in the other at once; a pin opened in both windows has two pages; a restart restores one store, not one per window; the migration merges two windows' pins without duplicates.
