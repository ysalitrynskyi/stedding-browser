# Handoff — how to pick this project up cold

Written for the next person continuing this work. AGENTS.md is the project context; this file is the operational knowledge that is otherwise only in one contributor's head. Read both.

## Fast path (the first hour)

`AGENTS.md`, "Your first fifteen minutes", is the order: `tooling/dev status`, `PLAN.md`,
`BACKLOG.md`, one message of questions to the operator (`docs/AGENT-LOOP.md`, "Ask once, up
front"), then use the product before any long job. The commands:

| To do this | Run |
|---|---|
| Build on Windows, to the end | `tooling\win\build-until-done.ps1 -Config win-checks -Targets unit_tests,stedding_browser_tests` (detached; wait for `SUPERVISOR_EXIT=`) |
| Build on the Mac | `tooling/dev build release chrome` |
| Checks build on the Mac | `tooling/dev build mac-checks unit_tests stedding_browser_tests` |
| Run the suites | `tooling/dev test all --no-build`; `STEDDING_TEST_OUT=win-checks` (`mac-checks`, `win-asan`) for a sanitizer build |
| Read a failing run | `tooling/digest-sanitizer <log>` (`tooling/dev` prints it when a run has a finding) |
| The Windows release gate | `tooling/win/release-gate.sh <version> <previous>`, started with `tooling\win\run-in-session.ps1` ("Release channel") |
| A test copy on the Mac | `tooling/test-copy make`, then `launch` and `quit` |
| Use the window | `tooling/drive <profile> <steps>` on the Mac; `. tooling\win\drive.ps1` on Windows |
| Find a string in the tree | `git grep -n <pattern> -- <dir>` in the checkout |

### Trap index

Read the trap for the topic in front of you, not the list. Retired: 10, 18, 28, 132, 141. Pointers to a fuller trap: 11, 15, 74, 79, 100, 115, 123, 125, 130, 136.

| Topic | Traps |
|---|---|
| Building, disk, rebuild cost, what a run leaves behind | 1, 16, 19, 23, 44, 45, 53, 54, 57, 70, 73, 83, 89, 90, 144, 146, 147, 149 |
| The working loop and the series | 5, 9, 13, 14, 17, 22, 50, 51, 89, 92, 134, 139 |
| Driving and capturing the window | 3, 7, 12, 24, 27, 29, 30, 36, 37, 52, 56, 59, 61, 63, 64, 65, 76, 78, 82, 93, 94, 95, 96, 103, 105, 107, 116, 121, 133, 137, 142 |
| What a test can and cannot prove | 2, 4, 31, 46, 48, 51, 52, 55, 56, 58, 59, 60, 66, 68, 69, 72, 75, 77, 78, 80, 81, 84, 86, 87, 88, 91, 98, 99, 101, 102, 104, 106, 107, 110, 111, 112, 113, 114, 119, 120, 126, 127, 138, 145, 150 |
| Windows | 32, 34, 36, 38, 40, 42, 53, 54, 55, 56, 57, 59, 62, 67, 68, 69, 70, 71, 91, 93, 98, 99, 101, 103, 106, 111, 113, 114, 116, 118, 121, 122, 128, 143, 145 |
| Release and signing | 44, 47, 49, 62, 85, 117, 118, 124, 129, 131, 140 |
| Chromium's and the platforms' own behaviour to know | 6, 8, 20, 21, 25, 26, 33, 35, 39, 41, 43, 60, 72, 73, 92, 95, 97, 98, 104, 105, 107, 108, 109, 110, 111, 113, 122, 135, 148, 150 |

## Where things live

- This repo holds the docs, the tooling, the patch series in `patches/`, and the branding. It is public. Never commit secrets or machine paths.
- The Chromium checkout lives outside this repo. `tooling/lib.sh` uses `~/chromium` unless `CHROMIUM_ROOT` is set or recorded in `.stedding-local` (local state, never committed). On Windows the checkout's `src` is `STEDDING_CHROMIUM_SRC` ("The Windows build"). Each checkout is pinned to `tooling/chromium-version`, on branch `stedding-work`. While you work, the commits on that branch are the source of truth; `tooling/update-patches` writes them out to `patches/`, which is what the other machine and CI apply. `tooling/apply-patches` resets a checkout to the pin and replays the series as commits on `stedding-work`. On a tree that already holds an older series, that rewrites every file the series touches; trap 89 is the route that rewrites only the files whose content differs. A series exported on one machine is built on the other before the release that carries it (trap 44).
- Build output on the Mac is `out/release`, with proprietary codecs on (`tooling/args/release.gn`). `out/official` is the performance baseline (`tooling/dev build official chrome`). Quote performance numbers from `official` (`docs/ROADMAP.md#the-quality-bar`). On Windows the output is `out\win-release` ("The Windows build").
- The website is https://stedding.dev, the private repository `ysalitrynskyi/stedding.dev`: Astro, static, Cloudflare Pages. At build time it reads the latest release from the GitHub Releases API. `tooling/publish-release` starts its Rebuild workflow, and that workflow also runs every six hours, so a published release reaches the download section without a commit there. The browser does not update from the site (ADR 0014). The site's own rules are that repository's `AGENTS.md` and `docs/DEPLOYMENT.md`. Keep this repository's README, `docs/INSTALL.md`, `docs/SHORTCUTS.md` and `docs/FAQ.md` true; the site is maintained from the same facts.

## The loop that works

The procedure is `docs/AGENT-LOOP.md`; the command is `tooling/dev`. Two tools it leans on:

`tooling/verify-build --app .../Stedding.app` checks that the app launches, renders a page, draws WebGL 1 and 2, and decodes a real frame of VP9, AV1, and H.264 with AAC. It also loads a page over the network (`--offline` skips that) and stays up in full screen (`--no-fullscreen` skips that).

On the Mac the capture step has two tools. Windows has its own ("The Windows build", step 5). `tooling/capture-state --out <prefix> --features 'SteddingArcStyleWindow:...' [switches] [URLs]` launches a fresh profile in the state the params describe, photographs every window that process owns by window id (a dialog is `<prefix>-2.png`), quits that pid through the Apple Event, and reports an abort from the browser log. It posts no input and changes no focus, and it stops if the browser becomes the frontmost app, so it is safe while someone is at the machine. A `chrome://` page is `--page`, not a command-line URL: Chromium opens the new tab page instead. `tooling/drive <profile> <steps>` clicks, drags and types. It is how you reach a context menu or a typed URL. It runs only when nobody is at the machine (trap 27): unlike `drive.ps1`, it does not watch for the operator's input.

## What needs which machine

The build configurations under `tooling/args/` are macOS and Windows. The Mac build script accepts Apple silicon only (`tooling/lib.sh`, `require_macos_arm64`).

The Windows PC is the development machine: it builds the series, runs both suites and drives the window ("The Windows build"). The Mac is needed for the macOS image: the Objective-C++ the series changes, against AppKit, with Xcode; its suites and the Mac-only checks; and signing and notarizing (`tooling/sign-release`). Three checks need no build:

- **The series applies.** `tooling/apply-patches --check` reads the pinned tree into a temporary index and applies the series there. Plain git: no depot_tools, no build, no macOS. Getting the tree is a `git init` plus one depth-1 fetch of the tag, with blobs and no working tree (about 1.4 GB). `git apply --cached` reads objects, not files. The `series` workflow does this on every change to `patches/` or the pin. Applying the series takes about twenty seconds. The workflow caches the Chromium objects under the pin, so a warm run skips the fetch (`.github/workflows/series.yml`).
- **The window's geometry.** `tooling/check-geometry` re-measures the card's gutters and corner radius in the captures named by `tooling/probes/geometry.json` (under `docs/images/`). It needs Pillow. It is not a CI check, so run it by hand after a recapture. Read a gutter as a band of window ground across the card: one pixel answers with whatever the page is showing. Fit the corner across the whole arc. The inset at the topmost scanline is not the radius; calling it one gives 8.7 for a 12 px corner.
- **shellcheck at the pinned version.** `tooling/check-shell` runs shellcheck and `bash -n`, and warns when the local version is not the one in `tooling/shellcheck-version`. CI installs that version and runs the same script. The Windows build of the pinned release runs under Git Bash through a one-line shim on PATH, so `tooling/check-shell` gives the same answer CI gives.

No CI runner can build, run the suites, drive a window or sign: that is `S-49`.

## Dev parameters (all on `SteddingArcStyleWindow`, tunable without rebuilds)

Metrics: `contents_corner_radius`, `card_gutter`, `location_bar_height`, `location_bar_width` (0 means no cap, which is how it ships), `toolbar_vertical_margin`, `toolbar_button_height`, `toolbar_button_inset`, `toolbar_button_icon_size`. The row metrics `vertical_tab_height`, `vertical_tab_corner_radius`, `vertical_tab_pinned_height` and `tab_favicon_size` are what the Comfortable density uses. Comfortable is the default (`stedding.sidebar.density` 0). Compact and Dense use their own figures.

State, for a capture or a test, because a headless harness cannot pin, fold or press the command bar: `extra_spaces/N` starts with N Spaces beyond the one every window already has. `pin_tabs/N` pins the first N tabs (the essentials row). `space_pin_tabs/N` pins the first N tabs in their Space, their URL as home, and `drift_tabs/N` then sends the first N of those to the next tab's page (a drifted pin, for pins H4 and H12). `folder_tabs/N`, when N is at least 2, wraps the first N tabs in a folder and nests the last of them one level down. `split_tabs` above zero puts the first two tabs side by side (toolbar T41). `open_command_bar/true` opens the command bar at startup. `drag_tabs_to_spaces` is on by default. `reduce_motion/true` turns Stedding's animation off, the same gate as the system's reduced motion (`docs/features/motion.md`).

Those startup-state params are compiled into `release` and `win-release`. An official build leaves the reads out (`#if !defined(OFFICIAL_BUILD)`).

Two switches do the same for windows. `--stedding-welcome[=<step>]` forces the welcome flow. The named steps are `search`, `import`, `appearance`, `behaviour`, `default` and `keys`. With no step the flow opens on its welcome screen; a named step opens on that step. `tooling/capture-state --seed collapsed` writes the collapsed rail (`vertical_tabs.collapsed_state`) into the fresh profile. `--seed grey-dark` writes dark mode with Customize Chrome's Grey (`browser.theme.color_scheme2` 2, `browser.theme.is_grayscale2`). Chromium keys an incognito window dark and grayscale the same way; Stedding's private window is a separate mark, and this seed keeps the ordinary coat (private V1). `--seed light` and `--seed dark` set the window's scheme whatever macOS is set to. `--seed horizontal` (or `horizontal-light`, `horizontal-dark`) turns vertical tabs off, for Chromium's horizontal strip. `--sidebar-width N` sets the open sidebar's width in DIP (`vertical_tabs.uncollapsed_width`), with any seed. A split, a tab group or pinned tabs in that strip come from an unpacked extension passed as `--load-extension=<dir>` with `--features ApiTabsSplitView` (`chrome.tabs.createSplit`, `chrome.tabs.group`).
## Traps this project already paid for (do not rediscover)

Each trap is the symptom, the cause and the rule that avoids it. Code and docs cite traps by number: never renumber. A trap whose cause is gone says "Retired"; one that repeats another points to it.

1. **siso stats sources once, near the start of a build.** An edit made after that is missing from the binary, and the build still succeeds. Do not edit the checkout until the build has finished. `tooling/dev build` refuses to start while a build runs; on the Mac, `tooling/build-chromium` also warns at the end if the tree changed.

2. **A screenshot cannot see teardown or input.** Anything that owns a tab needs a test: a use-after-free on close never shows in a capture.

3. **Synthetic input is `tooling/drive`.** It posts events only while its process is frontmost, and pointer input only where its window is topmost at the point; otherwise the step stops and names what is in the way, such as another app's window: move that window, and do not photograph the display to find it. Start with `activate`; grey traffic lights mean the window is not key, so check them before blaming a chord. The drive moves the real pointer and does not watch for anyone's input: never run it while someone is at the machine. It quits through an Apple Event, not ⌘Q.

4. **SIGTERM does not flush Chromium's session files.** A restore check that kills the process proves nothing; quit through an Apple Event, as `tooling/drive` does. The session service rebuilds its log from the live browser at startup and every 250 writes, dropping extra data a feature wrote: re-emit it through `stedding_session_rebuild.h` once the window is tracked, or it survives one restart.

5. **macOS bash is 3.2.** No `mapfile`, no associative arrays; `tooling/check-repo` rejects them. `tooling/check-shell` runs the shellcheck version in `tooling/shellcheck-version`, as CI does; a pass on a newer local shellcheck is not a pass.

6. **APIs in this tree.** `base::Value::Dict` and `List` are `base::DictValue` and `base::ListValue`. A token parses with `base::Token::FromString`, then `FromRawToken`. `BubbleDialogDelegateView` and `WidgetDelegateView` cannot be subclassed outside Views: change an existing view. `views::Separator` paints its whole bounds. FlexLayout stretches a child that declares no size; BoxLayout honours alignment.

7. **A tracked pref cannot be seeded from outside.** Chromium's pinned-tab pref is one (the anti-tamper check). Seed pins with the `pin_tabs` feature param.

8. **Colour mixers hand out one colour.** The dark ground is a gradient painted once on BrowserView (`SteddingWindowBackground`). The sidebar, the top container and the mat are made invisible over it, not removed: the layout dereferences their backgrounds.

9. **A sleep loop is not supervision.** A build prints progress every minute and stops when its budget runs out (`tooling/build-chromium --budget`, 15 minutes by default; `-BudgetMinutes` on Windows). On Windows, run `tooling\win\build-until-done.ps1` detached and wait for its `SUPERVISOR_EXIT=<n>` line; 4 means one step was killed at the end of three chunks in a row (trap 57). Before a wait over ten minutes, say where it stands, with a number.

10. **Retired.** A click no longer inherits the last chord: `tooling/drive-window.py` sets the modifier flags on every mouse event. A Ctrl-click is still a right-click on macOS.

11. **A window capture does not show another app covering the target.** Same as trap 3.

12. **`shot` is the largest window only**, by window id. A dialog the process owns, such as welcome, is in `shots`: every window of the pid, as the path, then `-2`, `-3`. `screen` is the whole display: use it only for macOS full screen, where the address row is a separate window.

13. **Branding is a copy, not a commit** (`tooling/apply-branding`). A sync, rebase or checkout that forces or stashes drops it, and the next build is `Chromium.app`; `tooling/fold-fix` keeps it. `tooling/drive` launches the last non-helper `.app` in `out/release`, so a stale `Stedding.app` beside the new build is what you drive. Run `tooling/apply-branding` before `gn gen`, and check `ls out/release/*.app`.

14. **A new `.grdp` part must be listed in `chrome/app/generated_resources.grd.gritdeps`**, in sorted order, or the build fails. Stedding's strings are the one file `chrome/app/stedding_strings.grdp`. A string that reaches a macOS menu or a toast needs a real `IDS_` id.

15. **Keys and clicks go nowhere until the window is key.** Same as trap 3.

16. **The Mac build refuses when free space is under the floor.** The floor is 60 GB; `STEDDING_MIN_FREE_GB` lowers it to 20 at least. The figure is Finder's, purgeable space included, not `df`, and the script prints it. Delete drive scratch profiles after a batch, and piled-up `$TMPDIR/dev.stedding.Stedding.chromium_chrome_url_fetcher_*` directories.

17. **The pin is scanned in every tracked file, patches included.** `tooling/check-repo` fails a non-documentation file that hard-codes the Chromium version (ADR 0007); only `tooling/chromium-version` carries it. A test of the version line uses a made-up one (`150.0.1234.5`).

18. **Retired.** `type` in `tooling/drive-window.py` puts the character on the key event, so the input source no longer changes what is typed.

19. **A new id in `chrome/app/chrome_command_ids.h` rebuilds most of the browser.** Stedding's command ids go in `chrome/browser/ui/stedding/stedding_command_ids.h`.

20. **On the Mac the focus manager sees a key before the focused view.** A text field that wants Tab never gets it, while a test that calls `HandleKeyEvent` directly stays green. Claim the key in `SkipDefaultKeyEventProcessing`, as the command bar does, and assert the claim. A panel that sizes itself from its rows recomputes its bounds on every rebuild path.

21. **Stedding's WebUI CSS and TypeScript are linted at build time.** stylelint wants a blank line before every rule and a short hex colour (`#fff`). A Lit handler is named `on<Context><Event>_`. A lint failure stops the build before any compile: read the first error line.

22. **A fix folded into an earlier patch can conflict with a later patch in the same include block.** Resolve it with the union of both sides, without duplicates. `tooling/fold-fix` stops before the branch moves if any commit conflicts. After a hand rebase, put branding back (trap 13) and check `git status` shows nothing else.

23. **Three small ones, each a wasted build.** zsh does not split an unquoted `$var`: pipe a file list through `xargs`. `tooling/dev` and `tooling/check-repo` live in this repo: call them by absolute path from inside the checkout. A command-bar row that depends on an asynchronous check is primed when the window is created, or the first actions-mode bar misses it.

24. **An unnamed Space takes its glyph and its name from its index.** Reordering two unnamed Spaces changes nothing a capture can see but the highlight and the title row. Give one an icon before capturing a drag.

25. **Views and build facts.** A `views::View` subclass, even in an anonymous namespace, needs `METADATA_HEADER` and `BEGIN_METADATA`/`END_METADATA`. `views::LabelButton::label()` is protected. `switches::kEnableFeatures` is in `base/base_switches.h`. A gn target is named after its directory unless the BUILD file says otherwise. A `Browser` has `GetProfile()` and no `window()` (use `BrowserWindow::FromBrowser`). `SkColorGetR` and the rest are macros. chrome://settings search finds a row but does not scroll to it.

26. **A test WebContents, a popup's bounds, and a shared extra Space.** `WebContentsTester::For` works only on a contents the harness or `WebContentsTester::CreateTestWebContents` made. A `ScopedUnownedUserData` must die before its host: a mark that must outlive a view belongs on `BrowserWindowFeatures`. `--window-size` and `--window-position` apply to every window the sizer places; a little window sets its own bounds after it exists (`little_window.cc`). `extra_spaces` adds its Space through the profile registry, so every new window shares it.

27. **Real input only with the operator's yes, and only through a driver that can refuse.** `tooling/drive-window.py` and `tooling\win\drive.ps1` send nothing unless the browser is in front (trap 3); `drive.ps1` also waits until the operator's last input is six seconds old. Without the yes, use `tooling/capture-state` or `tooling\win\capture.ps1`. Quit a browser a tool launched with `tooling/window_by_pid.py --quit <pid>`: an `osascript` quit addressed to the app also quits the owner's Stedding. A browser under `lldb --batch` never becomes key.

28. **Retired.** The apply script it described is gone; `tooling/update-patches` exports the series.

29. **`tooling/capture-state` photographs a fresh profile with no input.** It refuses while another process with the same bundle id runs, launches in the background with `--stedding-stay-in-background`, captures every window of that pid by id, quits it and deletes the profile; if the browser comes forward anyway, it captures nothing. The state comes from "Dev parameters" above. `tooling/drive` does not pass that switch: a drive needs the focus.

30. **The traffic-lights exclusion is a padded box.** macOS reports a box with an equal margin on every side, and the 12 DIP glyphs sit at its top, so a button centred on the box sits low (sidebar Y7). Compare two things within one capture. `tooling/capture-windows` omits the shadow, so every pixel is the window's.

31. **Run Chromium's own suites over the code the series changes.** `tooling/dev test upstream`, part of `test all`, runs them; after a pin bump, `tooling/dev test rebase` runs a wider ring. `browser_tests` and `interactive_ui_tests` are not built. A crash or a timeout prints no `FAILED` line: read the launcher's summary, which `tooling/dev test` prints.

32. **Read the exclusion on the strip's side.** The Mac's traffic lights are the leading exclusion, Windows' caption buttons the trailing one, and which of them lies over the strip depends on the strip's side (`OverStrip` in `stedding_browser_view_layout.cc`, sidebar Y41, Y42). A layout that skips every exclusion overlapping a vertical strip hides the Windows buttons.

33. **The rail's look follows the width being laid out.** Expanded on hover, a collapsed strip keeps its collapsed state at the open width. Key centring, icon-only rows, the stacked switcher and the opaque ground on `VerticalTabStripRegionView::IsRailWidth` (sidebar Y20), not on the collapsed state, or the hover overlay is dressed as a rail.

34. **A long virtualised `%LOCALAPPDATA%` blows past `MAX_PATH`.** A build started from an MSIX-packaged app inherits a redirected AppData, and vpython's venv path exceeds the limit. Set `STEDDING_VPYTHON_ROOT` to a short directory.

35. **A bubble asked for before the window is shown cannot anchor to a tracked element.** The element tracker knows a view only once its widget is visible, and the fallback anchor's `CHECK` kills the launch. With the app-menu button hidden, the "Restore pages?" bubble anchors to the top container (`AppMenuButton::GetAnchor`, toolbar T23). Anything that hides a toolbar button a startup bubble uses leaves a drawn view in its place.

36. **On Windows, capture without taking the focus.** `tooling\win\capture.ps1` renders with `PrintWindow` and launches with `CalculateNativeWinOcclusion` off, so a covered window still draws; its click is a posted `WM_LBUTTONDOWN`/`WM_LBUTTONUP`, never `SendInput`. It renders the largest `Chrome_WidgetWin_1` of the process, not `MainWindowHandle`. The default is scale 1 at 1400×880 DIP; a larger scale narrows the window in DIP, and Chromium then folds the forward button into the overflow.

37. **A layout a capture cannot explain is answered by the bounds.** Log every child's bounds after `Layout`, rebuild that one file, read the log, and take the log out before the patch is cut. On Windows, `tooling\win\uia-dump.ps1` reads the same tree with no build.

38. **Chromium reads Google Chrome's extension list whatever the branding.** On Windows its `ExternalRegistryLoader` reads Chrome's registry key and installs what it finds from Google's update server. Stedding does not create that provider (privacy Q9, patch 0039), which also leaves the Mac's Chrome folder unread. Ask the same of any other lookup keyed to Chrome.

39. **A WebUI `chrome.send` with no handler kills the browser.** It is a `NOTREACHED` in the browser process, not a console error. A handler compiled for one platform needs a `loadTimeData` boolean that the page checks before it sends.

40. **Test an installer outside an MSIX app's virtualised AppData.** An installer run from an MSIX-packaged app writes under the package's `LocalCache`, and the installed exe then fails to load. `tooling\win\test-installer.ps1` runs as the user's own scheduled task (a `/SC ONCE` task is gone the next day), never passes `--delete-profile`, and upgrades only after `-Mode backup`. Stop a test browser by the profile path on its command line, never by process name (`Drive-Stop`): the operator's Stedding is `chrome.exe` too (trap 143).

41. **Every Stedding build turns Chromium's field-trial testing config off.** Every file under `tooling/args/` sets `disable_fieldtrial_testing_config = true` (privacy Q10); without it Google's experiments switch on, official builds included, so a build from hand-written args runs them. The 2026 refresh features that config turned on are enabled in the source instead (patch 0042).

42. **Ctrl+Alt stays out of Chromium's main accelerator table.** `GetDefaultAcceleratorList` DCHECKs on a mapping with both modifiers (AltGr sends Ctrl+Alt), so a Ctrl+Alt row there kills a DCHECK build at startup. Stedding's Ctrl+Alt chords go in `kSteddingCtrlAltAcceleratorMap` (patch 0043). Where the layout gives the chord an AltGr character, `stedding::AltGrChords` runs it only for the left Alt (windows N14); a real AltGr layout is untried.

43. **A container takes its size from its layout.** A preferred height set by hand stays put when a child is added. A `BoxLayout` with a flexible child reports all the space it is offered: the sidebar's bottom row flexes the switcher only in the open form, or the rail's stack sits at the top (sidebar Y13).

44. **A fresh checkout needs the full disk floor, and an early autosquash rebuilds the rest.** `tooling/sync-chromium` wants 150 GB free (`STEDDING_SYNC_MIN_FREE_GB`, never under 100). On the Mac the dependencies borrow from the git cache by absolute path: run `tooling/repair-checkout` after moving the checkout. Fold a fix with `tooling/fold-fix`: an autosquash into an early patch checks out every later patch's files, and siso rebuilds them. Build a series on the other platform before the release that carries it.

45. **A point release is a delta, and nothing else may take the index while the series applies.** On the same milestone, `tooling/update-pin` syncs with `--point-release`: a 25 GB floor (`STEDDING_SYNC_POINT_RELEASE_MIN_FREE_GB`, never under 20). `tooling/apply-patches` uses `git am`, and a `git status` from another shell takes `index.lock` and stops it mid-series. Put branding back afterwards (trap 13).

46. **A green unit test is not a behaviour a person can reach.** Before a spec row says built, grep the checkout for a caller outside the tests. "Model only" means the helper and its test exist and no menu, key or setting reaches it. Shipped means reachable, with its test green.

47. **Try a release the way a person gets it: downloaded.** `tooling/verify-build` launches from the build directory, with no quarantine attribute, so it never meets Gatekeeper. Before the release is announced, `syspolicy_check distribution` passes on the app that goes into the image, and a downloaded copy opens.

48. **Full screen puts the toolbar in another widget.** macOS moves the top container into an overlay widget of its own. Convert a view another window may own only after `GetWidget()` says it is still this window's, or a CHECK fires (toolbar T24). `tooling/verify-build` opens in full screen for this; `--no-fullscreen` skips it.

49. **Sign with `tooling/sign-release`, and assess only after the ticket is stapled.** Until notarization finishes, every Developer ID app reads `Unnotarized Developer ID`; after stapling the script requires `source=Notarized Developer ID`. The signer waits two hours, and Apple can take longer. The signer's tests need Python 3.11; on another version, compare the failure list with and without the change.

50. **A milestone rebase is two jobs.** The conflicts are the first (`zdiff3` on). The port is the second, and the compiler lists it: build with `KEEP_GOING=1` (`-KeepGoing` on Windows) to get every error in one pass, and fold each fix into its owning patch with `tooling/fold-fix`. Resolve a fixup's conflict from the stage's side, ported, and a feature patch's from its own side; the tree-identity check catches a feature's dropped lines. The M157 port is trap 134.

51. **Chromium's search suites assert a Google default and an EEA-only choice.** Stedding's fallback is DuckDuckGo everywhere and its choice screen runs in every country (patch 0003). `tooling/dev test search` runs the cases about those two hunks. Other upstream suites (`DefaultSearchManagerTest`, `SearchEngineChoice*`, `RegionalCapabilitiesService*`, `TemplateURLPrepopulateDataTest`) still assert the old defaults and are in no filter: check a change to either hunk against them by hand.

52. **On the Mac, `ui::test::EventGenerator::MoveMouseTo` runs past its target.** It re-bases every step on the point just sent, so a drag overshoots. Drag and click the sidebar with `stedding::test::SendLeftMouse` and `ClickLeftMouse` after `WaitForRowsToSettle`, and a page's content with `content::SimulateMouseClickAt`. A background tab's renderer runs at low priority on the Mac: open it in front, or do not wait for it. A fix taken out and put back leaves its old objects: rebuild before a run that counts.

53. **`gclient sync --no-history` shallows a new clone, not an update.** An existing shallow dependency is updated with a fetch down to the shallow boundary, so a milestone move pulls history (M155 grew the Windows tree from 26 GB to 46 GB). Free space dips while packs arrive: do not read it a minute in. Cloning the dependencies again keeps them shallow.

54. **A full Windows build at siso's default parallelism runs out of memory.** On 32 threads and 32 GB it runs out of commit: compilers and Blink's generators fail, the paging file is too small, and the shell that started the build can die and orphan siso. None of that is the code. `tooling\win\build-until-done.ps1` uses 12 jobs (22 ran `win-checks` out of commit); `tooling\win\build.ps1` caps only with `-Jobs`. Read the commit charge before raising it, and stop an orphaned siso with `taskkill /F /T /PID`.

55. **Tests written on the Mac carry the Mac.** Before a Windows build of a new test: `<windows.h>` defines `near` and `far` away, so no variable takes either name; `FilePath::Append` takes no narrow literal (`AppendASCII`, `FILE_PATH_LITERAL`); compare paths through `NormalizePathSeparatorsTo('/')`; the selection chord is `ui::EF_PLATFORM_ACCELERATOR`, since `EF_COMMAND_DOWN` is the Windows key; a chord reads `Ctrl+Shift+K` off the Mac. A tab found by its title is lost once its page loads: keep the handle. A test that asserts one platform says which and why, and the other gets its own case.

56. **On Windows, start a test binary through `timeout`.** Started straight from an agent's shell, the row drags and a key typed into a page fail; under `timeout` they pass, for a reason not settled (trap 67). `tooling/dev` does this; anything else that starts a test binary from that shell uses `timeout` or starts it detached.

57. **An ASan-built `nasm` does not finish large assembly files unless `malloc_context_size` is 0.** In `win-asan`, three large media files take over 20 minutes each, and a budget kill leaves them as the only `FAILED:` lines; `tooling\win\build.ps1` sets `ASAN_OPTIONS=malloc_context_size=0` for an ASan build. ASan splits `ASAN_OPTIONS` on `:` and on space, so `tooling/dev` single-quotes the symbolizer's drive-letter path.

58. **Use the build before trusting the suites.** A fresh profile, the pointer and the keyboard, in light and in dark, find faults no test asked about (`docs/AGENT-LOOP.md`, "Order of evidence").

59. **A disconnected remote-desktop session fails the tests that need an active window.** `qwinsta` says `Disc` and `GetForegroundWindow` returns nothing, so drags find no window under the pointer, and checks builds can fail at exit. `tooling/dev` warns and still runs everything. Check `qwinsta` before chasing such a failure, and keep the session connected for a run overnight.

60. **Collect every DCHECK failure in one run.** A check that aborts at the first hides the rest. On `win-checks` or `mac-checks`, print every failure (`--test-launcher-print-test-stdio=always`), read them with `tooling/digest-sanitizer`, fix in batches, and run that build before ASan. Rules it has enforced: `BlendForMinContrast` needs an opaque background; a colour override starts with `ColorRecipe::Invariant()`; a `Label` on a layer that is not opaque turns subpixel text off; every focusable view has a role and an accessible name; a `raw_ptr` into the window is cleared before what it points at goes (a fixture's in `TearDownOnMainThread`); a renderer-initiated `NavigateParams` has an `initiator_origin`.

61. **Two browsers from one executable on the same `--remote-debugging-port` leave the second with a window and no UI.** DevTools answers for the first. Give each its own port (`tooling\win\drive.ps1 -DebugPort`), or stop the first (trap 40).

62. **An installer of the file version already installed repairs in place. A later release installs beside a running Stedding.** `tooling\win\build.ps1` writes Stedding's version into `chrome/VERSION` (`<milestone>.<100 × major + minor>.<patch>.<beta n, 999 for a release>`, updates Up14). The same version repairs, and fails while a running browser holds its folder; `tooling\win\test-installer.ps1` refuses while Stedding runs. The web still sees Chromium's version.

63. **A synthetic trackpad swipe that sets the line delta as well travels eight times as far.** Setting `kCGScrollWheelEventDeltaAxis2` on a pixel-unit scroll event makes macOS recompute the point delta from the lines. Post the point delta and the phases only, and read the event back through `[NSEvent eventWithCGEvent:]` before trusting it.

64. **Arc takes ⌥⌘N from any app while it runs.** It opens a Little Arc window and takes the focus, so a drive's remaining keys go nowhere. Drive Stedding's split with ⌃⌘N, which Arc leaves alone, or have Arc quit.

65. **Time a stall from a sample and from captures taken in process.** Run `sample <pid> 3 1 -file <out>` just before the action and read the main thread under the slow call. Photograph the window by id with `CGWindowListCreateImage` every few milliseconds; `screencapture` takes half a second a shot. Found this way (spaces B36): a label lays out whenever its font is set, so set it only when it changes; draw a glyph once per colour and size.

66. **`CompleteShutdown took more than 30 seconds` is the machine.** Under heavy load with swap full, tests crash there, including tests the change did not touch. Read `uptime` and `sysctl vm.swapusage` before reading a sweep, wait for a quiet machine, and leave other sessions' jobs running.

67. **Browser tests started over SSH need the signed-in session at normal priority, and their drags need the foreground.** `ssh` on the PC runs in session 0, where every browser test fails waiting for its window. A scheduled task with an interactive token (`schtasks /Create ... /IT`) runs in the operator's session but below normal priority, so Chromium stops before listing a test: its script sets `PriorityClass` to `Normal`, and the task gets priority 4 (trap 99). The row drags still need the foreground: run them at the desk, or say they were not run. Create such a task only with the operator's yes, and delete it afterwards.

68. **Off the Mac, `ui::test::EventGenerator` scales a click a second time when the display scale is not 1.** It hands over DIPs, and aura scales them again. A fixture that clicks through the generator calls `stedding::test::ForceScaleOneForEventGenerator`.

69. **A pointer at the edge of `GetWindowRect` is outside the window.** On Windows 10 and 11 that rectangle includes an invisible resize border of about 7 px, where the frame answers and no view hears the move. Aim inside `DWMWA_EXTENDED_FRAME_BOUNDS`, which `Drive-VisibleRect` returns.

70. **`SUPERVISOR_EXIT=6` means `build.ps1` refused to start.** It refuses while a browser from that output directory runs, because the link cannot replace `chrome.dll`. Stop your own test browsers first (trap 40) and leave the operator's running. It does not look for a running test binary, whose link then fails the same way: wait for the suite's last line before building into its directory.

71. **`drive.ps1` sends no input while the foreground window is not the browser under test.** A Windows Security prompt in front refuses every step. Answering it is the operator's call: say so, and do work that needs no screen until it is gone.

72. **A `raw_ptr` to a view inside a widget you own dangles when your object goes.** A delegate that owns its widget (`CLIENT_OWNS_WIDGET`) frees that view while its members are destroyed: a checks build crashes, a release build does not. Null the pointer in the destructor's body, as `WelcomeDialog` does, or declare it after the widget.

73. **`-Wunsafe-buffer-usage` is an error, so a loop that indexes a plain C array does not compile.** `chrome/` is checked. Use a `std::array` (`std::to_array`), or a range `for`.

74. **The supervisor defaults to 12 jobs. Raising that without room runs out of commit.** Same as trap 54.

75. **A container that lays out in view order draws a reorder only if it reorders its views.** `TabCollectionNode` reorders its list of children on a move, not its views. A `BoxLayout` follows view order, so `FolderView`'s `SyncRowOrder` puts the rows in the node's order before layout (folders F31). A new container that lays out by view order does the same, and its test reads drawn bounds.

76. **`Drive-Find` takes the first `Chrome_WidgetWin_1` wider than 300 px, which can be a dialog.** The welcome dialog qualifies, and so does Chromium's search-engine chooser. Launch with `--no-first-run` unless the flow is the subject, and call `Drive-Find` again after a dialog closes.

77. **A test that starts failing between two runs may be the machine.** Rebuild the last good code and run the same tests before bisecting the new code; that is one incremental build. A failure in code the change did not touch points here first.

78. **The real cursor over a test window fails the hover and edge tests.** A window that opens under a pointer that did not move hovers what lies under it: the sidebar expands, a row hovers, and a capture keeps the hover. `tooling/dev` parks the cursor before the browser suite and the serial leg, and `tooling/capture-state` before each launch, only after ten seconds with no input; `capture-state` also refuses to capture while the pointer is over the window. When the cursor was not parked, run again while the operator is idle.

79. **A `base::test::RunUntil` check must only look.** Same as trap 127.

80. **A filter part that names a test one platform does not build stops `tooling/dev test` on the other.** The lister refuses a part that matches nothing, and the sweep runs nothing. A suite only one platform builds goes in `MAC_FEATURE_FILTERS` or `WIN_FEATURE_FILTERS` in `tooling/dev`. Build a new filter on both machines before the release that needs it.

81. **A bubble placed while a Mac test window is still moving keeps the old place.** A bubble follows its window only when the window moves after it shows. Put test windows inside the screen's work area, and call `SizeToContents()` before measuring a bubble.

82. **`hover` posts one move. Leaving a view needs a path.** A hidden sidebar stays out when the pointer jumps away. Use `move X1 Y1 X2 Y2 SECONDS` (`tooling/drive`). In the command bar, send `key a+cmd` before `type`, or the old text stays in front of the new.

83. **A file put back from an archive keeps its old time, and the build skips it.** `tar` restores modification times, and a file older than the objects just built is not compiled again, files copied to the PC included. Extract with `tar xmf`, or `touch` what you put back. On the Mac, set `COPYFILE_DISABLE=1`, or the archive carries `._*` files.

84. **Browser tests pretend an OAuth client exists. A Stedding build has none.** `ChromeTestSuite` ignores the missing client, so `signin.allowed` is true in every browser test and false in a build. A test of signed-out behaviour appends `--allow-browser-signin=false` in `SetUpCommandLine`.

85. **A firewall that asks per program holds a newly signed build's connections.** On the Mac each signed build and each test copy is a new program, and an unanswered prompt stays above every app: `verify-build`'s network check stalls (run `--offline` and say so) and a guarded driver refuses any point under it. Chromium's network-time query goes out from every launch, so launch a test copy with `--disable-features=NetworkTimeServiceQuerying`. Crash dumps go to the default data folder's `Crashpad` whatever `--user-data-dir` says: move a test's out of the owner's folder.

86. **A layout that is right at rest can be wrong for the length of an animation.** A test that settles before it measures misses it. Step the animation (`BrowserAnimationController::SetAnimationContainerForTesting`) and check every step.

87. **A test that fails one run in a few can be the product's race.** Before trap 77's rebuild, put a `LOG(ERROR)` in the calls that should run and loop that one test with `STEDDING_TEST_LOG` set; `tooling/dev` appends each run's output. A view rebuilt between two passes has no bounds until the next layout.

88. **Most browser tests share the desktop. A few cannot.** Row drags, the pointer over the window, keys, the clipboard, picture-in-picture and a command bar held open across a wait fail, as a timeout, when another window covers them or takes the focus: a key reaches a window only while it has the focus, and Windows refuses `Activate()` from a background process. They are `SERIAL_BROWSER_TESTS` in `tooling/dev`, run one at a time after the rest run in parallel. A new fixture that drags, hovers, types or needs its window in front goes on that list. "M tests for serial" is a subset of "N tests for browser", not an addition.

89. **`tooling/apply-patches` rewrites every file the series touches, and the next build recompiles for hours.** It checks out the pin, `git am`s the series, and refuses the dirty tree branding leaves. To move a checkout that holds an older series, run `tooling/move-series` (`--check` lists what it would write): it rewrites only the files whose content differs. `tooling/update-patches` writing no change proves the tree is the series.

90. **A hook in a header much of the tree includes rebuilds most of the tree.** Count the includers (`git grep -l`) before adding to a header; that is why the session-storage hook has its own (`stedding_session_storage.h`). When putting a header back, `touch -r` it from an untouched neighbour and delete the objects built while it was changed (`find out/<dir> -name '*.o' -newer <marker> -delete`), or the next build mixes two layouts of one class.

91. **Only the Windows checks build sees a pointer left dangling when a window closes.** A raw pointer that a release build merely clears stops every test on `win-checks`, and a release shutdown crash can name the wrong function. In a round that adds a raw pointer on Windows, run the browser suite on `win-checks`, and read a release shutdown crash there.

92. **The sidebar's rows live in the region view's content area.** `content_area_view_`, a `FlexLayoutView`, holds the switcher, the Archived row, the bottom row and the update pill; the hover pill is on its own layer, outside layout. The rail's side margins are that area's interior margin. Its layer is not opaque: labels there turn subpixel text off (trap 60), and canvas text uses `gfx::Canvas::NO_SUBPIXEL_RENDERING`. On a port, append toast ids after upstream's last and move `kMaxValue` (trap 134), mark a new upstream engine in the welcome table, and fix an upstream test that assumes a default in the patch that changes it. `tooling/capture-state` takes a `chrome://` page as `--page` (opened through `tooling/devtools-page`), never on the command line, where Chromium opens the new tab page instead.

93. **A synthetic arrow without `KEYEVENTF_EXTENDEDKEY` is the numeric keypad's.** The arrows, Home, End, PgUp, PgDn, Insert and Delete need the flag; without it, with Alt held, a text field starts an Alt code and the accelerators never see the chord. `Drive-Key` sets it; any other sender must too.

94. **A clipboard manager takes ⇧⌘C from every app while it runs, as Arc takes ⌥⌘N (trap 64).** Copy Link then shows no toast. Ask the operator to quit both before a live keyboard check. When a chord does nothing, see what else is running before blaming the build.

95. **On macOS 27 the pointer is a window, and a guard that asks what is on top finds it.** `tooling/drive-window.py` passes over Window Server's "Cursor" window, the Dock's full-screen window, and the full-screen window Notification Centre keeps while a notification waits, except where its accessibility tree puts the notifications. Keep a drive's targets left of that stack, and do not click to dismiss it. A new check of what lies under a point needs the same exceptions.

96. **In macOS full screen a window point is not a screen point.** A `click` is in window points and a `screen` capture is the display; `tooling/drive-window.py` adds the window's origin when it posts. Convert a point read off a `screen` capture before clicking it, confirm with a capture, and do not reuse a fixed offset.

97. **On macOS 26 and later, a line under the full-screen title bar is the scroll pocket's.** It is `NSScrollPocket`'s hard edge, which the window's separator settings leave alone. `HideTitlebarPocketSeparators` turns the pocket's private `allowsSeparator` off (patch 0071). Look at the pocket before a separator view.

98. **On Windows `ui::test::EventGenerator` types the letter of every key it presses, Ctrl held or not.** It follows each key down with the plain letter's `WM_CHAR`, which a `views::Textfield` takes as text. Press a Ctrl chord into a focused field by dispatching a `ui::KeyEvent` down and up through `Dispatch`.

99. **Unit tests on mock time time out when their leg runs from a scheduled task at the default priority, and pass over SSH.** A task at priority 7 gives its processes low disk and memory priority, which `PriorityClass` (trap 67) does not change, and `FastForwardBy` waits on databases opening on that disk. After `schtasks /Create`: `$t = Get-ScheduledTask -TaskName <name>; $t.Settings.Priority = 4; Set-ScheduledTask -InputObject $t`.

100. **A test binary still running from an output directory makes the next link into it fail.** Same as trap 70.

101. **A theme change rebuilds the Space chips, so a test cannot hold them across one.** The Space tint and a page colour arrive a turn later and rebuild the switcher, freeing a raw pointer held across that wait. Track the chips with `views::ViewTracker` and take them again on `OnViewThemeChanged`.

102. **A drag that sends every move before any layout passes where a person's drag fails.** `TabDropTest::PressAndMove` sends all its moves before the window lays out, so a moved row is still drawn where the press found it. A drop onto something the drag can move (a folder header, its glyph in the rail) uses `PointerPressAndMove`, which settles the rows between moves. Assert `ShownWhole` first: in a short window or a scrolled list a drag aims at stale coordinates.

103. **A slept tab may never answer DevTools, so every wait in a driver needs its own clock.** `tooling\win\drive.ps1` bounds each wait (`Drive-Bounded` for UI Automation and the clipboard) and logs `TIMEOUT` for a call left behind. `Invoke-RestMethod -TimeoutSec` does not bound reading the answer. A new wait on the browser, on either platform, gets a bound and a log line.

104. **A title reaches the session file only when something writes the entry again.** Chromium writes an entry at its commit, before the page has a title, and again only from `NavigationEntryChanged`; later titles are written at most every 5 seconds (tabs R31). A loaded row shows the live title and hides an empty one in the file: check a row the restore has not loaded, or decode the files under `Sessions/`.

105. **A quit records every window it closed, and the next launch opens those windows again.** Chromium puts each window a quit closes on the recently-closed list. Stedding marks those tabs `stedding.archive.reopens` when the next launch reopens them, and the archive, the command bar, ⇧⌘T and the Recently Closed menus pass over them (archive A13, A15). Start such a check from a new profile.

106. **Expand-on-hover asks where the pointer is, not only the events a test plays.** `SetHoveredForTesting` stands in for the event, the on-strip and frame-active checks and the Windows exit debounce: `true` before the enter and move, `false` before the exit, `std::nullopt` after the last wait. The toggle's hover, the velocity heuristic and the leading edge read `SetPointerForTesting`'s point, else the real pointer. A rail drag turns expand-on-hover off first, or a pointer resting on the rail opens it.

107. **`--enable-automation` changes the browser under test.** It turns infobar slides off, shows the "controlled by automated test software" bar, skips other startup bars and sets `navigator.webdriver`. In-process browser tests and `s173-live.ps1` do not pass it; a test of the unanimated path asks for that path itself (`RemoveAllInfoBars(/*animate=*/false)`).

108. **The Mac's context menu draws the title, and a vector icon only where its menu icons are on.** It draws a row's label and icon, never minor text, and a vector icon only with `IsMenuSimplificationEnabled()` on macOS 26 or later. So `MarkSpaceItem` puts the words in the label on the Mac ("Work · Own session") and in minor text elsewhere: a test that compares a Space row's label with the bare name fails on the Mac.

109. **Replacing a tab's contents closes a tab-scoped toast.** A jar rebind and a sleep both replace the contents, and Chromium then clears every tab-scoped toast, as a navigation does. A toast that must outlive that is registered window-wide (`AddGlobalScoped`).

110. **App windows come back at start only after a restart or a crash.** Otherwise `ShouldRestoreApps` is false, and "Continue where you left off" restores no app window. A `PRE_` step that just ends records the app window's close; end it with `chrome::AttemptRestart()` under a `ScopedRelaunchChromeBrowserOverride` that starts nothing, which marks the next step a restart (`AppJarTest`).

111. **On Windows a new page's view reports the old page's background colour.** Aura copies the previous view's colour into the new one, so `GetBackgroundColor()` answers the page shown before until the new page draws. Read the content area's solid-colour layer instead (dark pages Dk7).

112. **Test pages on `127.0.0.1` are local tabs.** `stedding::IsLocalPage` counts `127.0.0.1` as this computer, so the active row wears the tape and a Comfortable row shows a host line (local tabs Lt6). Serve a page that must be plain with `GetURL("a.test", ...)` and `host_resolver()->AddRule("*", "127.0.0.1")`.

113. **Off the Mac a browser test draws nothing unless it asks.** On Aura, `BrowserTestBase` adds `--disable-gl-drawing-for-tests` unless the fixture calls `EnablePixelOutput()`, so a read-back is transparent black and a check it satisfies tests nothing. Call `EnablePixelOutput()` in the constructor; it also forces scale 1, so call it only under `USE_AURA`: the Mac draws anyway.

114. **Unit tests outside the desktop session on Windows read the system font at the screen's scale.** `unit_tests` does not call `base::win::EnableHighDPISupport()`, so outside the desktop session the system font and the DPI `gfx::SystemFonts` divides by can disagree: over SSH at 150%, a font-size test failed that passes at the desk. Run font-measuring unit tests in the desktop session.

115. **Keys sent to a test window go nowhere once another test has the foreground.** Same as trap 88.

116. **A window that is not in front, or whose first page is not visible, takes no key.** Windows keeps a window launched just after a script's own keys behind the foreground window, its pages hidden. `s173-live.ps1` brings it forward and waits up to 60 seconds for DevTools to call the first page visible. A first page that will not show is a busy machine only once the window is in front.

117. **A Mac copy updated through the real feed opens the default profile.** The check starts a released copy with its own `CrProductDirName`, but Sparkle replaces it with the published bundle, which names the real profile folder, and relaunches it. Quit the installed Stedding first, read the relaunched window, and quit it at once.

118. **A one-off task's window cannot take the foreground.** So `drive.ps1` refuses there. `tooling\win\update-n1.ps1` presses the update pill through UI Automation's Invoke pattern, and the Mac's check through `AXPress`; neither needs the pointer or the foreground.

119. **`host_resolver()` rules do not reach the tabs a launch opens.** Rules added in `SetUpOnMainThread` arrive after startup has opened the command line's addresses, which then commit error pages. Map the names with `--host-resolver-rules` in `SetUpCommandLine`, and check each page's title, not only its URL: an error page commits the address too.

120. **Python's `http.server` resets a burst on the Mac.** Its accept queue is five; macOS resets the connections that overflow it, and Chromium does not retry them, so a tab stays on the error page. A live check that opens more connections at once serves with `ThreadingHTTPServer` and `request_queue_size = 64`.

121. **On the PC, keys sent while an elevated window is in front are lost, and the modifiers stay down.** Windows drops a script's keys while a higher-integrity window such as Task Manager has the foreground. A Ctrl+Shift+W quit hands it the foreground mid-chord, the key-ups are lost, and the next launch reads Ctrl+W as Ctrl+Shift+W. Close Task Manager before a run, and release stuck modifiers only with an ordinary window in front. `s173-live.ps1`'s `Quit` still sends `ctrl+shift+w`.

122. **Windows takes some chords before the window hears them.** Alt+Escape, Ctrl down or not, sends the foreground window to the back, and the window gets no key message for it. A hot key comes first: the command bar registers Ctrl+Alt+Escape while the extensions chord holds (toolbar T39), and another program's hot key wins the same way. Ctrl+Alt+F4 and Ctrl+Alt+Space are not Alt+F4 and Alt+Space.

123. **Files copied to the PC with `tar xf` keep their Mac times, and the build may skip them.** Same as trap 83.

124. **A Stedding waiting to install an update stops the Mac's n-1 copies from checking.** Sparkle asks for an install in progress by the host's bundle id before it checks, so a test copy that keeps the real id makes no request and shows no pill. Give a retargeted copy a `CFBundleIdentifier` of its own; no script does this.

125. **`near` and `far` are macros on Windows.** Same as trap 55.

126. **On the Mac, a test window under the machine's resting pointer gets that pointer's events.** macOS sends events when a window moves under a pointer that did not, and a test's drag cannot share them. A drag test moves its window clear of the real pointer and fails if the pointer is still inside.

127. **A wait inside a `RunUntil` check never ends, and a settle loop can keep a layout from settling.** `base::test::RunUntil` runs its check while the loop is idle, so a check that waits itself (`DrawnRow`, `RowCentre`, `ShownWhole`, `WaitForRowsToSettle`) hangs until the test times out. Settle first; inside the check, only lay out and find (`RunScheduledLayout`, `FindDrawnRow`). After a row moves into a nested folder, settle with `WaitForRowsToSettleAtFramePace`: layouts with no frame between can find the folder at two heights forever. Neither wait covers a Space switch's slide (spaces B32).

128. **With no monitor on, the PC's console session can run at 1024×768 and the sidebar tests fail.** The test windows come up too small, and the layout and drag tests fail. Check the resolution before the Windows legs; nothing in `tooling/` does. Keep a remote-desktop window open, not minimized, and connected (trap 59).

129. **A real-feed check within five minutes of the feed's push sees the old feed.** GitHub serves `updates/appcast*.xml` with `max-age=300`. Wait five minutes after `publish-appcast`, or `curl` the served feed first; the scripts do not wait.

130. **On macOS 27 a waiting notification covers the screen, and only its stack takes the pointer.** Same as trap 95.

131. **A Windows update download at IDLE starves while a UI Automation client reads the window.** Polling the window starved the `BEST_EFFORT` sequence writing the installer, and GitHub reset the stalled stream. Patch 0078 downloads at `net::LOW` and retries within the hour. A screen reader is a UI Automation client too. The cause is not proven whole (S-279).

132. **Retired.** `tooling/capture-windows` takes the largest window from another Space when a full-screen app leaves none on the current one.

133. **Record the window, not the screen.** `screencapture -v -R` and ffmpeg's screen input record the whole display, covering windows included. `tooling/record-window` records the browser's window alone; `tooling/readme/record-demo.sh` uses it and paints back the traffic lights macOS 27 badges. Re-measure the scenes after a sidebar layout change.

134. **A rebase that merges cleanly can still drop a dependency, a brace or a number.** Read the end of every merge that kept both sides, and do not trust an enumerator, a default or a dependency that merged without a conflict. Rebase in a sparse worktree so the main checkout keeps building. From M157: a dependency on the removed `//chrome/browser/ui:ui` belongs on `//chrome/browser` (`gn check` lists the includes, S-335; `--fix` makes cycles, so fix by hand); per-tab helpers attach in `TabFeatures`; Stedding's toast ids are 63 to 71, 68 unused; `kUseActionsForBrowserCommands` stays off (patch 0074), or every Stedding command reads as disabled; Chromium pins an extension's toolbar button on install, and pinning it again fails a DCHECK (S-241).

135. **A row hears of a discard before its tab holds the discarded contents.** `TabDataObserver::OnTabDiscarded` runs from the will-discard callback, while `GetContents()` and `WasDiscarded()` still read the old page. Decide the row again once the swap is done, from a posted task (`TabView::UpdateTabData`, pins H29).

136. **A capture under the resting pointer keeps its hover.** Same as trap 78.

137. **A capture taken while another job loads the Mac shows pages still loading.** With a build or a test run going, page scripts time out and a tab keeps its spinner at any `--settle`. Take README and site captures on a quiet machine: no `siso`, `autoninja` or test binary, and a load under about 25.

138. **`--no-build` runs whatever test binary the output directory holds.** A stale binary passes without the round's newest tests. `tooling/dev test` names each binary older than a file the series changes. Compare a sweep's test count with the other configuration's before trusting it.

139. **A shell script edited while it runs can run the wrong lines when it returns.** Bash reads a script as it goes and resumes at a byte offset. Edit `tooling/` only while no `tooling/dev` runs, or put the file back byte for byte until it ends.

140. **`tooling/sign-release` empties `dist/signed`, which may hold the Stedding the owner is running.** A running app whose bundle is deleted breaks at its next helper. Sign from a worktree of this repository (`git worktree add --detach`, with `.stedding-local` copied in), then run `tooling/package-dmg --app <worktree>/dist/signed/stable/Stedding.app` in the main checkout, where `tooling/publish-release` reads `dist/`.

141. **`tooling/dev test` with `STEDDING_TEST_OUT` built `out/release` and ran the other directory's binaries.** Retired: `tooling/dev test` now builds the directory it runs. Trap 138 still applies.

142. **A shot is not taken at its step's moment: time a change that lasts under a few seconds from a recording.** `shot` runs `screencapture` and saves a file, so a second shot lands well after its `wait` says. Record the window (`tooling/record-window <pid> out.mov <seconds>`) and read frames with `ffmpeg -ss <t> -frames:v 1`.

143. **On Windows Stedding's own process is `chrome.exe`: never tell Chrome is running by the process name.** Read the profile's lock instead: `lockfile` in "User Data" on Windows, the `SingletonLock` link on the Mac, which may outlive a crash. The same goes for anything that counts or kills processes by name (trap 40).

144. **A round shipped to the PC as a patch must not rewrite files whose content did not change.** A `git checkout` of the last round and an apply of the next give every file of both a new time, and everything that includes them rebuilds. Apply the patch to a scratch index (`GIT_INDEX_FILE`, `git apply --cached`) and write out only the files whose blob differs from the disk.

145. **Windows browser tests assume a display scale of 1.** At 150%, geometry tests read an edge a DIP off from rounding alone. `tooling/dev test` forces scale 1 for a Windows release build's browser legs (`STEDDING_TEST_SCALE=native` keeps the display's); checks and ASan builds always run at the display's scale. Forcing does not change Windows' frame metrics (S-458). A change to window sizes, restore or hit-testing owes a native run. A test that needs a list to overflow fills it until it does, not to a fixed count.

146. **gclient refuses a git cache inside its checkout (depot_tools of 2026-11-09).** The cache lives beside the checkout (`$CHROMIUM_ROOT-git-cache`); `tooling/sync-chromium` stops with the commands to move it when it finds the old place. A sync that fails is not a synced tree: read the line before "apply" before trusting a series applied after it.

147. **Mac browser tests leave windows in WindowServer, and at about 17,900 it ends the login session.** Test windows outlive their processes and only logging out lowers the count; past the limit WindowServer restarts, logging the person out and quitting every app. `tooling/window-count` reads the count, and `tooling/dev` starts a Mac browser leg only under `STEDDING_MAX_WINDOWS`. After a build, a sweep or a release, run `tooling/leftovers --clean` (`tooling\win\leftovers.ps1 -Clean` on the PC) to end leftover processes, servers and mounted images and delete build logs and temporary files.

148. **A page in no tab strip has none of the tab's helpers.** A tab's `TabFeatures` makes `CoreTabHelper`, the favicon driver and `extensions::TabHelper`; `TabHelpers::AttachTabHelpers` does not. A page shown outside the strip, such as the peek, makes what it needs itself (patch 0176), and code that observes such a page assumes none of them. Each missing helper shows only as the next failure.

149. **Xcode's Metal toolchain is a component of its own, and an Xcode update leaves it uninstalled.** ANGLE compiles its internal Metal shaders during the build (`third_party/angle`, `metal_backend.gni`) through `xcrun metal`. Since Xcode 26 that toolchain is downloaded apart from Xcode, and the update to 27.2 did not bring its new version. Incremental builds kept the shaders compiled before, so nothing showed until a build into an empty `out/` failed at that one step 43 minutes in (2026-11-19). `tooling/build-chromium` now stops at the start when `xcrun metal` cannot run. The fix is `xcodebuild -downloadComponent MetalToolchain`. Until then, `STEDDING_METAL_TOOLCHAIN_DIR` names another toolchain's `usr/bin`, such as the one an earlier Xcode left mounted under `/private/var/run/com.apple.security.cryptexd/mnt/`, and the build passes it to ANGLE as `angle_metal_toolchain_dir`.

150. **A scroll view that scrolls with layers keeps its old size on the compositor's side until the next commit.** `ui::Layer::SetScrollOffset` scrolls through the compositor, which caps the offset at the size of its last commit (crbug.com/40772386). A scroll made in the same step that grew the contents is cut to the old size, and nothing reports it. On M158 on the Mac, Y26 failed 9 runs in 20 that way. That was the step where the tab list first overflows and gains its room past the last row, and the row stayed 4 DIP under the strip's edge. Before a test scrolls a view it has just resized, it calls `ScheduleFullRedraw()` on the widget's compositor and waits in `ui::DrawWaiterForTest::WaitForCommit`. No Stedding code scrolls a sidebar row into view; Chromium's strip scrolls the active tab itself.

## The Windows build

Git for Windows runs the bash tooling. PowerShell runs the rest. The toolchain is the installed Visual Studio (`DEPOT_TOOLS_WIN_TOOLCHAIN=0`, set by the scripts). Three variables name the machine's paths, so none is in the repo: `STEDDING_CHROMIUM_SRC` (the checkout's `src`), `STEDDING_DEPOT_TOOLS` when depot_tools is not already on `PATH`, and `STEDDING_VPYTHON_ROOT`, a short directory for vpython's venv (trap 34). The bash tooling takes the checkout as `CHROMIUM_ROOT`, the folder that holds `src`, as a POSIX path.

1. `tooling/sync-chromium` moves the checkout to the pin, then `tooling/apply-patches` puts the series on it, both before branding. Apply refuses a tree with uncommitted changes, and branding leaves tracked files modified on purpose (`tooling/status` counts what is left besides them). There is no git cache on Windows: `src` is one commit of the pinned tag, fetched by name the way `.github/workflows/series.yml` fetches it, and `gclient sync` uses `--no-history`. `--all-tags` is refused. A full sync wants 150 GB free. `--point-release`, a point release on the milestone the checkout already holds, wants 25. Trap 53 is what a milestone move costs: an update of a dependency that is already there is not shallowed.
2. `tooling/apply-branding`, from Git for Windows: the BRANDING file, the logos, the Windows icons, and the product name in every locale's tables. Before `gn gen`.
3. `tooling\win\build-until-done.ps1` builds to the end, detached. Status is `out\<config>\supervisor.log`. The last line is `SUPERVISOR_EXIT=<n>`. It runs `tooling\win\build.ps1` chunk after chunk and stops when the build is done, has failed, is stuck, or the same steps were killed at the end of three chunks (traps 9 and 57). `build.ps1` copies `tooling/args/<config>.gn` into the output directory, appends `stedding_version` from `VERSION`, runs `gn gen` and `autoninja`, and prints a progress line every minute (steps done, compilers, commit charge). `-BudgetMinutes` stops a chunk: exit 2 means it was still moving and a rerun resumes; exit 3 means no step finished and no compiler was running. `-KeepGoing` lists every error in one pass (trap 50). `-Jobs` caps the commit charge (traps 54, 74). The supervisor's default is 12. Alone, `build.ps1` builds `win-release`'s `chrome` and `mini_installer`. The supervisor also builds `unit_tests` and `stedding_browser_tests`. `win-checks` (DCHECKs and the dangling-pointer detector), `win-asan` and `win-debug` are for those test targets (`docs/ARCHITECTURE.md`, "Build configurations"). Off the Mac, `stedding_browser_tests` depends on `//chrome:packed_resources` (patch 0070), so a build of the test targets repacks `resources.pak` and the locale paks and the tests read that build's pages (S-213). A build is refused while a `chrome.exe` from that output directory is running. A test binary still running is not looked for, and the link fails the same way (trap 100).
4. `tooling/dev test all --no-build` (or one feature) runs the same filters against `out/win-release`. `tooling/dev test browser --no-build` runs `stedding_browser_tests` in two legs: most of them two at a time (`STEDDING_BROWSER_JOBS`, default 2 here and 4 on the Mac, trap 88) and the serial list one at a time, both through `timeout` (traps 56, 88). The default cap is 900 seconds. On a sanitizer build, set `STEDDING_TEST_OUT=win-checks` or `win-asan`: the run-time flags are set for you, and a finding is printed through `tooling/digest-sanitizer`. `STEDDING_TEST_LOG=<path>` keeps the raw output, one file per binary, emptied when a run starts. Every test that failed then runs again alone (`STEDDING_RERUN_ALONE`). A browser suite under ASan takes over an hour: `STEDDING_TEST_BUDGET_S=18000`, as the release gate sets. Run ASan builds at 10 jobs; more ran the PC out of memory. The session must be connected (trap 59).
5. Looking and driving. Each script is in `tooling\win\`:
   - `capture.ps1` captures the window and needs neither focus nor input (trap 36).
   - `cdp.ps1` runs JavaScript in a page over the DevTools websocket, and can screenshot that page.
   - `uia-dump.ps1` lists every accessible view with its name and bounds (trap 37).
   - `hit-test.ps1` asks what the frame answers at each row, with no input.
   - `drive.ps1` uses the real pointer and keyboard, takes a window-only screenshot, reads rows by UI Automation and the visible page by DevTools. The guards are trap 27. Ask the operator once first.
   - `package-installer.ps1` writes the release installer into `dist/`.
   - `tooling/publish-release`, from Git for Windows, publishes that installer beside the Mac's DMG (ADR 0018).

## Open items

Everything open is `BACKLOG.md`, in priority order. `PLAN.md` holds the owner's standing decisions and when an item is done. This file keeps no list of its own. What was built is `docs/PROJECT-LOG.md`. The notes for the current release are in `docs/release-notes/`. Every release's notes are on the [Releases page](https://github.com/ysalitrynskyi/stedding-browser/releases).

## The updater (Mac)

Sparkle 2 (ADR 0022, `docs/features/updates.md`).

- `tooling/fetch-sparkle` puts Sparkle 2.10.1 in the checkout at `third_party/stedding_sparkle/` (gitignored), with a `README.chromium` so the credits page names it. `tooling/build-chromium` runs that on every Mac build and sets `stedding_sparkle = true`. A build that never sets the flag has no updater.
- The feed URL and the EdDSA public key are in `chrome/app/app-Info.plist`. The feed is `updates/appcast.xml` on `main`, served from GitHub. `build/apple/tweak_info_plist.py` writes `CFBundleVersion` from `VERSION` (Up11).
- Only a bundle signed by a team starts the updater, so the ad hoc `out/release/Stedding.app` never replaces itself. Tests pass `--test-type` and use `stedding::FakeAppUpdater`.
- The private key is in the release Mac's login keychain under the account `stedding` (`generate_keys --account stedding`), and in the owner's backup. The repository does not hold it. Without that key no installed copy can be offered an update, and a new key reaches people only in a release they install by hand (ADR 0022).
- Offering a release is `tooling/publish-appcast` after `tooling/publish-release`, once the release has been tried the way a user gets it (trap 47).

With automatic updates on, a launch checks when the last check is over an hour old, ten seconds after that launch, and then every six hours while the browser runs (Up1, patch 0078). A launch inside that hour does not check again.

The local n-1 check, before a release that changes the updater or its feed. Sign two copies of one `out/release` build with the Developer ID (`STEDDING_SIGN_IDENTITY`) via `tooling/sign-release release --development`, which calls `sign_chrome.py --development --notarize none`. Lower `CFBundleVersion` on the older copy. Before signing, set three keys in each copy's `Info.plist` (a build has only `SUFeedURL`, so add the other two): `SUFeedURL` to a local server (`http://127.0.0.1:<port>/appcast.xml`; the app's `NSAllowsArbitraryLoads` allows it), `CrProductDirName` to a test folder, so the copy Sparkle relaunches still uses that profile, and `SUDefaultsDomain` to a test domain, so Sparkle's keys stay off the real app. Make the test folder and put a `First Run` file in it. A missing or empty folder is filled from `~/Library/Application Support/Chromium` when that folder holds a Stedding profile; a Chromium profile is left alone (windows N8). Without the file, a folder that was not filled is a first run and restores no tabs. Put the newer copy in a DMG signed with `sign_update`, write the feed with `tooling/appcast.py write --url ...`, sign the feed, and serve both with `python3 -m http.server`. Run the older copy from a folder of its own. It fetches the feed and the image, the sidebar shows the pill, and `AXPress` (no pointer) or a quit installs the newer copy in place. The relaunch's `CFBundleVersion` is the newer one, and the test profile's tabs come back.

The two copies share the real app's defaults domain (`dev.stedding.Stedding`, from `branding/BRANDING`), where Chromium writes `LastRunAppBundlePath` and the migration writes its decision. Export the domain before. Afterwards delete the domain and import the export: `defaults import` alone keeps keys the test added. Then stop both copies, delete the test profile and its cache, and `defaults delete` the test domain.

Use the Developer ID for that signing. An Apple Development identity makes macOS ask for the "Stedding Safe Storage" key, and a relaunch without `--use-mock-keychain` waits on it (`docs/ARCHITECTURE.md`).

Before a release that moves the pin or changes the updater, run the same check from the release people have installed. Take that release's app out of its DMG, change the same three keys, and sign only the outer bundle again with the same Developer ID:

```
codesign --force --sign <identity> --options runtime,library,restrict,kill --timestamp=none --preserve-metadata=identifier,entitlements,requirements
```

Nested code keeps the release's signatures. `--options` has to name the release's flags: once `--options` is given, `--preserve-metadata=flags` does not keep them. The newer copy is the new build, signed as above, with the next release's `CFBundleVersion`. Start the older copy with `--no-first-run`. Seed `Default/Preferences` with `{"stedding":{"welcome":{"shown":true}}}` so the relaunch does not open the welcome flow. A profile with no engine recorded can still open Chromium's search-engine chooser over the window (trap 76).

## The updater (Windows)

The browser's own updater (ADR 0023; its key, ADR 0026; `docs/features/updates.md` Up14–Up22).

- `chrome/browser/ui/stedding/app_updater_win.cc` is `stedding::AppUpdater` on Windows, started from `ChromeBrowserMainPartsWin::PostProfileInit`. `update_feed.cc` checks the feed's and the installer's Ed25519 signatures and picks the item, through the sandboxed XML parser. The feed URL and the public key are constants in `update_feed.h`. The feed is `updates/appcast-windows.xml` on `main`.
- The version. `tooling/win/build.ps1` writes the product version into the checkout's `chrome/VERSION` before `gn gen` (S-72): `<milestone>.<100 × major + minor>.<patch>.<beta>`, with 999 for a release. The milestone is the pin's: 0.6.1 on M157 is `157.6.1.999`. Chromium's own version stays on the next line, `CHROMIUM_VERSION`, which `version_info::GetChromiumVersionNumber()` returns for the user agent, the client hints, the Web Store, the component updaters and About. The file shows as modified, as the branding does. `git checkout -- chrome/VERSION` restores Chromium's, and `tooling/sync-chromium` does that before a sync. An unchanged version rebuilds nothing. A change rebuilds what includes the version headers.
- Only a copy the installer put in `%LOCALAPPDATA%\Stedding\Application` starts the updater (Up21). `out\win-release\chrome.exe` does not, and a test does not.
- The installer runs hidden, with `--do-not-launch-chrome --verbose-logging --log-file=...`. Chromium's in-use update leaves `new_chrome.exe` and the rename command in `HKCU\Software\Stedding`. `chrome::AttemptRestart`, or any quit, swaps it in (`chrome/browser/first_run/upgrade_util_win.cc`). `InstallerError` in that key is the installer's status: 30 is `IN_USE_UPDATED`, 31 is `SAME_VERSION_REPAIR_FAILED` (`chrome/installer/util/util_constants.h`; trap 62).
- The private key is on the Windows release PC at `%USERPROFILE%\.stedding\update-key`. `tooling/win/update-key.ps1 -Create` refuses to replace one. The key is encrypted and the passphrase is under DPAPI. The operator keeps a backup (`-Backup <folder>`). Without the key no installed Windows copy can be offered an update.
- Offering a release is `tooling/win/publish-appcast.ps1` after `tooling/publish-release`.

The schedule matches the Mac: ten seconds after a launch when the last check is over an hour old, then every six hours (Up14, patch 0078). `--stedding-update-feed` points a copy at a test feed, still checked with the same key. Plain http is allowed only for that test feed, and only to this computer.

The local n-1 check is `tooling\win\update-n1.ps1`. Build A at one `VERSION` and B at the next, and package each with `tooling\win\package-installer.ps1`. Install A over the installed copy with `tooling\win\test-installer.ps1 -Mode upgrade`. Do that from a one-off task, and read the registry from that task: a shell of an agent's app sees a virtualised copy with no `pv` and no uninstall entry (trap 40). Write B's feed with `tooling\win\publish-appcast.ps1 -Installer <B> -Feed <dir>\appcast-windows.xml -Url http://127.0.0.1:<port>/<B's name>`, put B's installer in that folder, and run `update-n1.ps1 -Feed <dir>` in the operator's own session. The script serves the folder, launches the installed A on a scratch profile with `--stedding-update-feed`, `--no-first-run` and the welcome already shown, and presses the pill through UI Automation (trap 118). The log ends in `N1_DONE`. About and `HKCU\Software\Stedding`'s `pv` should be B's version, and `new_chrome.exe` should be gone. `-TwoWindowPins` also checks the first launch's merge of each window's pins into the profile's store (ADR 0035, windows G19): before the update two windows of A pin pages with Ctrl+D, one address in both, and after the restart each window must show the three pins once (`PINS_MERGED`) and the closed profile's `stedding.pins.store` one record for each (`STORE_MERGED`); it presses keys, so it needs a connected session with nobody at the keyboard (trap 59).

## Release channel

Releases are GitHub Releases. `tooling/publish-release` creates one as the repository's latest, so the repository page and `/releases/latest` show it. `--prerelease` marks a test release instead. `gh release list` names the latest; `tooling/dev status` the pin and the patches. `VERSION` names the latest release, so the next release starts by bumping that file. The tag is `v` plus `VERSION`. The shipped platforms are macOS and Windows. The Windows image is built on a Windows PC and the Mac image on a Mac.

Installed copies update themselves from the feeds in `updates/`, served from GitHub: Sparkle on the Mac, Stedding's updater on Windows. The site is not on that path (ADR 0014).

The Mac image is a DMG. The app is signed with the Developer ID and notarized. `tooling/package-dmg` then signs, notarizes and staples the image when that app is notarized and `STEDDING_SIGN_IDENTITY` and `STEDDING_NOTARY_ARGS` are set. `STEDDING_DMG_UNSIGNED=1` leaves the image unsigned. The Windows installer is unsigned (S-56). Each file has its sha256 beside it.

On the Mac, from the repo root, with a clean tree: bump `VERSION`, run `tooling/dev build release chrome chrome/installer/mac:mac` (the About line is `stedding_version`, and the second target is the signer's packaging directory), empty `dist/`, run `tooling/sign-release release` (`--check` first; it signs, notarizes and staples into `dist/signed/stable/Stedding.app`), `tooling/verify-build --app dist/signed/stable/Stedding.app`, then `tooling/package-dmg release --app dist/signed/stable/Stedding.app`. That writes `dist/Stedding-<VERSION>-arm64.dmg` and its `.sha256`. Run `syspolicy_check distribution` on that app (trap 47), paste the checksum into `docs/release-notes/v<VERSION>.md`, commit, and push. Then `tooling/publish-release --check` and `tooling/publish-release`. Try the release the way a user gets it (trap 47). Then offer it: `tooling/publish-appcast --check`, then `tooling/publish-appcast --push` on the operator's yes for that release (ADR 0022). The push signs the image, writes and signs `updates/appcast.xml`, and commits it. Fetch the feed from its raw.githubusercontent.com URL. It should match the commit, `sign_update --account stedding --verify` should pass, and the image downloaded from the release should match the feed's `edSignature` (`sign_update --verify <image> <signature>`).

`publish-release` refuses to run until this commit is on the remote, and it pins the tag with `--target`. Push the commit first. It then fetches the tag GitHub created. `package-dmg` names the image from `VERSION` and warns about any other image left in `dist/`. `publish-release` takes the image named for this `VERSION`, accepts a single image that is not named that way, refuses to choose between two, and checks the sha256 against the file beside the image and against the release notes. Once the release is out, it deletes from `dist/` the images of earlier releases that a GitHub release carries, and keeps this release's image (`publish-appcast` signs it next) and any image no release carries. The notes must also name the pinned Chromium version (`Chromium <CHROMIUM_TAG>`, the tag in `tooling/chromium-version`) before any other: the website reads the first one from the release body, and its build fails without one.

Windows joins the same release from the PC. `tooling/win/release-gate.sh <version> <previous>`, started in the operator's session with `tooling\win\run-in-session.ps1 -Script tooling\win\release-gate.sh -Arguments '<version> <previous>'`, runs the whole of it: every build, the suites, `package-installer.ps1`, `installer-gate.ps1` (the previous release updated by its own updater with pins in two windows, then the installer's cycle), the acceptance parts (with the operator's yes; else `--no-drive`), and the DCHECK and ASan builds' suites. Its log, `%TEMP%\stedding-gate\gate-<version>.log`, ends in `GATE_DONE`. Use the installed build the way release checklist item 13 says (`docs/ROADMAP.md#release-checklist`). Paste the checksum under *Windows* in the notes, commit, push, and run `tooling/publish-release` from Git for Windows. Whichever platform publishes first creates the release. The other uploads into it, and the notes are refreshed (ADR 0018). Then the Windows feed, on the PC after `git pull`: `tooling\win\publish-appcast.ps1 -Check`, then `-Push` on the operator's yes (ADR 0023). Push one feed at a time. Both feeds are commits to `main`.

A newer Windows build installs over an older one as an ordinary upgrade, including two releases on the same Chromium milestone (patch 0073, S-72). An installer of the version already installed still repairs, and Stedding has to be closed for that (trap 62). The PC builds and tests its own image. A browser suite started over SSH lands in session 0 and fails (traps 67, 68).

**Side releases.** A Linux or ARM build, or a test build, is a side release (ADR 0031): `tooling/publish-side`, never `publish-release`. It reaches none of the places below, and no feed: a test item put in a feed, even for a moment, makes the Windows updater refuse every later feed on the copies that saw it.

**After a release.** Every place that names the release:

| Where | What follows the release | By hand |
|---|---|---|
| GitHub Releases | `tooling/publish-release` | |
| README, Download ("The newest release is ...") | written in the release commit; `publish-release` refuses a README that does not name the release | |
| The feeds (`updates/appcast.xml`, `updates/appcast-windows.xml`) | `tooling/publish-appcast --push` and `tooling\win\publish-appcast.ps1 -Push`, each on the operator's yes | |
| stedding.dev | its Rebuild workflow reads GitHub's latest release, and older main releases for a platform that one lacks (ADR 0031: side releases are never read); `publish-release` starts it, and it runs every six hours | `gh workflow run rebuild.yml -R ysalitrynskyi/stedding.dev` |
| stedding.dev's page after an update (`/thanks/updated/`) | what the release brought, each change with a capture and where its setting is: an entry in that repository's `src/data/whats-new.mjs` and its captures in `assets/whats-new/<tag>/`, pushed before the release; `publish-release` refuses a tag without one (the owner, 2026-11-02: people who update never read the notes) | the captures, from the release's own build, dark, window only (that repository's `README.md`, "What's new after an update") |
| The Homebrew cask (`ysalitrynskyi/homebrew-stedding`, `Casks/stedding.rb`) | its Bump workflow reads the release marked latest and the DMG's `.sha256`; `publish-release` starts it once the Mac image is in, and it runs every six hours. A release with no Mac image yet changes nothing | `gh workflow run bump.yml -R ysalitrynskyi/homebrew-stedding` |

Then nothing of the release's builds, tests and checks is left running or on disk: `tooling/leftovers --clean` on the Mac and `tooling\win\leftovers.ps1 -Clean` on the PC both end with "nothing left over" (trap 147).

Within the hour, the home page's download section should name the release, and this should carry its version:

```
gh api repos/ysalitrynskyi/homebrew-stedding/contents/Casks/stedding.rb --jq .content | base64 -d
```

The cask depends on the image's name (`Stedding-<version>-arm64.dmg`) and the `.sha256` beside it. A change to either is a change to `Casks/stedding.rb` in the same round.

When what a user installs changes (a new platform, a requirement, a file name, an install step), change every place that tells them, together: `README.md` (Download), `docs/INSTALL.md`, `docs/FAQ.md`, the cask (`depends_on`, `url`, `zap`), and on stedding.dev the download section (`src/pages/index.astro`), `content/copy.md`, `public/llms.txt`, the press kit's Platforms line and `/arc/`. Homebrew installs with `brew install --cask ysalitrynskyi/stedding/stedding`. The README, `docs/INSTALL.md` and the site's download notes say so.

**Release at least every five weeks, on a pin whose build date moves.** Chromium applies its built-in list of sites that must load only over HTTPS while the build is under 70 days old. `TransportSecurityState::IsBuildTimely()` in `net/http/transport_security_state.cc` is `(base::Time::Now() - build_time).InDays() < 70`. After that, `GetStaticSTSState()` returns false and the list is not applied. The date is the pin's commit, not the day of the build (`build/compute_build_timestamp.py` reads `build/util/LASTCHANGE.committime`). What this recipe ships is not an official build (S-168), so that time is rounded down to 05:00 UTC on the first Sunday of its month, or of the month before. Read the build's date from `out/<config>/gen/base/generated_build_date.h` rather than working it out; the list lapses 70 days after it.
