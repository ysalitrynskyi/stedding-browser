# What Arc switchers asked for (snapshot, 2026-08-31)

Moved here from `docs/AGENT-LOOP.md` on 2026-11-18, unchanged. The ranking is the 2026-08-31
snapshot; "Where it stands" is as that file last had it. What the product is now:
`docs/PRODUCT.md` and the specs in `docs/features/`.

What Arc switchers asked for, gathered 2026-08-31 from the issues and discussions of
`github.com/zen-browser/desktop` and from Zen's own documentation. Numbers are reaction
and upvote counts on that date. No Zen source was read or reused. Zen is MPL-2.0;
Stedding is BSD-3-Clause (`CONTRIBUTING.md`).

The table is that snapshot. Counts are a demand signal, not a specification. A feature
nobody upvoted can still be essential, and a popular request can still be wrong for
this product. The sections after the table are the product as it stands.

## The ranking

| Rank | Thing | Signal |
|---|---|---|
| 1 | Vertical sidebar: Spaces, Favorites, pinned tabs, **folders** | Folders discussion **412** upvotes — opener: "If you add this, i think lot of ARC users are going to pass into Zen" |
| 2 | Session restore that never loses a tab | Highest historical bug **182** reactions, 180 comments |
| 3 | Command bar | **203** upvotes for a command palette, plus **136** for "Arc's command bar" |
| 4 | Peek | Shipped by Zen and used; users insist it is **not** Little Arc |
| 5 | Cross-device sync of Spaces and pinned tabs | **475** upvotes, still open after ~two years — the largest single number found |

Workspace-adjacent requests are the top cluster. Folders were the highest Arc-named
request, and users said they would not leave Arc without collapsible pinned folders.

## Where it stands

**Folders ship**, including a folder in the pinned run (`docs/features/folders.md` F38).
`PRODUCT.md` marks them [1.0] and not deferrable.

**Session restore ships with the sidebar** (`docs/features/spaces.md` B2, B9). The
snapshot's largest bug cluster was tabs lost across windows, spaces and favorites.

**A Blank Window has Spaces of its own** (`docs/features/windows.md` G4): ⌥⇧⌘N on the
Mac, Ctrl+Alt+Shift+N on Windows (`docs/SHORTCUTS.md`). The snapshot had **155** upvotes
asking to turn synced windows off by default.

**Peek and a little window are different, and both ship** on macOS and Windows. The
related requests had **87** and **74** upvotes. Peek is a little window over the pinned
tab's window, on by default (`PLAN.md` decision 2), released in 0.3.0 beta 16
(`docs/features/peek.md`, `S-93`). A little window is its own window for a link from
another application: on the Mac from the start, on Windows since 0.3.0 beta 7
(`docs/features/little.md`).

**Sync has no Stedding account and no Stedding server** (`docs/ROADMAP.md`,
`docs/PRIVACY.md`). The answer to the **475** is a folder the user's own sync tool
keeps: the sidebar syncs through it, off by default
(`docs/decisions/0029-sidebar-sync-through-a-folder.md`, released in 0.3.0 beta 16; the owner's acceptance of the ADR is still open). A Space also exports and imports as a file. What is still owed
is `S-282`.

## Deferred

Boosts and Easels stay deferred (`docs/decisions/0012-defer-boosts-and-easels.md`,
`docs/ROADMAP.md`). Extensions already answer Boosts.

- **Boosts: 4 upvotes.** Zen shipped this. Almost nobody asked.
- **Easels: 41 upvotes**, with the community calling it extension-shaped and expensive.

The same snapshot has 412 for folders and 475 for sync.

## Decisions around the ranking

**Horizontal tabs: 253 upvotes, and Zen declined.** Chromium's own switch stays
(`PLAN.md` decision 1). Spaces, pins and folders work in horizontal mode. Stedding
builds no horizontal layout of its own
(`docs/decisions/0010-ride-upstream-vertical-tabs.md`).

**Tree-style tabs: 280 upvotes.** Folders shipped. A link opened in a new tab is drawn under its opener only while "Show tabs under the tab that opened them" is on (`docs/features/tabs.md` R56–R59, settings T26, `S-92`). That setting is off by default, and while it is off a new link is no one's child. Back at a child's first
page, which closes the child, is still open (R60).

**A bundled model: ~20 upvotes**, with pushback. ADR 0020: Stedding ships no bundled
model.
