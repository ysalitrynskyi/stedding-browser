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
- **Round 7** (2026-09-05, `docs/ARC-ROUND2.md`; patches 0037 and 0038, with a
  second pass the same evening on the operator's replies): the row is the page's
  colour exactly, square under it, the address centred on the row in a field with
  no chrome around it, 560 DIP where the row has the room and shrinking when it
  does not (toolbar T15–T18); the collapsed rail centred and the sidebar's toggle
  on the traffic lights' own centre (sidebar Y6–Y7); Arc's folder row — macOS's
  own folder symbol, the header, the New Tab row and the Space title on the tab
  rows' column — and the drifted-pin row (folders F12, pins H12); the folder quit
  crash; the keychain item under Stedding's own name (import I24); Arc's history
  and passwords in one click from the welcome flow (import I6, I21–I23, welcome
  W8). Two of Chromium's own suites had been red since patch 0002 because nothing
  ran them: they now assert what this fork does (`docs/HANDOFF.md`, trap 31).

- **Round 8** (2026-09-08, `docs/ARC-ROUND2.md`; patch 0039): the series built
  and ran on Windows for the first time -- nine `FilePath` portability fixes, then
  the operator's look at it, in four passes the same day. The address row under
  Windows' caption buttons with their glyphs in its colour and the buttons on the
  row's centre line; the focused bar and the dropdown in the page's colour; the
  row's colour surviving a reload; the rail's rows 44 DIP squares, centred, the
  switcher stacked, the hover overlay opaque. Three of them reach the Mac: a
  profile killed while collapsed crashed on every launch (the crashed-session
  bubble, toolbar T23), the address field could sit over the back button in a
  narrow window (toolbar T18), and the rail itself. Chrome's registry key for
  extensions is no longer read (privacy Q9). Verified on captures the tooling
  took itself with no focus and no input (`tooling/win/capture.ps1`, trap 36);
  the card measures the mac's geometry to the pixel. Not a port (M8, `S-56`):
  branding and the macOS chrome are `is_mac`.
- **M8, first slice** (2026-09-09; patches 0040–0041, ADR 0018): the collapsed
  rail expands on hover after a pause the user sets, 2 s by default, a click in
  the rail restarting it (sidebar Y11, settings T11); Windows knows the build as
  Stedding -- the name, the icon, `%LOCALAPPDATA%\Stedding`, its own registry
  keys, COM classes and sandbox prefix, so it lives beside a Chromium install
  (windows N3–N4); `tooling/apply-branding` runs under Git for Windows and the
  product-name rewrite reaches every locale; `tooling/win/build.ps1`,
  `package-installer.ps1` and a `publish-release` that joins a release across
  platforms make Chromium's `mini_installer` the Windows image, built, installed
  and uninstalled on the build machine (windows N6) and published with beta 5 as
  a preview. Chromium's field-trial testing config is off in every build from
  now on and the 2026 refresh it carried is on by decision (privacy Q10, patch
  0042). Still to come: little windows and links from other applications;
  unsigned; no updates (`S-56`).

- **Round 9** (2026-09-09, `docs/ARC-ROUND2.md`; patches 0043–0045): the
  operator's first three minutes in the Windows preview. Arc's keyboard for
  Windows -- ⌘ read as Ctrl, ⌥⌘ as Ctrl+Alt, Alt+1–9 for the Spaces (windows
  N7) -- with the shortcut reference reading the platform's own table on every
  platform (shortcuts Z6) and the settings and welcome strings in the
  platform's words; the local new tab page for Google too (`S-45` closed), no
  API-keys infobar (welcome W9), no Chromium theme picker (settings T12); the
  rail's rows 6 DIP apart, the Space title its glyph alone, the switcher's
  stack measuring itself so a Space added in the rail keeps the "+" on
  screen, no floating name over the downloads button (sidebar Y12–Y14).
  Published as beta 6 from Windows.

- **The Mac pass on beta 6** (2026-09-10, `docs/ARC-ROUND2.md`, *The Mac pass*):
  the checkout had been deleted for disk and was re-synced (HANDOFF trap 44); the
  first macOS build of the Windows-written patches needed a guard on a Windows-only
  colour id and a UTF-8 export file name (fixups into 0039); the first multi-tab
  capture showed every inactive sidebar row filled -- Chromium's field-trial
  testing config had been hiding that in every beta up to 4, and beta 5 was the
  first build with it off (privacy Q10) -- so the mixer pins inactive rows
  transparent (tabs R23, fixup into 0042); the release sweep grew
  `tooling/dev test upstream` and seven of Chromium's own cases now assert what
  this fork does. The macOS image joined beta 6 that day; the README's captures
  are from it.

Read `docs/HANDOFF.md` before touching anything — it carries the working loop,
every dev parameter, and the traps already paid for, numbered contiguously and cited
by number across the docs (`tooling/check-repo traps` keeps both true). `docs/ARC-ROUND2.md` is
the operator-feedback ledger; `docs/UI-SPEC.md` the measured Arc match.

Released: `v0.2.0-beta.4` (2026-09-05, published from this repo with
`tooling/publish-release`), unsigned (M7 waits on Apple). It carries rounds 5,
6 and 7, the round-7 second pass included. Published from Windows: `v0.2.0-beta.5`
(2026-09-09, round 8 and M8's first slice, the Windows preview installer alone)
and `v0.2.0-beta.6` (`docs/release-notes/v0.2.0-beta.6.md`, 2026-09-10, round 9:
the Windows keyboard map, the first start, the rail); the DMG and its checksum in
the notes were the Mac's to add to beta 6, and it did on 2026-09-10 -- after
re-syncing a checkout that had been deleted for disk (`docs/HANDOFF.md`, trap 44),
with two fixups into patch 0039 that the first macOS build of the Windows-written
patches turned up (`docs/ARC-ROUND2.md`, *The Mac pass*). Beta 5 stays a
Windows-only preview. Signing: the Apple developer account exists since 2026-09-10;
the certificate and the notary profile are the operator's next step (`S-17`).
Outstanding: `BACKLOG.md`. First vanilla perf comparison is in
`docs/perf/README.md`: on the deterministic page list every QUALITY budget is
met (cold +2.3%, warm −2.0%, memory +0.0% over vanilla).

## Map of the docs

| File | What's in it |
|---|---|
| `docs/README.md` | The index of everything under `docs/`, grouped by who it is for |
| `docs/INSTALL.md`, `docs/SHORTCUTS.md`, `docs/FAQ.md` | The user-facing pages the README links: installing and verifying, every shortcut on both platforms, questions and answers. Plain language; keep them true when behaviour changes |
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

The order is `BACKLOG.md`. `v0.2.0-beta.4` is out (unsigned, 2026-09-05): rounds
5, 6 and 7 — the Arc parity work, the Zen-mods plan in full
(`docs/ROUND6-PLAN.md`, patches 0016–0036), the operator's six from beta 3, the
Arc one-click import, and the second pass on the operator's replies the same
evening (patches 0037–0038 and fixups into 0001, 0002). `v0.2.0-beta.5` is
out with round 8 and M8's first slice as the Windows preview alone, and
`v0.2.0-beta.6` is out on both platforms: from Windows with round 9 on
2026-09-10, the macOS image added from the Mac the same day.

**Whoever picks this up next**: read `docs/HANDOFF.md` first — the loop, the dev
parameters and the traps, now including `tooling/capture-state` (a capture that
needs neither the keyboard nor the pointer, trap 29), the rule that a release
sweep runs Chromium's own suites around what the series touches, not only the
Stedding filters (trap 31), and what a vanished checkout costs and how it comes
back (trap 44). `tooling/dev status` says whether the checkout and `unit_tests`
exist before anything else is planned. What to build next is the operator's look
at beta 6; `docs/ARC-ROUND2.md` is where each round's findings are recorded, one
table per round, and the fix for each. `S-58` (the Mac's disk: an owner's
decision, since the checkout and a build need 85 GB on a volume that is 88% full)
comes before the next build. Until then the open rows are `S-52` (take
153.0.8010.27: the pin was Mac stable when it was taken and the line has moved
since), `S-51` (a legacy profile still reads the Chromium-named keychain item and
nothing rewrites it), `S-49` (a builder that can actually build — until it exists
CI checks repository hygiene and nothing verifies the product), `S-45` (Google's
new tab page when Google is chosen), `S-47` (an input-free settings probe), `S-48`
(the Arc data import run once against a real Arc profile), `S-56` (M8: the Windows
port's remainder after the first slice -- the keyboard map and the menus, signing,
updates, CI), `S-50` (the idle-network
audit as a recorded run) and `S-17` (signing: the developer account exists, the
Developer ID certificate and the notary profile are the operator's to make on the
Mac, then `tooling/sign-release` and a signed re-release). Every feature spec
names its own `gap` rows.

How to work here is `docs/HANDOFF.md`: the loop, the dev parameters that recreate
any state for a capture, and the traps. Two rules that cost the most when broken:
never edit the checkout while a build runs, and never inject input while someone
is at the machine (`tooling/capture-state` needs neither the keyboard nor the
pointer).
