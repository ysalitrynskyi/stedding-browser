# Handoff — how to pick this project up cold

Written for the next agent (or human) continuing this work. AGENTS.md is the
project context; this file is the operational knowledge that is otherwise only
in one contributor's head. Read both.

## Where things live

- This repo (`~/work/stedding-browser` on the original machine): docs, tooling,
  the patch series in `patches/`, branding. Public; never commit secrets or
  machine paths.
- The Chromium checkout: `/Users/Shared/chromium/src`, pinned to
  `tooling/chromium-version`, on branch `stedding-work`. The patch series in
  `patches/` is generated FROM that branch by `tooling/update-patches` — the
  branch is the source of truth while working; the patches are the durable
  artifact.
- Build output: `out/release` (proprietary codecs on). `out/official` exists
  for performance baselines (never quote numbers from `release`;
  `docs/QUALITY.md`).

## The loop that works

The procedure is `docs/AGENT-LOOP.md`; the command is `tooling/dev`. Short form:

```bash
# 1. spec the behaviour in docs/features/<feature>.md, write the failing test
# 2. edit code in /Users/Shared/chromium/src (on stedding-work) -- never while a build runs
tooling/dev test spaces               # builds unit_tests, runs the feature's filter
tooling/dev capture --features 'SteddingArcStyleWindow:extra_spaces/2/pin_tabs/1'
# look at the capture. measure pixels, don't eyeball.
# 3. commit in the checkout with Why:/Removable when: footers -- a fix to an existing
#    feature is a fixup into that feature's commit (git commit --fixup=<sha>, then
#    GIT_SEQUENCE_EDITOR=true git rebase --autosquash <pin>), not a new patch
tooling/dev patch                     # update-patches + check-repo
tooling/dev status                    # the numbers for any doc you touch
# commit + push this repo
```

`tooling/verify-build --app .../Stedding.app` checks rendering, codecs (H.264
decodes real frames), and navigation.

## Dev parameters (all on `SteddingArcStyleWindow`, tunable without rebuilds)

`contents_corner_radius`, `vertical_tab_height`, `vertical_tab_corner_radius`,
`vertical_tab_pinned_height`, `location_bar_height`, `location_bar_width`,
`toolbar_vertical_margin`, `toolbar_button_height`, `toolbar_button_inset`,
`toolbar_button_icon_size`, `tab_favicon_size` — metrics.
`extra_spaces/N` — start with N extra Spaces. `pin_tabs/N` — pin first N tabs
(the essentials row). `folder_tabs/N` — wrap first N tabs in a folder and nest
one (exercises the whole folder pipeline). `open_command_bar/true` — open ⌘T
overlay at startup. `drag_tabs_to_spaces` — on by default.

All exist because pinning/folders/⌘T are UI gestures a headless harness cannot
perform; a param that recreates the state IS the test surface.

## Traps this project already paid for (do not rediscover)

1. **siso stats sources once, near build start.** Edit during a build and your
   change silently misses the binary; `build-chromium` now warns when the tree
   moved mid-build. Never edit the checkout while a build runs.
2. **Screenshots cannot see teardown or input.** The folder close-crash (UAF)
   was invisible to every capture and found by a unit-test fixture. Anything
   that owns a tab needs a test, not a screenshot.
3. **Synthetic input**: `CGEventPostToPid` reaches the app for HOVER without
   focus; CLICKS and DRAGS need the window key (activate the process via
   System Events first, then post HID-tap mouse events; a tab drag needs a few
   slow moves past the threshold before the long move). Never drive the
   user's real pointer while they are at the machine. `tooling/capture-window.py`
   captures one window by id — never the screen. `tooling/drive` is the tool:
   its header lists the traps (a created key event inherits the last chord's
   modifiers, so clear them; a Cmd+Q keystroke does not quit, the AppleEvent
   does).
4. **SIGTERM does not reliably flush Chromium session files** from a raw binary
   launch — live restore tests via kill are meaningless; `tooling/drive` quits
   through an AppleEvent, which does flush. And the session log is **rebuilt
   from the live browser** at startup and every 250 writes: anything a feature
   keeps in session extra data must be re-emitted through
   `stedding_session_rebuild.h` *and* written once the window is tracked, or
   it survives exactly one restart.
5. **macOS bash is 3.2** (no mapfile); `tooling/check-shell` runs a pinned
   shellcheck because versions disagree about real findings.
6. **Chromium API drift in this tree**: `base::Value::Dict/List` are
   `base::DictValue/ListValue`; `TokenId` parses via `base::Token::FromString`
   + `FromRawToken`; `BubbleDialogDelegateView`/`WidgetDelegateView` cannot be
   subclassed outside Views (private ctor + friend list); `views::Separator`
   paints its whole bounds; FlexLayout stretches children that don't declare
   sizes (BoxLayout honours alignment).
7. **Tracked prefs** (`pinned_tabs`) cannot be seeded externally — that is
   anti-tampering working; add a dev param on our own code instead.
8. **Colour mixers hand out single colours** — the dark gradient is painted
   once on BrowserView with sidebar/top-container/mat made *invisible, not
   removed* (a nulled background crashes: the layout dereferences it).

9. **A sleep loop is not supervision.** A vanilla `official` build ran 3.5 h
   with an agent polling for an exit line and nothing else; the operator had to
   ask whether it was stuck (it was at 95%, but nobody could tell). Rule, now
   in code: `build-chromium` has a 15-minute budget, prints objects and active
   compilers every minute, and kills the build past the budget; longer runs
   are asked for and passed as `--budget <minutes>`. Hand-written waits follow
   the same rule (`docs/AGENT-LOOP.md`).

- **Trap 5 — synthetic mouse events inherit modifiers too.** After a `key f+ctrl+cmd`
  the harness's next plain click carried Ctrl, which macOS reads as a right-click:
  context menus opened where a click was meant. `tooling/drive-window.py` clears the
  flags on every mouse event now; if a "click" ever opens a menu, check this first.

6. **A floating window from another app can sit over the capture harness's
   click targets** (2026-09-03: Arc's mini player parked at the screen's
   top-left corner swallowed every click on the sidebar's first rows, so a
   pinned tab looked as if it had no context menu). Window captures never
   show it. Before blaming a view, list what is on screen there:
   `python3 -c 'import Quartz; ...CGWindowListCopyWindowInfo(...)'` or a
   full-screen `screencapture -x`, and move our window with
   `--window-position` on a fresh profile (a restored session keeps its old
   bounds).

7. **`tooling/drive`'s `shot` photographs the browser window's rectangle, not
   every window Stedding owns.** Menus, bubbles and sheets are in it; the
   welcome dialog (a separate child window) is not, so a check of it needs a
   full-screen `screencapture -x` while the run is parked on a `wait`, or a
   `CGWindowListCopyWindowInfo` listing to prove the window exists and where.

8. **A fold that stashes the branding and then fails leaves the stash
   unpopped** (2026-09-04: an autosquash rebase conflicted, `git rebase
   --abort` restored the tree, but `git stash list` still held the branding).
   The next `tooling/dev build` then produces `Chromium.app`, and
   `tooling/drive` keeps launching the stale `Stedding.app`, so every "fix"
   looks ineffective. After any failed fold run `git stash list`; scripts that
   stash must pop in an EXIT trap; `ls out/release/*.app` says which product
   the last build made.

9. **A new `.grdp` part must also be listed in `chrome/app/generated_resources.grd.gritdeps`**
   (2026-09-04: `stedding_strings.grdp`, the one file for every string this fork
   adds, failed the first build at `generated_resources_check_gritdeps` with a
   "gritdeps mismatch" diff; the manifest is sorted, add the line where the
   diff says). Stedding strings that reach a macOS menu or a toast need real
   `IDS_` ids; the settings page and the command bar still use literals.

10. **A drive's keys go nowhere when the window is not key.** Two runs that
    opened two URLs (`https://example.com/ https://example.org/`) came up with grey
    traffic lights; `activate` twice did not help, and ⌥⌘N never reached the window.
    Read the traffic lights in the shot before blaming a chord. The fallback that
    works for anything with a menu row is System Events from the foreground shell
    while the drive parks: `click menu item "Add Tab to New Split View" of menu 1 of
    menu bar item "Tab" of menu bar 1` (2026-09-05).
11. **`tooling/dev build` refuses under 60 GB free, and drives eat the margin.**
    Every `tooling/drive` profile keeps 100–500 MB of cache; a batch of ten leaves
    the volume 3 GB lighter and the next build exits at once with "need 60 GB free".
    Delete the scratch profiles after each batch (`rm -rf <scratchpad>/p-*`), then
    the reclaims in the disk runbook (old Playwright browsers, `npm cache clean`).
    The browser itself leaks `$TMPDIR/dev.stedding.Stedding.chromium_chrome_url_fetcher_.*`
    (25 MB each; 323 of them, 8.3 GB, after two days of drives) — delete those too.
    `df -k` is the number the check reads; Finder's figure includes purgeable space.
    For an incremental chunk `STEDDING_MIN_FREE_GB=40 tooling/dev build …` lowers the
    floor (20 is the least it accepts); the 60 stays the default for full builds.

## Open items

`BACKLOG.md` is the list; do not keep one here. First up: the operator
retests (`S-9`, `S-10`) on the DMG in `dist/`, which `tooling/package-dmg
release` cuts from the current series.

## Release channel

Pre-releases on GitHub Releases, unsigned, with the Gatekeeper right-click
instructions in the notes and the sha256 beside the DMG.
`tooling/package-dmg release` builds `dist/Stedding-<ver>-arm64.dmg`.
