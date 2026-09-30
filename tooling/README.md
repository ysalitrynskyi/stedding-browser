# tooling/

Scripts that build Stedding. The rule these exist to serve is in `../AGENTS.md`: the
documented procedure and the executed procedure must be the same thing, so anything a
contributor is told to do lives here as a script rather than as prose to be retyped.

Every script is idempotent, fails with the remedy rather than a stack trace, and reads
its configuration from `chromium-version` — never from a value typed twice.

## The files

| File | What it does |
|---|---|
| `dev` | **Start here.** `build`, `test <feature>`, `capture`, `patch`, `check`, `status` — the loop in [docs/AGENT-LOOP.md](../docs/AGENT-LOOP.md) as one command. Owns the feature→gtest-filter tables (unit_tests, components_unittests; Stedding's browser tests run whole). `test` lists what every part of the filter matches before it runs anything and stops when a part matches nothing; `--list` does only that. No retries: a test that passes only on its second run fails. |
| `assert-capture` | Checks a capture against a probe spec (points in DIPs with expected colour or luminance), optionally against a golden PNG. `--record` fills a spec from a capture you have inspected. `tooling/dev capture --assert <spec>` runs the spec's own capture command and checks it. |
| `probes/` | Probe specs. `window.json` is the reference window: sidebar edge, content corner radius, toolbar height, essentials grid, no Chromium buttons, switcher at the bottom. `ntp.json` is a fresh profile's new tab page: theme ground, the hint line, no shortcut tile (`docs/features/new-tab.md`). Probes with `w`/`h` check a box, for text and icons. |
| `drive` | Drives the built browser with synthetic clicks, drags and keys from a steps file (`drive-window.py`), captures after steps, and quits the launched pid so session files flush. Checks every step before it launches anything, refuses to start while another app with the same bundle id runs, and starts the browser in the background; any exit, Ctrl-C or kill quits that pid, then kills it. Input goes only to that pid while it is frontmost, and a click only where its window is on top. The real OS pointer moves: never on a machine someone is using. |
| `capture-state` | Photographs a browser state without input: a fresh profile in the state the feature params and switches describe (`--features`, `--stedding-welcome=<step>`, `--seed collapsed`), every window of the launched pid by id, a quit of that pid, the abort check. Refuses to start while another app with the same bundle id runs, starts the browser in the background, and fails if it ever becomes the frontmost app. Safe while someone is at the machine; how round 7 was verified. |
| `capture-windows` | Captures every on-screen window a pid owns, by window id, largest first — a dialog such as the welcome flow is the second file. Used by `capture-state`. `--largest PID OUT.png` captures the largest one only, on screen or not: `drive`'s `shot` step. |
| `drive-window.py` | The step runner behind `drive`. `--check <steps>` reads and checks a steps file and posts nothing. A button or modifier it pressed is always released, on an error or an interrupt too. |
| `window_by_pid.py` | The windows a launched pid (or its children) owns, and `--quit <pid>` for a clean quit of that one browser. Used by the capture and drive tools so they never touch another Stedding. |
| `status` | Prints what the repo and checkout actually contain (pin, patch count, tests per feature, backlog). Docs quote this instead of typing numbers. |
| `chromium-version` | The pinned upstream Chromium version. Single source of truth. Policy: [ADR 0007](../docs/decisions/0007-chromium-version-pin.md). |
| `lib.sh` | Shared paths, logging, and preflight checks. Sourced, never executed. |
| `bootstrap-depot-tools` | Verifies the host toolchain, then installs or updates `depot_tools`. |
| `sync-chromium` | Materialises the Chromium tree at the pin, outside this repository. Refuses under 150 GB free; `STEDDING_SYNC_MIN_FREE_GB` lowers the floor for a run that has done the arithmetic, never under 100 (HANDOFF trap 44). |
| `build-chromium` | `gn gen` + `autoninja` for a named configuration. |
| `apply-branding` | Copies `../branding/` assets over the checkout. Not a patch. |
| `apply-patches` | Replays the patch series onto the pin as commits on `stedding-work`. `--check` answers whether it would apply without touching anything, needs only git (no depot_tools, no Mac, no build), and reports which patches would need a three-way merge. The `series` workflow runs it. |
| `update-patches` | Turns those commits back into `../patches/`. |
| `fold-fix` | Folds fixes made in the working tree into an earlier commit of the series with git plumbing, no checkout: the fixed files are the only ones whose modification time changes, so siso rebuilds nothing else (HANDOFF trap 44). A conflict stops it before anything moves, and the branch moves only when the new tip's tree is the old tip's plus the fix. Run `update-patches` and `check-repo` after it. |
| `repair-checkout` | Rewrites git cache paths after a checkout is moved. |
| `update-pin` | Moves the Chromium pin to the newest stable and checks the series still applies. |
| `check-pin` | Is the pin current? Reports `current`, `behind` or `ahead` against stable on every desktop platform; `--self-test` runs the verdict on offline fixtures. The `upstream` workflow calls it. |
| `sign-release` | Sign and notarise a built app with Chromium's signing pipeline; `--check` lists what is missing (identity, notary profile, packaging dir) |
| `publish-release` | GitHub pre-release from `dist/`: tag `v<VERSION>`, notes from `docs/release-notes/<tag>.md`; `--check` first |
| `package-dmg` | Packages a built app into an installable `.dmg`. |
| `brand/generate.py` | Regenerates the whole brand system from one geometry file. |
| `check-repo` | Repository hygiene: shell portability, links, ADRs, patch series, the pin, traps, LF line endings, nothing tracked that is ignored, no machine paths; every test a spec row or BACKLOG cites exists and is in a `dev` filter. |
| `check-shell` | shellcheck at the pinned version over every script here, plus `bash -n`. CI calls this exact script. |
| `digest-sanitizer` | A test run's output as a few lines: the tests that crashed, each distinct DCHECK/FATAL once with the first frames that are this project's, each dangling raw_ptr as a pair (freed in / still held in), each AddressSanitizer report's head. `tooling/dev` calls it on any run with a finding; `STEDDING_TEST_LOG` keeps the raw output. Read findings through it, not raw (trap 60). |
| `dev test` with `STEDDING_TEST_OUT` | `STEDDING_TEST_OUT=win-checks` or `win-asan` points `tooling/dev test` at that output directory and sets the run-time flags (the detector flag, ASan's option string with the quoted symbolizer path) |
| `win/build.ps1` | One Windows build chunk: `gn gen` with the args file of `args/<config>.gn`, `autoninja`, a progress line a minute (steps, compilers, commit charge), a budget. `-Jobs` caps the steps; exit 0 built, 1 failed, 2 budget stop, 3 stuck |
| `win/build-until-done.ps1` | The build to the end, detached: `build.ps1` chunk after chunk, status in `out\<config>\supervisor.log` ending in `SUPERVISOR_EXIT=<n>`, exit 4 on steps killed at three stops in a row. Wait for that line; do not poll a clock (traps 9, 54, 57) |
| `win/drive.ps1` | The window used for real: pointer, keyboard, a window-only screenshot, rows and buttons by UI Automation, the visible page by DevTools, guarded (only into the window under test, only while the operator's hands are off). Ask the operator first (trap 27, trap 58) |
| `win/capture.ps1`, `win/cdp.ps1`, `win/uia-dump.ps1`, `win/hit-test.ps1` | Looking without touching, for when real input is not allowed: a window rendered by `PrintWindow`, JavaScript in a page over DevTools, every view with its bounds, what the frame answers at each row (traps 36, 37) |
| `win/test-installer.ps1` | The installer against a real install, one step per call (`status`, `backup`, `upgrade`, `uninstall-keep`, `install`), log in `dist\installer-test\`; it never deletes a profile and refuses to remove anything without a backup. Run it as a scheduled task of the user's, not from an agent's shell (trap 40) |
| `win/package-installer.ps1` | The release image in `dist/` from a built `mini_installer` (ADR 0018) |
| `check-geometry` | Re-measures the card's gutters and corner radius in `docs/images/*.png` against `probes/geometry.json`. Needs Pillow; runs anywhere. `--report` prints the measurements. Not a CI check. |
| `verify-build` | Runs a built browser and checks it renders, does WebGL, and decodes video. |
| `measure/` | Performance harness and the fixed ten-site list for the QUALITY.md budgets. |
| `args/` | `gn` argument files, one per build configuration, with the reasoning per flag. |

## Normal use

```bash
tooling/bootstrap-depot-tools     # once per machine
tooling/sync-chromium             # once per pin change
tooling/apply-patches             # our patch series
tooling/apply-branding            # our name and icon
tooling/build-chromium release
tooling/verify-build --app ~/chromium/src/out/release/Stedding.app
tooling/package-dmg release
```

## Following upstream

```bash
tooling/update-pin                # is there a newer stable? changes nothing
tooling/update-pin --apply        # take it, sync, check the series still applies
```

A scheduled workflow (`.github/workflows/upstream.yml`) runs this comparison daily and
opens a single tracking issue when we fall behind. A patch that conflicts on a routine
point release is in the wrong layer — see
[docs/ARCHITECTURE.md](../docs/ARCHITECTURE.md).

Full prerequisites, measured build times and sizes, and known failure modes are in
[docs/ARCHITECTURE.md](../docs/ARCHITECTURE.md#build-system).

## Branding

Branding is asset replacement, not patching: upstream's switch is boolean and grit
hardcodes the `chromium/` theme path, so our files overwrite that tree in place. It
must run before `gn gen`, and it leaves the Chromium checkout dirty on purpose so
`git status` shows exactly what changed.

```bash
tooling/apply-branding --check     # what would change; touches nothing
tooling/apply-branding             # copy branding/ into the checkout
tooling/apply-branding --revert    # restore Chromium's originals
```

Order matters when both are in play: `apply-patches` first (it requires a clean tree),
then `apply-branding`, then build.

## Patch workflow

Commits are the working representation; `../patches/` is the serialised form.

```bash
tooling/apply-patches             # series -> commits on stedding-work
# ... edit, commit, reorder, rebase ...
tooling/update-patches            # commits -> series
tooling/check-repo patches        # verify the result
```

Every patch commit message must carry `Why:` and `Removable when:` fields.
`update-patches` refuses to export a series without them, because a patch nobody can
justify or delete is how a minimal patch set stops being minimal.

### `capture-ui`

Execs `capture-state` with the same arguments, so older commands still run. It
does not look up a window itself. With no `--out`, the image is `ui-capture.png`
in the repo root; with no `--url`, the page is example.com.

```
tooling/capture-ui --out /tmp/now.png --size 1400x880
```


## Paths

All overridable by environment variable; defaults suit a fresh machine.

| Variable | Default | What |
|---|---|---|
| `STEDDING_ROOT` | the repository root | This repository |
| `DEPOT_TOOLS_DIR` | `~/depot_tools` | Chromium's `depot_tools` |
| `CHROMIUM_ROOT` | `~/chromium` | `gclient` checkout root |
| `CHROMIUM_SRC` | `$CHROMIUM_ROOT/src` | Chromium source tree |

The Chromium tree is never committed to this repository.
