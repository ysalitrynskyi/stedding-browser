# tooling/

Scripts that build, test, capture and release Stedding. Anything a contributor is told to do lives here as a script, so the procedure in [AGENTS.md](../AGENTS.md) and the command that runs it stay the same thing.

The Chromium pin is [chromium-version](chromium-version), and only there ([ADR 0007](../docs/decisions/0007-chromium-version-pin.md)). Scripts that need the pin read that file.

Shell scripts run on macOS arm64. Those not marked **(macOS)** also run in Git for Windows' bash on x86_64. `win/` is PowerShell.

## The files

| File | What it does |
|---|---|
| `dev` | **Start here.** `build`, `test`, `capture`, `patch`, `check`, `status`, `features`: the loop in [docs/AGENT-LOOP.md](../docs/AGENT-LOOP.md) as one command. `build` is macOS. On Windows it refuses, the build is `win/build.ps1`, and `test` takes `--no-build`. It owns the feature filters for `unit_tests` and `components_unittests`. `test` takes `<feature>`, `unit`, `browser`, `all` or `rebase` (Chromium's wider tab suites after a pin move). It lists what every part of the filter matches and runs nothing when a part matches nothing. `--list` only lists. There are no retries. With no filter, `test browser` runs two legs: the rest of the suite `STEDDING_BROWSER_JOBS` at a time (default 4 on both platforms), then `SERIAL_BROWSER_TESTS` one at a time ([docs/HANDOFF.md](../docs/HANDOFF.md) trap 88). On the Mac that serial list also includes `WindowButtonsTest`'s three full-screen cases. A filter on the command line runs one at a time. `STEDDING_TEST_OUT` names another output directory (`win-checks`, `mac-checks`, `win-asan`). A name containing `checks` turns on the dangling-pointer detector. A name containing `asan` sets `ASAN_OPTIONS`, with the symbolizer path quoted, when that variable is unset. |
| `assert-capture` | Checks a capture against a probe spec (points in DIPs, expected colour or luminance), and optionally a golden PNG. `--record` fills RGB probes from a capture you have inspected. `tooling/dev capture --assert <spec>` runs the spec's `capture` command and checks it. `probes/window.json` is the spec written that way. |
| `probes/` | Probe specs. `window.json` is the reference window: sidebar, content card and its corner, address row, essentials, gutters, the Space chip at the bottom, and the absence of the tab-search combo, the avatar and the new-tab pill. `ntp.json` is a fresh profile's new tab page: theme ground, the hint line, no shortcut tile ([docs/features/new-tab.md](../docs/features/new-tab.md)). `settings.json` is Settings, Stedding. `geometry.json` is what `check-geometry` measures. Probes with `w` and `h` check a box, for text and icons. |
| `drive` | **(macOS)** Drives the built browser with synthetic clicks, drags and keys from a steps file (`drive-window.py`), captures after steps, and quits the launched pid so session files flush. Checks every step before it launches anything, refuses to start while another app with the same bundle id runs, and starts the browser in the background. Any exit, Ctrl-C or kill quits that pid, then kills it. Input goes only to that pid while it is frontmost, and a click only where its window is on top. The pointer's own image, which macOS 27 draws as a Window Server window named "Cursor", does not count as a window on top. `shot` captures the window. `screen` captures the display it is on. In macOS full screen the address row is drawn in windows of its own, so it is in `screen` and not in `shot`. The real pointer moves. Run it only when nobody is using the machine. |
| `capture-state` | **(macOS)** Photographs a browser state without input: a fresh profile in the state the feature params and switches describe (`--features`, `--stedding-welcome=<step>`, `--seed collapsed`), or a page Chromium will not open from its command line (`--page chrome://settings/stedding`, through `devtools-page`). Captures every window of the launched pid by id, quits that pid, and checks the log for an abort. Refuses to start while another app with the same bundle id runs, starts the browser in the background, and fails if that browser becomes the frontmost app. Safe while someone is at the machine ([docs/HANDOFF.md](../docs/HANDOFF.md) trap 29). |
| `capture-ui` | **(macOS)** Runs `capture-state` with the same arguments, so older commands still work. With no `--out` the image is `ui-capture.png` in the repo root. With no `--url`, `--page` or positional URL, the page is example.com. `tooling/dev capture` calls it. |
| `capture-windows` | **(macOS)** Captures every on-screen window a pid owns, by window id, largest first. A dialog such as the welcome flow is the second file. Used by `capture-state`. `--largest PID OUT.png` captures the largest one only, on screen or not: `drive`'s `shot` step. With none on the current Space (the operator in a full-screen app) the first form takes the largest from another (trap 132). |
| `record-window` | **(macOS)** Records one window of a pid and nothing else, as video (ScreenCaptureKit's single-window filter, built from `record-window.swift` into a cache outside the repository on first use): `record-window PID OUT.mov MAX_SECONDS`, stopped early by SIGINT. The README demo's recorder by default, when `swiftc` is available (trap 133). |
| `devtools-page` | Opens a page in a browser tooling launched with `--remote-debugging-port=0`, through its local DevTools endpoint (`/json/new`). No input, no focus change. `--close-new-tab` closes the launch's new tab page. Fails unless the tab reports the address asked for and a title, so a capture cannot pass for a page it does not show. Used by `capture-state --page`. |
| `readme/` | **(macOS)** The README's pictures and its animation, made from a build the same way every time. `capture-stills.sh` takes every still with `capture-state` (no input). `record-demo.sh` drives the storyboard ([docs/images/readme/STORYBOARD.md](../docs/images/readme/STORYBOARD.md)) with real input, records the window with `record-window` by default, and makes the GIF and the MP4 with ffmpeg. `promote-readme.py` writes `README.md` from `docs/readme-draft.md` once the draft has no `confirm-when-built` marker, every linked file exists, and `docs/images/readme/demo.gif` is at most 8 MB. [Its own README](readme/README.md) has the order of work. |
| `acceptance/` | The acceptance scripts of [docs/features/acceptance.md](../docs/features/acceptance.md), run with real input on a real build. `mac/run-mac.sh` **(macOS)** (`layout`, `tst6`, `tst7`, `tst9` or `all`) seeds a fresh profile with three Spaces (`seed-profile.py`), files the local pages of `pages/` into the fixture, renders the steps files of `templates/` for `drive`, and keeps each run's captures and logs in a directory of its own. An app path drives an installed copy instead of `out/release`. `win/s173-live.ps1` (`-Part layout`, `tst6`, `tst7`, `tst9` or `all`; `-Exe` for an installed copy) is the same on Windows through `win/drive.ps1`. It finds rows, chips and buttons by UI Automation, and reads what a step did from UI Automation and from DevTools. Both move the real pointer and press real keys. Only with the operator's yes. |
| `drive-window.py` | **(macOS)** The step runner behind `drive`. `--check <steps>` reads and checks a steps file and posts nothing. A button or modifier it pressed is always released, on an error or an interrupt too. Each `hover` checks the window anew, about 0.2 s a step. `move X1 Y1 X2 Y2 SECONDS` glides the pointer on time. Its two ends are checked once, as a drag's are. |
| `window_by_pid.py` | **(macOS)** The windows a launched pid (or its children) owns, and `--quit <pid>` for a clean quit of that one browser. Used by the capture and drive tools so they never touch another Stedding. |
| `status` | Prints what the repo and checkout actually contain (pin, patch count, tests per feature, backlog). Docs quote this instead of typing numbers. `tooling/dev status` runs it. |
| `chromium-version` | The pinned upstream Chromium version. Single source of truth. Policy: [ADR 0007](../docs/decisions/0007-chromium-version-pin.md). |
| `lib.sh` | Shared paths, logging, and preflight checks. Sourced, never executed. |
| `bootstrap-depot-tools` | **(macOS)** Verifies the host toolchain, then installs or updates `depot_tools`. |
| `sync-chromium` | Materialises the Chromium tree at the pin, outside this repository. A full sync refuses under 150 GB free. `STEDDING_SYNC_MIN_FREE_GB` lowers that floor and will not go under 100 ([docs/HANDOFF.md](../docs/HANDOFF.md) trap 44). `--point-release`, when the checkout is already on the pin's milestone, uses 25 GB (`STEDDING_SYNC_POINT_RELEASE_MIN_FREE_GB`, at least 20). |
| `build-chromium` | **(macOS)** `gn gen` and `autoninja` for a named configuration. The default budget is 15 minutes. `--budget 0` has no limit. Runs `fetch-sparkle` before a Mac build. |
| `fetch-sparkle` | **(macOS)** Puts Sparkle 2.10.0's framework at `third_party/stedding_sparkle/` in the checkout, from its release archive checked against the digest pinned in the script, without the XPC services. Keeps the archive and Sparkle's tools (`sign_update`, `generate_keys`) in `~/Library/Caches/Stedding` (`STEDDING_CACHE_DIR` overrides the cache root). `--tools` prints the tools' directory. |
| `apply-branding` | Copies `../branding/` assets over the checkout, and runs `brand/product_name.py`. Not a patch. |
| `apply-patches` | Replays the patch series onto the pin as commits on `stedding-work`. `--check` answers whether it would apply without touching anything, needs only git (no depot_tools, no Mac, no build), and reports which patches would need a three-way merge. [`.github/workflows/series.yml`](../.github/workflows/series.yml) runs `--check`. |
| `update-patches` | Turns those commits back into `../patches/`. |
| `fold-fix` | Folds fixes made in the working tree into an earlier commit of the series with git plumbing, no checkout. The fixed files are the only ones whose modification time changes, so siso rebuilds nothing else ([docs/HANDOFF.md](../docs/HANDOFF.md) trap 44). A file the tip does not have is a new file of the fix, added to that commit and every later one. A conflict stops it before anything moves, and the branch moves only when the new tip's tree is the old tip's plus the fix. Run `update-patches` and `check-repo` after it. |
| `repair-checkout` | Rewrites git cache paths after a checkout is moved. `--check` changes nothing. Source files are left alone. |
| `update-pin` | With no flag, reports whether a newer stable exists and changes nothing. `--apply` moves the pin, syncs, and checks the series still applies. `--to <version>` names the version. It does not commit, push or build. |
| `field-trials` | What Chrome Stable turns on or off by field trial (Google's variations seed, which Stedding never receives) where the checkout's code defaults differ: feature, Chrome's share on the Mac and on Windows (100% is every client), Stedding's default per platform, the study, its limits and the `file:line` of the default. The request is Stable, for the pin's milestone, on the Mac and on Windows, decoded with the checkout's own `components/variations/proto`. `--save DIR` keeps the seeds. `--seed` reads saved seeds and uses no network. A standing step of every pin move ([docs/AGENT-LOOP.md](../docs/AGENT-LOOP.md); `S-240`). |
| `check-disclosure` | Checks a pull request against [CONTRIBUTING.md](../CONTRIBUTING.md), "AI tools": the form's AI assistance section answered, and its commits agreeing (an `Assisted-by:` trailer on each when a tool helped, no tool as a co-author). [`.github/workflows/disclosure.yml`](../.github/workflows/disclosure.yml) runs it on every pull request from the base branch's copy. `--self-test` runs its verdicts on fixtures. |
| `check-pin` | Is the pin current? Reports `current`, `behind` or `ahead` against stable on Mac, Windows and Linux. `--self-test` runs the verdict on offline fixtures. [`.github/workflows/upstream.yml`](../.github/workflows/upstream.yml) calls it. [`.github/workflows/checks.yml`](../.github/workflows/checks.yml) runs `--self-test`. |
| `sign-release` | **(macOS)** Sign and notarise a built app with Chromium's signing pipeline. `--check` lists what is missing (identity, notary arguments, packaging directory, the app). |
| `publish-release` | GitHub release from `dist/`: tag `v<VERSION>`, notes from `docs/release-notes/<tag>.md`, created as the repository's latest release. `--prerelease` marks a test release. The platform that publishes second adds its image to the same release. It refuses a tag that stedding.dev's page after an update does not show yet (`src/data/whats-new.mjs` in that repository). `--check` changes nothing. Afterwards it starts the website's rebuild and, for a Mac image, the Homebrew cask bump. The update feeds are a separate step. Only with the operator's word in chat ([AGENTS.md](../AGENTS.md), red lines). |
| `publish-appcast` | **(macOS)** Offers the release to installed copies ([ADR 0022](../docs/decisions/0022-sparkle-updates-the-mac.md)). Checks that `dist/`'s image is the release's and its app carries the updater, signs it with Sparkle's `sign_update`, writes `updates/appcast.xml` through `appcast.py`, signs and verifies the feed, and commits it. `--push` pushes that commit to `main`. Run it after the release has been tried the way a user gets it ([docs/HANDOFF.md](../docs/HANDOFF.md) trap 47). `--check` changes nothing. |
| `win/publish-appcast.ps1` | The Windows feed ([ADR 0023](../docs/decisions/0023-updates-on-windows-and-linux.md), [ADR 0026](../docs/decisions/0026-a-windows-update-key.md)). After `publish-release`, and once the release was tried the way a user gets it (trap 47): signs the installer, writes `updates/appcast-windows.xml`, signs the feed, and commits. `-Check` changes nothing. `-Push` pushes the commit to `main`. `-Feed` and `-Url` write a local feed for `win/update-n1.ps1` and do not touch the repository. |
| `appcast.py` | Writes and reads both update feeds, `updates/appcast.xml` and `updates/appcast-windows.xml`: newest item first, five kept. `selftest` checks it. |
| `win/update-key.ps1` | The Ed25519 key that signs Windows updates ([ADR 0026](../docs/decisions/0026-a-windows-update-key.md)). The key lives outside this repository. `-Create`, `-PublicKey`, `-Sign`, `-Verify`, `-Backup`. |
| `package-dmg` | **(macOS)** Packages a built app into an installable `.dmg`. With a notarized app and `STEDDING_SIGN_IDENTITY` and `STEDDING_NOTARY_ARGS` set, signs, notarizes and staples the image too. |
| `brand/` | `generate.py` regenerates the mark's assets from `mark.py`, the mark's one geometry file. `win_icons.py` makes the Windows icons from the same mark. `favicon.py` renders the default-favicon PNGs from `branding/favicon/world-www.svg`. `product_name.py` rewrites the product name in Chromium's string tables (`apply-branding` runs it). |
| `verify/` | The probe page and the media clips `verify-build` serves to the built app. |
| `shellcheck-version` | The shellcheck version `check-shell` and CI pin. |
| `check-repo` | Repository hygiene, the same command CI runs: no bash 4 syntax, links, ADRs, the patch series, the pin, trap numbers, LF line endings, nothing tracked that is ignored, no machine paths, every test a built or partial row names exists in the series, or is a Chromium test the check allows by name, unless that column starts with `none`, and every test the series defines that a spec row or BACKLOG cites is one a `dev` sweep runs, added sources are in a GN list, every file in `args/` keeps the shared settings, and a list of phrases that are no longer true. With no arguments it runs every check. A name runs one. |
| `check-shell` | shellcheck at the pinned version over every script here, plus `bash -n`. CI calls this exact script. |
| `digest-sanitizer` | A test run's output as a few lines: the tests that crashed, failed or timed out; each distinct DCHECK or FATAL once, with the first frames that are this project's; each dangling raw_ptr as a pair (freed in / still held in); each AddressSanitizer report's head. `tooling/dev` calls it when the log has an AddressSanitizer report, a dangling-pointer report or a FATAL line. `STEDDING_TEST_LOG` keeps the raw output. Read those findings through it, not raw (trap 60). |
| `win/build.ps1` | One Windows build chunk: `gn gen` with the args file of `args/<config>.gn`, `autoninja`, a progress line a minute (steps, compilers, commit charge), a budget. `-Jobs` caps the steps. Exit 0 built, 1 failed, 2 budget stop, 3 stuck. |
| `win/build-until-done.ps1` | The build to the end, detached: `build.ps1` chunk after chunk, status in `out\<config>\supervisor.log` ending in `SUPERVISOR_EXIT=<n>`. Exit 4 when the same steps are killed at three stops in a row. Wait for that line. Do not poll a clock (traps 9, 54, 57). |
| `win/drive.ps1` | The window used for real: pointer, keyboard, a screenshot of the screen around the window, rows and buttons by UI Automation, the visible page by DevTools. Input goes only into the window under test, and only while the operator's hands are off. Ask the operator first (trap 27). |
| `win/capture.ps1`, `win/cdp.ps1`, `win/uia-dump.ps1`, `win/hit-test.ps1` | Looking without taking the pointer or the foreground, for when real input is not allowed (trap 36). `capture.ps1` renders the window with `PrintWindow` and can post a click to that window's queue. `cdp.ps1` runs JavaScript in a page over DevTools. `uia-dump.ps1` lists every accessible view and its bounds (trap 37). `hit-test.ps1` reports what the frame answers at each row. |
| `win/park-cursor.ps1` | Moves the real cursor to the primary screen's bottom-right corner before the browser tests, so a cursor resting where test windows open does not expand a sidebar on hover (trap 78). It moves the cursor only when nobody has touched the mouse or keyboard for ten seconds. `tooling/dev` runs it before each browser leg on Windows. |
| `park-cursor` | **(macOS)** The same on the Mac: the real cursor to the main screen's right edge, halfway down (not a corner, which may be a hot corner), under the same ten-second rule. `tooling/dev` runs it before each browser leg on the Mac. |
| `win/test-installer.ps1` | The installer against a real install, one step per call (`status`, `backup`, `upgrade`, `uninstall-keep`, `install`). The log is in `dist\installer-test\`. It never deletes a profile and refuses to remove anything without a backup. Run it as a scheduled task of the user's, not from an agent's shell (trap 40). |
| `win/update-n1.ps1` | The Windows updater's n-1 check. An installed copy, pointed at a local feed (`-Feed`), finds the next build, installs it, and the pill restarts into the new version. Run it in the user's own session (trap 40). |
| `win/package-installer.ps1` | The release image in `dist/` from a built `mini_installer` ([ADR 0018](../docs/decisions/0018-windows-installer.md)). |
| `check-geometry` | Re-measures the card's gutters and corner radius in the captures named in `probes/geometry.json`. Needs Pillow. Runs anywhere. `--report` prints the measurements. Not a CI check. |
| `verify-build` | **(macOS)** Runs a built browser and checks that it launches, renders a page, draws WebGL 1 and 2, and decodes video, including H.264 and AAC. It also opens full screen for about ten seconds. `--no-fullscreen` skips that. |
| `measure/` | **(macOS)** Performance harness: the ten live sites (`sites.txt`) and the ten local pages (`sites-local.txt`) for the quality bar's budgets ([docs/ROADMAP.md](../docs/ROADMAP.md#the-quality-bar), [docs/perf/README.md](../docs/perf/README.md)). |
| `args/` | `gn` argument files, one per build configuration, with the reasoning per flag. |

## Normal use

On the Mac:

```bash
tooling/bootstrap-depot-tools     # once per machine
tooling/sync-chromium             # once per pin change
tooling/apply-patches             # the patch series
tooling/apply-branding            # name and icon
tooling/build-chromium release --budget 0   # 0 = no time limit; the default stops at 15 min
tooling/verify-build --app "$CHROMIUM_SRC/out/release/Stedding.app"
tooling/package-dmg release
```

On Windows, from Git for Windows' bash, run the same sync, patches and branding. `depot_tools` has to be at `DEPOT_TOOLS_DIR` already. `bootstrap-depot-tools` is macOS. The build runs detached with `win/build-until-done.ps1` (wait for its `SUPERVISOR_EXIT=` line) and `win/package-installer.ps1` makes the installer. Both read `STEDDING_CHROMIUM_SRC`.

## Following upstream

```bash
tooling/update-pin                # is there a newer stable? changes nothing
tooling/update-pin --apply        # take it, sync, check the series still applies
tooling/field-trials --save DIR   # Chrome Stable's field trials against the new pin's code defaults
```

[`.github/workflows/upstream.yml`](../.github/workflows/upstream.yml) runs `tooling/check-pin` every day. When the pin is not `current` (`behind` or `ahead`) it opens one tracking issue, or updates the open one. When the pin is `current` again it closes that issue. The run fails only when the question could not be answered.

If a routine point release regularly needs a manual merge, those patches are in the wrong layer. See [docs/ARCHITECTURE.md](../docs/ARCHITECTURE.md).

Prerequisites, disk floors and the sizes those floors cite are in [docs/ARCHITECTURE.md](../docs/ARCHITECTURE.md#build-system). Wall-clock build times are not recorded there. [Known failure modes](../docs/ARCHITECTURE.md#known-failure-modes) follow that section.

## Branding

Branding is asset replacement, not patching. Upstream's switch is boolean and grit hardcodes the `chromium/` theme path, so our files overwrite that tree in place. It must run before `gn gen`. It leaves the Chromium checkout dirty on purpose, so `git status` shows what changed.

```bash
tooling/apply-branding --check     # what would change; touches nothing
tooling/apply-branding             # copy branding/ into the checkout
tooling/apply-branding --revert    # restore Chromium's originals
```

Order matters when both are in play. `apply-patches` first (it requires a clean tree), then `apply-branding`, then build.

## Patch workflow

Commits are the working representation. `../patches/` is the serialised form.

```bash
tooling/apply-patches             # series -> commits on stedding-work
# ... edit, commit, reorder, rebase ...
tooling/update-patches            # commits -> series
tooling/check-repo patches        # verify the result
```

Every patch commit message must carry `Why:` and `Removable when:`. `update-patches` refuses to export a series without them, because a patch nobody can justify or delete is how a minimal patch set stops being minimal.

## Paths

All overridable by environment variable. Defaults suit a fresh machine.

| Variable | Default | What |
|---|---|---|
| `STEDDING_ROOT` | the repository root | This repository |
| `DEPOT_TOOLS_DIR` | `~/depot_tools` | Chromium's `depot_tools` |
| `CHROMIUM_ROOT` | `~/chromium`, or the location the first sync recorded in `.stedding-local` (local state, never committed) | `gclient` checkout root |
| `CHROMIUM_SRC` | `$CHROMIUM_ROOT/src` | Chromium source tree, for the shell scripts |
| `GIT_CACHE_PATH` | `$CHROMIUM_ROOT/.git-cache` | depot_tools git cache. The Windows sync does not use one |
| `STEDDING_CHROMIUM_SRC` | none; the PowerShell scripts require it | The checkout's `src` for `win/` |

The Chromium tree is never committed to this repository.
