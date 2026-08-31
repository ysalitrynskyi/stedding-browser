# Evidence: what Arc switchers actually ask for

Product decisions here should be answerable with something better than taste. Zen
Browser is an Arc-style browser on Firefox with a large public issue tracker, and it has
been walking this road for about two years. Its tracker is the closest thing to a
controlled experiment we have: the same users, wanting the same things, voting.

Gathered 2026-08-31 from `github.com/zen-browser/desktop` issues and discussions, and
from Zen's own documentation. Numbers are reaction/upvote counts at that date. **No Zen
source code was read or reused** — Zen is MPL-2.0 and we are BSD-3-Clause; see
`../CONTRIBUTING.md`.

Counts are a demand signal, not a specification. A feature nobody upvoted can still be
essential, and a popular request can still be wrong for this product. Where we go
against the numbers below, we say so.

## The ranking

| Rank | Thing | Signal |
|---|---|---|
| 1 | Vertical sidebar: Spaces, Favorites, pinned tabs, **folders** | Folders discussion **412** upvotes — opener: "If you add this, i think lot of ARC users are going to pass into Zen" |
| 2 | Session restore that never loses a tab | Highest historical bug **182** reactions, 180 comments |
| 3 | Command bar | **203** upvotes for a command palette, plus **136** for "Arc's command bar" |
| 4 | Peek | Shipped by Zen and used; users insist it is **not** Little Arc |
| 5 | Cross-device sync of Spaces and pinned tabs | **475** upvotes, still open after ~two years — the largest single number found |

## What this changes for us

**Folders are the gate, not a nicety.** They were the highest Arc-named request Zen
actually closed, and users said plainly they would not leave Arc without collapsible
*pinned* folders. `PRODUCT.md` has them at 1.0; this says they are not deferrable.

**Session restore is part of the tab model, not a follow-up.** Zen's largest bug cluster
is tab identity across windows, spaces and favorites — restore duplicating favorites,
moving a favorite to a new window silently un-favoriting it. The lesson is sequencing:
build the persistence model *with* the sidebar, not after it. An Arc-style information
architecture without reliable restore loses switchers on day two.

**Independent windows must stay possible.** Zen shipped window syncing without an off
switch and took **155** upvotes asking to disable it by default. Our Blank Window
concept already covers this; the evidence says it is not optional.

**Peek and Little Arc are different products.** Users called them "fundamentally
different workflows" (**87** and **74** upvotes on the related requests). Peek is the
in-window overlay; Little Arc is an independent OS window with a global hotkey for links
from other applications. Building one does not satisfy the other. `PRODUCT.md` specifies
both, which the evidence supports.

**Sync is the largest unmet demand in this space — and we have it out of scope.**
`ROADMAP.md` excludes sync services and `PRIVACY.md` commits to running no accounts.
That is a deliberate position, not an oversight, and this document does not overturn it.
But **475** upvotes on a request nobody has closed in two years is the strongest signal
in this research, and it deserves a real answer rather than silence: end-to-end
encrypted, self-hostable, or file-based export/import are all positions we could take
without running an account system. Flagged in `PRODUCT.md` as needing a decision.

## What this confirms we were right to cut

`decisions/0012-defer-boosts-and-easels.md` deferred Boosts and Easels on the reasoning
that extensions already answer them. The numbers agree, and more strongly than expected:

- **Boosts: 4 upvotes.** Zen shipped this. Almost nobody asked.
- **Easels: 41 upvotes**, with the community calling it extension-shaped and expensive.

Compare 412 for folders and 475 for sync. The two features we cut are, by this evidence,
the two least wanted things on the list.

## What we are deliberately ignoring

**Horizontal tabs: 253 upvotes, and Zen said no.** A large number attached to a request
that would undo the product. If someone wants horizontal tabs there are excellent
browsers for that, and carrying both layouts is a permanent tax — the same reasoning as
`decisions/0010-ride-upstream-vertical-tabs.md`, where the cost of fighting upstream's
layout is measured in commits per year.

**Tree-style tabs: 280 upvotes.** Real demand, different product. Folders first.

**AI features: ~20 upvotes**, with pushback. Not a switch-blocker for anyone, which is
worth knowing given `PRODUCT.md` currently lists the whole Arc Max bundle as needing a
decision.
