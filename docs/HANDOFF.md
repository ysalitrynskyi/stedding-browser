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

The capture step has two tools. `tooling/capture-state --out <prefix> --features
'SteddingArcStyleWindow:...' [switches] [URLs]` launches a fresh profile in the state
the params describe, photographs every window the process owns by window id (a
dialog is `<prefix>-2.png`), quits through the AppleEvent and reports an abort: no
synthetic input, no focus change, safe while someone is at the machine, and the way
round 7 was verified. `tooling/drive <profile> <steps>` clicks, drags and types; it
is the only way to reach a context menu or a typed URL, and it waits for an empty
chair (trap 27). Measure the PNG (PIL, a luma scan) rather than eyeballing it.

## What can be checked without a Mac

Most of this project needs the Mac. Three things do not, and they are worth knowing
about before assuming a check has to wait for a build:

- **The series applies.** `tooling/apply-patches --check` reads the pinned tree into a
  temporary index and applies the series into it. Plain git: no depot_tools, no build,
  no macOS. Getting the tree is a `git init` plus one blobless-free depth-1 fetch of
  the tag (about 1.4 GB, two minutes); no working tree is needed, because
  `git apply --cached` reads objects rather than files. The `series` workflow does
  exactly this on every change to `patches/` or the pin, cached under the pin.
- **The window's geometry.** `tooling/check-geometry` re-measures the card's gutters
  and corner radius in `docs/images/*.png` against `tooling/probes/geometry.json`. It
  needs Pillow and the committed captures, so it runs wherever CI runs. Two traps in
  measuring this way: read a gutter as a band of window ground across the whole card
  rather than as one probed pixel, or the page's own content answers instead; and fit
  a corner radius across the whole arc, because the inset of the edge one scanline
  below the top is `r - sqrt(2r)`, which reads 8.7 for a 12 px corner and looks like a
  real discrepancy.
- **shellcheck at the pinned version.** The Windows build of the pinned release runs
  under Git Bash through a one-line shim on PATH, so `tooling/check-shell` gives the
  same answer CI gives.

What still cannot: the build, Chromium's own suites, anything driving a window, and
signing. The patch series touches nine Objective-C++ files against AppKit and needs
full Xcode, so no amount of disk changes it. That is `S-49`.

## Dev parameters (all on `SteddingArcStyleWindow`, tunable without rebuilds)

`contents_corner_radius`, `vertical_tab_height`, `vertical_tab_corner_radius`,
`vertical_tab_pinned_height`, `location_bar_height`, `location_bar_width`,
`toolbar_vertical_margin`, `toolbar_button_height`, `toolbar_button_inset`,
`toolbar_button_icon_size`, `tab_favicon_size`, `card_gutter` — metrics.
`extra_spaces/N` — start with N extra Spaces. `pin_tabs/N` — pin first N tabs
(the essentials row). `space_pin_tabs/N` — pin the first N tabs in their Space,
their URL as home; `drift_tabs/N` — then send the first N of those to the next
tab's page (a drifted pin, for pins H4 and H12). `folder_tabs/N` — wrap first N tabs in a folder and nest
one (exercises the whole folder pipeline). `open_command_bar/true` — open ⌘T
overlay at startup. `drag_tabs_to_spaces` — on by default.

All exist because pinning/folders/⌘T are UI gestures a headless harness cannot
perform; a param that recreates the state IS the test surface. Two switches do the
same for windows: `--stedding-welcome[=<step>]` forces the welcome flow (on a named
step: `search`, `import`, `appearance`, `default`, `keys`), and `tooling/capture-state
--seed collapsed` writes the collapsed-rail preference (`vertical_tabs.collapsed_state`)
into the fresh profile.

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

10. **Synthetic mouse events inherit modifiers too.** After a `key f+ctrl+cmd`
    the harness's next plain click carried Ctrl, which macOS reads as a right-click:
    context menus opened where a click was meant. `tooling/drive-window.py` clears the
    flags on every mouse event now; if a "click" ever opens a menu, check this first.

11. **A floating window from another app can sit over the capture harness's
    click targets** (2026-09-03: Arc's mini player parked at the screen's
    top-left corner swallowed every click on the sidebar's first rows, so a
    pinned tab looked as if it had no context menu). Window captures never
    show it. Before blaming a view, list what is on screen there:
    `python3 -c 'import Quartz; ...CGWindowListCopyWindowInfo(...)'` or a
    full-screen `screencapture -x`, and move our window with
    `--window-position` on a fresh profile (a restored session keeps its old
    bounds).

12. **`tooling/drive`'s `shot` photographs the browser window's rectangle, not
    every window Stedding owns.** Menus, bubbles and sheets are in it; the
    welcome dialog (a separate child window) is not, so a check of it needs a
    full-screen `screencapture -x` while the run is parked on a `wait`, or a
    `CGWindowListCopyWindowInfo` listing to prove the window exists and where.

13. **A fold that stashes the branding and then fails leaves the stash
    unpopped** (2026-09-04: an autosquash rebase conflicted, `git rebase
    --abort` restored the tree, but `git stash list` still held the branding).
    The next `tooling/dev build` then produces `Chromium.app`, and
    `tooling/drive` keeps launching the stale `Stedding.app`, so every "fix"
    looks ineffective. After any failed fold run `git stash list`; scripts that
    stash must pop in an EXIT trap; `ls out/release/*.app` says which product
    the last build made.

14. **A new `.grdp` part must also be listed in `chrome/app/generated_resources.grd.gritdeps`**
    (2026-09-04: `stedding_strings.grdp`, the one file for every string this fork
    adds, failed the first build at `generated_resources_check_gritdeps` with a
    "gritdeps mismatch" diff; the manifest is sorted, add the line where the
    diff says). Stedding strings that reach a macOS menu or a toast need real
    `IDS_` ids; the settings page and the command bar still use literals.

15. **A drive's keys go nowhere when the window is not key.** Two runs that
    opened two URLs (`https://example.com/ https://example.org/`) came up with grey
    traffic lights; `activate` twice did not help, and ⌥⌘N never reached the window.
    Read the traffic lights in the shot before blaming a chord. The fallback that
    works for anything with a menu row is System Events from the foreground shell
    while the drive parks: `click menu item "Add Tab to New Split View" of menu 1 of
    menu bar item "Tab" of menu bar 1` (2026-09-05).

16. **`tooling/dev build` refuses under 60 GB free, and drives eat the margin.**
    Every `tooling/drive` profile keeps 100–500 MB of cache; a batch of ten leaves
    the volume 3 GB lighter and the next build exits at once with "need 60 GB free".
    Delete the scratch profiles after each batch (`rm -rf <scratchpad>/p-*`), then
    the reclaims in the disk runbook (old Playwright browsers, `npm cache clean`).
    The browser itself leaks `$TMPDIR/dev.stedding.Stedding.chromium_chrome_url_fetcher_.*`
    (25 MB each; 323 of them, 8.3 GB, after two days of drives) — delete those too.
    `df -k` is the number the check reads; Finder's figure includes purgeable space.
    For an incremental chunk `STEDDING_MIN_FREE_GB=40 tooling/dev build …` lowers the
    floor (20 is the least it accepts); the 60 stays the default for full builds.

17. **Patch files are tracked, so ADR 0007's version scan reads them.** A unit test
    that spelled the pinned Chromium version (`stedding_version_unittest.cc`) passed
    `tooling/check-repo` while its patch was still untracked and failed the moment
    the patch was committed. Tests of version formatting use a made-up version
    (`150.0.1234.5`); only `tooling/chromium-version` carries the pin (2026-09-05).

18. **The machine's input source leaks into the harness.** A `type` step that used
    virtual key codes alone typed Cyrillic into the address bar once a non-Latin
    input source was active (2026-09-05, 05:21: `chrome://settings/stedding` became a
    DuckDuckGo search). `tooling/drive-window.py` now puts the character on every
    typed event as well as the code; if a capture shows the wrong script, that is
    the first thing to check.

19. **A new `IDC_` id rebuilds most of the browser.** Adding one line to
    `chrome/app/chrome_command_ids.h` (2026-09-05, `IDC_STEDDING_COMMAND_PALETTE`) put
    about 2,800 steps on the unit_tests build at roughly 0.5–0.8 steps a second: four
    15-minute chunks. Batch new ids with other header-wide changes, and start such a
    build first thing in a session rather than last.

20. **On the Mac the focus manager sees a key before the focused view does.** A
    Textfield that wants ⇥ (the command bar's mode switch, 2026-09-05) never gets it:
    `FocusManager::OnKeyEvent` runs tab traversal first, focus lands on the toolbar
    and the bar closes on the focus change -- while the unit test, which calls the
    controller's `HandleKeyEvent` directly, stays green. Claim the key in
    `SkipDefaultKeyEventProcessing` (as `OmniboxViewViews` does) and assert the claim
    in the test. The same shape hides a sizing bug: a panel that sizes itself from
    its rows must recompute its bounds on every rebuild path; a `GetPreferredSize`
    probe cannot see an early `return`, only the live shot can.

21. **Stedding's own WebUI CSS and TypeScript go through Chromium's linters at build
    time.** stylelint wants a blank line before every rule and short hex colours
    (`#fff`, not `#ffffff`); the Lit template linter wants event handlers named
    `on<Context><Event>_` (`onRouteAddChange_`, not `onRouteAdd_`). A lint failure
    stops the build before any compile step, so read the first `✖` line of the log.

22. **A fixup into an earlier patch can conflict with a later patch's hunk in the
    same include block.** `git rebase --autosquash` then stops twice: once applying
    the fixup, once re-applying the later patch. Both conflicts were include lists;
    the resolution is the union of both sides, deduplicated, then `git add` and
    `GIT_EDITOR=true git rebase --continue`, and only then `git stash pop` the
    branding files. Check `git status` shows no non-branding changes at the end.

23. **Small things that cost a build each:** the shell here is zsh, which does not
    word-split an unquoted `$var` (pipe file lists through `xargs`); `tooling/dev`
    and `tooling/check-repo` are relative to the repo root, so a subshell that `cd`s
    into the checkout must call them by absolute path; a bar action gated on an
    asynchronous check (a file's existence) has to be primed at window creation,
    not at the first actions-mode bar, or every first look at it comes up empty.

24. **The vertical tab strip's anonymous Spaces take their glyph and name from
    their index.** A reorder of two unnamed Spaces is invisible in a capture except
    through the active highlight and the title row; give one an icon through its
    chip menu before capturing a drag.

25. **Small things that cost a build each, round 6 wave 3:** a `views::View`
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
    directory, so `cd` to the scratch directory first. (This trap once said the
    feature params `folder_tabs` and `pin_tabs` do not exist; they do, and are
    the way to seed a folder or an essential for a capture. A Space pin comes
    from `space_pin_tabs/N`, or the ⌘T action "Pin to This Space".)

26. **Wave 4's lessons.** `content::WebContents::Create` makes a plain
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

27. **Never drive the machine while the operator is at it — and an app launched
    under lldb is never key for the harness.** A `drive-window.py` run against a
    browser started by `lldb --batch` could not activate it; every synthetic key
    went to the frontmost app, which was the operator's chat (2026-09-05). The
    input-free path covers almost everything: `tooling/capture-ui` (a window
    capture by id, no focus change) with feature params for the state
    (`folder_tabs/N` does exist, whatever trap 25 says; `pin_tabs/N`,
    `extra_spaces/N`, `space_pin_tabs/N`, `drift_tabs/N`; the collapsed rail is
    a profile preference, `vertical_tabs.collapsed_state`, seeded into a fresh
    profile's `Default/Preferences`), and `osascript -e 'tell application "…/Stedding.app" to
    quit'` for a clean quit — which is also how the folder quit crash was
    reproduced under `lldb --batch -o run -k "bt 40"` with a symbolised stack
    (the release build keeps its symbol table; `symbol_level=0` drops only the
    line tables). Drives wait for an empty chair.

28. **An apply script's anchors die at the first clang-format.** The pipeline
    formats after applying, so a re-run fails on any anchor or guard that
    clang-format rewrapped, and stops before the build. Re-run the pipeline
    with a no-op apply once the edits are in, and write guards on lines
    clang-format will not touch.

29. **`tooling/capture-state` is the harness that needs no hands.** It launches
    the app on a fresh profile, captures every window the process owns by id and
    quits through the AppleEvent, so a state can be photographed while someone is
    at the machine -- what `tooling/drive` must never do (trap 3). The state comes
    from feature params, not from input: `space_pin_tabs/N`, `drift_tabs/N`,
    `folder_tabs/N`, `pin_tabs/N`, `extra_spaces/N`, `open_command_bar/true`,
    `--stedding-welcome=<step>`, `--seed collapsed`.

30. **A window capture carries the window's shadow.** An absolute y read off one
    is not a window coordinate; compare two things inside the same capture --
    the toggle's centre against the traffic lights' centre (sidebar Y7), never
    either against zero. The exclusion macOS reports for the lights is a box with
    a margin around them, not the glyphs themselves: the glyphs are 12 DIP circles
    at the box's top inset, so half the box's height sits a button 3 DIP low.

31. **Chromium's own suites are not in the Stedding filters, and two of its tab
    tests had been red since patch 0002.** `tooling/dev test <feature>` runs our
    filters; nothing ran `TabTest.*`, which reads the favicon column's width and
    the discard ring -- both of which this fork changes on purpose. Before a
    release, run the suites around what the series touches (`TabTest.*`,
    `TabStripModelTest.*`, `LocationBarViewTest.*`), not only ours.

32. **Windows' caption buttons are on the right, and the frame reports them as
    the trailing exclusion.** The layout skipped every exclusion with a vertical
    strip because macOS's lights sit over the sidebar's column; Windows' buttons
    sit over the row's. Read both exclusions, never assume one side (round 8).
33. **Collapse state and drawn width are two different things.** Expanded on
    hover the state stays collapsed while the strip is at its open width. Anything
    styled for the rail -- centring, icon-only rows, the stacked switcher, the
    opaque ground -- keys on the width being laid out, or it dresses the hover
    overlay as a rail (round 8, three fixes in a row got this wrong first).
34. **A Windows build from the Claude desktop app inherits an MSIX-redirected
    %LOCALAPPDATA%** some 60 characters longer than the real one, and vpython's
    venv then blows past MAX_PATH; point `VPYTHON_ROOT` at a short directory. And
    a driver that clicks must verify the browser is the foreground window first
    (`GetForegroundWindow`, after the Alt-key tap Windows requires):
    `SetForegroundWindow` is allowed to fail, and one launch put the clicks into
    the operator's own app. Trap 36 is the way that needs neither.
35. **A bubble before the window is shown cannot anchor to a tracked element.**
    The element tracker knows a view only once its widget is visible, so a
    startup bubble -- the crashed-session "Restore pages?" one -- that falls
    back to `kFallbackPopupAnchorElementId` because its button is not drawn
    (the address row hidden, toolbar T8) finds nothing, and Chromium's CHECK
    kills the launch: a profile killed while the sidebar was collapsed never
    opened again (round 8, second pass). Anything that hides a toolbar button
    must give such bubbles a drawn view to anchor to (toolbar T23).
36. **On Windows a capture needs neither focus nor input.** `PrintWindow` with
    `PW_RENDERFULLCONTENT` renders a window behind others, provided the launch
    disables occlusion tracking (`--disable-features=CalculateNativeWinOcclusion`)
    so Chromium keeps drawing a covered window; a click goes to the window's own
    queue as `WM_LBUTTONDOWN`/`WM_LBUTTONUP` in client coordinates, never through
    `SendInput`, so nothing reaches whatever the operator is doing. The
    `Chrome_WidgetWin_1` window to render is the largest one of the process:
    bubbles and toasts have the same class, and a console launched with
    redirected output is what `MainWindowHandle` returns.
37. **A views layout that a capture cannot explain is answered by a dump, not
    a theory.** Three readings of the toolbar's flex rules did not predict the
    field landing on the back button; one `VLOG` of every child's bounds after
    `Layout` did in a minute (the layout had dropped the centring spacers and
    the clamp read their empty bounds). Chromium's own `--enable-ui-devtools`
    listens but its `DOM.getDocument` never answered this build. Add the dump,
    rebuild the one file, read the log, remove it before the patch is cut.
38. **On Windows, Chromium reads Google Chrome's registry key for extensions
    whatever the branding** (`Software\Google\Chrome\Extensions`, machine
    and user, `ExternalRegistryLoader`), and installs what it finds from
    Google's update server. On a PC with Chrome and Adobe Acrobat that is an
    "Action required" chip on a fresh profile's first launch. Stedding does
    not create that provider (privacy Q9); any other Chrome-keyed lookup a
    port meets deserves the same question.

## Open items

`BACKLOG.md` is the list; do not keep one here. First up: the operator's look
at beta 4 (`docs/ARC-ROUND2.md` gets a round 8 table when it comes), `S-48`
(the Arc data import run once on a real Arc profile) and `S-17` (signing, when
Apple answers).

## Release channel

Pre-releases on GitHub Releases, unsigned, with the Gatekeeper right-click
instructions in the notes and the sha256 beside the DMG. The order, all from the
repo root with a clean tree: bump `VERSION`, `tooling/dev build release chrome`
(the About line is a build flag), `tooling/verify-build --app
.../out/release/Stedding.app`, empty `dist/`, `tooling/package-dmg release`
(`dist/Stedding-<VERSION>-arm64.dmg` and its `.sha256`), paste the checksum into
`docs/release-notes/v<ver>.md`, commit, **push**, `tooling/publish-release --check`,
then `tooling/publish-release`. Beta 4 went out this way on 2026-09-05.

The push moved ahead of the publish on purpose. `gh release create` cuts the tag on
the remote, so publishing from an unpushed commit tagged whatever the remote's default
branch happened to be; `publish-release` now pins the tag to this commit with
`--target` and refuses to run until the commit is on the remote, which is why the push
comes first and `git push --tags` afterwards is no longer part of the dance.

"Empty `dist/`" is still worth doing, but it is no longer the thing standing between a
release and the wrong image. `package-dmg` names the image for the product version
rather than Chromium's — two Stedding releases on one pin used to produce one filename
— and warns about anything else left in `dist/`; `publish-release` takes the image
named for this VERSION, accepts a lone unnamed one, refuses to choose between two, and
recomputes the sha256 against both the file beside it and the number in the release
notes.
