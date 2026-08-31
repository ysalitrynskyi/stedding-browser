# Roadmap

Milestones from zero to 1.0. Each milestone ends in something installable and has
acceptance criteria a user can verify. A milestone is done when every criterion passes,
not when the code is merged.

**No dates.** This roadmap is a sequence, not a schedule. We do not promise dates, and
any date you find elsewhere is wrong. The order can change only via an ADR in
`docs/decisions/`.

The quality bar that applies to every milestone lives in `docs/QUALITY.md`. "Installable"
below always means: a fresh macOS user account can install the artifact and run it
without developer tools, without terminal commands, and without reading build docs
(Windows/Linux equivalents apply from M8/M9 on).

---

## M0 — Reproduce a vanilla Chromium build (macOS arm64)

**Goal:** prove we can build stock Chromium from source on macOS arm64, and document it
so any machine or agent can repeat it without tribal knowledge.

Scope:

- Check out and build Chromium stable channel source for macOS arm64.
- Pin the exact Chromium version, checkout method, `gn` args, and toolchain versions.
- Document every step — prerequisites, disk/RAM requirements, full command sequence,
  expected build time range on reference hardware, and known failure modes — in the
  build section of `docs/ARCHITECTURE.md`.
- Verify the result with `tooling/verify-build --app <path to the built Chromium.app>`,
  which is what checks the "launches, browses, plays video and WebGL" criterion below.
- Record the vanilla performance baselines defined in `docs/QUALITY.md` with
  `tooling/measure/harness.py`. These are the *vanilla* numbers; they become the
  baseline proper at M1, when Stedding is measured against them at the same pin.

Acceptance criteria:

- A second, clean machine (or wiped checkout) reproduces the build following only the
  written docs, with no undocumented steps.
- The resulting `Chromium.app` launches, browses, and plays video and WebGL content.
- The pinned Chromium version and full build configuration are committed to the repo.

## M1 — Branded minimal build, installable .dmg

> **In progress.** Branding is applied and the build produces `Stedding.app` with
> our icon and bundle identifier `dev.stedding.Stedding`; `tooling/package-dmg`
> makes an installable image. Outstanding: the network audit, the performance
> baselines from an `official` build, and the codec decision in ADR 0008.

**Goal:** the same browser, but ours: name, icons, defaults, and zero telemetry —
delivered as a .dmg a user can install.

Scope:

- Branding patch series: product name "Stedding", app icon, About page, bundle
  identifier, user agent policy (documented in an ADR — brand tokens in the UA are a
  compatibility trade-off).
- Default settings patch: no telemetry, no crash reporting to Google, no field trials,
  no promotional or sign-in prompts; privacy defaults per `docs/PRIVACY.md`.
- Network audit: enumerate every request a fresh profile makes on first run and idle,
  and document each one that remains (e.g. component/extension updates, safe browsing —
  each kept or removed per `docs/PRIVACY.md`).
- .dmg packaging (unsigned is acceptable at this milestone; signing lands at M7).
- Measure and commit the performance baselines against vanilla Chromium at the same
  pinned version (see `docs/QUALITY.md` — this replaces the TBD baselines).

Acceptance criteria:

- A user installs the .dmg by dragging to Applications and launches Stedding on a
  machine with no developer tools (Gatekeeper bypass is documented until M7 signing).
- App name, icon, and About page show Stedding, not Chromium.
- A network capture of first run and 10 minutes idle matches the documented request
  list — nothing unexplained, and no telemetry endpoints.
- Chrome Web Store works: a user installs an extension (e.g. uBlock Origin) and it runs.
- Performance baselines are committed and within the budgets in `docs/QUALITY.md`.

## M2 — Sidebar with vertical tabs (first public pre-alpha)

**Goal:** the Arc-style sidebar replaces the horizontal tab strip. First build we
publish for strangers to try.

> **Since this was written, upstream shipped vertical tabs.** Chromium 153 has a
> landed `VerticalTabStripRegionView` with collapse, pinning, drag-reorder and
> persisted state, enabled by default behind a user pref. M2 therefore builds on it
> rather than replacing the tab strip — see
> `decisions/0010-ride-upstream-vertical-tabs.md`. That makes M2 much cheaper, and it
> means the sidebar by itself is no longer a differentiator. What still distinguishes
> Stedding is workspaces, the command bar, split view, privacy defaults and
> governance. Whether that changes the product's positioning is an open question for
> a human, recorded in ADR 0010.

Scope:

- Sidebar with vertical tabs: create, close, reorder (drag), pin, favicons, titles,
  audio indicator, and the `Space` preview specified in `docs/PRODUCT.md`. Hover
  previews are deliberately not listed: they are not in the product spec, and adding
  scope here rather than there is how a phantom requirement gets built.
- Collapse/expand the sidebar; toggle shortcut; state persists across restarts.
- Vertical tabs on by default: the `vertical_tabs.enabled` pref defaults on, so the
  sidebar fully replaces the horizontal strip as specified in `docs/PRODUCT.md`. Any
  look-and-feel divergence lives in a subclass in new files, never as edits to
  `browser_view.cc` or `vertical_tab_strip_region_view.cc` — 412 and 181 commits a
  year respectively.
- Keyboard: all existing Chromium tab shortcuts still work; sidebar-specific shortcuts
  documented in the shortcut reference.
- Pre-alpha release published on GitHub with known-issues list.

Acceptance criteria:

- Installable .dmg published as a GitHub pre-release.
- A user can do a full day of tab management (open, close, reorder, pin, switch by
  mouse and keyboard) using only the sidebar, with no crashes attributable to it.
- Sidebar state (width, collapsed, pinned tabs) survives quit and relaunch.
- The UX completeness definition in `docs/QUALITY.md` passes for the sidebar feature.

## M3 — Workspaces

**Goal:** separate contexts (work, personal, projects) with their own tab sets.

Scope:

- Create, rename, reorder, and delete workspaces; per-workspace icon/color.
- Each workspace has its own tab set in the sidebar; switching is instant and keyboard
  driven.
- Workspace-to-Chromium-profile mapping implemented as specified in
  `docs/PRODUCT.md` (one shared profile by default, optional per-space profile
  binding); the already-specified decision is recorded in an ADR.
- Tabs can be moved between workspaces.
- All workspace state persists across restarts and survives crashes.

Acceptance criteria:

- Installable .dmg published as a pre-release.
- A user maintains at least three workspaces for a day; every tab is in the workspace
  they left it in after quit, relaunch, and forced kill.
- Workspace switching works by mouse and by shortcut; shortcuts are documented.
- Deleting a workspace warns about its tabs and is undoable or explicitly confirmed.

## M4 — Command bar

**Goal:** a keyboard-first launcher for navigation and browser actions.

Scope:

- Summonable command bar (default shortcut documented): open/switch tabs, search open
  tabs and history, navigate to URL, run browser commands (new tab, new workspace,
  toggle sidebar, etc.).
- Fuzzy matching; ranked results; full keyboard operation.
- Relationship to the omnibox implemented as specified in `docs/PRODUCT.md` (the
  command bar replaces the always-visible URL bar); the already-specified decision
  is recorded in an ADR.
- Every sidebar and workspace action added so far is reachable from the command bar.

Acceptance criteria:

- Installable .dmg published as a pre-release.
- A user can switch tabs, open sites, and trigger every shipped Stedding feature
  without touching the mouse.
- Command bar opens in under the input-latency budget in `docs/QUALITY.md`.
- Escape always dismisses; no dead-end states.

## M5 — Split view

**Goal:** two pages side by side in one window.

Scope:

- Split a window into exactly two panes: create from sidebar, command bar, and drag.
  Three or more panes and grids are post-1.0 in `docs/PRODUCT.md` and are out of scope
  here; shipping them early would put an unspecified feature through the UX
  completeness gate.
- Resize divider; swap panes; close one pane back to single view; clear focused-pane
  indication (keyboard input, shortcuts, and the command bar / compact sidebar URL
  target the focused pane — there is no always-visible address bar after M4).
- Split state persists per workspace across restarts.

Acceptance criteria:

- Installable .dmg published as a pre-release.
- A user can create, resize, swap, and dismiss a split by mouse and keyboard, and both
  panes browse independently.
- Restoring a session restores splits exactly as left.
- No rendering artifacts or focus traps in split mode with DevTools, find-in-page, and
  fullscreen video.

## M6 — Settings, import, polish (public beta)

**Goal:** everything shipped so far is configurable, discoverable, and complete; a
Chrome/Arc user can migrate in minutes. First build we call a beta.

Scope:

- Stedding settings surface: every Stedding feature has its settings entry (shortcuts,
  sidebar behavior, workspace options, command bar options), integrated with Chromium
  settings.
- Import from Chrome/Chromium-family browsers: bookmarks, history, passwords,
  extensions list, open tabs where feasible; explicit report of what did and did not
  import.
- Full pass of `docs/QUALITY.md` UX completeness and accessibility gates over M2–M5
  features; fix or explicitly de-scope (ADR) everything that fails.
- Complete keyboard shortcut reference shipped in-product.
- A setting for URL elision. The steady-state omnibox shows the bare host, as Arc
  does; Chrome tried the same thing and withdrew it, on the grounds that a user
  can misjudge a page from a host a long path would contradict. Ours is narrower
  -- the full URL returns on focus, and a bad certificate or the existing
  `kPreventUrlElisionsInOmnibox` pref keeps it visible throughout -- but the
  choice belongs to the user, not to us. See patch 0005.
- Known-issues list triaged to zero release-blockers.

Acceptance criteria:

- Installable .dmg published as a public beta on GitHub.
- A Chrome user imports their profile and retains bookmarks, history, and passwords,
  with a visible summary of the result.
- Every shipped feature passes the UX completeness definition and the accessibility
  gates (VoiceOver, keyboard-only) in `docs/QUALITY.md`.
- A new user can discover and change every Stedding-specific behavior via settings and
  the command bar without reading the repo.

## M7 — Signed, notarized, auto-updating; site live

**Goal:** distribution is production-grade: install with no warnings, update without
thinking, learn about it at stedding.dev.

Scope:

- Developer ID signing and Apple notarization in a reproducible release pipeline.
- Auto-update mechanism (updater choice recorded in an ADR), serving deltas or full
  updates over HTTPS; update checks contain no identifying data beyond what the
  updater strictly needs (documented in `docs/PRIVACY.md`).
- Update safety gates from `docs/QUALITY.md`: n-1 upgrade test and rollback path.
- stedding.dev live: download, release notes, source link, security policy. The site
  lives in its own repository (`ysalitrynskyi/stedding-site`, Astro, static) and is
  deliberately not on the path of an update check — see
  `decisions/0014-github-releases-as-update-channel.md`.
- Release checklist from `docs/QUALITY.md` adopted as the gate for every release from
  here on.

Acceptance criteria:

- A fresh macOS machine downloads from stedding.dev and installs with no Gatekeeper
  warnings or manual overrides.
- A machine running the previous release receives and applies the update automatically
  and relaunches into the new version with profile intact.
- The documented rollback path restores the previous version with profile intact.
- The release was produced by the documented pipeline and passes the full release
  checklist.

## M8 — Windows port

**Goal:** feature parity on Windows x64 with a native-quality installer and updates.

Scope:

- Windows build of the full patch series; platform-appropriate shortcuts and window
  chrome; installer (format recorded in an ADR); code signing; auto-update on Windows.
- CI or documented reproducible build path for Windows releases.
- Windows-specific pass of the quality gates, including performance budgets re-measured
  against vanilla Chromium on Windows.

Acceptance criteria:

- A signed Windows installer is published; SmartScreen state is documented honestly.
- All shipped features (M2–M6) work on Windows and pass the same acceptance criteria
  as their macOS milestones.
- Auto-update from the previous Windows release works, with the same n-1 and rollback
  gates as M7.

## M9 — Linux port

**Goal:** feature parity on Linux x64 with maintainable packaging.

Scope:

- Linux build of the full patch series; package formats chosen and recorded in an ADR
  (e.g. .deb/.rpm/Flatpak/AppImage — decided then, not promised now); update story per
  format.
- Linux-specific pass of the quality gates, including performance budgets re-measured
  on Linux.

Acceptance criteria:

- At least one supported package format installs and runs on a clean install of a
  named mainstream distribution, following only the published instructions.
- All shipped features work and pass their acceptance criteria on Linux.
- The update story for each supported format is documented and tested.

## 1.0 — Quality gate

**Goal:** nothing new. 1.0 is a claim about quality, not a feature.

Acceptance criteria:

- Every gate in `docs/QUALITY.md` is green on every supported platform, verified
  against the current release, with evidence (measurements, test runs, checklist
  records) linked from the release notes.
- No open release-blocker issues.
- The Chromium base is current stable, and the security-update gate in
  `docs/QUALITY.md` has been met for the preceding releases.

---

## Out of scope for this ladder

Mobile, built-in AI features, sync services, and paid add-ons are not on the path to
1.0. Any of them entering the roadmap requires an ADR and a roadmap revision.

## Build order, and why

The milestone order below predates any evidence about what Arc switchers actually want.
`EVIDENCE.md` gathers that evidence from the tracker of a comparable project. Two things
in it change how these milestones should be built rather than what is in them:

- **Session restore belongs inside the sidebar milestone, not after it.** The largest
  bug cluster on the comparable project is tab identity across windows, spaces and
  favorites — restore duplicating favorites, moving a favorite between windows silently
  un-favoriting it. Build the persistence model with the tab model.
- **Folders are a gate, not a nicety** (412 upvotes, and named as the thing keeping
  people on Arc). They belong with the sidebar, not in a later polish pass.

## Deferred, with the intent to return

Real Arc features that are specified in `PRODUCT.md` and deliberately not in the first
releases. Listed here so they are visible as future work rather than quietly missing.

| Feature | Why deferred | What brings it back |
|---|---|---|
| **Boosts** (per-site CSS/JS, Zap) | Extensions already answer it — Stylus, Violentmonkey, uBlock's element picker — and full extension support is a hard requirement we keep regardless. It is also a script host, so it carries security work nothing else here does. | The workflow features ship and meet the quality bar, *and* a threat model exists. The threat model comes first, not alongside. |
| **Easels** (whiteboards) | A drawing application inside a browser, and the single largest item in `PRODUCT.md`. Almost nothing to do with browsing. | Capacity after the features people actually stay in Arc for, or evidence users want it. |

Deferred is not cancelled. Both remain specified in `PRODUCT.md`; see
`decisions/0012-defer-boosts-and-easels.md` for the reasoning and the conditions.

Page capture is **not** deferred — captures are useful with or without a canvas.
