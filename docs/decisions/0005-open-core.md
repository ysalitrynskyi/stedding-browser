# 0005 — Open core: the browser stays BSD forever

Status: Accepted
Date: 2026-08-30

## Context

The project has no revenue model yet, but a browser is expensive to maintain
indefinitely, and pretending money will never matter is how projects either die or
surprise their users with a rug-pull. The sustainability question had to be answered
in writing before the first user shows up, so the promise is on record and dated.
The license (BSD-3-Clause, ADR 0002) was chosen to keep every option open.

## Decision

Stedding is **open core**:

- The browser — everything needed to build, install, and use the full product
  described in `../PRODUCT.md` — is and stays **BSD-3-Clause, forever**. No feature
  that exists in the core moves behind a paywall or a closed license later.
- Closed-source or paid features are **permitted**, but only as separate add-ons or
  services layered on top of the core (for example, a paid sync service or premium
  extensions), clearly labeled, and never bundled in a way that degrades the core
  for people who decline them.
- Paid or closed features must never come at the cost of crippling the open core.
  If a capability is table stakes for a browser, it belongs in the core.

No paid product exists today and none is planned for a specific date; this ADR
records the boundary, not a roadmap.

## Consequences

- Users and contributors can rely on the core staying fully open; this promise is
  citable and dated, and reversing it would be a public breach of trust.
- A future revenue path exists without relicensing or a contributor CLA fight.
- Every future feature must be classified: core (BSD, in-repo) or add-on (may be
  closed/paid, separate). Ambiguity defaults to core, per the rule above.
- Forks can ship the entire core commercially under BSD terms; we accept that.
