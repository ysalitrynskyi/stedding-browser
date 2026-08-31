# 0011 — The product target is full functional parity with Arc

Status: Accepted
Date: 2026-08-30

## Context

ADR 0010 established that Chromium now ships vertical tabs by default, and left an
open question: if the sidebar alone no longer differentiates, what is this project for?

The answer, from the operator, is that the target is **full functional parity with
Arc** — not the subset of Arc ideas that `PRODUCT.md` currently specifies.

That reframes the project. Stedding is not "a browser with some Arc-like ideas". It is
Arc's workflow, rebuilt on ground the user controls. The differentiation was never
going to be any single feature; it is the whole workflow *plus* the things Arc could
not offer: open source under BSD, no telemetry, no vendor able to discontinue it.

One fact makes this tractable. **Arc is frozen.** Its maker put it in maintenance mode
in May 2025 and moved to Dia (`../COMPETITORS.md`). Parity with a live product is a
race you cannot finish; parity with a product that has stopped moving is a finite
amount of work. The target will not run away.

## Decision

Stedding targets **full functional parity with Arc as it actually shipped**, using
Arc's own terminology for its concepts.

- `PRODUCT.md` is rewritten from a verified inventory of Arc's shipped features, taken
  from Arc's own documentation rather than from recollection.
- Where a feature depends on Arc's hosted services — anything requiring their account,
  sync, or servers — parity means the local capability, not the service. Those are
  called out individually rather than quietly dropped.
- Arc's terminology is kept where it names a real concept (Spaces, Split View, Little
  Arc, Boosts, Easels). Inventing our own names for the same ideas would make the spec
  harder to check against the thing it is copying. Trademarked branding is not reused
  — see `../BRAND.md`.
- Parity is the floor, not the ceiling. It does not preclude doing better, but "better"
  never justifies shipping less.

## Consequences

- The roadmap grows substantially. M2–M6 as written cover a fraction of Arc; the
  milestone ladder needs restructuring against the inventory, and it is dishonest to
  leave a roadmap in place that implies parity is close.
- 1.0 acquires a concrete definition it did not have: parity with a fixed target, at
  the quality bar in `../QUALITY.md`. That is a harder gate than "no open blockers",
  and a more meaningful one.
- Features that were open questions become requirements — Boosts, Easels, Little Arc,
  the archive model — several of which are substantial products in themselves.
- Some Arc behaviour is hosted, and honest parity means saying so where a local
  equivalent is not possible, rather than claiming a checkbox.
- ADR 0010 stands unchanged: riding upstream's vertical tabs is still correct, and is
  now more clearly a means rather than the point.
