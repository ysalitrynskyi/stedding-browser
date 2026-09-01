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

```bash
# edit code in /Users/Shared/chromium/src (on stedding-work)
tooling/build-chromium release        # incremental, ~40s-14min
tooling/capture-ui --out /tmp/x.png --size 1400x880 \
  --features 'SteddingArcStyleWindow:extra_spaces/2/pin_tabs/1'
# look at the capture. measure pixels, don't eyeball.
autoninja -C out/release unit_tests   # when model code changed
./out/release/unit_tests --gtest_filter='SpaceModelTest.*:SpaceDragTargetTest.*:FolderSessionTest.*:TabStripModelTest.AddToNewFolder*'
# commit in the checkout with Why:/Removable when: footers, then:
tooling/update-patches && tooling/check-repo
# commit + push this repo
```

23 tests currently green. `tooling/verify-build --app .../Stedding.app` checks
rendering, codecs (H.264 decodes real frames), and navigation.

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
   focus; CLICKS need the window key. Never drive the user's real pointer.
   `tooling/capture-window.py` captures one window by id — never the screen.
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

## Open items, in priority order

1. **Drag a tab into a folder** — folders are menu-driven; `TabDragTarget` is
   the seam (see `SpaceDragTarget` for the pattern and its tests).
2. **Live folder/Space restore check via a real ⌘Q** (mechanism unit-tested;
   see trap 4). Also operator retests: fullscreen URL width, pill site icon
   (`docs/ARC-ROUND2.md` items 1 and 4).
3. **Folder variant in the tab-strip mojom** — FOLDER currently maps to the
   plain-container variant (patch 0042 note).
4. **New Tab row position** — Arc puts it under the Clear line, above unpinned.
5. **Space switching + full session-compaction audit** (ADR 0015 carries the
   reasoning; per-tab extra data is the channel).
6. **Performance baselines from `out/official`** (M1 leftover), then the M1
   network audit.
7. **Peek, settings surface, import** — `docs/ROADMAP.md` M4–M6.
8. **Signing + notarisation + updater** — M7; the help page points at GitHub
   Releases until then.

## Release channel

Pre-releases on GitHub Releases, unsigned, with the Gatekeeper right-click
instructions in the notes and the sha256 beside the DMG.
`tooling/package-dmg release` builds `dist/Stedding-<ver>-arm64.dmg`.
