# Stedding Browser

A fully open-source, Chromium-based desktop browser with an Arc-style interface:
sidebar with vertical tabs, workspaces, split view, and a command bar.

## Why

Arc showed that a browser built around a sidebar, workspaces, and keyboard-driven
navigation is a genuinely better way to work — and then its future was decided by a
VC-funded company's pivot. Stedding takes that workflow and rebuilds it on ground the
user controls: a minimal patch-set fork of Chromium stable, fully open source under
BSD-3-Clause, with full Chrome extension compatibility and no telemetry by default.
It is aimed at technical users who want privacy, control, and a modern, productive UI
without trusting anyone's roadmap but their own.

A *stedding* is a haven where outside power cannot reach — the name is a metaphor for
using the web without surveillance or vendor control. See `docs/NAMING.md`.

## Status

**M0 in progress — nothing installable yet.** The repository holds the project's
documentation and the build tooling in `tooling/`: scripts that check out Chromium at
a pinned version, build it, verify the result, and measure it. What does not exist yet
is a browser you can download.

The first engineering milestone (M0) is reproducing a vanilla Chromium build on macOS
and documenting it well enough that anyone can repeat it. See `docs/ROADMAP.md` for
the milestone ladder and `docs/ARCHITECTURE.md` for the build.

If you are evaluating browsers to use today, this is not one yet. If you want to
follow or shape the design before the product exists, this is the right time.

## Planned features

- **Sidebar with vertical tabs** — the primary tab surface, collapsible, drag-and-drop.
- **Workspaces** — separate tab sets and contexts you can switch between instantly.
- **Command bar** — keyboard-first navigation and actions across tabs, history, and commands.
- **Split view** — two or more pages side by side in one window.
- **Full Chrome extension support** — a hard requirement, not a roadmap item; it is a
  top reason for basing on Chromium at all.
- **Privacy defaults** — tracking protection on, no calling home, privacy treated as a
  product feature (`docs/PRIVACY.md`).
- **No telemetry by default** — nothing is collected unless the user explicitly opts in.

The full feature specification lives in `docs/PRODUCT.md`.

## Principles

- **Open source, BSD-3-Clause.** The core browser is and stays permissively licensed.
  Closed or paid add-ons may exist later; the browser itself does not depend on them.
- **User control.** Your data, your defaults, your machine. No account required, no
  server-side dependency for core features.
- **No ads, no crypto, ever.** The browser will never bundle advertising, sponsored
  content, or cryptocurrency features.
- **Ship polished or not at all.** Every milestone ends in something installable and
  usable. Features ship complete — shortcuts, settings, edge cases — or they wait.

## Technical direction

Minimal patch-set fork of Chromium stable (the Brave/Helium model, not a hard fork).
UI changes live as high in the stack as possible to keep rebases against upstream
cheap and routine. Target platforms in order: macOS, then Windows, then Linux.
Details in `docs/ARCHITECTURE.md`.

## Documentation

| Document | Contents |
|---|---|
| [AGENTS.md](AGENTS.md) | Canonical project context — start here |
| [CLAUDE.md](CLAUDE.md) | Pointer to AGENTS.md for Claude Code sessions |
| [docs/VISION.md](docs/VISION.md) | Why this exists, values, explicit non-goals |
| [docs/PRODUCT.md](docs/PRODUCT.md) | Full feature spec: sidebar, workspaces, split view, command bar, settings, import |
| [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) | Fork strategy, build system, patch management, updater, signing |
| [docs/ROADMAP.md](docs/ROADMAP.md) | Milestones M0 → 1.0 with acceptance criteria |
| [docs/QUALITY.md](docs/QUALITY.md) | The "ready-to-use" bar: performance budgets, release checklist |
| [docs/PRIVACY.md](docs/PRIVACY.md) | Privacy principles and concrete defaults |
| [docs/COMPETITORS.md](docs/COMPETITORS.md) | Arc, Dia, Zen, Helium, Vivaldi, Brave, Thorium — and our gap |
| [docs/NAMING.md](docs/NAMING.md) | The naming decision record |
| [docs/BRAND.md](docs/BRAND.md) | Name meaning, voice, taglines, trademark hygiene |
| [docs/decisions/](docs/decisions/) | Architecture decision records (ADRs) |
| [CONTRIBUTING.md](CONTRIBUTING.md) | How to contribute |
| [SECURITY.md](SECURITY.md) | How to report vulnerabilities |

**For AI agents and new contributors:** start with [AGENTS.md](AGENTS.md). It is the
canonical context file for this repository and is kept current as decisions change.

## License

[BSD-3-Clause](LICENSE).
