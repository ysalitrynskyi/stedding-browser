# 0028 — A Space with its own session has its own essentials

Narrows ADR 0019. “Essentials stay on the default partition” now holds for shared essentials only. The current rule is `docs/features/spaces.md` B6 and `docs/features/sessions.md` S8.

Status: Accepted (the owner, 2026-10-22; GitHub issue 8). Amended by [ADR 0034](0034-spaces-that-share-a-named-session.md), accepted 2026-11-10: the Spaces of one session share their own essentials.
Date: 2026-10-22

## Context

Essentials are Chromium’s pinned tabs of a window, shown above every Space’s list (spaces B6). ADR 0019 kept them on the profile’s shared cookie jar, because they are in every Space. Pinning a page from a Space with its own session (sessions S32) reloaded it in the shared jar. A user asked for essentials per Space (GitHub issue 8).

## Decision

Essentials stay shared, except in a Space with its own session.

- A tab pinned in a Space with its own session is that Space’s own essential. It stays in the Space’s jar and shows in that Space alone. That Space shows its own essentials and no shared one. Every other Space shows the shared ones.
- When every Space has a session of its own, the shared essentials show in each, so they can always be reached. Choosing a shared essential from a Space that does not show it brings the first Space that does.
- Turning a Space’s session off makes its own essentials that Space’s pinned tabs, with their homes, in the shared jar. A deleted Space’s own essentials go with its tabs to the Space that takes them, and become pinned tabs there unless that Space has a session of its own.
- The session marks an essential that is its Space’s own (`stedding.own_essential`, beside the Space’s key), so a restart puts it back in its Space’s jar.

The warning in sessions S33, and its setting (settings T25), are withdrawn. An essential pinned in such a Space no longer leaves the Space’s session.

## Consequences

- Code that chose a jar from the pin bit asks whether the tab is a shared essential or the Space’s own (`SpaceModel::IsSharedEssential`, `SpaceModel::IsOwnEssential`, the restored-tab jar helpers, the navigation throttle, the rebinds). The essentials grid lays out only the cards the Space shows.
- Export writes a Space’s own essentials with that Space (`docs/features/sidebar-file.md` Sf6, patch 0090).
- The Arc importer still brings Favorites in as shared essentials, capped at twelve (import I11). Arc’s per-Space profile binding is not imported (import I8).
