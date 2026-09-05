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
(the essentials row). `space_pin_tabs/N` — pin the first N tabs in their Space,
their URL as home; `drift_tabs/N` — then send the first N of those to the next
tab's page (a drifted pin, for pins H4 and H12). `folder_tabs/N` — wrap first N tabs in a folder and nest
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

12. **Patch files are tracked, so ADR 0007's version scan reads them.** A unit test
    that spelled the pinned Chromium version (`stedding_version_unittest.cc`) passed
    `tooling/check-repo` while its patch was still untracked and failed the moment
    the patch was committed. Tests of version formatting use a made-up version
    (`150.0.1234.5`); only `tooling/chromium-version` carries the pin (2026-09-05).

13. **The machine's input source leaks into the harness.** A `type` step that used
    virtual key codes alone typed Cyrillic into the address bar once a non-Latin
    input source was active (2026-09-05, 05:21: `chrome://settings/stedding` became a
    DuckDuckGo search). `tooling/drive-window.py` now puts the character on every
    typed event as well as the code; if a capture shows the wrong script, that is
    the first thing to check.

14. **A new `IDC_` id rebuilds most of the browser.** Adding one line to
    `chrome/app/chrome_command_ids.h` (2026-09-05, `IDC_STEDDING_COMMAND_PALETTE`) put
    about 2,800 steps on the unit_tests build at roughly 0.5–0.8 steps a second: four
    15-minute chunks. Batch new ids with other header-wide changes, and start such a
    build first thing in a session rather than last.
15. **On the Mac the focus manager sees a key before the focused view does.** A
    Textfield that wants ⇥ (the command bar's mode switch, 2026-09-05) never gets it:
    `FocusManager::OnKeyEvent` runs tab traversal first, focus lands on the toolbar
    and the bar closes on the focus change -- while the unit test, which calls the
    controller's `HandleKeyEvent` directly, stays green. Claim the key in
    `SkipDefaultKeyEventProcessing` (as `OmniboxViewViews` does) and assert the claim
    in the test. The same shape hides a sizing bug: a panel that sizes itself from
    its rows must recompute its bounds on every rebuild path; a `GetPreferredSize`
    probe cannot see an early `return`, only the live shot can.

16. **Stedding's own WebUI CSS and TypeScript go through Chromium's linters at build
    time.** stylelint wants a blank line before every rule and short hex colours
    (`#fff`, not `#ffffff`); the Lit template linter wants event handlers named
    `on<Context><Event>_` (`onRouteAddChange_`, not `onRouteAdd_`). A lint failure
    stops the build before any compile step, so read the first `✖` line of the log.
17. **A fixup into an earlier patch can conflict with a later patch's hunk in the
    same include block.** `git rebase --autosquash` then stops twice: once applying
    the fixup, once re-applying the later patch. Both conflicts were include lists;
    the resolution is the union of both sides, deduplicated, then `git add` and
    `GIT_EDITOR=true git rebase --continue`, and only then `git stash pop` the
    branding files. Check `git status` shows no non-branding changes at the end.
18. **Small things that cost a build each:** the shell here is zsh, which does not
    word-split an unquoted `$var` (pipe file lists through `xargs`); `tooling/dev`
    and `tooling/check-repo` are relative to the repo root, so a subshell that `cd`s
    into the checkout must call them by absolute path; a bar action gated on an
    asynchronous check (a file's existence) has to be primed at window creation,
    not at the first actions-mode bar, or every first look at it comes up empty.
19. **The vertical tab strip's anonymous Spaces take their glyph and name from
    their index.** A reorder of two unnamed Spaces is invisible in a capture except
    through the active highlight and the title row; give one an icon through its
    chip menu before capturing a drag.
20. **Small things that cost a build each, round 6 wave 3:** a `views::View`
    subclass, even one in an anonymous namespace, needs `METADATA_HEADER` and
    `BEGIN_METADATA`/`END_METADATA` or `AddChildView` fails a static assert;
    `views::LabelButton::label()` is protected, so a row whose font must change
    is a subclass that re-exports it; `switches::kEnableFeatures` is in
    `base/base_switches.h`, not content's switches; gn targets are named after
    their directory unless the BUILD file says otherwise
    (`//components/embedder_support`, `//components/bookmarks/test`); a
    `Browser` has `GetProfile()`, not `profile()`, and no `window()` (use
    `BrowserWindow::FromBrowser`); `SkColorGetR` and friends are macros, not
    functions. In the live checks, chrome://settings' search box finds a row
    but does not scroll to it: click the page body and press space instead;
    `tooling/drive-window.py` writes its `shot` files into the current
    directory, so `cd` to the scratch directory first; the feature params
    `folder_tabs` and `pin_tabs` do not exist, a folder comes from the ⌘T
    action "Move Tab to New Folder" and a Space pin from "Pin to This Space".
21. **Wave 4's lessons.** `content::WebContents::Create` makes a plain
    WebContents; `WebContentsTester::For` on it is a wrong cast that only
    sometimes faults (patch 0027's restored-tab test did, once the layout
    shifted): a test that drives navigation makes its contents with
    `WebContentsTester::CreateTestWebContents`. A view's `UnownedUserData` must
    die before its window: a per-window mark lives on `BrowserWindowFeatures`
    as a plain flag. `tooling/drive` passes `--window-size` and
    `--window-position`, which the window sizer applies to every window the
    process opens, so a little window's own bounds only show on a plain
    launch; and its `shot` picks the window behind when two share a position:
    `screencapture -x -R x,y,w,h` of the front one instead. The
    `extra_spaces` feature param adds a Space to every new window, and with
    the registry that Space is shared: make the second Space through the
    sidebar's "+" when capturing a second window.
22. **Never drive the machine while the operator is at it — and an app launched
    under lldb is never key for the harness.** A `drive-window.py` run against a
    browser started by `lldb --batch` could not activate it; every synthetic key
    went to the frontmost app, which was the operator's chat (2026-09-05). The
    input-free path covers almost everything: `tooling/capture-ui` (a window
    capture by id, no focus change) with feature params for the state
    (`folder_tabs/N` does exist, whatever trap 20 says; `pin_tabs/N`,
    `extra_spaces/N`, `space_pin_tabs/N`, `drift_tabs/N`; the collapsed rail is
    a profile preference, `vertical_tabs.collapsed_state`, seeded into a fresh
    profile's `Default/Preferences`), and `osascript -e 'tell application "…/Stedding.app" to
    quit'` for a clean quit — which is also how the folder quit crash was
    reproduced under `lldb --batch -o run -k "bt 40"` with a symbolised stack
    (the release build keeps its symbol table; `symbol_level=0` drops only the
    line tables). Drives wait for an empty chair.
23. **An apply script's anchors die at the first clang-format.** The pipeline
    formats after applying, so a re-run fails on any anchor or guard that
    clang-format rewrapped, and stops before the build. Re-run the pipeline
    with a no-op apply once the edits are in, and write guards on lines
    clang-format will not touch.

## Open items

`BACKLOG.md` is the list; do not keep one here. First up: the operator
retests (`S-9`, `S-10`) on the DMG in `dist/`, which `tooling/package-dmg
release` cuts from the current series.

## Release channel

Pre-releases on GitHub Releases, unsigned, with the Gatekeeper right-click
instructions in the notes and the sha256 beside the DMG.
`tooling/package-dmg release` builds `dist/Stedding-<ver>-arm64.dmg`.
