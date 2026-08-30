# AGENTS.md — start here

You are an AI agent (or a human) opening this repository cold. This file gives you full
context. Read it before doing anything else. It is model-agnostic and tool-agnostic:
everything you need is in this repo, nothing depends on a particular assistant, session,
or machine.

## What this project is

**Stedding Browser** — a fully open-source, Chromium-based desktop browser with an
Arc-style interface: sidebar with vertical tabs, workspaces, split view, and a command
bar. Built for technical users who want privacy, control, and a modern, productive UI —
without trusting a VC-funded company's roadmap or telemetry.

- Site/domain: **stedding.dev** (owned, DNS on Cloudflare)
- Repo: `ysalitrynskyi/stedding-browser` on GitHub
- License: **BSD-3-Clause** (permissive; closed-source or paid add-ons may exist later,
  the core stays BSD — see `docs/decisions/0005-open-core.md`)
- Started: 2026-08-30

The name: a *stedding* is a haven in Robert Jordan's Wheel of Time where the One Power
cannot touch you. Metaphor: a place to use the web where surveillance and vendor control
cannot reach. The name was chosen after vetting 38 candidates against trademark, SEO,
and pronunciation criteria — full record in `docs/NAMING.md`. We use only the word
itself; no Wheel of Time trademarks, artwork, or claimed affiliation, ever.

## The mandate — read this twice

We are building a **ready-to-use product**, not a tech demo, not a proof of concept,
not a config for enthusiasts. The bar is: a technical user downloads an installer,
opens it, imports their profile, and prefers it to Chrome/Arc within a day. Every
milestone must end in something installable and usable. When choosing between
"interesting" and "shippable and polished", choose shippable and polished.

Concretely (full detail in `docs/QUALITY.md`):

- Every merged change keeps the browser buildable and runnable.
- Features ship complete: keyboard shortcuts, settings entry, edge cases, polish —
  or they don't ship.
- No telemetry by default. Privacy defaults are product features, not afterthoughts
  (`docs/PRIVACY.md`).
- Full Chrome extension compatibility is a hard requirement — it is a top reason to
  base on Chromium at all.

## Technical direction (summary — details in docs/ARCHITECTURE.md)

- Base: **Chromium, stable channel, minimal patch-set fork** (the Brave/Helium model,
  not a hard fork). UI work lives as high in the stack as possible (views/WebUI/top
  chrome) to keep rebases cheap.
- Patches are maintained as an ordered, documented series; tracking upstream stable is
  a recurring scheduled task, not an emergency.
- Considered and rejected: Electron/CEF wrapper (no real extension support, worse
  performance), Firefox base (extension ecosystem, and Zen already owns that lane).
- Target platforms in order: **macOS first, then Windows, then Linux.**

## State of the project

Pre-code. The current phase is documentation and planning — this scaffold. The first
engineering milestone (M0) is reproducing a vanilla Chromium build. See
`docs/ROADMAP.md` for the milestone ladder and acceptance criteria.

## Map of the docs

| File | What's in it |
|---|---|
| `docs/VISION.md` | Why this exists, values, explicit non-goals |
| `docs/PRODUCT.md` | Full feature spec: sidebar, workspaces, split view, command bar, settings, import |
| `docs/ARCHITECTURE.md` | Fork strategy, build system, patch management, updater, signing |
| `docs/ROADMAP.md` | Milestones M0→1.0 with acceptance criteria |
| `docs/QUALITY.md` | The "ready-to-use" bar: performance budgets, release checklist |
| `docs/PRIVACY.md` | Privacy principles and concrete defaults |
| `docs/COMPETITORS.md` | Arc, Dia, Zen, Helium, Vivaldi, Brave, Thorium — and our gap |
| `docs/NAMING.md` | The naming decision record (38 candidates vetted) |
| `docs/BRAND.md` | Name meaning, voice, taglines, trademark hygiene |
| `docs/decisions/` | ADRs — every irreversible decision gets one |
| `CONTRIBUTING.md` | How to contribute |
| `SECURITY.md` | How to report vulnerabilities |

## Conventions for agents working here

- **Write docs and code in plain, correct English.** Terse is fine; cryptic is not.
- **Decisions get ADRs.** Anything hard to reverse (dependency, base version policy,
  naming, licensing) goes in `docs/decisions/NNNN-slug.md` before or with the change.
- **Never commit secrets, machine-specific paths, or personal operational data.**
  This repo is public.
- **Don't fabricate.** No invented benchmarks, dates, user counts, or claims. If a doc
  needs a number we don't have, mark it `TBD`.
- **Keep this file true.** If you change direction (platforms, fork strategy, license),
  update AGENTS.md and the relevant ADR in the same commit.
- Commit messages: conventional, imperative, explain why when it isn't obvious.
- When a task is ambiguous, the tiebreaker is the mandate above: what gets a polished,
  installable browser into users' hands sooner?

## Current priorities (keep this list short and fresh)

1. Complete and refine this documentation scaffold.
2. M0: vanilla Chromium build reproduced on macOS, documented step-by-step in
   `docs/ARCHITECTURE.md` (build section) so any machine/agent can repeat it.
3. Branding patch-set: name, icons, user agent, default settings (M1).
