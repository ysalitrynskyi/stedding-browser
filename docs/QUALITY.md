# Quality — the "ready-to-use" bar

This document defines what "ready to use" means for Stedding, as verifiable gates.
A gate is either green (the check passed, with evidence) or red. There is no "mostly".
Aspirations that cannot be checked do not belong here.

These gates apply per release. The roadmap (`docs/ROADMAP.md`) says when each gate
starts applying; from that point it applies to every subsequent release. 1.0 requires
all of them green on all supported platforms.

## Performance budgets (relative to vanilla Chromium)

Measured with `tooling/measure/harness.py all --sites local` against a vanilla build at
the same pin; the live list (`--sites live`) serves only the two absolute budgets.
Current numbers: `docs/perf/README.md`.

Stedding is Chromium plus patches, so performance is measured as **overhead relative to
vanilla Chromium at the same pinned version, same build configuration, same hardware**.
Absolute numbers depend on hardware and are not promised; the overhead budgets are.

Baselines land in two steps. At **M0** the *vanilla* Chromium numbers are measured on
the reference configuration and committed (machine model, OS version, Chromium version,
method, and raw numbers) — that is the "compared to what?". At **M1** Stedding is
measured against them at the same pin, and the overhead figures those budgets are
actually written against become real. Until each step happens its values are **TBD**. Re-measured whenever the Chromium base version changes and
on each new platform (M8, M9).

| Metric | Method | Budget vs. vanilla |
|---|---|---|
| Cold startup to usable window | Median of 10 runs, fresh profile, timed launch to first accepted input | ≤ 10% overhead |
| Warm startup | Median of 10 runs, existing profile with 10 restored tabs | ≤ 10% overhead |
| Memory, 10-tab session | Physical footprint summed over the browser process tree after loading the fixed 10-site list and idling 60 s, median of 5 runs | ≤ 10% overhead |
| Input latency, tab switch via sidebar | Keypress/click to target tab painted, median of 20 switches | ≤ 16 ms added over vanilla tab-strip switch |
| Command bar open | Shortcut press to bar rendered and accepting input, median of 20 | ≤ 100 ms absolute |
| Page load / rendering | Identical to vanilla | No measurable regression: we do not patch the rendering or network path |

The measurement harness is `tooling/measure/harness.py` and the ten-site list is
`tooling/measure/sites.txt`, so anyone can reproduce the numbers:

```bash
tooling/measure/harness.py all --app ~/chromium/src/out/official/Chromium.app --out vanilla.json
tooling/measure/harness.py all --app /Applications/Stedding.app            --out stedding.json
```

Two practical notes before running it. Measure the **`official`** build, not `release`:
the release configuration skips PGO and LTO, so numbers from it describe a browser
nobody ships. And a full run takes tens of minutes and needs working network — ten cold
launches, ten warm, and five memory runs that each load the ten live sites in
`tooling/measure/sites.txt` and idle for a minute. There is no offline mode; without
network the memory and warm legs fail, and the harness will tell you so rather than
publish a median over whatever survived.

Two things about the harness are worth knowing before quoting anything it prints.
It measures launch to **first painted frame** of a trivial local page — the browser
cannot accept input into a page it has not painted, which is the operational reading
of "launch to first accepted input". And it discards one warmup launch: the very first
run of a binary also pays to fault the executable into the OS page cache, a cost paid
once per machine rather than once per browser start, and large enough to swamp the
overhead the budgets are trying to detect.

Memory is summed **physical footprint**, not RSS. macOS reports several memory numbers
that disagree by a factor of three: summing `ps` RSS counts every shared page once per
process, which on a three-tab session measured 9599 MB against a real cost of 3104 MB.
Physical footprint is what Activity Monitor reports, and the harness reads it via
`proc_pid_rusage`, which agrees with `vmmap --summary` exactly. It is summed over the
launched process and its descendants — not over every process running from the app
bundle, which on a machine where anything else is driving a copy of the same browser
silently counts that too.

Expect a three-figure process count: with site isolation, an ad-heavy news page alone
contributes a process per cross-origin iframe. The harness reports the count alongside
the total, because a count that moves between two builds is itself a finding.

Metrics that depend on features not yet built (sidebar tab switching, command bar) are
absent from the harness rather than stubbed, and are added with the feature.

A budget miss is a release blocker; either the regression is fixed or the
budget is changed by ADR with the reasoning on record.

## Stability

- **Crash-free sessions:** because there is no telemetry, we cannot measure a fleet
  crash rate — we do not fabricate one. The gate is local and reproducible: a scripted
  8-hour soak (tab churn across workspaces, splits, command bar use, restarts) completes
  with zero browser-process crashes, and any UI-process crash reported by a user with
  reproduction steps is a release blocker until fixed or shown to be upstream.
- **No data loss on crash:** kill all browser processes (`SIGKILL`) during active use;
  on relaunch, session restore recovers all workspaces, tabs, splits, and sidebar
  state as of a few seconds before the kill. Tested before every release.
- **No data loss on upgrade:** covered under update safety below.
- Chromium's own recovery surfaces ("Restore pages?") must work, not be patched into
  a broken state.

## UX completeness — the definition of "shipped"

A feature is shipped only when all of the following exist. A feature missing any of
them is not shipped, regardless of merge state.

1. **Keyboard shortcuts** for its primary actions, listed in the in-product shortcut
   reference, not conflicting with each other or with Chromium shortcuts that
   `docs/PRODUCT.md` does not deliberately remap; every deliberate remap is listed
   in the shortcut reference.
2. **Settings entry** for every behavior a reasonable user would want to change,
   discoverable in settings search and the command bar.
3. **Edge cases handled:** 0 items, 1 item, hundreds of items; extreme window sizes;
   fullscreen; multiple windows and displays; RTL text where user content is shown.
4. **Empty states** designed — a new workspace, an empty sidebar, no command bar
   matches — with wording per `docs/BRAND.md`, never a blank panel.
5. **Interruptions survive:** the feature behaves sanely across restart, crash
   recovery, and update.
6. **Documented:** covered in the feature spec (`docs/PRODUCT.md`) and release notes.

The verification is a written checklist pass per feature per release, recorded with
the release.

## Accessibility

- **VoiceOver:** every Stedding surface (sidebar, workspaces, command bar, split
  controls, settings) is navigable and operable with VoiceOver: elements have correct
  roles and labels, focus is announced, no unreachable controls. Verified by a scripted
  VoiceOver walkthrough per release.
- **Full keyboard navigation:** every action available by mouse is available by
  keyboard; focus is always visible; no focus traps. Verified by completing the UX
  walkthrough with the mouse disconnected.
- **Contrast and scaling:** Stedding UI meets WCAG 2.1 AA contrast; respects system
  "increase contrast" and "reduce motion"; remains usable at 200% display scaling.
- Chromium's existing accessibility must not regress: our patches may not break what
  upstream already does right.

## Update safety

Applies from M7 (first auto-updating release) onward.

- **n-1 upgrade tested:** before publishing version N, a machine running N-1 with a
  populated profile (workspaces, splits, pinned tabs, extensions, passwords) receives
  the update through the real update channel, applies it, and relaunches with all
  state intact. This test is part of the release checklist, not optional.
- **Skip-version upgrade:** the updater handles a user who missed releases (oldest
  supported direct-upgrade version is documented).
- **Rollback path:** a documented, tested procedure returns a user from N to N-1 with
  profile intact (or with an explicitly documented, bounded loss if a profile
  migration is one-way — such migrations require an ADR).
- **Update transparency:** what the updater sends and how often is documented in
  `docs/PRIVACY.md`; no identifiers beyond what the update mechanism strictly needs.
- A failed or interrupted update leaves the installed version working.

## Security

- **Upstream security bumps:** when Chromium stable ships a security update, Stedding
  ships a rebased release within **7 days** for actively exploited (in-the-wild)
  fixes and within **14 days** otherwise. The gate is checked per upstream release;
  misses are recorded publicly in the release notes with reasons. This is the standing
  cost of running a fork — the patch series and build pipeline are designed around it.
- **No bundled analytics or tracking SDKs.** Zero third-party analytics, crash
  reporting to third parties, advertising, or attribution SDKs in the product.
  Verifiable by dependency audit and by the network capture gate below.
- **Network conduct:** each release re-runs the M1-style network audit — every request
  from a fresh profile at first run and idle matches the documented list in
  `docs/PRIVACY.md`. An unexplained endpoint is a release blocker.
- **Signed releases only** (from M7): every published artifact is signed (and
  notarized on macOS); checksums published with the release.
- Vulnerability reports handled per `SECURITY.md`.

## Release checklist

- Codec licence terms recorded per `decisions/0008-proprietary-codecs.md` (a superseding ADR) before any public 1.0 release.

Every public release, from M7 on, ships only after each item is checked off and the
completed checklist is stored with the release records. Pre-M7 releases use the
applicable subset.

1. Chromium base is current stable, or the divergence is stated in release notes.
2. Full patch series applies cleanly; build is reproducible from the documented steps.
3. Performance budgets re-verified if the base version or platform changed.
4. Stability gates pass: soak run, kill-and-restore test.
5. UX completeness checklist passes for every shipped feature.
6. Accessibility walkthroughs (VoiceOver, keyboard-only) pass.
7. Network audit matches the documented request list.
8. Artifact signed; notarized (macOS); checksums generated.
9. n-1 auto-update tested end-to-end on a real machine.
10. Rollback procedure verified against this release.
11. Changelog written: user-facing changes, known issues, Chromium base version.
12. Git tag created, matching the released artifact; release published with checksums
    and changelog.

If any item fails, the release does not go out. There are no exceptions that are not
written down as an ADR.
