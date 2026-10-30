# Documentation

Everything under `docs/`, grouped by who it is for.

## For users

| Document | Contents |
|---|---|
| [INSTALL.md](INSTALL.md) | Installing on macOS (Apple silicon) and Windows: the checksum, updating, uninstalling, and where your data lives. Linux is not shipped yet |
| [SHORTCUTS.md](SHORTCUTS.md) | Every shortcut Stedding adds or changes, on macOS and Windows, and where it differs from Chromium |
| [FAQ.md](FAQ.md) | Questions and answers: the project, installing and updating, using it (including what Stedding has that Arc did not, and the reverse), privacy, and contributing |
| [PRIVACY.md](PRIVACY.md) | The privacy principles, and every network connection the browser makes |
| [release-notes/v0.4.0-beta.2.md](release-notes/v0.4.0-beta.2.md) | What the current release changed, with checksums. Earlier releases are on the [Releases page](https://github.com/ysalitrynskyi/stedding-browser/releases) |
| [../LICENSE](../LICENSE) | The BSD-3-Clause licence |

## About the project

| Document | Contents |
|---|---|
| [VISION.md](VISION.md) | Why this exists, the values and non-goals, the name, the brand and voice, and the competitors |
| [ROADMAP.md](ROADMAP.md) | Milestones from zero to 1.0, with acceptance criteria, and the quality bar: performance budgets and the release checklist |
| [PRODUCT.md](PRODUCT.md) | The feature specification: Arc parity, what goes beyond it, where each feature lives, and the UI spec |
| [../BACKLOG.md](../BACKLOG.md) | The open work |

## For contributors

| Document | Contents |
|---|---|
| [../AGENTS.md](../AGENTS.md) | Start here: the project, the rules, how to work, and the red lines |
| [../PLAN.md](../PLAN.md) | The owner's standing decisions, and when an item is done |
| [HANDOFF.md](HANDOFF.md) | The fast path, where things live, the dev parameters, and the traps, with an index |
| [AGENT-LOOP.md](AGENT-LOOP.md) | How a change is made: what to ask first, which evidence to trust, how to run a long job, then the loop for one change. At the end, what Arc switchers ask for |
| [PROJECT-LOG.md](PROJECT-LOG.md) | What was built since 2026-10-15, round by round, with the evidence. History, not instructions |
| [ARCHITECTURE.md](ARCHITECTURE.md) | Fork strategy, the build, patch management, branding, the updater, signing, and measured numbers |
| [features/](features/) | One specification per feature: each behaviour, its test, and whether it is built, partial or planned |
| [features/acceptance.md](features/acceptance.md) | The scripts run on a real build before a release, the core loop first, with a table of every run |
| [decisions/](decisions/) | Architecture decision records |
| [history/](history/) | The audit of 2026-09-26 ([plan-2026-09-26.md](history/plan-2026-09-26.md), whose ids the code cites: TAB-1, SPC-4, and the rest) and [archive.md](history/archive.md): closed backlog items, including the code review of 2026-10-15 (S-179 to S-210) |
| [perf/](perf/) | How to measure the performance budgets. The one comparison is from 2026-09-02, on Chromium 153; nothing current |
| [images/readme/STORYBOARD.md](images/readme/STORYBOARD.md) | How the README's animation is made |
| [../tooling/README.md](../tooling/README.md) | The build, capture and release scripts |
| [../branding/README.md](../branding/README.md) | The mark, the palette, and how the assets are generated |
| [../CONTRIBUTING.md](../CONTRIBUTING.md) · [../SECURITY.md](../SECURITY.md) | How to contribute; how to report a vulnerability |

`images/` holds the captures the docs show. `tooling/check-geometry` re-measures the card gutters and corner radius in the captures named in `tooling/probes/geometry.json`.
