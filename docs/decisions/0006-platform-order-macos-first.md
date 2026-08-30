# 0006 — Platform order: macOS, then Windows, then Linux

Status: Accepted
Date: 2026-08-30

## Context

A one-team browser cannot ship three platforms at once to the quality bar in
`../QUALITY.md` — every milestone must end installable and polished. An explicit
order is needed so milestones, CI, and signing infrastructure are built in the
right sequence instead of three half-finished ports. Chromium itself supports all
three targets well, so the constraint is our capacity, not the engine.

## Decision

Target platforms ship in this order:

1. **macOS first.** It is the primary development machine, so the edit-build-test
   loop is fastest there, and it is where Arc's audience — the users most likely to
   want an Arc-style browser after Arc's deprioritization — predominantly lives.
2. **Windows second.** The largest desktop population; comes after the product has
   proven itself on macOS.
3. **Linux third.** Overlaps most with users willing to build from source in the
   meantime, and its packaging landscape (deb/rpm/Flatpak) is the most work per
   user reached.

The order governs sequencing of installers, code signing, and updater work — it is
not a statement that any platform is out of scope. Cross-platform correctness is
still required in patches from day one (no `#ifdef` walls around features).

## Consequences

- M0–M1 build and release tooling targets macOS only; Windows and Linux CI come
  later, per `../ROADMAP.md`.
- Apple signing and notarization become the first distribution problem to solve.
- Windows and Linux users wait; we accept the community cost and say so publicly
  rather than promising dates we cannot keep.
- Patches that would bake in macOS-only assumptions are rejected in review even
  while macOS is the only shipping target.
