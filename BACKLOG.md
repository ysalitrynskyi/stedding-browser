# Backlog

The one list. Other documents cite ids from here; they do not keep lists of their own.
Ids are stable: never renumber, never reuse. Close an item by moving it to the Done
table with the commit or patch that closed it.

Priority order within Open is the order to pick work up. Feature behaviour ids (`B<n>`)
refer to `docs/features/<feature>.md`.

## Open

| Id | Item | Feature / spec | Notes |
|---|---|---|---|
| S-44 | Round 6: Zen mods and beyond | `docs/ROUND6-PLAN.md` | The plan from the 2026-09-04 review of the 77 Zen Browser community mods (zen-browser.app/mods) plus ideas beyond them: four waves, R6-01 onwards, each with spec rows, setting, shortcut, files; decisions D1–D11 recorded there. Wave 1 (R6-01–R6-10, plus toolbar T7 and the 6 DIP card gutter) landed as patches 0016–0018 on 2026-09-05; wave 2's model work (R6-13 to R6-18, R6-20, R6-21 in part) landed as patches 0019–0021 the same night and R6-11 (the command bar's actions mode) as 0022 and R6-12 (⌃⇥) as 0023 and R6-14 (the menus) as 0024 and the last rows as 0025 (wave 2 complete); wave 3 opened with R6-22, Import from Arc, as 0026, R6-23, routing, as 0027 R6-24, the archived view, as 0028 R6-25, the address row, as 0029 R6-26, the Privacy block, as 0030 R6-27, sidebar density, as 0031, R6-28, bookmarks to pins, as 0032 and R6-29, sidebar backups, as 0033 (wave 3 complete); wave 4 follows per `docs/AGENT-LOOP.md` |
| S-41 | Download progress on the sidebar button | `docs/features/toolbar.md` (downloads, round 5 item 12) | Patch 0021 points the ring and the started animation at the sidebar button (`toolbar.md` T14, built: the capture `w2_download_ring` shows the ring on the sidebar button, patch 0025 docs). Before: the bottom-left button showed the static icon; Chromium's progress ring and the "download started" animation still target the toolbar button, which appears at the top right during a download |
| S-42 | Space colour on the welcome flow | `docs/features/welcome.md` W7 | A colour picker on the appearance step that tints the first Space |
| S-45 | Google's new tab page when Google is the chosen engine | `docs/features/new-tab.md`; S-21 | Choosing Google on the welcome flow (or in settings) switches chrome://newtab to Chromium's first-party page (Google logo, Gmail/Images links, OneGoogleBar requests), not the local third-party page S-21 promised for every provider. Seen 2026-09-05 on the welcome flow's swatch check. Pin the local page whatever the provider (`search::` NTP selection), keep the hint line and the shortcut row |
| S-17 | Signing, notarisation, updater | ROADMAP M7 | Pipeline verified end to end 2026-09-03: `tooling/sign-release release --development` signed and verified the app through Chromium's own signer with the Apple Development identity in this keychain (local use only; it carries a personal Apple ID). A public release needs a Developer ID Application certificate and a notarytool keychain profile: `export STEDDING_SIGN_IDENTITY=... STEDDING_NOTARY_ARGS=--keychain-profile=...` then `tooling/sign-release release`. The updater is decided (ADR 0014, GitHub Releases; stub in patch 0006) |

## Done

| Id | Item | Closed by |
|---|---|---|
| S-43 | About page version label | chrome://settings/help reads "Stedding <VERSION> · Chromium <pin> (arm64)" through `stedding::AboutVersionString` and a `stedding_version` GN argument `tooling/build-chromium` writes from `VERSION` (patch 0018); settings T10, verified live 2026-09-05 |
| S-40 | Capture toast | `ToastId::kSteddingCaptureSaved` on Chromium's toast framework, "Copied · Saved to Downloads" with Show in Finder, dialog colours (patch 0017); screenshot C5–C6, verified live 2026-09-05 |
| S-38 | Fullscreen toolbar over the sidebar | `SteddingBrowserViewLayout::CalculateTopContainerLayout` insets the overlay's toolbar by the strip width while immersive fullscreen is on (patch 0002); ARC-ROUND2 round 4 |
| S-18 | Proprietary-codecs licensing decision | Decided 2026-08-31 (ADR 0008, Accepted): ship H.264/AAC in every configuration; the licence itself is a 1.0 release-checklist item (`docs/QUALITY.md`), not a code gap |
| S-36 | Sidebar and Spaces settings rows | Sidebar hover (T6), width slider applied live (T7), auto-archive threshold (T8, patch 0011), Spaces list with rename and delete (T9, patch 0012); the rest in patch 0010, the archiver in 0011 |
| S-37 | Perf budgets on the first vanilla pair | Noise, not the series: on the deterministic local list the pair reads cold +2.3%, warm −2.0%, memory +0.0% (`docs/perf/README.md`); the live list's swings were third-party frames. Re-measure the next official build the same way before a release |
| S-39 | Space tint on the sidebar ground, neutral new tab page | Blend in `stedding_color_mixer` and `SteddingWindowBackground` (patch 0007); spaces B11 |
| S-9 | Operator retest: fullscreen URL width | Retested by capture on the 2026-09-02 release build in real fullscreen (⌃⌘F): the omnibox stays at its cap, centred, unfocused and focused (ARC-ROUND2 #1) |
| S-10 | Operator retest: pill site icon | Same capture: the pill's site icon renders clean at 2× (ARC-ROUND2 #4) |
| S-31 | Vanilla `official` build at the pin, measured with the same harness (tree deleted 2026-09-02 for disk; rebuild with `tooling/dev build vanilla chrome --budget 60` from the detached pin) | `docs/perf/README.md` "The comparison": vanilla vs Stedding back to back, overheads against the QUALITY budgets. `tooling/args/vanilla.gn`; built under `--budget 60` |
| S-35 | Promote a peek into a split | ⇧⌘O and an "Open in Split" button hand the page to `chrome::AddWebContents` with `NEW_SPLIT_VIEW`; Chromium 153's split view pairs it with the source tab (peek P9, patch 0009) |
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
