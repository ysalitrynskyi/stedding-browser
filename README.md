# Stedding Browser

A fully open-source, Chromium-based desktop browser with an Arc-style interface:
sidebar with vertical tabs, Spaces, folders, and a command bar.

![Stedding today: floating content card, essentials row, folders with nesting, Space switcher](docs/images/ui-current.png)

*The screenshot is a real capture of the current build, taken by the project's
own verification tooling — every UI claim in these docs is checked this way.*

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

**M1 in progress — buildable, not yet released.** The tooling in `tooling/` checks
out Chromium at a pinned version, applies our patch series, brands it, builds it,
verifies it and packages a `.dmg`. That produces **Stedding**: our name, our icon, our
bundle identifier, with the vertical tab sidebar on by default.

What does not exist yet is a *release*. Builds are unsigned, so macOS requires a
right-click to open them; signing and notarisation land at M7. There is no download
page and no published binary — if you want one today you build it, and the steps are
in [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md).

## What works today

The tree carries a 43-patch series on Chromium stable 153. Working now, each
verified by capture or unit test:

- **Sidebar** at Arc's proportions: essentials row (pinned above every Space),
  per-Space pinned tabs, a Clear line, 44 px tab rows with 18 px favicons.
- **Spaces** — per-window tab sets: switcher at the sidebar's bottom with
  floating hover names, per-Space window tint, icon/rename/colour/delete from a
  context menu, drag-a-tab-onto-a-Space, and full persistence across restarts
  including which Space each tab was in.
- **Folders with nesting** — created from the tab context menu, collapse on
  click, rename on double-click, persisted across restarts.
- **Command bar on ⌘T** — searches open tabs across every Space (naming the
  Space a result is in), opens URLs, falls back to search.
- **Floating content card** — the page floats on the window ground with rounded
  corners; dark mode is a `#21263A → #31243A` gradient, light mode warm sand.
- **Privacy defaults** — no Google sign-in promotion; the usual no-telemetry
  stance (`docs/PRIVACY.md`).
- **Proprietary codecs** — H.264/AAC verified decoding real frames.

**Try it:** grab the `.dmg` from
[Releases](https://github.com/ysalitrynskyi/stedding-browser/releases). Builds
are **unsigned until M7**: right-click the app → Open on first launch. Treat it
as a beta — daily-driving it is brave but welcome.

See `docs/ROADMAP.md` for the milestone ladder and `docs/UI-SPEC.md` +
`docs/ARC-ROUND2.md` for the measured state of the Arc match.

## Building it

```bash
tooling/bootstrap-depot-tools     # once per machine
tooling/sync-chromium             # once per pin change; downloads tens of GB
tooling/apply-patches             # our patch series
tooling/apply-branding            # our name and icon
tooling/build-chromium release
tooling/package-dmg release
```

Full prerequisites, measured build times, and the failure modes we actually hit are
in [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md). Following upstream is
`tooling/update-pin`, and a scheduled workflow opens an issue the day Chromium
stable moves ahead of our pin.

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
| [docs/HANDOFF.md](docs/HANDOFF.md) | Operational handoff: the working loop, dev parameters, traps, open items |
| [docs/UI-SPEC.md](docs/UI-SPEC.md) | The measured Arc match, item by item |
| [docs/ARC-ROUND2.md](docs/ARC-ROUND2.md) | Operator-feedback ledger from real builds |
| [docs/IMPLEMENTATION.md](docs/IMPLEMENTATION.md) | How each feature is built, what upstream already provides, and what it costs |
| [docs/EVIDENCE.md](docs/EVIDENCE.md) | What Arc switchers actually ask for, with counts |
| [docs/decisions/](docs/decisions/) | Architecture decision records (ADRs) |
| [tooling/README.md](tooling/README.md) | The build scripts and how to use them |
| [branding/README.md](branding/README.md) | The mark, the palette, and how assets are generated |
| [CONTRIBUTING.md](CONTRIBUTING.md) | How to contribute |
| [SECURITY.md](SECURITY.md) | How to report vulnerabilities |

**For AI agents and new contributors:** start with [AGENTS.md](AGENTS.md). It is the
canonical context file for this repository and is kept current as decisions change.

## License

[BSD-3-Clause](LICENSE).
