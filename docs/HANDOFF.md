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
   captures one window by id — never the screen. `S-19` turns this into a tool.
4. **SIGTERM does not reliably flush Chromium session files** from a raw binary
   launch — live restore tests via kill are meaningless; use unit tests or a
   real menu quit.
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

## Open items

`BACKLOG.md` is the list; do not keep one here. First up: cut a DMG for the
operator retests (`S-9`, `S-10`).

## Release channel

Pre-releases on GitHub Releases, unsigned, with the Gatekeeper right-click
instructions in the notes and the sha256 beside the DMG.
`tooling/package-dmg release` builds `dist/Stedding-<ver>-arm64.dmg`.
