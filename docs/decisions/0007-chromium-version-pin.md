# 0007 — Chromium version pin: newest stable, single source of truth

Status: Accepted
Date: 2026-08-30

## Context

ADR 0003 chose Chromium stable as the base. That settles the *channel*, not the
*pin*: at any moment several stable versions exist at once. On 2026-08-30 the Mac
stable channel carried three live milestones — M153 (`153.0.8010.12`, rolling out),
M152 (`152.0.7977.65`), and M151 (`151.0.7922.176`, extended stable). A fork has to
say which one it builds, where that answer is written down, and when it moves.

Getting this wrong is expensive in a specific way: the patch series is rebased
against the pin, so a pin that lags means every rebase carries more upstream drift,
and — per the security gate in `../QUALITY.md` — a lagging pin means shipping known
vulnerabilities.

## Decision

**Pin to the newest version on the Chromium stable channel for our platforms**, held
in exactly one place: `tooling/chromium-version`. Every script and build reads the pin
from that file, and `tooling/check-repo version` fails if any non-documentation file
hard-codes a version. Prose may quote the current pin where it aids the reader; code
and configuration may not, because those are what silently go stale.

- The initial pin is `153.0.8010.12` (M153).
- Security point releases move the pin on the timetable in `../QUALITY.md` (7 days
  for in-the-wild exploits, 14 otherwise).
- **Extended stable is not our channel.** It trades feature currency for enterprise
  change-management we do not need, and it eventually stops receiving fixes.
- Moving the pin is always its own commit, recording the version, the upstream
  commit, and the result of applying the patch series.
- The pin may be held back only for a named, fixed blocker, recorded in the commit
  that holds it. "Not got to it yet" is not a blocker.

## Consequences

- One grep answers "what are we built on"; provenance is checkable from any build.
- Adopting a milestone during its rollout means occasionally hitting bugs the wider
  population has not — acceptable pre-1.0, and the alternative is a permanent lag.
- Rebases are frequent and small rather than rare and large, which is the whole
  premise of the minimal patch series in ADR 0003.
- We inherit upstream's deprecation timing rather than deferring it, so patches that
  depend on soon-to-be-removed upstream surfaces break early, when they are cheap
  to fix.
