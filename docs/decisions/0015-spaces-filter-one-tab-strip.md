# 0015 — Spaces filter one tab strip; they do not park tabs

Status: Accepted
Date: 2026-08-31

## Context

Spaces are the feature people name when they say why they stay in Arc, and
`EVIDENCE.md` records workspace-adjacent requests as the top cluster on the
comparable project. `docs/UI-SPEC.md` puts the space switcher at the top of the
sidebar. The switcher is currently unbuilt, deliberately: a row of pills that
changes an active id without moving any tabs is a picture of a feature, and the
mandate in `AGENTS.md` says features ship complete.

So the real question is what a space *is* to the tab model. Three candidates:

**A. Parking.** On switch, detach the outgoing space's tabs from the tab strip
and hold them; insert the incoming space's tabs.

**B. Filtering.** Every tab stays in the one tab strip and carries a space id.
The sidebar shows only the active space's tabs.

**C. A collection type.** Add `SPACE` to the tab collection tree in
`components/tabs/`, so `TABSTRIP` holds `SPACE` collections which in turn hold
`PINNED` and `UNPINNED`.

## Decision

**B. One tab strip, every tab tagged with a space id, filtered for display.**

## Why not A

Parking loses tabs on restart, and it does so silently.

`SessionServiceBase` does not only append commands. Every `kWritesPerReset`
(250) writes it compacts the log by *rebuilding* it from the live browser —
`BuildCommandsForBrowser` walks the tab strip that exists right now. A parked
tab is not in that tab strip. It survives in the log only until the next
compaction, and then it is gone, with no error and nothing in the UI to suggest
anything was lost. A user with five spaces would find four of them quietly
emptied after a long session.

Working around that means teaching the session service about a second place
tabs can live, which is a patch into exactly the kind of upstream machinery
`ARCHITECTURE.md` says to stay out of.

## Why not C

C is the tidier model, and it is where this should end up if the tab strip ever
grows a real notion of tab sets. Today it is a deep change: `TabCollection`
subclasses declare strict `supported_child_collections_` allow-sets, and
`TABSTRIP` currently accepts `PINNED` and `UNPINNED` directly. Inserting a layer
between them moves every index calculation in the tab strip model, which is the
most invariant-heavy code we would be touching. That is a large, risky change
bought for a structural nicety users cannot see.

Folders went the other way — ADR 0013 made them a collection type — because a
folder genuinely nests inside the strip and needs the tree's containment rules.
A space contains the whole strip, which is the opposite shape.

## Consequences

Good:

- Session restore works with no session-service patch at all. Every tab is in
  the live tab strip at every moment, so compaction rebuilds all of them. The
  space id rides along in the per-tab `extra_data` channel that already exists.
- The change is confined to code we already own or already patch: a space id on
  the tab, a filter in the sidebar, and the switcher.
- Closing a window still closes its tabs, including the spaces not on screen,
  which is what a window closing should mean.

Costs, accepted:

- `TabStripModel` still holds every space's tabs, so anything that walks it by
  index sees tabs the user cannot currently see. Ctrl+Tab, ⌘1–⌘9 and next/
  previous tab must be made space-aware explicitly; they will not be correct by
  default. This is the main work this decision creates, and the main thing to
  test.
- `tab_strip_model()->count()` is a count across all spaces. Anything user-facing
  that reports a tab count needs to say which it means.
- Tab search deliberately keeps searching every space, matching Arc.

## Removable when

The tab collection tree grows a first-class notion of tab sets, at which point
this becomes option C and the filter turns into a tree walk.
