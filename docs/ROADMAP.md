# Roadmap

Milestones from zero to 1.0. Each ends in something a person can install, and a milestone
is done when every criterion below passes. This is a sequence, not a schedule. The order
changes only by an ADR in `docs/decisions/`.

What is released is on the [GitHub Releases page](https://github.com/ysalitrynskyi/stedding-browser/releases).
The notes for the current release are in `docs/release-notes/`. What is open is
`BACKLOG.md`. What a feature does is its spec under `docs/features/`.

"Installable" means a fresh account installs the artifact and runs it, without developer
tools, a terminal or the build docs. The quality bar at the end of this page applies to
every release.

## Done so far

| Milestone | State | Still open |
|---|---|---|
| M0 — A vanilla Chromium build, reproduced (macOS arm64) | Done. The pin moves by `tooling/update-pin --apply` (ADR 0007). The same series builds on Windows. | — |
| M1 — Branded build, installable image | Done: `Stedding.app`, bundle id `dev.stedding.Stedding` (ADR 0009), `tooling/package-dmg`, codecs (ADR 0008). | A recorded idle-network run on a real keychain, long enough for the push service (S-50) |
| M2 — Sidebar with vertical tabs | Done, on Chromium's own vertical tabs (ADR 0010), with folders (ADR 0013), pinned tabs, the rail, density, and a sidebar that hides completely. | — |
| M3 — Workspaces | Done as Spaces (ADR 0015, ADR 0016). A Space can have cookies of its own (ADR 0019). | — |
| M4 — Command bar | Partly done (`docs/features/commandbar.md`). ⌘L opens the bar with the page's address in it. | A click on the address does not open the bar, and Move Tab acts on the active tab only (K12, S-127). Turn Bookmarks into Pinned Tabs stays listed with nothing to convert (K16, S-158). |
| M5 — Split view | Done: Chromium's split view, the sidebar's verbs on both panes, a split made by dragging a tab onto the page (J10–J15), ⌘W and the number keys on a split, and a Space pin in a split (J2, J3, J5). | |
| M6 — Settings, import, polish | Done except the open rows. | A 400-tab import inside the budgets (S-103, I5). The rows still short of one test or one look, including a screen reader on the rail's New Tab and Archived rows (S-129, sidebar Y15). |
| M7 — Signed, notarized, auto-updating; site live | The Mac image is signed and notarized (S-17) and updates itself from 0.2.0 beta 16 (ADR 0022). Windows updates itself from 0.2.0 beta 19 (ADR 0023, ADR 0026, S-215). The site is https://stedding.dev. | The rollback path tried for real. Updates on Linux are M9 (S-216). |

## M8 — Windows port

**Goal:** feature parity on Windows x64, with a signed installer and updates.

Windows x64 ships in the release and updates itself (from 0.2.0 beta 19, S-215). In
already: the series and the window; the branding (N3–N4); Chromium's `mini_installer`
(ADR 0018); the keyboard (N7); little windows (E10); import from Arc (S-81). The
installer is not signed (S-56).

Still open:

- Signing and SmartScreen (S-56).
- A builder that builds the product. GitHub-hosted runners cannot build Chromium, so CI
  checks the repository only (S-49, `docs/ARCHITECTURE.md`, "CI reality").
- Performance budgets on Windows. `tooling/measure/harness.py` takes a macOS app bundle.
- A Space swipe that follows the fingers (B15, B35), which is the Mac's (TAB-31). On
  Windows a sideways touchpad scroll steps one Space (B39); those tests pass, and a real
  touchpad has not been tried.

Acceptance criteria:

- A signed Windows installer is published, and the SmartScreen state is stated as it is.
- Everything shipped in M2–M6 works on Windows and passes the same acceptance criteria.
- An update from the previous Windows release works, with the same n-1 and rollback gates
  as M7.

## M9 — Linux port

**Goal:** feature parity on Linux x64, with packaging that can be kept up.

There is no Linux build (S-216). The update design is ADR 0023: the package system
updates Stedding, and a self-contained package, if one ships, uses the Windows updater
with a feed of its own. Which formats ship is this milestone's decision.

Acceptance criteria:

- At least one package format installs and runs on a clean install of a named mainstream
  distribution, following the published instructions only.
- Everything shipped works on Linux and passes its acceptance criteria.
- The update story for each format that ships is documented and tested.

## M10 — Beyond parity

**Goal:** behaviour Arc does not have, taken from what Nook and Aura showed people want
(ADR 0021). Their code is not used. Nook is Swift on WebKit under GPL-3.0; Aura is Swift
on WebKit under MPL-2.0. Each item stands on its own, behind its spec rows and the quality
bar, and `BACKLOG.md` sets the order. M10 runs alongside M8 and M9. Built-in AI stays out
(ADR 0020).

Released, with any leftover named in `BACKLOG.md`: ad and tracker blocking's first phase,
off by default (S-88, Bk1–Bk13; ADR 0030 is Proposed); clean links (S-89); shortcuts the
user can change (S-91); Peek rebuilt (S-93); the sidebar on the right (S-96); History and
Downloads in the sidebar (S-98); dark pages, one switch with exceptions in both directions
(S-100, `docs/features/dark-pages.md`); child tabs nested under the opener (S-92,
R56–R59); Dia's bookmarks, history and passwords, and Safari's export file (S-101,
I28–I32, I34–I42); site controls in the page-info panel (S-118, Si1–Si11); undo after
closing tabs (S-97); S-119 to S-124; the copy button on the address (copy-link L7).

Still open:

- Blocking's later slices: element hiding, the blocked-page card, optional lists, a count
  (S-88, Bk20–Bk23). Lists are fetched at run time, never built in.
- A web app that binds the same chord gets the first press, and Stedding the second
  (S-90).
- A pin shown in every window, a ghost row with "Show here / Go to window" (S-94). The
  question itself is in, for a page found from another window (windows G11).
- The mini player (S-95, Mp1–Mp4). Picture in picture by key is released (S-122, Mp5).
- A Space's two-colour gradient, and the command bar's selected row in the Space's colour,
  are not built. An emoji and a colour, including one each for light and dark, are released
  (B41–B44, S-99).
- Dia's sidebar (S-101, I33).
- Site controls' remaining check (S-118, Si12). Si1–Si11 are not yet seen live.
- Three conveniences (S-125): an empty essentials row that is a drop target; each Space's
  stored size in Settings; "Open in the system viewer" on the PDF toolbar.

What was read and left out is in ADR 0021.

Acceptance criteria:

- Each item meets its spec's rows on macOS and Windows, with tests that failed before the
  change, and the UX completeness definition in "The quality bar" below.
- With blocking on, a fresh profile's idle-network list in `docs/PRIVACY.md` gains only
  the filter-list fetches its ADR names. A site it breaks is fixed by that site's switch,
  in one click.
- Nothing in the series comes from Nook's or Aura's files (ADR 0021).

## 1.0 — Quality gate

**Goal:** nothing new. 1.0 is a claim about quality.

Acceptance criteria:

- Every gate in "The quality bar" below is green on every platform that ships, checked
  against the current release, with the measurements, test runs and checklists linked from
  the release notes.
- No open release-blocker.
- The Chromium base is current stable, and the security-update gate below has been met
  for the releases before this one.

## Out of scope for this ladder

Mobile, a built-in model, a sync service of Stedding's own, and paid add-ons are not on
the path to 1.0. Any of them entering the roadmap takes an ADR and a revision of this
file. Sync through a folder the user's own tool keeps, or through WebDAV or S3 storage the
user sets up, is not a service (ADR 0029, ADR 0032). ADR 0020 keeps models out. The AI features Nook and Aura carry — a sidebar chat, a tab
organizer, an agent-control server, "Browse for Me" — are not taken (ADR 0021).

## Deferred, with the intent to return

Arc features that are specified in `docs/PRODUCT.md` and are not in the releases. They
are listed here so they stay visible.

| Feature | Why deferred | What brings it back |
|---|---|---|
| **Boosts** (per-site CSS/JS, Zap) | Extensions already cover it (Stylus, Violentmonkey, uBlock's element picker), and full extension support stays a hard requirement. A script host is security work nothing else here does. | The workflow features have shipped and meet the quality bar, and a threat model exists. The threat model comes first. Aura's editor is the model then: a live preview while typing, and a switch per site in the page menu (ADR 0021). |
| **Easels** (whiteboards) | A drawing application inside a browser, and the largest item in `docs/PRODUCT.md`. It has almost nothing to do with browsing. | Capacity after the features people stay in Arc for, or evidence that users want it. |

Deferred is not cancelled. Both stay specified in `docs/PRODUCT.md`. The reasoning is
`docs/decisions/0012-defer-boosts-and-easels.md`.

Page capture is not deferred. A capture is useful with or without a canvas.

## The quality bar

This is what "ready to use" means, as gates a person can check. A gate is green (the
check passed, and the evidence is recorded) or red. Aspirations that cannot be checked
do not belong here.

The gates apply from the milestone each one names: update safety and signing from M7,
Windows from M8. 1.0 needs all of them green on every platform that ships.

Some gates have no tooling and no record yet, and each of those says so. Until a gate
has both, it is a target, and no release may be described as passing it.

### Performance budgets (relative to vanilla Chromium)

Measured with `tooling/measure/harness.py all --sites local` against a vanilla build at
the same pin. The live list (`--sites live`) is only for the two absolute budgets.
There is no current measurement; the record is `docs/perf/README.md`. The harness takes
a macOS app bundle, so Windows has no number yet (M8).

The comparison is overhead against vanilla Chromium at the same pin, the same
configuration and the same hardware. Absolute numbers depend on the machine and are not
promised. The overhead budgets are.

The budgets are re-measured when the Chromium base changes, and on each new platform
(M8, M9).

| Metric | Method | Budget vs. vanilla |
|---|---|---|
| Cold startup to usable window | Median of 10 runs, fresh profile, timed launch to first accepted input | ≤ 10% overhead |
| Warm startup | Median of 10 runs, existing profile with 10 restored tabs | ≤ 10% overhead |
| Memory, 10-tab session | Physical footprint summed over the browser process tree after loading the fixed 10-site list and idling 60 s, median of 5 runs | ≤ 10% overhead |
| Input latency, tab switch via sidebar | Keypress or click to the target tab painted, median of 20 switches | ≤ 16 ms added over a vanilla tab-strip switch |
| Command bar open | Shortcut press to the bar rendered and accepting input, median of 20 | ≤ 100 ms absolute |
| Page load / rendering | Identical to vanilla | No measurable regression. The series patches no renderer code. Its hunks in the network stack are listed in `docs/ARCHITECTURE.md` ("Where patches are allowed to live"). |

How to run the harness, and what it measures, is in `docs/perf/README.md`. Published
images are `release` builds. The budgets are measured on `official`. Which configuration
ships is TBD (S-168).

The sidebar tab switch and the command bar have no measurement in the harness, so both
of those budgets are TBD. They are added to the harness rather than stubbed.

A miss is a release blocker. The regression is fixed, or the budget is changed by an ADR
with the reason on record.

### Stability

- **Crash-free sessions.** There is no telemetry, so there is no fleet crash rate, and
  none is invented. The gate is local: a scripted 8-hour soak (tab churn across Spaces,
  splits, the command bar, restarts) finishes with no browser-process crash. A UI-process
  crash a user reports with steps to reproduce is a release blocker until it is fixed or
  shown to be upstream. No soak script exists yet.
- **No data loss on crash.** Kill the browser processes (`SIGKILL`) during use. On
  relaunch, session restore brings back every Space, tab, split and the sidebar state
  from a few seconds before the kill. This is to be tested before every release. There
  is no script and no record of it yet. Restarts and restores are covered by browser
  tests with `PRE_` steps, and by real use (`docs/features/spaces.md` B9).
- **No data loss on upgrade.** Covered under update safety below.
- **Unit tests stay out of the user's data folder.** `unit_tests` use a directory of
  their own in the system's temporary folder, and `tooling/dev test` fails a run that
  leaves a test's folder in Stedding's or Chromium's data folder (S-220).
- Chromium's own recovery ("Restore pages?") keeps working.

### UX completeness — the definition of "shipped"

A feature is shipped only when all of the following exist. Missing any of them, it is
not shipped, whatever the merge state.

1. **Keyboard shortcuts** for its primary actions, listed in the in-product shortcut
   reference, and not conflicting with each other or with Chromium shortcuts that
   `docs/PRODUCT.md` does not deliberately remap. Every deliberate remap is in the
   shortcut reference.
2. **A settings entry** for every behaviour a reasonable user would want to change,
   findable in settings search and the command bar.
3. **Edge cases:** 0 items, 1 item, hundreds of items; extreme window sizes; fullscreen;
   several windows and displays; RTL text where user content is shown.
4. **Empty states** designed — a new Space, an empty sidebar, no command-bar matches —
   worded as `docs/VISION.md` ("Brand and voice") asks, never a blank panel.
5. **Interruptions.** The feature behaves sanely across restart, crash recovery and
   update.
6. **Documented** in the feature's spec (`docs/features/`), the user pages it changes
   (README, SHORTCUTS, FAQ) and the release notes.

The check is a written pass per feature per release, stored with the release. No release
has stored one yet. Each spec's rows and their tests are the record so far.

### Accessibility

- **VoiceOver.** Every Stedding surface (sidebar, Spaces, command bar, split controls,
  settings) is navigable and operable with VoiceOver: correct roles and labels, focus
  announced, no unreachable control. A scripted VoiceOver pass per release. Not done for
  any release yet (S-140, S-141, S-148; sidebar Y15 in S-129).
- **Full keyboard use.** Every action the mouse can do has a key. Focus is always
  visible. There is no focus trap. Checked by completing the UX walkthrough with the
  mouse disconnected.
- **Contrast and scaling.** Stedding's UI meets WCAG 2.1 AA contrast, follows the
  system's "increase contrast" and "reduce motion", and stays usable at 200% display
  scaling.
- Chromium's existing accessibility does not regress. Patches do not break what upstream
  already does.

### Update safety

Applies from M7 (the first auto-updating release) on.

- **n-1 upgrade.** Before publishing version N, a machine running N-1 with a populated
  profile (Spaces, splits, pinned tabs, extensions, passwords) receives the update
  through the real channel, applies it, and relaunches with the state intact. This is
  part of the release checklist.
- **Skip-version upgrade.** The updater handles a user who missed releases. The oldest
  version that can upgrade directly is documented.
- **Rollback.** A documented, tested procedure returns a user from N to N-1 with the
  profile intact, or with a loss that is written down and bounded if a migration is
  one-way. A one-way migration takes an ADR.
- **What the updater sends.** What it transmits, and how often, is in `docs/PRIVACY.md`.
  No identifier beyond what the mechanism needs.
- A failed or interrupted update leaves the installed version working.

How it works (ADR 0022, ADR 0023, `docs/features/updates.md`, `docs/HANDOFF.md`, "The
updater"): a published release reaches installed copies only once it is offered in the
signed feed (`tooling/publish-appcast`, `tooling/win/publish-appcast.ps1`), after it has
been tried the way a user gets it. On the Mac the feed keeps the newest five releases,
and Sparkle takes the newest one the system can run, so a copy that has the updater goes
to the latest. Sparkle never installs an older version over a newer one. A bad release
is taken back by removing it from the feed at once (a `git revert` of its offer commit)
and fixing it in a later version. A profile a newer Chromium has opened is not promised
to open in an older one.

### Security

- **Upstream security bumps.** When Chromium stable ships a security update, the target
  is a rebased release within **7 days** for a fix of a vulnerability exploited in the
  wild, and within **14 days** otherwise. The gate is checked per upstream release. A
  miss is recorded in the release notes, with the reason.
- **The clock is started by a machine.** `.github/workflows/upstream.yml` runs daily,
  asks `tooling/check-pin` where the pin stands, and opens one tracking issue while the
  pin is not current. The check reads stable on every desktop platform. A point release
  on the milestone that ships reaches the other platforms at the same time, and a pulled
  macOS rollout would otherwise hide it.
- **No bundled analytics or tracking SDKs.** No third-party analytics, no crash
  reporting to a third party, no advertising SDK, no attribution SDK. Checked by a
  dependency audit and by the network capture below.
- **Network conduct.** Each release re-runs the M1 network audit. Every request from a
  fresh profile at first run and at idle matches the list in `docs/PRIVACY.md`. An
  endpoint the list does not name is a release blocker.
- **Signed releases** (from M7; on Windows from M8). Every published artifact is signed,
  and notarized on macOS, and the checksums are published with the release. The macOS
  image is signed and notarized from 0.2.0 beta 10. The Windows installer is not signed
  yet (S-56).
- Vulnerability reports are handled as `SECURITY.md` says.

### Release checklist

Every public release, from M7 on, ships only after each item is checked and the
completed list is stored with the release records. Releases before M7 use the items
that applied. Each beta's notes record what was checked ("How it was checked"). No
complete checklist has been stored with a release yet. Before a public 1.0, the codec
licence terms are recorded in an ADR that supersedes
`docs/decisions/0008-proprietary-codecs.md`.

1. The Chromium base is current stable, or the release notes say how it differs.
2. The full patch series applies cleanly, and the build can be reproduced from the
   documented steps.
3. Performance budgets are re-checked if the base version or the platform changed.
4. Stability: the soak, and the kill-and-restore test.
5. The UX completeness list passes for every shipped feature.
6. The accessibility walks pass (VoiceOver, and keyboard only).
7. The network audit matches the documented request list.
8. The artifact is signed, and notarized on macOS. Checksums are generated.
9. The n-1 auto-update is tested end to end on a real machine.
10. The rollback procedure is verified against this release.
11. The changelog is written: user-facing changes, known limits, the Chromium base. The
    page the browser opens after an update shows the release's new features and settings,
    each with a capture from the release build (stedding.dev, `src/data/whats-new.mjs`;
    `tooling/publish-release` checks it).
12. The git tag matches the artifact. The release is published with the checksums and
    the changelog.
13. The build is used for real on the platform being released, from the installer a user
    gets: a fresh profile, the first launch and its welcome flow, light and dark, a click
    on every kind of row, and the gestures the specs name, with the real pointer and
    keyboard (`docs/AGENT-LOOP.md`, "Real use, safely"). The core-loop script in
    `docs/features/acceptance.md` passes on that build, on each platform released, and
    the run is recorded in that file's table. A failed step gets a BACKLOG row and a
    failing test before the release goes out.
14. Both suites are clean with DCHECKs and the dangling-pointer detector on
    (`STEDDING_TEST_OUT=win-checks tooling/dev test all --no-build` on Windows,
    `STEDDING_TEST_OUT=mac-checks` on the Mac), and the lifetime suites are clean under
    ASan. A green release suite does not excuse a DCHECK failure, and a check that stops
    at the first failure hides the rest (trap 60).

If any item fails, the release does not go out. An exception is an ADR.
