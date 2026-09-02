# Backlog

The one list. Other documents cite ids from here; they do not keep lists of their own.
Ids are stable: never renumber, never reuse. Close an item by moving it to the Done
table with the commit or patch that closed it.

Priority order within Open is the order to pick work up. Feature behaviour ids (`B<n>`)
refer to `docs/features/<feature>.md`.

## Open

| Id | Item | Feature / spec | Notes |
|---|---|---|---|
| S-9 | Operator retest: fullscreen URL width | ARC-ROUND2 #1 | needs next DMG |
| S-10 | Operator retest: pill site icon | ARC-ROUND2 #4 | needs next DMG |
| S-17 | Signing, notarisation, updater | ROADMAP M7 | help page points at GitHub Releases until then |
| S-18 | Proprietary-codecs licensing decision | decisions/0008 | needs a human |
| S-31 | Vanilla Chromium `official` build at the pin, measured with the same harness, so the QUALITY.md overheads can be computed | QUALITY | ~4 h build; then the M1 network audit |
| S-36 | Sidebar and Spaces settings rows (settings T6) once those behaviours exist | settings | width, auto-archive, Space management |
| S-35 | Promote a peek into a split (peek P9) | peek, ROADMAP M5 | after split view exists |

## Done

| Id | Item | Closed by |
|---|---|---|
| S-8 | Popup windows have no Spaces: unit test | `PopupSpaceTest.PopupWindowsHaveNoSpaces` (spaces B14). The SEGV was the test constructing a second Browser by hand; the fixture's typed constructor (`BrowserWithTestWindowTest(Browser::TYPE_POPUP)`, as `TestWithBrowserView` does for hosted apps) builds a popup cleanly |
| S-34 | Peek for links that open a new tab from a pinned tab | One check at the top of `chrome::Navigate()`; `PeekNewTabTest.*` (peek P8, patch 0009) |
| S-15 | Settings surface | chrome://settings/stedding, first in the menu, three toggles backed by `stedding_prefs.h`; `docs/features/settings.md` (patch 0010) |
| S-33 | New tab page: a setting to hide the shortcut row | The "Stedding" settings section's third toggle (new-tab N5) |
| S-14 | Peek | Links leaving a pinned tab's site open over the window; Escape/click dismiss, ⌘O promotes the same page into a tab. `docs/features/peek.md`, `PeekNavigationThrottle` + `PeekView` (patch 0009) |
| S-28 | A Stedding new tab page | The local page carries a "Press ⌘T…" hint, no Chrome Web Store tile, theme ground; `docs/features/new-tab.md`, `tooling/probes/ntp.json` (patch 0003) |
| S-32 | Branding leftovers in chrome://settings | "About Stedding" (branding now rewrites `settings_chromium_strings.grdp`); the Stedding mark replaces Chromium's glyph in the omnibox chip, app menu and WebUI (`branding/vector_icons`, one hunk in `cr_elements/icons.html.ts`); helper processes were already "Stedding Helper" |
| S-4 | Folder variant in the tab-strip mojom | `Folder {id, title, is_collapsed}` in the data model union; converter and utilities handle it; folder window verified live (patch 0008) |
| S-29 | De-Google chrome://settings | "You and Google" and "AI in Chrome" hidden; landing route falls through to Autofill (patch 0003) |
| S-30 | Import entry in the app menu | Already present: app menu → Bookmarks and lists → Import Bookmarks and Settings |
| S-13 | Performance baselines from `out/official` | `docs/perf/2026-09-02-official.json` + `docs/perf/README.md`: cold 0.63 s, warm 0.77 s, 5.7 GB / ~107 processes for the ten-site list. Overheads need the vanilla half (`S-31`) |
| S-20 | Folder drop highlight | `tooling/drive` `dragstart`/`dragmove`/`shot`/`dragend`: the hovered header paints its rounded highlight mid-drag; drop lands the tab inside |
| S-16 | Import from Chrome / Arc / Firefox | Chromium's importer works as-is: chrome://settings/importData lists installed browsers (Firefox seen) and imports history, bookmarks, autofill. No Stedding code needed; a menu entry is `S-30` |
| S-27 | Sidebar collapse button | Keep: it is Arc's sidebar toggle in the same corner; only the tab-group/tab-search combo was foreign |
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
