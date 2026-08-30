# Vision

Stedding Browser is a fully open-source, Chromium-based desktop browser with an
Arc-style interface: a sidebar with vertical tabs, workspaces, split view, and a
command bar. It is built for technical users who want privacy, control, and a
modern, productive UI — without betting their daily workflow on a company's
pivot, acquisition, or monetization plan.

This document explains why the project exists, what it values, who it is for,
and — just as important — what it will never be.

## Why this exists

Arc proved something: a browser organized around a sidebar, workspaces, and a
command bar is a genuinely better way to work than a row of horizontal tabs.
People who adopted that model rarely wanted to go back.

Then its maker moved on. The Browser Company shifted its attention to Dia, its
AI-centric browser, and stopped building Arc forward. Arc was never open
source, so nobody outside the company could pick it up. Users who had
reorganized their working lives around that interface were left with a product
in maintenance and no exit that preserved their workflow.

Look at the alternatives and there is a gap:

- Arc is closed source and no longer the focus of its maker.
- Zen carries a similar spirit but is built on Firefox, which rules out the
  Chrome extension ecosystem many technical users depend on.
- Vivaldi is powerful but its UI layer is proprietary.
- Brave is open source but bundles crypto and rewards features, and its UI is
  conventional Chrome.
- Helium (de-Googled) and Thorium (performance-focused) are minimal Chromium
  forks that keep Chrome's UI; neither rethinks the interface.

A fuller comparison lives in `docs/COMPETITORS.md`. The short version: **no
fully open, permissively licensed Chromium browser carries the Arc workflow
model forward.** That is the gap Stedding fills.

Because the core is BSD-3-Clause, this cannot happen to Stedding's users the
way it happened to Arc's. If the maintainers lose interest, pivot, or sell,
anyone can fork the browser and keep going. The license is the exit that Arc
never gave anyone.

## What we are building

A minimal patch-set fork of Chromium stable (the Brave/Helium model, not a hard
fork), with the UI work kept as high in the stack as possible so tracking
upstream stays cheap. Full Chrome extension compatibility is a hard
requirement. macOS first, then Windows, then Linux.

The product bar is fixed: every milestone ends in something installable, and
features ship complete — shortcuts, settings, edge cases, polish — or they do
not ship. Details in `docs/PRODUCT.md`, `docs/ARCHITECTURE.md`, and
`docs/QUALITY.md`.

## Values

**User control.** The browser answers to the person using it. Defaults are
opinionated, but everything meaningful is configurable, and nothing phones home
to ask permission. Your profile, your data, your machine.

**Privacy by default.** No telemetry unless you turn it on. Privacy protections
are product features with the same quality bar as everything else, not
checkbox settings buried three menus deep. Concrete commitments are in
`docs/PRIVACY.md`.

**Openness.** The entire browser is developed in public under BSD-3-Clause.
Decisions that are hard to reverse get written down as ADRs in
`docs/decisions/` before or with the change. Closed or paid add-ons may exist
someday, but the core browser — everything needed to build, run, and fork it —
stays permissively licensed.

**Craft.** Shipping polished beats shipping first. A feature that is 90% done
is 0% done. Performance, keyboard support, and detail work are part of the
definition of every feature, not a later pass.

## Who it is for

Technical users: developers, researchers, power users — people who live in
their browser all day, keep dozens of tabs across several projects, rely on
extensions, and notice when software wastes their time. People who read a
privacy policy, or would rather use software that makes reading one
unnecessary.

It is emphatically for former Arc users who want that workflow back on a
foundation nobody can take away.

It is not, at least initially, aimed at users who want a browser that manages
itself. Stedding is opinionated and rewards investment. The defaults will be
good, but the payoff is in the workspaces, the command bar, and the keyboard.

## Non-goals

These are commitments, not omissions. Absence from this list is not a promise;
presence on it is.

- **No crypto or web3 features.** No wallet, no tokens, no rewards program, no
  blockchain integration of any kind. Users who want these can install
  extensions.
- **No ads or sponsored placements, ever.** No sponsored tiles, no paid default
  shortcuts, no affiliate-injected results, no "partner" content. The new tab
  page belongs to the user.
- **No AI gimmicks bolted on.** Any AI-assisted feature must be opt-in,
  clearly labeled, and off by default. Nothing sends page content or browsing
  data to a model without an explicit action by the user. Dia exists for people
  who want an AI browser; Stedding is not that.
- **No mobile, initially.** Desktop (macOS, Windows, Linux) is the whole scope
  until 1.0 is shipped and stable. A mobile browser is a different product with
  different constraints, and doing it badly would violate the quality bar.
- **Not a Chrome re-skin.** Stedding is an opinionated workflow browser. The
  point is the sidebar, workspaces, split view, and command bar — a different
  way of working. If a change merely recolors Chrome, it is not worth a patch.

## What success looks like

A technical user downloads an installer, opens it, imports their profile, and
prefers it to Chrome or Arc within a day. Every milestone on the way there ends
in something installable (`docs/ROADMAP.md`).

We do not measure success in user counts we would have to invent. The project
succeeds when it is someone's daily browser and they stop thinking about it —
and when, if this project ever ends, its users are not stranded.
