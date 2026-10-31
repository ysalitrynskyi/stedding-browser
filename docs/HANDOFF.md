# Handoff — how to pick this project up cold

Written for the next person continuing this work. AGENTS.md is the project context; this file is the operational knowledge that is otherwise only in one contributor's head. Read both.

## Fast path (the first hour)

The long form of each step is `docs/AGENT-LOOP.md`.

1. **Orient.** `tooling/dev status`; `PLAN.md`; `BACKLOG.md`.
2. **Ask the operator once** for the things you would otherwise find out hours in. The list is `docs/AGENT-LOOP.md`, "Ask once, up front": the screen and keyboard, push and release, what you may delete, the machine overnight, a setting only they may flip, their own Stedding closed for the installer test, Arc and any clipboard manager quit for the keyboard checks.
3. **Use the product** before any long job. Launch it on a fresh profile and click through the first launch, in light and in dark, including the gestures the specs name. On Windows that is `tooling\win\drive.ps1`; on the Mac, `tooling/drive`. Real input needs the operator's yes. With more than one agent on the machine, follow `docs/AGENT-LOOP.md`, "Roles, when more than one agent is working": one lock for builds, one for the screen, and a copy of the app beside the owner's.
4. **Run the suites on the shipping configuration:** `tooling/dev test all --no-build`. That is `out/release` on the Mac and `out/win-release` on Windows.
5. **Sanitizer runs, cheapest first.** A DCHECK and dangling-pointer build (`win-checks`, or `mac-checks` on the Mac), then ASan (`win-asan`; the Mac has no ASan configuration). The same test command, naming the directory: `STEDDING_TEST_OUT=win-checks tooling/dev test all --no-build`. Read findings with `tooling/digest-sanitizer`, not raw. `tooling/dev` already prints that digest when a run has a finding.
6. **Fix.** Edit the checkout only while no build is running. Fold the fix into the commit that owns it (`tooling/fold-fix`), then `tooling/dev patch`, and commit this repo.
7. **Report** what was and was not verified, result first.

| To do this | Run |
|---|---|
| Build on Windows, to the end | `tooling\win\build-until-done.ps1 -Config win-checks -Targets unit_tests,stedding_browser_tests` (detached; wait for `SUPERVISOR_EXIT=`) |
| Build on the Mac | `tooling/dev build release chrome` |
| Checks build on the Mac | `tooling/dev build mac-checks unit_tests stedding_browser_tests` |
| Run a checks suite | `STEDDING_TEST_OUT=win-checks tooling/dev test all --no-build` (`mac-checks` on the Mac) |
| Run the ASan browser suite | `STEDDING_TEST_BUDGET_S=2400 STEDDING_TEST_OUT=win-asan tooling/dev test browser --no-build` (the default cap is 900 seconds) |
| Read a failing run | `tooling/digest-sanitizer <log>` |
| Use the window | `tooling/drive <profile> <steps>` on the Mac; `. tooling\win\drive.ps1` on Windows |
| Find a string in the tree | `git grep -n <pattern> -- <dir>` in the checkout |

### Trap index

The traps follow. 28 is retired. Read the one for the topic in front of you, not the list.

| Topic | Traps |
|---|---|
| Building, disk, rebuild cost | 1, 16, 19, 23, 44, 45, 53, 54, 57, 70, 73, 74, 83, 89, 90, 100, 123 |
| The working loop and the series | 5, 9, 13, 14, 17, 22, 50, 51, 89, 92, 139 |
| Driving and capturing the window | 3, 7, 10, 11, 12, 15, 18, 24, 27, 29, 30, 36, 37, 52, 56, 59, 61, 63, 64, 65, 76, 82, 93, 94, 95, 96, 103, 105, 107, 116, 121, 130, 132, 133, 136, 137 |
| What a test can and cannot prove | 2, 4, 31, 46, 48, 51, 52, 55, 56, 58, 59, 60, 66, 68, 69, 72, 75, 77, 78, 79, 80, 81, 84, 86, 87, 88, 91, 98, 99, 101, 102, 104, 106, 107, 110, 111, 112, 113, 114, 115, 119, 120, 126, 127, 138, 141 |
| Windows | 32, 34, 36, 38, 40, 42, 53, 54, 55, 56, 57, 59, 62, 67, 68, 69, 70, 71, 74, 91, 93, 98, 99, 100, 101, 103, 106, 111, 113, 114, 115, 116, 118, 121, 122, 125, 128 |
| Release and signing | 44, 47, 49, 62, 85, 117, 118, 124, 129, 131, 140 |
| Chromium's and the platforms' own behaviour to know | 6, 8, 20, 21, 25, 26, 33, 35, 39, 41, 43, 60, 72, 73, 92, 95, 97, 98, 104, 105, 107, 108, 109, 110, 111, 113, 122, 135 |

## Where things live

- This repo holds the docs, the tooling, the patch series in `patches/`, and the branding. It is public. Never commit secrets or machine paths.
- The Chromium checkout lives outside this repo. `tooling/lib.sh` uses `~/chromium` unless `CHROMIUM_ROOT` is set or recorded in `.stedding-local` (local state, never committed). On Windows the checkout's `src` is `STEDDING_CHROMIUM_SRC` ("The Windows build"). Each checkout is pinned to `tooling/chromium-version`, on branch `stedding-work`. While you work, the commits on that branch are the source of truth; `tooling/update-patches` writes them out to `patches/`, which is what the other machine and CI apply. `tooling/apply-patches` resets a checkout to the pin and replays the series as commits on `stedding-work`. On a tree that already holds an older series, that rewrites every file the series touches; trap 89 is the route that rewrites only the files whose content differs. A series exported on one machine is built on the other before the release that carries it (trap 44).
- Build output on the Mac is `out/release`, with proprietary codecs on (`tooling/args/release.gn`). `out/official` is the performance baseline (`tooling/dev build official chrome`). Quote performance numbers from `official` (`docs/ROADMAP.md#the-quality-bar`). On Windows the output is `out\win-release` ("The Windows build").
- The website is https://stedding.dev, the private repository `ysalitrynskyi/stedding.dev`: Astro, static, Cloudflare Pages. At build time it reads the latest release from the GitHub Releases API. `tooling/publish-release` starts its Rebuild workflow, and that workflow also runs every six hours, so a published release reaches the download section without a commit there. The browser does not update from the site (ADR 0014). The site's own rules are that repository's `AGENTS.md` and `docs/DEPLOYMENT.md`. Keep this repository's README, `docs/INSTALL.md`, `docs/SHORTCUTS.md` and `docs/FAQ.md` true; the site is maintained from the same facts.

## The loop that works

The procedure is `docs/AGENT-LOOP.md`. The command is `tooling/dev`.

```bash
# 1. Spec the behaviour in docs/features/<feature>.md and write the failing test.
# 2. Edit the checkout on stedding-work. Never while a build is running.
tooling/dev test spaces                 # Mac: builds unit_tests, runs the feature's filter
# Windows: tooling\win\build-until-done.ps1 -Targets unit_tests,stedding_browser_tests
#          then tooling/dev test spaces --no-build
tooling/dev capture --features 'SteddingArcStyleWindow:extra_spaces/2/pin_tabs/1'
# Mac. Windows: tooling\win\capture.ps1, or drive.ps1 for real use.
# Measure pixels (tooling/assert-capture, tooling/check-geometry).
# 3. Commit in the checkout with Why: and Removable when: footers.
#    A fix folds into the feature's commit. tooling/fold-fix <sha> <files>
#    leaves every other file's modification time alone (trap 44).
#    The other way: git commit --fixup=<sha>, then
#    GIT_SEQUENCE_EDITOR=true git rebase --autosquash <pin>
tooling/dev patch                        # update-patches, then check-repo
tooling/dev status                       # the numbers for any doc you touch
# Commit this repo. Push only when the operator has said so.
```

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

1. **siso stats sources once, near the start of a build.** An edit after that
   is missing from the binary, and the build still succeeds. On the Mac,
   `tooling/build-chromium` warns at the end if the tree changed.
   `tooling/dev build` refuses to start while a build is already running.
   Do not edit the checkout until it has finished. The Windows build states
   the same rule and does not warn afterwards (`tooling/win/build.ps1`).

2. **A screenshot cannot see teardown or input.** Anything that owns a tab
   needs a test. A use-after-free on close never shows in a capture.

3. **Synthetic input is `tooling/drive`.** It posts HID events only while its
   process is frontmost, and a click, hover or drag only where that process's
   window is the topmost one at the point; otherwise the step stops and names
   what is in the way (`tooling/drive-window.py`). Start with `activate`. A
   drag wiggles past the drag threshold before the long move. Do not run it
   while someone is at the machine: it moves the real pointer and does not
   watch for their input. `shot` captures one window by id
   (`tooling/capture-windows --largest`), never the screen. Quitting is an
   AppleEvent, not a Cmd+Q keystroke (`tooling/lib.sh`, `stop_app_pid`).

4. **SIGTERM does not flush Chromium's session files.** A restore check that
   kills the process proves nothing. `tooling/drive` quits through an
   AppleEvent, which does flush. The session service rebuilds its log from
   the live browser at startup and every 250 writes, and does not know about
   extra data a feature wrote. Re-emit it through `stedding_session_rebuild.h`,
   and write it once the window is tracked, or it survives exactly one restart.

5. **macOS bash is 3.2.** No `mapfile`, no associative arrays; `tooling/check-repo`
   rejects them. `tooling/check-shell` runs the shellcheck version in
   `tooling/shellcheck-version`, the same one CI runs. A newer local
   shellcheck is not a pass.

6. **APIs in this tree.** `base::Value::Dict` and `List` are `base::DictValue`
   and `base::ListValue`. A token parses with `base::Token::FromString`, then
   `FromRawToken`. `BubbleDialogDelegateView` and `WidgetDelegateView` cannot
   be subclassed outside Views (private constructor and a friend list): change
   an existing view. `views::Separator` paints its whole bounds. FlexLayout
   stretches a child that declares no size; BoxLayout honours alignment.

7. **A tracked pref cannot be seeded from outside.** Chromium's pinned-tab
   pref is one; that is the anti-tamper check working. Seed pins with the
   `pin_tabs` feature param on our own code.

8. **Colour mixers hand out one colour.** The dark ground is a gradient
   painted once on BrowserView (`SteddingWindowBackground`). The sidebar, the
   top container and the mat are invisible over it, not removed: the layout
   dereferences those backgrounds.

9. **A sleep loop is not supervision.** A build prints progress every minute
   and stops itself when its budget runs out (`tooling/build-chromium
   --budget`, default 15 minutes; `tooling\win\build.ps1 -BudgetMinutes`).
   The budget kills the steps in flight. `tooling\win\build-until-done.ps1`
   starts the next chunk with no gap, writes a status file whose last line is
   `SUPERVISOR_EXIT=<n>`, and exits 4 when the same step is killed at the end
   of three chunks in a row (trap 57). Wait for that line. Before a wait over
   ten minutes, say where it stands, with a number (`docs/AGENT-LOOP.md`).

10. **Retired.** `tooling/drive-window.py` sets modifier flags on every mouse
    event, so a click no longer inherits the last chord. On macOS a Ctrl-click
    is a right-click.

11. **A window capture does not show another app covering the target.** The
    drive used to click that window and look as if the view had no menu. It
    now refuses the event and names the app (`require_mouse_at`). It already
    passes `--window-position=0,0`. Move the other window; do not photograph
    the display to see it.

12. **`shot` is the largest window only**, by window id. A dialog the process
    owns, such as welcome, is not in it. `shots` writes every window of the
    pid, largest first: the path, then `-2`, `-3`. `screen` is the display
    the window is on. Use it for macOS full screen, where the address row is
    a window of its own above the browser and `shot` leaves it out. A dialog
    of the pid is `shots`, not `screen`.

13. **Branding is a copy, not a commit** (`tooling/apply-branding`).
    `tooling/fold-fix` does not stash or check out, so it does not drop those
    files. A rebase or checkout that does makes the next build `Chromium.app`.
    `tooling/drive` launches the last non-helper `.app` in `out/release`, so a
    stale `Stedding.app` beside the new one is what you drive. Run
    `tooling/apply-branding` before `gn gen`, and look at `ls out/release/*.app`.

14. **A new `.grdp` part must be listed in
    `chrome/app/generated_resources.grd.gritdeps`**, in sorted order, or the
    build fails the gritdeps check. Stedding's strings are the one file
    `chrome/app/stedding_strings.grdp`. A string that reaches a macOS menu or
    a toast needs a real `IDS_` id. The settings page and the command bar
    still use literals.

15. **Keys and clicks go nowhere until the window is key.** `tooling/drive`
    starts in the background. `activate` brings it forward, and the harness
    sends nothing if another process is frontmost. Grey traffic lights mean
    the window is not key: read them before blaming a chord. A menu-bar item
    can be clicked with System Events from the foreground shell while the
    drive is parked.

16. **The Mac build refuses when free space is under the floor.** The default
    is 60 GB; `STEDDING_MIN_FREE_GB` lowers it and 20 is the least accepted
    (`tooling/build-chromium`). On macOS the number is the volume's available
    capacity for important usage, purgeable space included (Finder's figure),
    not `df` (`free_gb` in `tooling/lib.sh`). The script prints the figure it
    used. Delete drive scratch profiles after a batch, and
    `$TMPDIR/dev.stedding.Stedding.chromium_chrome_url_fetcher_*` if those
    directories have piled up.

17. **The pin is scanned in every tracked file, patches included.**
    `tooling/check-repo` fails a non-documentation file that hard-codes the
    Chromium version (ADR 0007). A test of the version line uses a made-up
    version (`150.0.1234.5`). Only `tooling/chromium-version` carries the pin.

18. **Retired.** `type` in `tooling/drive-window.py` puts the character on the
    key event, so a non-Latin input source no longer changes what is typed.

19. **A new id in `chrome/app/chrome_command_ids.h` rebuilds most of the
    browser.** That header is included widely. Stedding's own command ids go
    in `chrome/browser/ui/stedding/stedding_command_ids.h`.

20. **On the Mac the focus manager sees a key before the focused view.** A
    text field that wants Tab never receives it: focus moves, and the command
    bar closes on that change, while a test that calls `HandleKeyEvent`
    directly stays green. Claim the key in `SkipDefaultKeyEventProcessing`,
    as the command bar does, and assert the claim. A panel that sizes itself
    from its rows must recompute its bounds on every rebuild path. A
    `GetPreferredSize` probe cannot see an early return; the live window can.

21. **Stedding's WebUI CSS and TypeScript are linted at build time.** stylelint
    wants a blank line before every rule and a short hex colour (`#fff`, not
    `#ffffff`). A Lit handler is named `on<Context><Event>_`
    (`onRouteAddChange_`). A lint failure stops the build before any compile.
    Read the first error line of the log.

22. **A fix folded into an earlier patch can conflict with a later patch in
    the same include block.** The resolution is the union of both sides,
    without duplicates. `tooling/fold-fix` stops before the branch moves if
    any commit conflicts. On a hand rebase, continue only after that, put
    branding back with `tooling/apply-branding` if the checkout dropped it,
    and check `git status` shows nothing outside branding.

23. **Three small ones, each a wasted build.** zsh does not split an unquoted
    `$var`; pipe a file list through `xargs`. `tooling/dev` and
    `tooling/check-repo` are paths from this repo, so a shell that has entered
    the checkout must call them by absolute path. A command-bar row that
    depends on an asynchronous check (a file existing) has to be primed when
    the window is created, or the first actions-mode bar is missing that row.

24. **An unnamed Space takes its glyph and its name from its index.** The
    glyph comes from the icon list when the Space has none; the name is
    "Space N". Reordering two unnamed Spaces changes nothing a capture can
    see except the active highlight and the title row. Give one an icon from
    its chip menu before capturing a drag.

25. **Views and build facts.** A `views::View` subclass, even in an anonymous
    namespace, needs `METADATA_HEADER` and `BEGIN_METADATA`/`END_METADATA`,
    or `AddChildView` fails a static assert. `views::LabelButton::label()` is
    protected, so a row whose font must change is a subclass that re-exports
    it. `switches::kEnableFeatures` is declared in `base/base_switches.h`.
    A gn target is named after its directory unless the BUILD file says
    otherwise (`//components/embedder_support`, `//components/bookmarks/test`).
    A `Browser` has `GetProfile()`, not `profile()`, and no `window()` (use
    `BrowserWindow::FromBrowser`). `SkColorGetR` and the rest are macros.
    chrome://settings search finds a row and does not scroll to it: click the
    page and press space. A relative `shot` path is written in the current
    directory. `folder_tabs/N` and `pin_tabs/N` seed a folder or an essential;
    a Space pin is `space_pin_tabs/N`, or the command-bar action "Pin to This
    Space".
26. **A test WebContents, a popup's bounds, and a shared extra Space.** `WebContentsTester::For` applies only to a contents the harness made or `WebContentsTester::CreateTestWebContents` made (`content/public/test/web_contents_tester.h`). `content::WebContents::Create` is a plain contents, and `For` on it is the wrong cast. A `ScopedUnownedUserData` erases itself from its host in its destructor, so it has to die before that host: a mark that must outlive a view belongs on `BrowserWindowFeatures`. `--window-size` and `--window-position`, which `tooling/drive` and `tooling/capture-state` pass, are a request the window sizer applies to every window it places. A little window calls `SetBounds` after it exists, and those bounds hold (`chrome/browser/ui/stedding/little_window.cc`). `extra_spaces` adds a Space in each new window of a non-official build, through the profile registry, so the Space is shared; an official build ignores the param. `tooling/drive`'s `shot` captures the largest window by id; `shots` captures each window of the pid.

27. **Real input only with the operator's yes, and only through a driver that can refuse.** `tooling/drive-window.py` sends keys only while the launched pid is frontmost, and mouse input only while that pid's window is the topmost one at the point. On Windows, `tooling\win\drive.ps1` sends input only while its browser is in front and the operator's last input (`GetLastInputInfo`) is more than six seconds old. Without the yes, use `tooling/capture-state` or `tooling\win\capture.ps1`. Quit the browser a tool launched with `tooling/window_by_pid.py --quit <pid>`. An `osascript` quit addressed to the app reaches the owner's Stedding too. A browser started under `lldb --batch` does not become key, so synthetic keys go to whatever is in front.

28. **Retired.** The apply script it described is gone. `tooling/update-patches` exports the series.

29. **`tooling/capture-state` photographs a fresh profile with no input.** It refuses to start while another process with the same bundle id is running, launches in the background, captures every window of that pid by id, quits that pid and deletes the profile. The launch passes `--stedding-stay-in-background`, which skips `activateIgnoringOtherApps:` (patch 0057), so the browser does not take the focus. If it comes forward anyway, the run stops and captures nothing. `tooling/drive` does not pass that switch: a drive needs the focus, and it waits for an empty chair (trap 27). State comes from feature params on `SteddingArcStyleWindow` (`extra_spaces`, `pin_tabs`, `folder_tabs`, `space_pin_tabs`, `drift_tabs`, `open_command_bar`, `split_tabs`), `--stedding-welcome=<step>`, `--seed` (`collapsed`, `grey-dark`, `light`, `dark`, `horizontal`, `horizontal-light`, `horizontal-dark`) and `--sidebar-width`. A `chrome://` page is `--page`, not a URL on the command line. `tooling/capture-ui` runs this script.

30. **The traffic-lights exclusion is a padded box.** macOS reports a box with an equal margin on every side. The glyphs are 12 DIP circles at the top of that box, so a button centred on the box sits low (sidebar Y7). Compare two things inside the same capture. `tooling/capture-windows` captures by window id and omits the shadow (`screencapture -o -l`), so a pixel in that image is a window pixel.

31. **Run Chromium's own suites over the code the series changes.** `tooling/dev test upstream` is part of `tooling/dev test all`. In `unit_tests` the filter is `TabStripModelTest`, `HttpsFirstModeSettingsTrackerTest`, `TabGroupHeaderViewTest`, `VerticalTabStripStateControllerTest`, `AcceleratorTableTest`, `TabMenuModelTest`, `TabCollectionAnimatingLayoutManagerTest`, `TabTest.DiscardIndicatorResponsiveness`, `TabTest.SingleElementCentering` and `SessionServiceTest`. In `components_unittests` it is `SessionServiceCommandsTest` and `ContentSerializedNavigationBuilderTest`. After a pin bump, `tooling/dev test rebase` runs `TabTest`, `TabContainerTest` and `TabStripTest`. A filter part that matches no test stops the sweep before anything runs. `browser_tests` and `interactive_ui_tests` are not built. A crash or a timeout prints no `FAILED` line; the launcher's summary counts them, and `tooling/dev test` prints that summary.

32. **Read the exclusion on the strip's side.** macOS's traffic lights are the leading exclusion: over a strip on the left, and over the address row when the strip is on the right. Windows' caption buttons are the trailing exclusion: over the address row when the strip is on the left, and over the strip when it is on the right (`OverStrip` in `stedding_browser_view_layout.cc`, sidebar Y41 and Y42). A layout that skips every exclusion overlapping a vertical strip hides the Windows buttons.

33. **The rail's look follows the width being laid out.** Expanded on hover, the collapsed state stays set while the strip is at its open width. Centring, icon-only rows, the stacked switcher and the opaque ground key on `VerticalTabStripRegionView::IsRailWidth` (sidebar Y20). Keying them on the collapsed state dresses that hover overlay as a rail.

34. **A long virtualised `%LOCALAPPDATA%` blows past `MAX_PATH`.** A build started from an MSIX-packaged app inherits a redirected AppData, and vpython's venv path then exceeds the limit. `tooling\win\build.ps1` copies `STEDDING_VPYTHON_ROOT` to `VPYTHON_ROOT`; point that at a short directory. A click driver checks that the browser is the foreground window first: `SetForegroundWindow` is allowed to fail. `tooling\win\drive.ps1` checks. `tooling\win\capture.ps1` needs no focus (trap 36).

35. **A bubble asked for before the window is shown cannot anchor to a tracked element.** The element tracker knows a view only once its widget is visible. With the address row hidden (toolbar T8), the crashed-session "Restore pages?" bubble has no app-menu button to anchor to, and the fallback anchor's `CHECK` killed the launch. It anchors to the top container (`AppMenuButton::GetAnchor`, toolbar T23). Anything that hides a toolbar button a startup bubble uses has to leave a drawn view in its place.

36. **On Windows, capture without taking the focus.** `tooling\win\capture.ps1` renders with `PrintWindow` and `PW_RENDERFULLCONTENT`. The launch disables `CalculateNativeWinOcclusion`, so Chromium keeps drawing a covered window. A click is `WM_LBUTTONDOWN` and `WM_LBUTTONUP` posted to the window's queue, in client coordinates, never `SendInput`. The window to render is the largest `Chrome_WidgetWin_1` of the process: bubbles and toasts share that class, and a console with redirected output is what `MainWindowHandle` returns. The default launch is scale 1 at 1400×880 DIP. `--force-device-scale-factor` shrinks the DIP size, and Chromium folds the forward button into the overflow when the window is that narrow.

37. **A layout a capture cannot explain is answered by the bounds.** Log every child's bounds after `Layout`, rebuild that one file, read the log, and take the log out before the patch is cut. On Windows, `tooling\win\uia-dump.ps1` reads the same tree with no build.

38. **Chromium reads Google Chrome's extension list whatever the branding.** On Windows that is `Software\Google\Chrome\Extensions`, machine and user, through `ExternalRegistryLoader`, and it installs what it finds from Google's update server. Stedding does not create that provider (privacy Q9, patch 0039). On the Mac the same decision leaves `/Library/Application Support/Google/Chrome/External Extensions` unread. Any other lookup keyed to Chrome deserves the same question.

39. **A WebUI `chrome.send` with no handler kills the browser.** It is a `NOTREACHED` in the browser process, not a console error in the page. A handler compiled only for the Mac, called by a page that ships everywhere, crashed chrome://settings/stedding on Windows (windows N5). A platform-gated handler needs a `loadTimeData` boolean the page checks before it sends. The shortcut reference's boolean, `steddingHasShortcutReference`, is on for every platform (patch 0043).

40. **Test an installer outside an MSIX app's virtualised AppData.** A process started from an MSIX-packaged app sees a virtualised `%LOCALAPPDATA%` and HKCU. An installer run there writes under the package's `LocalCache`, and the installed exe then fails to load because the Windows loader probes the real path. `tooling\win\test-installer.ps1` runs as the user's own scheduled task (`schtasks /Create`, then `schtasks /Run`), with its log outside AppData. It never passes `--delete-profile`. `-Mode uninstall-keep` uninstalls and keeps the profile. `-Mode upgrade` and `-Mode uninstall-keep` refuse to start until `-Mode backup` has copied `%LOCALAPPDATA%\Stedding`. A `/SC ONCE` task is not still there the next day; create it again.

41. **Every Stedding build turns Chromium's field-trial testing config off.** `disable_fieldtrial_testing_config = true` is set in every file under `tooling/args/` (privacy Q10). Without that line, `testing/variations/fieldtrial_testing_config.json` switches on Google's experiments, in official builds as well. A build from hand-written args is running that set until the line is there. The seven features of the 2026 desktop refresh that the config had switched on are enabled in the source instead (patch 0042): MenuSimplification, RoundedIcons, TabGroupColorRefresh, TabStripDeclutter, ToolbarGlowUp, UpdateTabGroupColors, WebuiRefresh2026. With the config off, inactive sidebar rows would take the Material fill; the Stedding mixer pins that colour transparent (tabs R23).

42. **Ctrl+Alt stays out of Chromium's main accelerator table.** `GetDefaultAcceleratorList` DCHECKs on any mapping with both modifiers, because AltGr sends Ctrl+Alt. Stedding's Ctrl+Alt chords are `kSteddingCtrlAltAcceleratorMap`, inserted after that check (patch 0043, windows N7). A Ctrl+Alt row in the main table kills a DCHECK build at startup. On a key the layout gives an AltGr character, Windows delivers that character and no row matches. `stedding::AltGrChords` runs the chord when it was made with the left Alt (windows N14). `AltGrChordsTest` plays the keyboard's state. A real AltGr layout has not been tried.

43. **A container takes its size from its layout.** A preferred height set by hand stays put when a child is added. A `BoxLayout` with a flexible child reports the space it is offered as its preferred size. The sidebar's bottom row flexes the switcher in the open form only (`SetFlexForView`, weight 1 open and 0 in the rail). With the flex left on in the rail, the row asked for everything under the Archived row and the stack sat at the top (sidebar Y13). The row's height is its children's, and the switcher reports a height that counts its dots as dots.

44. **A fresh checkout needs the full disk floor, and an early autosquash rebuilds the rest.** `tooling/sync-chromium` refuses to start with under 150 GB free. `STEDDING_SYNC_MIN_FREE_GB` may lower that, never under 100. On the Mac, dependencies are cloned with alternates into the git cache, so the cache is part of the checkout. `tooling/repair-checkout` rewrites those absolute paths after the checkout moves. Windows clones shallow and has no cache. The sync's `git checkout -f` drops the uncommitted branding; `tooling/apply-branding` puts it back after the series is on. Export the series only with `tooling/update-patches`. `tooling/check-repo eol` rejects a CR byte in a tracked text file. Build a series on the other platform before the release that carries it. Fold a fix with `tooling/fold-fix`. An autosquash into an early patch checks out every later patch's files, and siso rebuilds those objects.

45. **A point release is a delta, and nothing else may take the index while the series applies.** When the milestone does not change, `tooling/update-pin` passes `--point-release` to `tooling/sync-chromium`: a 25 GB floor (`STEDDING_SYNC_POINT_RELEASE_MIN_FREE_GB`, never under 20) instead of the 150 GB a checkout from nothing needs. `--point-release` is refused when the checkout is missing or is on another milestone; that bump is a full sync. `git checkout -f` drops the branding; run `tooling/apply-branding` once the series is on. `tooling/apply-patches` applies with `git am`. A `git status` from another shell takes `index.lock`, and the apply stops mid-series. Read the log while it runs.

46. **A green unit test is not a behaviour a person can reach.** `tooling/check-repo` cannot tell a called function from an uncalled one. Before a spec row says built, grep the checkout for a caller outside the tests. "Model only" means the helper and its unit test exist, and no menu, key or setting reaches it (`docs/features/sessions.md`). A behaviour is shipped when a person can reach it and its test is green.

47. **Try a release the way a person gets it: downloaded.** `tooling/verify-build` launches the app from the build directory. That copy has no quarantine attribute, so it never meets Gatekeeper. The macOS image is signed and notarized (`docs/INSTALL.md`). Before the release is announced, `syspolicy_check distribution` has to pass on the app that goes into the image, and a copy downloaded the way a person downloads it has to open.

48. **Full screen puts the toolbar in another widget.** macOS moves the top container into an overlay widget of its own. Converting that toolbar's bounds as if it were still this window's hits a CHECK (toolbar T24). Convert a view another window may own only after `GetWidget()` says it is still this window's. `SteddingWindowBackgroundTest.PageBarNeedsTheToolbarInTheSameWidget` covers the guard. `tooling/verify-build` opens the browser with `--start-fullscreen` over a page that carries a theme colour. `--no-fullscreen` skips that check.

49. **Sign with `tooling/sign-release`, and assess only after the ticket is stapled.** The signer's parser treats a `--notary-arg` value that starts with `--` as an option of its own, so the script passes one `--notary-arg=<word>` per word. Patch 0051 leaves Gatekeeper until notarization has finished: until the ticket exists, every Developer ID app is `Unnotarized Developer ID`. After stapling, `tooling/sign-release` requires `source=Notarized Developer ID`. The signer's own wait is two hours (`chrome/installer/mac/signing/pipeline.py`, `timeout=60 * 60 * 2`). Apple can hold a submission longer than that. The signer's tests need Python 3.11: `pipeline.py` uses `asyncio.TaskGroup`, and the tests call `assertEquals`, which Python 3.12 removed. On another version, compare the failure list with and without the change.

50. **A milestone rebase is two jobs.** The conflicts are the first (`zdiff3` on). The port is the second, and the compiler is what lists it. Build with `KEEP_GOING=1`, or `tooling\win\build.ps1 -KeepGoing`, so one pass reports every error. Fold each fix into the patch that owns the code with `tooling/fold-fix`. The branch moves only when the new tip is the old tip plus those files. An early `--fixup` and autosquash checks out every later patch (trap 44). Resolve a fixup's conflict from the stage's own side, ported, and a feature patch's conflict from that patch's own side. Taking the stage's side for both drops the feature's lines; the tree-identity check is what catches that. Since M155, product code holds `BrowserWindowInterface`: `GetTabStripModel()`, `GetProfile()`, `GetSessionID()`. `tab_strip_model()` is still an inline that calls `GetTabStripModel()`. A URL with parameters goes through `BrowserWebContentsDelegate::From(window)->OpenURLFromTab`. The M157 test-fixture change is trap 134.
51. **Chromium's search suites assert a Google default and an EEA-only choice.**
    Stedding's fallback is DuckDuckGo in every region, and the choice screen runs in
    every country (`docs/PRIVACY.md`; `docs/history/plan-2026-09-26.md` WEB-4; patch
    0003). `tooling/dev test search` runs the cases about those two hunks:
    `TemplateURLPrepopulateDataTest.DuckDuckGoIsTheFallbackInEveryRegion`,
    `RegionalCapabilitiesServiceTest.IsInEeaCountry`,
    `RegionalCapabilitiesServiceTest.IsInSearchEngineChoiceScreenRegion` and
    `ClientIsInSearchEngineChoiceScreenRegionTest.*`. Other upstream cases still assert
    a Google default and an EEA-only region. They are in no filter, and no patch
    rewrites them, so a change to either hunk is checked against them as well.
    Measured 2026-09-28, not re-counted since: `DefaultSearchManagerTest` (3),
    `SearchEngineChoiceServiceTest` (5),
    `SearchEngineChoiceServiceDisplayStateRecordTest` (1),
    `SearchEngineChoiceEligibilityTest` (6),
    `SearchEngineChoiceEligibilityOnRestoreTest` (2),
    `RegionalCapabilitiesServiceProgramDeterminationTest` (4),
    `RegionalCapabilitiesServiceTest.GetCountryAndProgramCommandLineOverride`,
    `TemplateURLPrepopulateDataTest` (3, a Google fallback and the EEA list sizes) and
    the `LoadedTemplateURLServiceUnitTestBase` fixture's six users.

52. **On the Mac, `ui::test::EventGenerator::MoveMouseTo` runs past its target.** It
    re-bases every step on the point just sent, so a drag overshoots and only the
    release lands where asked. Drag and click the sidebar with
    `stedding::test::SendLeftMouse` and `ClickLeftMouse`
    (`chrome/test/stedding/sidebar_test_util.h`). A single `MoveMouseTo` followed by a
    click is fine. Call `WaitForRowsToSettle` before a click. To delete from settings,
    open `chrome://settings` and send `initializeClearBrowsingData` first: opening
    `chrome://settings/clearBrowserData` drops a reply still pending. A test that
    deletes data asks for cookies alone. Clearing the network history while other
    browser tests run can outlast the wait. A background tab's renderer runs at a low
    priority on the Mac, so open it in front or do not wait for it. The rail expands
    on hover only in the active window, so those fixtures are in `SERIAL_BROWSER_TESTS`
    (trap 88). The generator's click reaches the window's views and not a page's
    content: use `content::SimulateMouseClickAt`, or an interactive_ui_test. A drag
    through `SendLeftMouse` makes the dragged tab active, as a person's does. A fix
    taken out and put back leaves its old objects: rebuild before a run that counts
    (trap 1).

53. **`gclient sync --no-history` shallows a new clone, not an update.** An existing
    shallow dependency is brought up with a fetch of every branch down to the shallow
    boundary, so a milestone move of the Windows checkout pulls dependency history.
    Free space dips while packs are received and collected, below the figure it
    settles at: do not read it a minute in. `tooling/sync-chromium` still passes
    `--no-history` on Windows and refuses to start under 150 GB free
    (`STEDDING_SYNC_MIN_FREE_GB`, never under 100). Cloning the dependencies again
    keeps them shallow. The move from 153.0.8010.12 to 155.0.8059.12 grew that tree
    from 26 GB to 46 GB.

54. **A full Windows build at siso's default parallelism runs out of memory.**
    `tooling\win\build.ps1` passes `-j` only when `-Jobs` or `STEDDING_BUILD_JOBS` is
    set. On a 32-thread machine with 32 GB the default ran the first M155 build out of
    commit: the compiler out of memory, `MemoryError` in Blink's binding generators,
    a paging file too small, and the shell that started the build dying, which
    orphans siso. None of that is the code. Pass `-Jobs`. The progress line shows the
    commit charge against its limit. The supervisor defaults to 12 (trap 74) and runs
    each chunk detached. Stop an orphaned siso with `taskkill /F /T /PID`. The page
    file can stay grown until the machine restarts, so free space after a failed run
    is not free space after a restart.

55. **Tests written on the Mac carry the Mac.** Before a Windows build of a new test:
    `<windows.h>` defines `far` and `near` as nothing; `FilePath::Append` takes no
    narrow literal (`AppendASCII` or `FILE_PATH_LITERAL`; `docs/features/windows.md`
    N1); compare `FilePath::value()` through `NormalizePathSeparatorsTo('/')`;
    `ui::EF_COMMAND_DOWN` is the Windows key and the selection chord is
    `ui::EF_PLATFORM_ACCELERATOR`; a chord reads `⇧⌘K` on the Mac and `Ctrl+Shift+K`
    elsewhere; `chrome::DIR_USER_EXTERNAL_EXTENSIONS` is the Mac and Linux path, and
    Windows uses Chrome's registry key (patch 0057). The swipe that follows the
    fingers is the Mac's (spaces B35). On Windows a sideways scroll steps one Space
    and does not follow the fingers (B39, WIN-12); a touchpad has not been tried. A
    tab found by its title is lost once its page loads, which on Windows is at once,
    so keep the handle. A test that asserts one platform says which
    (`#if BUILDFLAG(IS_MAC)`, with the reason). The other platform gets a case of its
    own.

56. **On Windows, start a test binary through `timeout`.** `tooling/dev` does
    (`timeout --foreground`, `STEDDING_TEST_BUDGET_S`, 900 seconds by default). A
    binary started straight from an agent's shell failed the row drags and a key
    typed into a page on every run; the same binary under `timeout` passed. Why is
    not settled (trap 67). Anything else that starts one from that shell uses
    `timeout` or starts it detached. A run that fails exactly those tests is this.

57. **An ASan-built `nasm` does not finish large assembly files unless
    `malloc_context_size` is 0.** In `win-asan` the assembler is ASan-built, and a
    stack trace on every allocation makes three large files (ffmpeg, dav1d, libvpx)
    take more than 20 minutes each. A budget kill leaves them as the only `FAILED:`
    lines, and the link never runs. Copying the release `nasm.exe` over does not
    hold: siso rebuilds it. `tooling\win\build.ps1` sets
    `ASAN_OPTIONS=malloc_context_size=0` when the args file has `is_asan = true`,
    which brings each under 4 minutes. A test run wants the symbolizer the other
    way. ASan splits `ASAN_OPTIONS` on `:` and on space, so a drive letter ends an
    option. `tooling/dev` puts the symbolizer path in single quotes when
    `STEDDING_TEST_OUT` names an `asan` directory. An `ASAN_OPTIONS` you set yourself
    keeps both.

58. **Use the build before trusting the suites.** A fresh profile, the pointer and
    the keyboard, in light and in dark, finds faults no test asked
    (`tooling\win\drive.ps1`; `docs/AGENT-LOOP.md`, "Order of evidence"). The first
    Windows pass's five are fixed: Mac wording and light-mode contrast (patches 0057
    and 0042), the command bar past a narrow window (S-68, patch 0057), the card
    gutter and the restore infobar in full screen (S-69, patches 0059 and 0063), and
    a Space chip named twice (S-70, patch 0063).

59. **A disconnected remote-desktop session fails the tests that need an active
    window.** `qwinsta` says `Disc`, and `GetForegroundWindow` returns nothing. The
    drags (`TabDropTest`, `SidebarClickTest`'s row drag) find no window under the
    pointer. The session there is live in trap 56; here it is not. `tooling/dev`
    warns when the session is not `Active` and still runs every test, so the drags
    fail. On `win-checks`, while disconnected, `SpaceJarTest` has passed and then
    failed at exit with a dangling `Profile`, and
    `SidebarFormsTest.FullScreenIsEdgeToEdge` has missed its full-screen step. Both
    were clean once the session was `Active`. Check `qwinsta` before chasing either.
    A run meant to go on overnight needs the session kept connected.

60. **Collect every DCHECK failure in one run.** A check that aborts at the first
    hides the rest. With `dcheck_always_on` and the dangling-pointer detector
    (`win-checks`, `mac-checks`), print every failure
    (`--test-launcher-print-test-stdio=always`), read them through
    `tooling/digest-sanitizer`, and fix in batches. Run that build before ASan. What
    it enforces: `BlendForMinContrast` needs an opaque background, because a
    transparent fill reads as black; a colour recipe that is not invariant still
    runs Chromium's own recipe first, so lead an override with
    `ColorRecipe::Invariant()`; a `Label` on a layer that is not opaque draws
    grayscale text (`SetSubpixelRenderingEnabled(false)` with
    `SetSkipSubpixelRenderingOpacityCheck`); every focusable view has a role and an
    accessible name; `raw_ptr` members of a test fixture that point into the window
    are cleared in `TearDownOnMainThread`, and a container of `raw_ptr`s to child
    views is cleared before the views go; when the unpinned container is destroyed,
    the Clear line and the New Tab row are nulled in `TabStripView` (WIN-1, SPC-3);
    quiet permission prompts and adaptive (CPSS) prompts are one setting's two
    choices; a renderer-initiated `NavigateParams` has an `initiator_origin`; a
    `ScopedAllowBlockingForTesting` outlives a destructor that deletes files
    (`ScopedTempDir`). ASan found one use-after-free here, a test that read a
    deleted Space's id: `RemoveSpace` copies the id before it deletes the Space
    (patch 0057).

61. **Two browsers from one executable on the same `--remote-debugging-port` leave
    the second with a window and no UI.** DevTools answers for the first. Stop the
    first by profile path (trap 40), or give each its own port
    (`tooling\win\drive.ps1 -DebugPort`; `Drive-Launch` uses it). The default is
    9222.

62. **An installer of the file version already installed repairs in place. A later
    release installs beside a running Stedding.** Since patch 0073 (`S-72`),
    `tooling\win\build.ps1` writes Stedding's version into `chrome/VERSION`:
    `<milestone>.<100 × major + minor>.<patch>.<beta n, 999 for a release>`
    (0.2.0-beta.19 on Chromium 156 is 156.2.0.19; updates Up14). The same file
    version still repairs, and a running browser holding that version folder makes
    the repair fail (`SAME_VERSION_REPAIR_FAILED`). `tooling/win/test-installer.ps1`
    refuses to upgrade, install or uninstall while Stedding runs, and logs the
    sha256 of `chrome.dll`. What the web and Google's services see stays Chromium's
    version (`CHROMIUM_VERSION`; updates Up22).

63. **A synthetic trackpad swipe that sets the line delta as well travels eight
    times as far.** `CGEventCreateScrollWheelEvent` in pixel units sets the point
    delta. Also setting `kCGScrollWheelEventDeltaAxis2` makes macOS recompute the
    point delta as eight times the lines. Post the point delta and the phases only,
    and read the event back through `[NSEvent eventWithCGEvent:]` before trusting
    it. `tooling/drive-window.py`'s `wheel` posts a notched wheel in line units and
    does not set that field.

64. **Arc takes ⌥⌘N from any app while it runs.** The chord opens a Little Arc
    window and brings Arc forward, so the rest of a drive's keys go nowhere.
    Stedding's menu split on the Mac is ⌃⌘N, which Arc leaves alone (shortcuts Z3,
    `S-79`, patch 0070). Chromium's ⌥⌘N still splits when Arc is not holding it.
    Drive the split with ⌃⌘N, or quit Arc. A second click where the pointer already
    rests is no longer refused for Window Server's cursor window
    (`tooling/drive-window.py`; trap 95).

65. **Time a stall from a sample and from captures taken in process.** Start
    `sample <pid> 3 1 -file <out>` just before the action and read the main thread
    as a tree under the slow call. Photograph the window with
    `CGWindowListCreateImage` by window id, every few milliseconds.
    `screencapture` takes about half a second a shot. A Space switch that re-themes
    every row sets a title's font only when the font changed, because a label lays
    out whenever its font is set, and draws a folder glyph once per colour and size
    (spaces B36). Both are in the product
    (`SpaceSwitchTest.ARethemeDoesNotLayOutTheListPerRow`,
    `FolderViewTest.TheGlyphIsDrawnOncePerColourAndSize`).

66. **`CompleteShutdown took more than 30 seconds` is the machine.** The harness
    gives the browser's thread pool thirty seconds to stop. Under a heavy load, with
    swap full, tests crash there with "ThreadPool currently running tasks: none",
    including tests the change did not touch. Read `uptime` and `sysctl vm.swapusage`
    before reading a sweep. Wait for a quiet machine. Leave other sessions' jobs
    running.

67. **Browser tests started over SSH need the signed-in session at normal priority,
    and their drags need the foreground.** What `ssh` starts on the PC runs in
    session 0, where every browser test fails waiting for its window. A scheduled
    task with an interactive token (`schtasks /Create ... /IT`) runs in the
    operator's session, and Task Scheduler starts it below normal priority, so
    Chromium stops before it lists a test (`!IsProcessBackgrounded()`). The task's
    script sets `PriorityClass` to `Normal` first. Disk and memory priority stay low
    unless the task itself is priority 4 (trap 99). The row drags
    (`SidebarClickTest.EachPartOfTheStripAnswersItsOwnPress` and the `TabDropTest`
    drags) still need the foreground, which a task's window may not take. Run those
    at the desk, or say they were not run. Create such a task only with the
    operator's yes, and delete it when the run ends.

68. **Off the Mac, `ui::test::EventGenerator` scales a click a second time when the
    display scale is not 1.** The generator hands over a point in DIPs, and aura
    scales it again (`WindowEventDispatcher::TransformEventForDeviceScaleFactor`).
    A real click is scaled once. Click fixtures call
    `stedding::test::ForceScaleOneForEventGenerator`
    (`--force-device-scale-factor=1`, compiled off the Mac). A new fixture that
    clicks through the generator calls it too. `TabDropTest` hands its events to
    the root view and is not affected.

69. **A pointer at the edge of `GetWindowRect` is outside the window.** On Windows
    10 and 11 the rectangle includes the invisible resize border, about 7 px a side
    (`tooling\win\drive.ps1`). The frame answers there, and no view hears the move.
    Aim at `DwmGetWindowAttribute(DWMWA_EXTENDED_FRAME_BOUNDS)`, which
    `Drive-VisibleRect` returns. In a maximized window the screen's edge is the
    client's.

70. **`SUPERVISOR_EXIT=6` means `build.ps1` refused to start.** It throws while a
    browser from that output directory is running, because the link cannot replace
    `chrome.dll`. `tooling\win\build-until-done.ps1` catches the throw and writes
    the finish line. Stop your own test browsers by profile path before a build
    (trap 40). Leave the operator's running.

71. **`drive.ps1` sends no input while the foreground window is not the browser
    under test.** A Windows Security prompt holds the foreground, and every step is
    refused (`REFUSED: the foreground window is not the browser under test`).
    Answering it changes a security setting, which is the operator's. Say so, and
    work on what needs no screen until it is gone.

72. **A `raw_ptr` to a view inside a widget you own dangles when your object goes.**
    A delegate that owns its widget (`CLIENT_OWNS_WIDGET`) frees that view while its
    members are destroyed, and a `raw_ptr` released afterwards still points at it.
    A release build does not crash. A checks build does: `tooling/dev` turns the
    detector on for `win-checks` and for `mac-checks`. Null the pointer in the
    destructor's body, as `WelcomeDialog` does (patch 0015), or declare it after
    the widget so it is released first.

73. **`-Wunsafe-buffer-usage` is an error, so a loop that indexes a plain C array
    does not compile.** `chrome/` is checked (`build/config/unsafe_buffers_paths.txt`
    in the checkout) and warnings are errors. Declare the table as a `std::array`,
    or `constexpr auto kRows = std::to_array<int>({...})`, or use a range `for` when
    the index is not needed. `FolderViewTest.HeaderMenuOffersNewTabAndAlphabetize`
    does (patch 0060).

74. **The supervisor defaults to 12 jobs. Raising that without room runs out of
    commit.** Trap 54's cap depends on what else holds memory.
    `tooling\win\build-until-done.ps1` uses `-Jobs 12` because 22 ran `win-checks`
    out of commit on 32 GB. A compiler killed on a signal in several unrelated files
    is memory. Read the commit charge at idle and on the progress line before
    choosing `-Jobs`. `build.ps1` with no `-Jobs` is still siso's default (trap 54).

75. **A container that lays out in view order draws a reorder only if it reorders
    its views.** `TabCollectionNode` adds each child's view at the end and, on a
    move, reorders its list of children. Chromium's own containers lay out from
    that list (`GetDirectChildren()`). `FolderView` uses a `BoxLayout`, which
    follows view order, so `SyncRowOrder` puts the rows in the node's order before
    layout (patch 0060, folders F31). A new container that lays out by view order
    does the same, and its test reads drawn bounds.
76. **`Drive-Find` takes the first `Chrome_WidgetWin_1` wider than 300 px, which can be a dialog.** `tooling/win/drive.ps1` returns that window of the browser it launched. The welcome dialog qualifies, so later shots miss the browser. Launch with `--no-first-run` unless the flow is the subject, and call `Drive-Find` again after a dialog closes. Finish and Skip record the current default as the choice, DuckDuckGo on a fresh profile (`KeepTheDefaultEngineIfNoneWasChosen`, patch 0070). A profile whose welcome is already marked shown, and that never recorded an engine, still gets Chromium's chooser (`SearchEngineChoiceDialog::Show`, patch 0015), and that dialog takes the window the same way.

77. **A test that starts failing between two runs may be the machine.** Rebuild the last good code and run the same tests before bisecting the new code. That is one incremental build. A failure in code the change did not touch is this.

78. **The real cursor over a test window fails the hover and edge tests.** Test windows open at the top left. A cursor there expands the sidebar and hovers rows. `tooling/dev` runs `tooling/win/park-cursor.ps1` (bottom-right corner) or `tooling/park-cursor` (right edge, halfway down, so not a hot corner) before the browser suite and again before the serial leg, and only after ten seconds with no input. If the script says the cursor was not parked, the suite still runs, and those tests can fail. Park it while the operator is idle.

79. **A `base::test::RunUntil` check must only look.** A helper that runs a loop of its own (`WaitForRowsToSettle`) from the condition never returns on the Mac, and the test times out. Settle before the check. Inside it, only lay out and find (`RunScheduledLayout`, `FindDrawnRow`), as `FolderTabsTest.TheHeadersMenuSortsAndOpensATab` does.

80. **A filter part that names a test one platform does not build stops `tooling/dev test` on the other.** The lister refuses a part that matches nothing, and the sweep runs nothing. Put a suite only one platform builds in `MAC_FEATURE_FILTERS` or `WIN_FEATURE_FILTERS` in `tooling/dev`. A class both platforms build needs a case on each: `SteddingStringsTest` says "Show in Finder" on the Mac and "Show in folder" off it (patch 0059). Build a new filter on both machines before the release that needs it.

81. **A bubble placed while a Mac test window is still moving keeps the old place.** A bubble follows its window only when the window moves after the bubble shows. Put test windows in the screen's work area, and call the bubble's `SizeToContents()` before measuring where it sits.

82. **`hover` posts one move. Leaving a view needs a path.** A hidden sidebar stays out when the pointer jumps to the middle of the page. Use `move X1 Y1 X2 Y2 SECONDS` (`tooling/drive`). In the command bar, `key a+cmd` before `type`, or the last text stays in front of the new.

83. **A file put back from an archive keeps its old time, and the build skips it.** `tar` restores the modification time. When that time is older than the objects just built, the next build compiles nothing. `touch` every file put back, or copy it so the copy is new.

84. **Browser tests pretend an OAuth client exists. A Stedding build has none.** `ChromeTestSuite` calls `SetIgnoreMissingOAuthClientForTesting`, so `signin.allowed` is true in every browser test and false in a build. A test of the signed-out build then passes for the wrong reason, or fails against a fix that works. Append `--allow-browser-signin=false` in `SetUpCommandLine` (`QuietStartTest`).

85. **A firewall that asks per program holds a newly signed build's connections.** On the Mac each signed build is a new program. An unanswered prompt stalls `verify-build`'s network check. The question is the operator's. Run `verify-build --offline` and say so. A connection held at quit can make the shutdown watchdog (`chrome/browser/shutdown_watchdog_mac.cc`, still linked) end the process, and `tooling/drive` then reports that the pid did not quit. The dump goes to the default data folder's `Crashpad`: `DIR_CRASH_DUMPS` is that folder plus `Crashpad`, whatever `--user-data-dir` says (patch 0057). Move a test's dumps out of the owner's folder.

86. **A layout that is right at rest can be wrong for the length of an animation.** Tests that settle the sidebar before they measure miss a hidden sidebar while it is still narrower than the traffic lights. Step the animation (`BrowserAnimationController::SetAnimationContainerForTesting` with an `AnimationContainerTestApi`) and check every step (`WindowButtonsTest.OpeningAHiddenSidebarKeepsTheRowOffTheLights`).

87. **A test that fails one run in a few can be the product's race.** Log it before trap 77's rebuild. Put a `LOG(ERROR)` in the calls that should run, and loop that one test with `STEDDING_TEST_LOG` set: `tooling/dev` appends each run to `$STEDDING_TEST_LOG.<binary>`. A view rebuilt between two passes has no bounds until the next layout.

88. **Most browser tests share the desktop. A few cannot.** A row drag, the pointer over the window, keys, the clipboard, picture-in-picture, and a command bar held open across a wait fail when another window covers them or takes the focus. The failure looks like a timeout. They are `SERIAL_BROWSER_TESTS` in `tooling/dev`. The rest run four at a time on the Mac and two at a time on Windows (`STEDDING_BROWSER_JOBS`; on the Mac that leg took 397 s where one at a time took 815 s; on Windows, four at a time failed a different few drags, bubbles and keys in every run of 2026-10-31, S-369), then these run one at a time. A new fixture that drags, hovers, types, or needs its window in front goes on that list. The listing overlaps: "N tests for all" (or "for browser") is every test, and "M tests for serial" is the subset run at the end, so the leg runs N tests. A drag asks which window is under each point. `stedding::test::KeepAboveOtherWindows` raises the widget and, on Windows, takes it out of the native occlusion tracker's count (patch 0077).

89. **`tooling/apply-patches` rewrites every file the series touches, and the next build recompiles for hours.** It checks out the pin and `git am`s the series. It also refuses a dirty tree, and branding leaves the tree dirty on purpose (`tooling/apply-branding`). To move a checkout that already holds an older series, run `tooling/move-series` (`--check` lists the files it would write). It builds the new commits in a temporary index on the pin (`git mailinfo -b`, `git apply --cached`, `--3way` when that fails, `git write-tree`, `git commit-tree`), then `git read-tree -m -u <old tip> <new tip>`. That rewrites only files whose content differs and leaves the branded files, and it points `stedding-work` and `refs/stedding/applied` at the new tip. `tooling/update-patches` writing no change proves the tree is the series.

90. **A hook in a header much of the tree includes rebuilds most of the tree.** Count the includers (`git grep -l` on the path) before adding to it. The session-storage hook lives in `content/public/browser/stedding_session_storage.h` (patch 0067) for that reason. Putting the header back gives it a new time: `touch -r` it from an untouched neighbour, and delete the objects built while it was changed (`find out/<dir> -name '*.o' -newer <marker> -delete`, `*.obj` on Windows). Otherwise the next build mixes two layouts of one class.

91. **Only the Windows checks build sees a pointer left dangling when a window closes.** A raw pointer that a release build only clears stops every test on `win-checks`, and a release shutdown crash can name the wrong function. Run `STEDDING_TEST_OUT=win-checks tooling/dev test browser --no-build` in a round that adds a raw pointer on Windows, and read a release shutdown crash on that build. A `tar` made on the Mac for the PC carries `._*` files unless `COPYFILE_DISABLE=1` is set. They show up as untracked files in the checkout.

92. **The sidebar's rows live in the region view's content area.** `content_area_view_` is a `FlexLayoutView`. It holds the switcher, the Archived row, the bottom row and the update pill (patches 0004, 0060, 0068). The hover pill is a direct child of the region view, on a layer of its own, ignored by layout (patch 0004). The rail's side margins are that content area's interior margin. The top container is placed by `CalculateProposedLayout`, which reads the margins the rail form sets (patch 0060). The strip is added with `AddTabStripView` and removed with `RemoveTabStripView`. `kSteddingSigninPromoOnAvatarPill` keeps the avatar promo off (patch 0003). `TabGroupHeaderView` colours its parts in `UpdateColors()`. `TabRestoreService::RestoreEntryById` returns an optional (patch 0067). `AutocompleteMatchType` is an enum class (`kHistoryUrl`, patch 0061). Toast ids are histogram values: append after upstream's last and move `kMaxValue`. In this series Stedding's run from 63 to 71, and 68 is retired (patches 0017, 0027, 0060, 0083, 0096; the M157 collision is trap 134). An engine upstream adds needs a mark in the welcome table (Perplexity, patch 0060). The window layout is its own target, `//chrome/browser/ui/views/frame:stedding_browser_view_layout` (patch 0002). The content area's layer is not opaque. A label there turns subpixel text off (`SetSubpixelRenderingEnabled(false)` and `SetSkipSubpixelRenderingOpacityCheck(true)`), and canvas text uses `gfx::Canvas::NO_SUBPIXEL_RENDERING`. `FolderTabsTest.EveryLabelInTheSidebarSuitsItsGround` checks the labels without painting. It cannot see canvas text. An upstream test that assumes a default Stedding changes belongs in the patch that changes that default. `tooling/capture-state` refuses a `chrome://` address on the command line. Pass it as `--page` and the tool opens it through `tooling/devtools-page`. Fold a port's fixes with `tooling/fold-fix`.

93. **A synthetic arrow without `KEYEVENTF_EXTENDEDKEY` is the numeric keypad's.** The arrows, Home, End, PgUp, PgDn, Insert and Delete need the flag. Without it, and with Alt held, a text field takes the key as the start of an Alt code, and the window's accelerators never see the chord. `Drive-Key` in `tooling/win/drive.ps1` sets the flag (`ExtendedVks`). Any other sender must set it too.

94. **A clipboard manager takes ⇧⌘C from every app while it runs, as Arc takes ⌥⌘N (trap 64).** Copy Link then shows no toast. Ask the operator to quit the clipboard manager, and Arc, before a live keyboard check (`docs/AGENT-LOOP.md`, "Ask once"). When a chord does nothing, see what else is running before blaming the build.

95. **On macOS 27 the pointer is a window, and a guard that asks what is on top finds it.** `tooling/drive-window.py` refuses a click unless the browser's window is the topmost one at the point. It passes over Window Server's window named "Cursor", which never takes a click. It also passes over the Dock's full-screen window (from macOS 26 the Dock takes the pointer only outside the visible frame) and Notification Centre's full-screen window while a notification waits (only the notification stack takes the pointer). A new check of what lies under a point needs the same exceptions.

96. **In macOS full screen a window point is not a screen point.** A `click` is in window points. A `screen` capture is the display. `tooling/drive-window.py` adds the window's origin when it posts (`to_screen`). Convert a point read off a `screen` capture before using it as a `click`, and confirm the click with a capture after it. What the full-screen offset is made of was measured once and not established, so do not reuse a fixed correction.

97. **On macOS 26 and later, a line under the full-screen title bar is the scroll pocket's.** It is the hard edge of `NSScrollPocket`. The window's `titlebarSeparatorStyle` and the accessory's `allowsAutomaticSeparator` leave it. `HideTitlebarPocketSeparators` in `immersive_mode_controller_cocoa.mm` sets the pocket's private `allowsSeparator` off whenever the title bar may lay the pocket out again, and does nothing on a macOS without the pocket (patch 0071). Look at the pocket before a separator view. `WindowButtonsTest.FullScreenTitleBarDrawsNoDivider` covers it.

98. **On Windows `ui::test::EventGenerator` types the letter of every key it presses, Ctrl held or not.** It follows each key down with the plain letter's `WM_CHAR`. Windows itself sends a control character, which a text field ignores, and `views::Textfield` takes the plain letter as text. A test that presses a Ctrl chord into a focused field dispatches a `ui::KeyEvent` down and up through `Dispatch`, as `SpaceSwitchTest.TheCoreChordsAsKeysThroughTheWindow` does when the chord does not also hold Alt (patch 0071).

99. **Unit tests on mock time time out when their leg runs from a scheduled task at the default priority, and pass over SSH.** Task Scheduler starts a task at priority 7. That gives the task's processes disk priority 1 and memory priority 2, and the children inherit both. Raising `PriorityClass` (trap 67) changes neither. `FastForwardBy` waits for the thread pool to go idle, and the profile services then open their databases on that disk. After `schtasks /Create`, set priority 4: `$t = Get-ScheduledTask -TaskName <name>; $t.Settings.Priority = 4; Set-ScheduledTask -InputObject $t`. The tests that showed it are `SidebarNoBackupTest.AnHourOfAWindowWritesNoBackup`, `SleepTabsTest.SpaceTimerLeavesTabsInUseAwake` and `TabArchiverTest.TimerSweeps`.

100. **A test binary still running from an output directory makes the next link into it fail.** Windows will not overwrite a running executable (`lld-link` reports permission denied on the exe). `tooling/win/build.ps1` refuses to start only while that directory's `chrome.exe` is running. It does not look for a test binary. Wait for the suite's last line before building into the same directory.
101. **A theme change rebuilds the Space chips, so a test cannot hold them across one.**
    The Space tint, and a page colour, arrive a turn later and rebuild the switcher. A raw
    pointer held across that wait is then freed. `SpaceSwitchTest.TheChipsStayTheSameViewsWhileTheSidebarAnimates`
    tracks the chips with `views::ViewTracker` and takes them again when `OnViewThemeChanged`
    fires. What must stay the same is the width's form, not the views across a theme change.

102. **A drag that sends every move before any layout passes where a person's drag fails.**
    `TabDropTest::PressAndMove` sends twelve moves and only then lets the window lay out, so
    a row the drag has moved is still drawn where the press found it. A drop onto something
    the drag itself can move (a folder header, or its glyph in the rail) uses
    `PointerPressAndMove`: thirty moves, with `stedding::test::WaitForRowsToSettle` between
    two, as `tooling/acceptance/win/s173-live.ps1`'s `DragTo` moves. Assert `ShownWhole`
    first. In a short window or a scrolled list the drag aims at stale coordinates.

103. **A slept tab may never answer DevTools, so every wait in a driver needs its own clock.**
    In `tooling/win/drive.ps1`, `Drive-Eval` waits 3 seconds and a page that has not answered
    is not visible; `Drive-Pages` waits 5 seconds for the page list; UI Automation goes
    through `Drive-Bounded` (30 seconds) and the clipboard through it (10); a call left
    behind is logged `TIMEOUT`; WMI uses `-OperationTimeoutSec` 15. `Invoke-RestMethod
    -TimeoutSec` does not bound reading the answer. A new wait on the browser, on either
    platform, gets a bound and a log line before it.

104. **A title reaches the session file only when something writes the entry again.**
    Chromium writes a navigation entry at its commit, before the page has a title, and again
    only from `NavigationEntryChanged`. `SessionTabHelper::TitleWasSet` writes an entry's
    first title at once and later ones at most every 5 seconds (`kTitleWriteInterval`, tabs
    R31). A row the restore then loads shows the live title and hides an empty one in the
    file. Read a row the restore has not loaded (`RestoredTitleTest.AnUnloadedRowReadsItsPagesTitle`),
    or decode `Sessions/Tabs_*` and `Session_*`.

105. **A quit records every window it closed, and the next launch opens those windows again.**
    Chromium puts each closing window on the recently-closed list (`UnloadController::OnWindowClosing`,
    `TabRestoreService::BrowserClosing`), a quit's windows too. Stedding marks those tabs
    `stedding.archive.reopens` when the next launch opens the window again, and the archive,
    the command bar, ⇧⌘T and the Recently Closed menus pass over them (archive A13, A15).
    Entries written before that mark stay until `stedding.archive.keep_days` (default 30).
    Start a check from a new profile: `tooling/acceptance/mac/seed-profile.py` refuses a
    directory that already holds one.

106. **Expand-on-hover asks where the pointer is, not only the events a test plays.**
    `SetHoveredForTesting` stands in for the event, for whether the pointer is on the strip,
    for the frame-active check, and for the Windows exit debounce: `true` before the enter
    and the move, `false` before the exit, `std::nullopt` after the last wait
    (`SidebarFormsTest`, `LocalTabsTest.TheRailShowsTheTapeAndNoText`). The toggle's hover,
    the velocity heuristic and the leading edge read `SetPointerForTesting`'s point, else
    the real pointer. Focus inside the strip still holds the reveal open. A rail drag turns
    expand-on-hover off first (`TabDropTest::CollapseToTheRail`): a pointer that rests on
    the rail opens it (sidebar Y11).

107. **`--enable-automation` changes the browser under test.**
    It turns every infobar's slide off, shows Chromium's "controlled by automated test
    software" bar, skips the other startup bars, and sets `navigator.webdriver`. In-process
    browser tests do not pass it. A test of the unanimated path asks for it
    (`RemoveAllInfoBars(/*animate=*/false)` in `SidebarFormsTest.FullScreenIsEdgeToEdge`,
    toolbar T33). `tooling/acceptance/win/s173-live.ps1` launches without the switch, so
    tst9-9 is not measuring against that bar.

108. **The Mac's context menu draws the title, and a vector icon only where its menu icons are on.**
    `ui/menus/cocoa/menu_controller.mm` reads a row's label and its icon. It does not draw
    minor text or the accessible name, and `SetMenuItemIcon` draws a vector icon only under
    `features::IsMenuSimplificationEnabled()` (`initializeWithNewMenuIconScheme`) on macOS 26
    or later. `MarkSpaceItem` puts the words in the label on the Mac (`NameWithIsolationMark`,
    "Work · Independent session") and in minor text elsewhere (sessions S32). A test that
    compares a Space row's label to the bare name fails on the Mac.

109. **Replacing a tab's contents closes a tab-scoped toast.**
    A jar rebind and a sleep both replace the contents (sessions S23). Chromium then clears
    every tab-scoped toast, as a navigation of the primary page does
    (`Browser::OnTabReplacedAt`, `ToastController::OnActiveTabChanged`). A toast that must
    outlive that is registered window-wide (`AddGlobalScoped`). The pin-left-session toast
    this was written for is withdrawn (sessions S33).

110. **App windows come back at start only after a restart or a crash.**
    `ShouldRestoreApps` (`startup_browser_creator_impl.cc`) is otherwise false: a plain start
    with "Continue where you left off" restores the browser's windows and no app's (web apps
    Wa12). A `PRE_` step that just ends records the app window's close
    (`AppSessionService::WindowClosed`), so the restart preference alone is not enough.
    `AppJarTest.PRE_ARestoredAppWindowKeepsTheJar` ends with `chrome::AttemptRestart()` under
    an `upgrade_util::ScopedRelaunchChromeBrowserOverride` that starts nothing. That sets
    `prefs::kWasRestarted`, and the next step is the next start.

111. **On Windows a new page's view reports the old page's background colour.**
    Aura's `RenderWidgetHostViewAura::TakeFallbackContentFrom` copies the previous view's
    colour (`CopyBackgroundColorIfPresentFrom`), so `GetBackgroundColor()` on the view a
    navigation has just made answers the page shown before (on Windows, the new tab page's)
    until the coming page has drawn. `DarkPagesTest.ADarkenedPageIsDarkBeforeItsFirstFrame`
    reads the content area's solid-colour layer (`ContentsWebView`'s layer), not that view
    (dark pages Dk7).

112. **Test pages on `127.0.0.1` are local tabs.**
    A bare `embedded_test_server()->GetURL("/x")` is `127.0.0.1`, which `stedding::IsLocalPage`
    counts as this computer (`net::IsLocalhost`). The active row then wears the tape, and a
    Comfortable row shows the host under the title, with the title higher in the row. The
    row's height, the title's x and width, the favicon, the close slot and the number badge
    stay (local tabs Lt6). Serve a page that must be plain with `GetURL("a.test", ...)` and
    `host_resolver()->AddRule("*", "127.0.0.1")`.

113. **Off the Mac a browser test draws nothing unless it asks.**
    On Aura, `BrowserTestBase` adds `--disable-gl-drawing-for-tests` unless the fixture calls
    `EnablePixelOutput()`, so a read back through `CopyFromSurface` is `rgba(0,0,0,0)`. The
    Mac draws anyway. A check that transparent black satisfies passes without testing
    anything. Call `EnablePixelOutput()` in the constructor. It also forces a scale factor
    of 1, so `PageColourRowTest` calls it only under `USE_AURA`. `DarkPagesTest` calls it.

114. **Unit tests outside the desktop session on Windows read the system font at the screen's scale.**
    `unit_tests` does not call `base::win::EnableHighDPISupport()`; the browser tests' `main`
    does. Outside the desktop session the system font and the DPI that `gfx::SystemFonts`
    divides by can disagree. Over SSH, at 150% (`LogPixels` 144),
    `LocalRowLinesTest.TheComfortableRowAloneShowsTheHostLine` read a 24 DIP title and a 22
    DIP host line, and passed in the desktop session. Run a font-measuring unit test in the
    desktop session, and read a font-size failure over SSH as this first.

115. **Keys sent to a test window go nowhere once another test has the foreground.**
    A `ui::KeyEvent` through the window's dispatcher reaches its handlers only while that
    window holds the keyboard focus. `OnNativeWidgetActivationChanged(true)` does not give
    the focus back, and Windows refuses `Activate()` from a background process. On desktop
    Aura a view takes accelerators only while its widget is active
    (`View::CanHandleAccelerators`). On Windows those tests are in `SERIAL_BROWSER_TESTS`
    (`tooling/dev`): `NumberBadgeTest.*`, `SpaceSwitchTest.TheCoreChordsAsKeysThroughTheWindow`,
    `SpaceSwitchTest.NumbersAndCtrlTabReachOnlyRowsOnScreen`,
    `SpaceSwitchTest.TheChipsStayTheSameViewsWhileTheSidebarAnimates` and
    `SpaceSwitchTest.MoveUpAndDownPassAnotherSpacesRows`.

116. **A window that is not in front, or whose first page is not visible, takes no key.**
    `tooling/acceptance/win/s173-live.ps1`'s fixture waits up to 60 seconds for DevTools to
    call Page A visible, and brings the window forward first and again while it waits.
    Windows keeps a window launched just after the script's own keys behind the foreground
    window, its pages hidden (BACKLOG S-248). A first page that will not show is a busy
    machine only once the window is in front.

117. **A Mac copy updated through the real feed opens the default profile.**
    The check starts a released copy with its own `CrProductDirName` and Sparkle defaults
    domain, so that copy uses a scratch folder. Sparkle then replaces the bundle with the
    published one, whose `Info.plist` names `~/Library/Application Support/Stedding`, and
    relaunches there. Quit the installed Stedding first, read the relaunched window, and
    quit it at once. The local n-1 check sets `CrProductDirName` on the new bundle too, so
    it stays on the test profile.

118. **A one-off task's window cannot take the foreground.**
    `tooling/win/drive.ps1` sends input only while the browser is the foreground window, and
    a scheduled task cannot bring it forward. `tooling/win/update-n1.ps1` presses the update
    pill with UI Automation's Invoke pattern, which needs neither the pointer nor the
    foreground. The Mac's check presses it with `AXPress` for the same reason.

119. **`host_resolver()` rules do not reach the tabs a launch opens.**
    Rules added in `SetUpOnMainThread` reach the network service only after startup has
    opened the command line's addresses, so those tabs commit a name-not-resolved error
    page. `CommandLineTabsTest` maps the names with `--host-resolver-rules` in
    `SetUpCommandLine` (`network::switches::kHostResolverRules`) and checks each page's
    title, not only its URL: an error page commits the address too (tabs R46, BACKLOG
    S-251).

120. **Python's `http.server` resets a burst on the Mac.**
    Its accept queue is five. macOS resets the connections that overflow it, and Chromium
    does not retry a fresh connection that is reset before its response, so a background tab
    stays on the error page. A launch no longer opens a second connection per tab:
    `CertVerifierServiceImpl::OnCertVerifierChanged` says nothing until the service has
    verified a certificate (BACKLOG S-251). A live check that still opens more connections
    at once than the queue holds should serve with `ThreadingHTTPServer` and
    `request_queue_size = 64`.
121. **On the PC, keys sent while an elevated window is in front are lost, and the
    modifiers stay down.** Task Manager runs at high integrity. A script's injected keys
    are medium, and Windows drops them while a higher window has the foreground (UIPI).
    A quit by Ctrl+Shift+W closes the browser mid-chord. The foreground then falls to
    that window, the chord's key-ups are dropped, and Ctrl and Shift stay down. The next
    launch reads them as held, so its first Ctrl+W quits as Ctrl+Shift+W. While the
    elevated window is in front, `GetAsyncKeyState` from the script reads no key, so the
    stuck keys show only once a medium window is in front again. With the script's own
    window immediately behind the browser, the same quit leaves nothing held. Close Task
    Manager before a run. Where the keys are not the subject, do not quit with that chord
    while an elevated window will take the foreground, and release stuck modifiers only
    with a medium window in front. `tooling/acceptance/win/s173-live.ps1`'s `Quit` still
    sends `ctrl+shift+w`.
122. **Windows takes some chords before the window hears them.** Escape with Alt down is
    Alt+Esc, Ctrl down or not. The foreground window goes to the back, and it is sent no
    key message for the Escape, so no handling of `WM_KEYDOWN`, `WM_SYSKEYDOWN` or
    `WM_SYSCOMMAND` can stop it. A hot key comes first. While the extensions chord holds,
    the command bar registers Ctrl+Alt+Escape and Windows does nothing else with it
    (toolbar T39; `HiddenRowControlsTest.CtrlAltEscapeIsTheBrowsersWhileTheChordHolds`,
    patch 0077). Another program's hot key wins the same way: on the PC one holds
    Ctrl+Alt+Space, and that chord brings it forward. Ctrl+Alt+F4 and Ctrl+Alt+Space are
    not Alt+F4 and Alt+Space.
123. **Files copied to the PC with `tar xf` keep their Mac times, and the build may skip
    them.** tar restores each file's modification time. A file edited on the Mac before
    that object was last built arrives older than the object, and the build does not
    compile it again. Extract with `tar xmf`, which stamps the files with the time of
    the copy.
124. **A Stedding waiting to install an update stops the Mac's n-1 copies from checking.**
    Sparkle names an install in progress by the host app's bundle id and asks for one
    (the `<bundle id>-spks` service) before it checks. A test copy that keeps the real id
    finds that install, makes no request to the feed and shows no pill. When its
    `Info.plist` is retargeted, give the copy a `CFBundleIdentifier` of its own (the test
    domain plus `.app`). No script does this. Chromium's defaults then stay off the real
    app's too.
125. **`near` and `far` are macros on Windows.** `windef.h` defines both as nothing, so
    `gfx::Rect near = bounds;` fails to compile there ("expected unqualified-id") and
    builds on the Mac. Name the variable anything else.
126. **On the Mac, a test window under the machine's resting pointer gets that pointer's
    events.** macOS reports events when a window moves under a pointer that did not move,
    and a drag the test sends cannot share them (S-252, closed). The drag test in patch
    0077 moves its window clear of the real pointer, to the side with room, and fails if
    the pointer is still inside. A test that drags does the same.
127. **A wait inside a `RunUntil` check never ends, and a settle loop can keep a layout
    from settling.** `base::test::RunUntil` runs its check while the loop is idle. A
    check that waits itself (`DrawnRow`, `RowCentre`, `ShownWhole`, anything calling
    `WaitForRowsToSettle`) runs a loop inside that check, and the test hangs until it
    times out. Look rows up with `FindDrawnRow` inside a check. `WaitForRowsToSettle`
    lays out at every idle turn. Right after a row moves into a folder nested in
    another, two layouts with no frame between find the nested folder at two heights, so
    the rows start over and never settle. At a frame's pace they settle within 200 ms
    (`WaitForRowsToSettleAtFramePace`, patch 0083). A Space switch slides the list on its
    layer (spaces B32). Neither wait covers that: a row is cut off by the list's edge
    until the slide ends.
128. **With no monitor on, the PC's console session can run at 1024×768 and the sidebar
    tests fail.** Windows falls back to that size, the test windows come up too small,
    and layout and drag tests fail. Check the resolution before the Windows legs. Nothing
    in `tooling/` does. A remote-desktop session has its own display: keep its window
    open, not minimized, while the legs run, and do not leave it disconnected, which
    locks the session.
129. **A real-feed check within five minutes of the feed's push sees the old feed.**
    GitHub serves `updates/appcast.xml` and `updates/appcast-windows.xml` from
    raw.githubusercontent.com with `cache-control: max-age=300`. Wait five minutes after
    `publish-appcast` before a real-feed check, or `curl` the served feed first. The
    scripts do not wait.
130. **On macOS 27 a waiting notification covers the screen, and only its stack takes the
    pointer.** While a notification waits (a Time Sensitive one stays until it is read),
    Notification Centre keeps a window over the whole screen, above every app.
    `tooling/drive-window.py` `require_mouse_at` ignores that window except where its
    accessibility tree says the notifications are, as it already does for the Dock's
    full-screen window. Keep the parts a drive presses left of that stack. Do not click
    to close it: there is no panel open, and the click is input on the operator's
    machine for nothing.
131. **A Windows update download at IDLE starves while a UI Automation client reads the
    window.** At IDLE, `SimpleURLLoader` writes the installer on a `BEST_EFFORT`
    sequence. Polling the window through UI Automation starved that sequence: the HTTP/2
    stream stalled and GitHub reset it. Patch 0078 downloads the installer at `net::LOW`
    (`WinAppUpdaterTest.TheInstallerDownloadIsNotLeftToIdleTime`) and a failed download
    tries again within the hour
    (`WinAppUpdaterTest.AFailedDownloadTriesAgainWithinTheHour`). A screen reader is a
    UI Automation client too. The cause is not proven whole (BACKLOG S-279): an
    installed copy also failed with no polling, in the minutes after a publish. Still
    owed: a real-feed update from a copy that has this fix, with `--log-net-log`,
    straight after publishing, and once with Narrator on. Both `publish-appcast` scripts
    fetch the published image and compare its checksum before they write the feed.
132. **Retired.** `tooling/capture-windows` takes the largest window from another Space when a full-screen app leaves none on the current one.
133. **Record the window, not the screen.** `screencapture -v -R` and ffmpeg's screen
    input record a rectangle of the whole display. Another window that covers the
    browser lands in the take, and the raw file holds the whole screen.
    `tooling/record-window` records the browser's window alone (ScreenCaptureKit's
    single-window filter). `tooling/readme/record-demo.sh` uses it unless another
    recorder is named. macOS 27 badges a captured window where its traffic lights are;
    the conversion paints the lights back (`clean_window_badge`). Re-measure the scenes
    after a sidebar layout change: a drag aimed at a row can catch a different one, and
    a row on screen makes no split (splits J13).
134. **A rebase that merges cleanly can still drop a dependency, a brace or a number.**
    `main` holds 111 patches on Chromium 157.0.8103.31. That series is not released.
    Read the end of every merge that kept both sides: the brace between an upstream test
    and Stedding's can go. Do not trust an enumerator, a default or a dependency that
    merged with no conflict. Rebase in a sparse worktree so the main checkout keeps
    building.
    `//chrome/browser/ui:ui` is gone. A dependency that sat on it belongs on
    `//chrome/browser`, which links it and does not let a small source set include it.
    `gn check` lists those includes (BACKLOG S-335). They build and link. `gn check
    --fix` adds dependencies that make cycles; fix them by hand, target by target.
    Per-tab helpers attach in `TabFeatures` (`chrome/browser/ui/tabs/tab_features.cc`),
    at the tab's start and when its contents are replaced. The dark-pages helper and
    Peek's press are there.
    Stedding's toast ids are 63 to 71. 68 is unused (`kSteddingPinLeftSession`,
    withdrawn). Upstream holds 61 and 62 (patches 0017, 0083, 0096).
    `kUseActionsForBrowserCommands` is on in M157. Patch 0074 turns it off. On, the
    command controller knows only commands mapped to an action, so Stedding's commands
    (55100 to 55199) read as disabled and none run. The unit tests of those commands
    caught it (`SpaceCommandTest`, `CommandBarViewTest`); a build does not. Patch 0111
    puts `BrowserWithTestWindowTest`'s browser, window and `AddTab()` back. Upstream
    tests of Chromium's sidebar header (`VerticalTabStripTopContainerTest`) and of
    group focus mode (`TabGroupHeaderViewTest.DISABLED_FocusModeVisibility`) are
    disabled, with the reason. M157 pins an extension to the toolbar on install
    (`prefs::kExtensionsPinnedByDefault`); Stedding follows it until S-241. The omnibox
    popup's window is made at its first show. Patch 0074 still enables
    `kPaymentRequestRejectTooSmallWindows`. Its defaults test expects tab-search CJK
    word boundaries and the Aperitif helpers on; those two stay upstream's defaults.
    HTTPS-First balanced mode stays the pref default in patch 0030 (privacy Q2).
135. **A row hears of a discard before its tab holds the discarded contents.** Chromium's
    discard swaps the tab's contents. `TabDataObserver::OnTabDiscarded` runs from the
    will-discard callback while the tab still holds the old, awake contents, and tells
    the row then. `GetContents()` and `WasDiscarded()` there read the old page. The
    row's own `tab_data_` already has the new discarded flag (patch 0075). Decide the
    row again once the swap is done: `TabView::UpdateTabData` posts a task that calls
    `UpdatePinCloseButton` (patch 0110, pins H29). Stedding's sleep at home
    (`ReplaceWithHomeAsleep`) calls `NotifyTabChanged` after `DiscardWebContents`
    (patch 0083) and does not have this gap.

136. **A capture under the resting pointer keeps its hover.** A window that opens
    under a pointer that did not move still hovers what lies under it (trap 126), and
    `tooling/capture-state` photographs that. Most of the README's stills from
    2026-10-26 showed the sidebar edge's resize bar, which appears only while the
    pointer rests on the edge, because the pointer had been left there. Before the
    launch `capture-state` parks the pointer off the window's area with
    `tooling/park-cursor` (only after ten idle seconds, so never from the operator's
    hand), waits up to a minute while someone works, and refuses to capture while the
    pointer is over the window.

137. **A capture taken while another job loads the Mac shows pages still loading.** With a
    Chromium build or a browser test run going, the load average reaches 150 to 220 and a
    page's scripts time out (Django's script loader gives up after seven seconds). Its tab
    keeps a globe or a spinner, at any `--settle`. Captures for the README and the site
    wait for a quiet machine: no `siso`, `autoninja` or test binary running, and a load
    under about 25. They also stay out of a browser test run's way, whose windows open in
    the same corner (trap 78).
138. **`--no-build` runs whatever test binary the output directory holds.** On 2026-10-30
    a `mac-checks` sweep ran a binary built before the round's last four tests: it listed
    four fewer than the release build, passed, and missed a test that called
    `GetURL` on a server it never started, which crashes on a build with DCHECKs. A release
    build has no DCHECK, so there the test passed too. `tooling/dev test` now names each
    binary older than a file the series or the tree on top of it changes. Compare a
    sweep's test count with the other configuration's before trusting it.
139. **A shell script edited while it runs can run the wrong lines when it returns.** Bash
    reads a script as it goes and comes back to the byte offset after the command it was
    running, so `tooling/dev`, edited during a sweep, would go on from that offset in the
    new file after `main` returned. Edit `tooling/` only while no `tooling/dev` runs, or put
    the file back byte for byte until it ends.
140. **`tooling/sign-release` empties `dist/signed`, which may hold the Stedding the owner
    is running.** On 2026-10-31 the owner's copy ran from `dist/signed/stable/Stedding.app`,
    the beta 2 image's app. Deleting a running app's bundle breaks it as soon as it starts a
    helper. Sign from a worktree of the repository instead (`git worktree add --detach`,
    with `.stedding-local` copied in): its `dist/signed` is its own, and `tooling/package-dmg
    --app <worktree>/dist/signed/stable/Stedding.app` in the main checkout puts the image in
    the `dist/` that `tooling/publish-release` reads.
141. **`tooling/dev test` with `STEDDING_TEST_OUT` built `out/release` and ran the other
    directory's binaries.** On 2026-10-31 a `mac-checks` sweep after the S-323 patch built
    the release tests and ran `mac-checks`' binaries from that morning: 681 browser tests,
    where the release build listed 685, all passing on code without the patch. The build step
    now builds the directory the sweep runs. Compare a sweep's count with the other
    configuration's (trap 138).
## The Windows build

Git for Windows runs the bash tooling. PowerShell runs the rest. The toolchain is the installed Visual Studio (`DEPOT_TOOLS_WIN_TOOLCHAIN=0`, set by the scripts). Three variables name the machine's paths, so none is in the repo: `STEDDING_CHROMIUM_SRC` (the checkout's `src`), `STEDDING_DEPOT_TOOLS` when depot_tools is not already on `PATH`, and `STEDDING_VPYTHON_ROOT`, a short directory for vpython's venv (trap 34). The bash tooling takes the checkout as `CHROMIUM_ROOT`, the folder that holds `src`, as a POSIX path.

1. `tooling/sync-chromium` moves the checkout to the pin, then `tooling/apply-patches` puts the series on it, both before branding. Apply refuses a tree with uncommitted changes, and branding leaves tracked files modified on purpose (`tooling/status` counts what is left besides them). There is no git cache on Windows: `src` is one commit of the pinned tag, fetched by name the way `.github/workflows/series.yml` fetches it, and `gclient sync` uses `--no-history`. `--all-tags` is refused. A full sync wants 150 GB free. `--point-release`, a point release on the milestone the checkout already holds, wants 25. Trap 53 is what a milestone move costs: an update of a dependency that is already there is not shallowed.
2. `tooling/apply-branding`, from Git for Windows: the BRANDING file, the logos, the Windows icons, and the product name in every locale's tables. Before `gn gen`.
3. `tooling\win\build-until-done.ps1` builds to the end, detached. Status is `out\<config>\supervisor.log`. The last line is `SUPERVISOR_EXIT=<n>`. It runs `tooling\win\build.ps1` chunk after chunk and stops when the build is done, has failed, is stuck, or the same steps were killed at the end of three chunks (traps 9 and 57). `build.ps1` copies `tooling/args/<config>.gn` into the output directory, appends `stedding_version` from `VERSION`, runs `gn gen` and `autoninja`, and prints a progress line every minute (steps done, compilers, commit charge). `-BudgetMinutes` stops a chunk: exit 2 means it was still moving and a rerun resumes; exit 3 means no step finished and no compiler was running. `-KeepGoing` lists every error in one pass (trap 50). `-Jobs` caps the commit charge (traps 54, 74). The supervisor's default is 12. Alone, `build.ps1` builds `win-release`'s `chrome` and `mini_installer`. The supervisor also builds `unit_tests` and `stedding_browser_tests`. `win-checks` (DCHECKs and the dangling-pointer detector), `win-asan` and `win-debug` are for those test targets (`docs/ARCHITECTURE.md`, "Build configurations"). Off the Mac, `stedding_browser_tests` depends on `//chrome:packed_resources` (patch 0070), so a build of the test targets repacks `resources.pak` and the locale paks and the tests read that build's pages (S-213). A build is refused while a `chrome.exe` from that output directory is running. A test binary still running is not looked for, and the link fails the same way (trap 100).
4. `tooling/dev test all --no-build` (or one feature) runs the same filters against `out/win-release`. `tooling/dev test browser --no-build` runs `stedding_browser_tests` in two legs: most of them two at a time (`STEDDING_BROWSER_JOBS`, default 2 here and 4 on the Mac, trap 88) and the serial list one at a time, both through `timeout` (traps 56, 88). The default cap is 900 seconds. On a sanitizer build, set `STEDDING_TEST_OUT=win-checks` or `win-asan`: the run-time flags are set for you, and a finding is printed through `tooling/digest-sanitizer`. `STEDDING_TEST_LOG=<path>` keeps the raw output, one file per binary, emptied when a run starts. A browser-suite run under ASan takes 20 minutes: `STEDDING_TEST_BUDGET_S=2400`. The session must be connected (trap 59).
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

- `tooling/fetch-sparkle` puts Sparkle 2.10.0 in the checkout at `third_party/stedding_sparkle/` (gitignored), with a `README.chromium` so the credits page names it. `tooling/build-chromium` runs that on every Mac build and sets `stedding_sparkle = true`. A build that never sets the flag has no updater.
- The feed URL and the EdDSA public key are in `chrome/app/app-Info.plist`. The feed is `updates/appcast.xml` on `main`, served from GitHub. `build/apple/tweak_info_plist.py` writes `CFBundleVersion` from `VERSION` (Up11).
- Only a bundle signed by a team starts the updater, so the ad hoc `out/release/Stedding.app` never replaces itself. Tests pass `--test-type` and use `stedding::FakeAppUpdater`.
- The private key is in the release Mac's login keychain under the account `stedding` (`generate_keys --account stedding`), and in the owner's backup. The repository does not hold it. Without that key no installed copy can be offered an update, and a new key reaches people only in a release they install by hand (ADR 0022).
- Offering a release is `tooling/publish-appcast` after `tooling/publish-release`, once the release has been tried the way a user gets it (trap 47).

With automatic updates on, a launch checks when the last check is over an hour old, ten seconds after that launch, and then every six hours while the browser runs (Up1, patch 0078). A launch inside that hour does not check again.

The local n-1 check, before a release that changes the updater or its feed. Sign two copies of one `out/release` build with the Developer ID (`STEDDING_SIGN_IDENTITY`) via `tooling/sign-release release --development`, which calls `sign_chrome.py --development --notarize none`. Lower `CFBundleVersion` on the older copy. Before signing, set three keys in each copy's `Info.plist`: `SUFeedURL` to a local server (`http://127.0.0.1:<port>/appcast.xml`; the app's `NSAllowsArbitraryLoads` allows it), `CrProductDirName` to a test folder, so the copy Sparkle relaunches still uses that profile, and `SUDefaultsDomain` to a test domain, so Sparkle's keys stay off the real app. Make the test folder and put a `First Run` file in it. A missing or empty folder is filled from `~/Library/Application Support/Chromium` when that folder holds a Stedding profile; a Chromium profile is left alone (windows N8). Without the file, a folder that was not filled is a first run and restores no tabs. Put the newer copy in a DMG signed with `sign_update`, write the feed with `tooling/appcast.py write --url ...`, sign the feed, and serve both with `python3 -m http.server`. Run the older copy from a folder of its own. It fetches the feed and the image, the sidebar shows the pill, and `AXPress` (no pointer) or a quit installs the newer copy in place. The relaunch's `CFBundleVersion` is the newer one, and the test profile's tabs come back.

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
- The version. `tooling/win/build.ps1` writes the product version into the checkout's `chrome/VERSION` before `gn gen` (S-72): `<milestone>.<100 × major + minor>.<patch>.<beta>`, with 999 for a release. The milestone is the pin's. Chromium's own version stays on the next line, `CHROMIUM_VERSION`, which `version_info::GetChromiumVersionNumber()` returns for the user agent, the client hints, the Web Store, the component updaters and About. The file shows as modified, as the branding does. `git checkout -- chrome/VERSION` restores Chromium's, and `tooling/sync-chromium` does that before a sync. An unchanged version rebuilds nothing. A change rebuilds what includes the version headers. `VERSION` is `0.3.0-beta.22` and the pin is `157.0.8103.31`, so a Windows build of this tree is `157.3.0.22`. The released 0.3.0 beta 22 was built on Chromium 156, so that installer is `156.3.0.22`.
- Only a copy the installer put in `%LOCALAPPDATA%\Stedding\Application` starts the updater (Up21). `out\win-release\chrome.exe` does not, and a test does not.
- The installer runs hidden, with `--do-not-launch-chrome --verbose-logging --log-file=...`. Chromium's in-use update leaves `new_chrome.exe` and the rename command in `HKCU\Software\Stedding`. `chrome::AttemptRestart`, or any quit, swaps it in (`chrome/browser/first_run/upgrade_util_win.cc`). `InstallerError` in that key is the installer's status: 30 is `IN_USE_UPDATED`, 31 is `SAME_VERSION_REPAIR_FAILED` (`chrome/installer/util/util_constants.h`; trap 62).
- The private key is on the Windows release PC at `%USERPROFILE%\.stedding\update-key`. `tooling/win/update-key.ps1 -Create` refuses to replace one. The key is encrypted and the passphrase is under DPAPI. The operator keeps a backup (`-Backup <folder>`). Without the key no installed Windows copy can be offered an update.
- Offering a release is `tooling/win/publish-appcast.ps1` after `tooling/publish-release`.

The schedule matches the Mac: ten seconds after a launch when the last check is over an hour old, then every six hours (Up14, patch 0078). `--stedding-update-feed` points a copy at a test feed, still checked with the same key. Plain http is allowed only for that test feed, and only to this computer.

The local n-1 check is `tooling\win\update-n1.ps1`. Build A at one `VERSION` and B at the next, and package each with `tooling\win\package-installer.ps1`. Install A over the installed copy with `tooling\win\test-installer.ps1 -Mode upgrade`. Do that from a one-off task, and read the registry from that task: a shell of an agent's app sees a virtualised copy with no `pv` and no uninstall entry (trap 40). Write B's feed with `tooling\win\publish-appcast.ps1 -Installer <B> -Feed <dir>\appcast-windows.xml -Url http://127.0.0.1:<port>/<B's name>`, put B's installer in that folder, and run `update-n1.ps1 -Feed <dir>` in the operator's own session. The script serves the folder, launches the installed A on a scratch profile with `--stedding-update-feed`, `--no-first-run` and the welcome already shown, and presses the pill through UI Automation (trap 118). The log ends in `N1_DONE`. About and `HKCU\Software\Stedding`'s `pv` should be B's version, and `new_chrome.exe` should be gone.

## Release channel

Releases are GitHub Releases. `tooling/publish-release` creates one as the repository's latest, so the repository page and `/releases/latest` show it. `--prerelease` marks a test release instead. The latest release is Stedding 0.4.0 beta 3 (`v0.4.0-beta.3`, 2026-10-31), for macOS and Windows, built on Chromium 157.0.8103.31; `tooling/dev status` counts the patches. `VERSION` names the latest release, so the next release starts by bumping that file. The tag is `v` plus `VERSION`. The shipped platforms are macOS and Windows. The Windows image is built on a Windows PC and the Mac image on a Mac.

Installed copies update themselves from the feeds in `updates/`, served from GitHub: Sparkle on the Mac, Stedding's updater on Windows. The site is not on that path (ADR 0014).

The Mac image is a DMG. The app is signed with the Developer ID and notarized. `tooling/package-dmg` then signs, notarizes and staples the image when that app is notarized and `STEDDING_SIGN_IDENTITY` and `STEDDING_NOTARY_ARGS` are set. `STEDDING_DMG_UNSIGNED=1` leaves the image unsigned. The Windows installer is unsigned (S-56). Each file has its sha256 beside it.

On the Mac, from the repo root, with a clean tree: bump `VERSION`, run `tooling/dev build release chrome` (the About line is `stedding_version`), empty `dist/`, run `tooling/sign-release release` (`--check` first; it signs, notarizes and staples into `dist/signed/stable/Stedding.app`), `tooling/verify-build --app dist/signed/stable/Stedding.app`, then `tooling/package-dmg release --app dist/signed/stable/Stedding.app`. That writes `dist/Stedding-<VERSION>-arm64.dmg` and its `.sha256`. Run `syspolicy_check distribution` on that app (trap 47), paste the checksum into `docs/release-notes/v<VERSION>.md`, commit, and push. Then `tooling/publish-release --check` and `tooling/publish-release`. Try the release the way a user gets it (trap 47). Then offer it: `tooling/publish-appcast --check`, then `tooling/publish-appcast --push` on the operator's yes for that release (ADR 0022). The push signs the image, writes and signs `updates/appcast.xml`, and commits it. Fetch the feed from its raw.githubusercontent.com URL. It should match the commit, `sign_update --account stedding --verify` should pass, and the image downloaded from the release should match the feed's `edSignature` (`sign_update --verify <image> <signature>`).

`publish-release` refuses to run until this commit is on the remote, and it pins the tag with `--target`. Push the commit first. It then fetches the tag GitHub created. `package-dmg` names the image from `VERSION` and warns about any other image left in `dist/`. `publish-release` takes the image named for this `VERSION`, accepts a single image that is not named that way, refuses to choose between two, and checks the sha256 against the file beside the image and against the release notes.

Windows joins the same release from the PC. Run `tooling\win\build-until-done.ps1`, then both suites on that build, `tooling\win\package-installer.ps1`, and `tooling\win\test-installer.ps1` (`-Mode backup`, then `upgrade`, `uninstall-keep`, `install`). Use the installed build the way release checklist item 13 says (`docs/ROADMAP.md#release-checklist`). Paste the checksum under *Windows* in the notes, commit, push, and run `tooling/publish-release` from Git for Windows. Whichever platform publishes first creates the release. The other uploads into it, and the notes are refreshed (ADR 0018). Then the Windows feed, on the PC after `git pull`: `tooling\win\publish-appcast.ps1 -Check`, then `-Push` on the operator's yes (ADR 0023). Push one feed at a time. Both feeds are commits to `main`.

A newer Windows build installs over an older one as an ordinary upgrade, including two releases on the same Chromium milestone (patch 0073, S-72). An installer of the version already installed still repairs, and Stedding has to be closed for that (trap 62). The PC builds and tests its own image. A browser suite started over SSH lands in session 0 and fails (traps 67, 68).

**After a release.** Every place that names the release:

| Where | What follows the release | By hand |
|---|---|---|
| GitHub Releases | `tooling/publish-release` | |
| README, Download ("The newest release is ...") | written in the release commit; `publish-release` refuses a README that does not name the release | |
| The feeds (`updates/appcast.xml`, `updates/appcast-windows.xml`) | `tooling/publish-appcast --push` and `tooling\win\publish-appcast.ps1 -Push`, each on the operator's yes | |
| stedding.dev | its Rebuild workflow reads the release list, pre-releases included; `publish-release` starts it, and it runs every six hours | `gh workflow run rebuild.yml -R ysalitrynskyi/stedding.dev` |
| The Homebrew cask (`ysalitrynskyi/homebrew-stedding`, `Casks/stedding.rb`) | its Bump workflow reads the release marked latest and the DMG's `.sha256`; `publish-release` starts it once the Mac image is in, and it runs every six hours. A release with no Mac image yet changes nothing | `gh workflow run bump.yml -R ysalitrynskyi/homebrew-stedding` |

Within the hour, the home page's download section should name the release, and this should carry its version:

```
gh api repos/ysalitrynskyi/homebrew-stedding/contents/Casks/stedding.rb --jq .content | base64 -d
```

The cask depends on the image's name (`Stedding-<version>-arm64.dmg`) and the `.sha256` beside it. A change to either is a change to `Casks/stedding.rb` in the same round.

When what a user installs changes (a new platform, a requirement, a file name, an install step), change every place that tells them, together: `README.md` (Download), `docs/INSTALL.md`, `docs/FAQ.md`, the cask (`depends_on`, `url`, `zap`), and on stedding.dev the download section (`src/pages/index.astro`), `content/copy.md`, `public/llms.txt`, the press kit's Platforms line and `/arc/`. Homebrew installs with `brew install --cask ysalitrynskyi/stedding/stedding`. The README, `docs/INSTALL.md` and the site's download notes say so.

**Release at least every five weeks, on a pin whose build date moves.** Chromium applies its built-in list of sites that must load only over HTTPS while the build is under 70 days old. `TransportSecurityState::IsBuildTimely()` in `net/http/transport_security_state.cc` is `(base::Time::Now() - build_time).InDays() < 70`. After that, `GetStaticSTSState()` returns false and the list is not applied. The date is the pin's commit, not the day of the build. `build/compute_build_timestamp.py` reads `build/util/LASTCHANGE.committime`. What this recipe ships is not an official build (`release` on the Mac, `win-release` on Windows; S-168), so that time is rounded down to 05:00 UTC on the first Sunday of the month, or of the month before when the commit falls earlier. An official build would keep the commit's own time. The pin `157.0.8103.31` was committed on 2026-10-27, after 4 October, so it rounds to 2026-10-04, the same day the Chromium 156 releases use. The list lapses on 2026-12-13. The notes of 0.3.0 beta 22 say so for that release. Another release on this pin keeps 2026-10-04. The date moves when a pin's commit is on or after 05:00 UTC on 1 November 2026, the next such Sunday.
