# Backlog

The one list. Other documents cite ids from here; they do not keep lists of their own.
Ids are stable: never renumber, never reuse. Close an item by moving it to the Done
table with the commit or patch that closed it.

Priority order within Open is the order to pick work up. Feature behaviour ids (`B<n>`)
refer to `docs/features/<feature>.md`.

## Open

| Id | Item | Feature / spec | Notes |
|---|---|---|---|
| S-20 | Folder drop highlight: capture mid-drag to verify the header tint | folders F7 | `tooling/drive` with a shot between `drag` steps needs a mid-drag hook |
| S-4 | Folder variant in the tab-strip mojom (FOLDER maps to the plain container today) | folders | patch 0008 note |
| S-9 | Operator retest: fullscreen URL width | ARC-ROUND2 #1 | needs next DMG |
| S-10 | Operator retest: pill site icon | ARC-ROUND2 #4 | needs next DMG |
| S-13 | Performance baselines from `out/official` | QUALITY | then the M1 network audit |
| S-14 | Peek | ROADMAP M4 | |
| S-15 | Settings surface | ROADMAP M5 | |
| S-16 | Import from Chrome / Arc | ROADMAP M6 | |
| S-17 | Signing, notarisation, updater | ROADMAP M7 | help page points at GitHub Releases until then |
| S-8 | Popup windows have no Spaces: unit test | spaces B14 | `CreateBrowser(profile, TYPE_POPUP, ...)` in `BrowserWithTestWindowTest` SEGVs before the assertion, in a release build with no symbols; find out whether that is the fixture or us |
| S-18 | Proprietary-codecs licensing decision | decisions/0008 | needs a human |
| S-28 | A Stedding new tab page: blank or minimal, local, no Web Store tile | PRIVACY, ui-spec | replaces Chromium's third-party page |
| S-27 | Sidebar collapse button at the top-left: keep or drop to match the reference | ui-spec | the only Chromium control left in the sidebar's top row |

## Done

| Id | Item | Closed by |
|---|---|---|
| S-7 | Command bar across Spaces (test) | `CommandBarViewTest.*` (spaces B13) |
| S-26 | First-run search engine chooser | Chromium's own shuffled choice screen, built into the Chromium-branded build, worldwide, shown over the local new tab page even with a non-Google default (patch 0003). Verified live on a fresh profile |
| S-12 | `capture --assert` | `tooling/assert-capture` + `tooling/probes/window.json`, 14 probes; first run caught three square content corners (upstream's glass-mode radii made the "set if empty" guard never fire) |
| S-21 | De-Google the new tab page and omnibox | DuckDuckGo is the prepopulated default, and chrome://newtab is always Chromium's local third-party page -- a provider's own new-tab URL (DuckDuckGo's remote chrome_newtab) is never used (patch 0003). No "Ask Google", no AI Mode |
| S-22 | Essentials as a grid of cards | two cards per row at the sidebar width, a lone card stays card-sized (patch 0002) |
| S-23 | Sidebar top row: Chromium's tab-group/tab-search combo and the hairline under it are gone; the toolbar's profile avatar too (patch 0002) |
| S-24 | Default Space chip glyph | an un-iconed Space shows a glyph from the menu's list (patch 0004) |
| S-5 | New Tab row above the unpinned tabs, under the Clear line; the bottom "+" pill is gone. The row opens the command bar (patch 0002) |
| S-25 | Command bar shows the typed text as an "Open"/"Search" row (patch 0005) |
| S-3 | Live restart check for Spaces and folders through a real quit | `tooling/drive` scenario: quit via AppleEvent, three relaunches, list intact (spaces B9) |
| S-6 | Session-compaction audit | Found the bug: the rebuild dropped every Stedding extra-data command; fixed by the rebuild provider registry plus writing the Space list on the first insert (`SessionRebuildTest.*`, `FolderSessionTest.RebuildReemitsFolderPaths`) |
| S-19 | Live drag/click/key harness as a tool | `tooling/drive` + `tooling/drive-window.py` |
| S-11 | Squash the patch series into per-feature patches | 45 chronological patches → 8 feature patches (tabs, ui, sign-in, spaces, commandbar, updater, colours, folders); final tree byte-identical; old branch kept as `stedding-work-pre-squash` |
| S-2 | Drag a tab onto a folder header to move it in | patch 0008, `folder_drag_target_unittest.cc` (folders F7–F9), verified live by synthetic drag |
| S-1 | Spaces core semantics: membership on insert, active tab follows the switch, empty Space opens a tab, delete moves tabs | patch 0004, `space_model_window_unittest.cc` (spaces B1–B8) |
