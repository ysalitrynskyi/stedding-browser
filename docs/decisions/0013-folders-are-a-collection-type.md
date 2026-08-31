# 0013 — Folders are a new collection type, not nested tab groups

Status: Accepted
Date: 2026-08-31

## Context

Arc's Folders are named, collapsible containers of tabs that live in the sidebar, nest,
and never auto-archive. `PRODUCT.md` puts them at 1.0, and `EVIDENCE.md` records that
they were the single highest Arc-named request on the comparable project — the thing
users said kept them on Arc.

Chromium 153 has a tab **collection tree** (`components/tabs/`): `TabCollection` with
`PINNED`, `UNPINNED`, `GROUP` and `SPLIT` subclasses, each declaring which child
collection types it accepts. Nesting is already real — `SPLIT` lives inside `GROUP`.

The obvious cheap move is to let `GROUP` contain `GROUP`. The allow-list is one line
(`components/tabs/impl/tab_group_tab_collection.cc:16-24`), and after changing it the
tree accepts nested groups and everything compiles.

It also silently corrupts.

`TabModel::UpdateProperties` (`chrome/browser/ui/tabs/tab_model.cc:386-412`) walks a
tab's ancestors and, for each `GROUP` it passes, overwrites the tab's group id. The
**outermost** group therefore wins, and inner membership disappears from `GetGroup()`,
from session restore, from saved tab groups, and from every consumer that asks a tab
which group it belongs to. Nothing fails loudly.

Beyond that, roughly twenty-five sites assume a group is a contiguous `gfx::Range` and
that a tab has at most one group: `TabGroup::ListTabs` requires contiguity by contract,
`EnsureGroupContiguity`, `MoveGroupToImpl`, `GetSurroundingTabGroup` (which infers
membership from neighbour equality), the sessions command format
(`kCommandSetTabGroup`, one token per tab), and the saved-tab-group sync path, which
zips saved tabs against the range with a length `CHECK`.

## Decision

**A Folder is `TabCollection::Type::FOLDER`, a new collection type**, not a nested
group. Chrome's tab groups are left exactly as they are, as a sibling concept under
`UNPINNED`.

- `FolderTabCollection` accepts `FOLDER` and `SPLIT` children and holds tabs, so
  folders nest and may contain splits. It does not accept `GROUP`.
- Identity is a `FolderId` (its own `TokenId`, not comparable to `TabGroupId`), carried
  in session `extra_data` rather than in the group commands.
- `UNPINNED` gains `FOLDER` in its allow-list, so folders sit beside groups.

## Consequences

- None of the twenty-five contiguity and single-group assumptions are disturbed. Groups
  keep working as they do upstream, and saved tab groups are untouched.
- The cost is small and in cheap places: the type enum
  (`components/tabs/public/tab_collection.h`, 20 commits/year), its mirror in the views
  layer (2/year), the `UNPINNED` allow-list (0/year), and two `BUILD.gn` files. The
  compiler's exhaustive `switch` checking found exactly two call sites needing the new
  case, which is the type system doing its job.
- Folders are ours to maintain. They will not be synced by saved tab groups and will not
  appear in group APIs — correct, since they are not groups, but it means anything that
  should know about folders must be taught explicitly.
- If upstream ever ships its own folder concept, this is the seam where we would drop
  ours. That is the `Removable when:` condition on the patch.
