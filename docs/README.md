# Documentation

Everything under `docs/`, grouped by who it is for.

## For users

| Document | Contents |
|---|---|
| [INSTALL.md](INSTALL.md) | Installing on macOS and Windows, verifying the checksum, updating, uninstalling, where your data lives |
| [SHORTCUTS.md](SHORTCUTS.md) | Every keyboard shortcut, macOS and Windows, and where Stedding differs from Chromium |
| [FAQ.md](FAQ.md) | Questions and answers |
| [PRIVACY.md](PRIVACY.md) | The privacy principles and every network connection the browser makes |
| [release-notes/](release-notes/) | What each release changed, with checksums |

## About the project

| Document | Contents |
|---|---|
| [VISION.md](VISION.md) | Why this exists, values, explicit non-goals |
| [ROADMAP.md](ROADMAP.md) | Milestones from zero to 1.0, with acceptance criteria and where each stands |
| [PRODUCT.md](PRODUCT.md) | The full feature specification: sidebar, Spaces, split view, command bar, settings, import |
| [COMPETITORS.md](COMPETITORS.md) | Arc, Dia, Zen, Helium, Vivaldi, Brave, Thorium — and the gap Stedding fills |
| [EVIDENCE.md](EVIDENCE.md) | What Arc switchers actually ask for, with counts |
| [NAMING.md](NAMING.md) | How the name was chosen |
| [BRAND.md](BRAND.md) | Name meaning, voice, taglines, trademark hygiene |
| [QUALITY.md](QUALITY.md) | The "ready-to-use" bar: performance budgets, release checklist |
| [UI-SPEC.md](UI-SPEC.md) | The measured match to Arc's interface, item by item |
| [ARC-ROUND2.md](ARC-ROUND2.md) | The ledger of what real use turned up on each build, round by round, and what changed |
| [../BACKLOG.md](../BACKLOG.md) | The one list of open work |

## For contributors and AI agents

| Document | Contents |
|---|---|
| [../AGENTS.md](../AGENTS.md) | Start here: the project in one file, state, conventions, priorities |
| [HANDOFF.md](HANDOFF.md) | Where things live, the dev parameters, the traps already paid for |
| [AGENT-LOOP.md](AGENT-LOOP.md) | The working procedure: research → spec → failing test → implement → build → test → capture → patch |
| [ARCHITECTURE.md](ARCHITECTURE.md) | Fork strategy, the build, patch management, branding, updater, signing, measured numbers |
| [features/](features/) | One specification per feature; each behaviour has a test. The definition of done |
| [decisions/](decisions/) | Architecture decision records |
| [IMPLEMENTATION.md](IMPLEMENTATION.md) | How each feature is built and what upstream already provides |
| [ROUND6-PLAN.md](ROUND6-PLAN.md) | Round 6, the Zen-mods review: the plan and how each part landed |
| [perf/](perf/) | The performance harness and the first vanilla comparison |
| [../tooling/README.md](../tooling/README.md) | The build, capture and release scripts |
| [../branding/README.md](../branding/README.md) | The mark, the palette, and how the assets are generated |
| [../CONTRIBUTING.md](../CONTRIBUTING.md) · [../SECURITY.md](../SECURITY.md) | How to contribute; how to report a vulnerability |

`images/` holds the captures the docs show; `tooling/check-geometry` re-measures the
ones the interface spec depends on.
