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

**Feature work is well past M1** — the milestone ladder in `docs/ROADMAP.md` is
being executed out of order on purpose, chasing operator feedback on real
builds. The patch series sits on the pin; unsigned beta pre-releases go to
GitHub Releases. `tooling/dev status` prints the real counts (patches, tests
per feature, pin); do not type them here.

What "working" means here: **a behaviour is shipped when its test in
`docs/features/<feature>.md` is green.** Captures prove pixels only. This rule
exists because the Spaces feature shipped with its switcher, colours and
persistence all verified by capture while a new tab did not actually join the
active Space and switching Spaces did not change the active tab
(`docs/features/spaces.md` B1–B5, found 2026-09-01). The procedure that
prevents a repeat is `docs/AGENT-LOOP.md`.

Built, with tests or measured captures:

- Arc-proportioned sidebar: essentials row, per-Space pins, Clear line,
  44 px rows, 18 px favicons; floating content card; centred bare-host URL;
  33 px toolbar.
- **Spaces**: switcher with floating hover names, per-Space tint, context-menu
  icon/rename/colour/delete, drag-tab-onto-Space, persistence (`decisions/0015`).
  Core semantics — membership on open, active tab follows the switch, delete
  moves tabs — landed as patch 0004 with `space_model_window_unittest.cc`.
- **Folders with nesting**: create from tab context menu, drop a dragged tab
  on a folder header (patch 0008), collapse, inline rename, session
  persistence; the close-path use-after-free is fixed and regression-tested.
- **⌘T command bar** across Spaces, also behind the sidebar's New Tab row.
  Stedding colours (sand light, blue→plum gradient dark). Codecs verified.
  Sign-in promo removed; DuckDuckGo default search; the new tab page is
  local (hint line, no Web Store tile) and the omnibox has no Google entry
  points; chrome://settings has no Google or AI sections and carries the
  Stedding mark. Mac updater stubbed
  (no Keystone) pointing at GitHub Releases.
- **Peek**: a link leaving a pinned tab's site opens over the window instead
  of navigating the tab; Escape or a click outside dismisses it, ⌘O moves the
  same page into a tab (`docs/features/peek.md`).
- **Settings**: a "Stedding" section first in chrome://settings, one control
  per Stedding preference, plus the window's Spaces to rename or delete
  (`docs/features/settings.md`).
- **Auto-archive**: unpinned tabs outside folders that nobody has looked at
  for 12 hours (a setting) close into the recently-closed list
  (`docs/features/archive.md`).
- **Round 5 Arc parity** (`docs/ARC-ROUND2.md`): the bar sits on the page and
  takes its colour, the Space title heads the list with its pinned run and
  the Clear line, ⌘S toggles the sidebar, ⌘T classifies and suggests,
  downloads at the bottom-left, the sidebar edge drags, a swipe changes Space.
- **Screenshots**: ⇧⌘2 the page, ⌥⇧⌘2 a region, ⇧⌘1 the full document; PNG
  to Downloads and the clipboard (`docs/features/screenshot.md`).
- **Welcome flow**: `chrome://stedding-welcome` over a profile's first window:
  search engine, import, appearance, default browser, shortcuts
  (`docs/features/welcome.md`).
- **Round 6, wave 1** (`docs/ROUND6-PLAN.md`, patches 0016–0018): Arc's keys for
  Spaces (⌃1–9, ⌥⌘←/→, ⌘D pins, ⇧⌘K clears, ⌥⇧⌘←/→ moves the tab) and a
  Spaces menu in the menu bar; ⇧⌘C copies a clean link, ⌥⇧⌘C a Markdown one;
  the close glyph only on hover, alerts as a corner badge on essentials; the
  shortcut reference in chrome://settings/stedding; the status pill and the
  find bar inside the card, no ring around split panes; the capture and
  copy-link toasts; motion follows macOS Reduce Motion and a setting; the
  About line reads "Stedding <VERSION> · Chromium <pin>"; Space swatches on
  the welcome flow; the address row takes the page colour on either side of
  the contrast line (toolbar T7) and sits in a 6 DIP gutter like the card's
  other three sides.
- **Round 6, wave 2** (patches 0019–0025): sleeping tabs with one dimmed look,
  Sleep Tab / Sleep Others and a Space that sleeps after the user leaves it;
  rename in place that survives restore; row numbers while ⌘ is held; verbs
  that act on the selection with plural labels; Stedding's short tab menu
  with Chromium's behind a setting; Arc's pinned-tab lifecycle (a home URL,
  ⌘W sleeps, the drifted dot, the favicon reset, the menu rows, peek reads
  the stored site); the switcher's overflow dots and Move Left / Move Right;
  download progress on the sidebar button; the command bar's actions mode
  (⇥, a leading ">", ⇧⌘P: every command with its chord, ⌘L with the URL
  selected); ⌃⇥ through the Space's most recent tabs with a hold-to-see
  strip, ⌥⇧⌘↑/↓ moving the row folder-aware; the page and app menus without
  Google's rows, Import, Screenshot and Spaces in the app menu, a menu per
  row kind and for the folder header, Move to Space; a chip drag reorders
  the Spaces; a split's panes take a Space, a pin and a sleep together.
- **Round 6, wave 4** (patches 0034–0036, complete): private windows wear a
  different coat (`docs/features/private.md`); the little window for links
  from other apps (`docs/features/little.md`); one sidebar for every window
  through the SpaceRegistry (`docs/features/windows.md`, ADR 0016); ADR 0016 (the SpaceRegistry)
  and the specs for the little window and one sidebar for every window
  are written (`docs/features/little.md`, `docs/features/windows.md`).
- **Round 6, wave 3** (patches 0026–0033, complete): Import from Arc — Spaces,
  essentials, pins and folders from Arc's sidebar file, every tab unloaded
  (`docs/features/import.md`); routing — a site opens in the Space it is
  routed to, with a toast that undoes it (`docs/features/routing.md`); the
  archived view — what auto-archive, Clear and a close left behind, by day
  and Space, restorable (`docs/features/archive.md` A7–A11); the address
  row hides with the sidebar, ⇧⌘D shows it on its own
  (`docs/features/toolbar.md` T8–T12); the tracker-free defaults and the
  Privacy block (`docs/features/privacy.md`, ADR 0017); sidebar density
  presets and a text size (`docs/features/sidebar.md`); imported bookmarks
  become pins, and sidebar backups, export and restore in the importer's
  format (`docs/features/import.md` I13–I20).
- **Round 7** (2026-09-05, `docs/ARC-ROUND2.md`; patches 0037 and 0038): the row is the page's colour exactly,
  square under it, the star and the address cluster centred (toolbar T15–T18);
  the collapsed rail centred with its toggle clear of the traffic lights
  (sidebar Y6–Y7); Arc's folder and drifted-pin rows (folders F12, pins H12);
  the folder quit crash; Arc's history and passwords in one click from the
  welcome flow (import I6, I21–I23, welcome W8).

Read `docs/HANDOFF.md` before touching anything — it carries the working loop,
every dev parameter, and the traps already paid for. `docs/ARC-ROUND2.md` is
the operator-feedback ledger; `docs/UI-SPEC.md` the measured Arc match.

Outstanding: `BACKLOG.md`. Unsigned (M7). First vanilla perf comparison is in
`docs/perf/README.md`: on the deterministic page list every QUALITY budget is
met (cold +2.3%, warm −2.0%, memory +0.0% over vanilla).

## Map of the docs

| File | What's in it |
|---|---|
| `docs/AGENT-LOOP.md` | **The working procedure**: research → spec → failing test → implement → build → test → capture → patch |
| `docs/features/` | One spec per feature; numbered behaviours, each with its test id. The definition of done |
| `BACKLOG.md` | The one list of open work, by id. Other docs cite ids |
| `docs/HANDOFF.md` | Where things live, dev parameters, the traps already paid for |
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

The order is `BACKLOG.md`. `v0.2.0-beta.3` (unsigned) carries round 5 of the
Arc parity work, screenshots, the welcome flow, the fixes from the visual
audit of every surface and from the first look at beta 2 (`docs/ARC-ROUND2.md`);
the operator retests it against Arc. `S-17` signing waits on Apple's organisation enrolment (then
`tooling/sign-release` and a signed re-release), `S-18` on a licensing
decision. Of the small gaps found while verifying round 5, `S-40`, `S-42`
and `S-43` (capture toast, welcome swatches, About version) closed with wave
1; `S-41` (download progress on the sidebar button) is wave 2's. `S-44` is
the body of work under way: `docs/ROUND6-PLAN.md`, the reviewed plan from the Zen mods and
beyond (four waves, decisions recorded): wave 1 landed 2026-09-05 (patches
0016–0018) and most of wave 2 the same night (patches 0019–0022, the command
bar's actions mode included), every row verified live or by unit test, notes
in the plan, the ⌃⇥ switcher (R6-12) as 0023, the menus (R6-14) as 0024
and the last rows (B27, J4, T14) as 0025: wave 2 is complete. Wave 3 opened
with R6-22 (Import from Arc) as 0026, R6-23 (routing) as 0027 and R6-24 (the
archived view) as 0028, R6-25 (the address row) as 0029, R6-26 (the
Privacy block) as 0030, R6-27 (sidebar density) as 0031, R6-28 (bookmarks to
pins) as 0032 and R6-29 (sidebar backups) as 0033: wave 3 is complete. Wave 4
opened with R6-32 (the private coat) as 0034 and ADR 0016, then R6-30 (the
little window) as 0035 and R6-31 (the registry) as 0036: round 6 is complete
apart from the rows each spec marks as gaps. Round 7 (`S-46`, 2026-09-05) took
the operator's six from beta 3 and the folder quit crash as patch 0037, and Arc's
history and passwords as patch 0038; the next round waits on the operator's
look at beta 4.
