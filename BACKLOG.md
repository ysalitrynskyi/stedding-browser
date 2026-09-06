# Backlog

The one list. Other documents cite ids from here; they do not keep lists of their own.
Ids are stable: never renumber, never reuse. Close an item by moving it to the Done
table with the commit or patch that closed it.

Priority order within Open is the order to pick work up. Feature behaviour ids (`B<n>`)
refer to `docs/features/<feature>.md`.

## Open

| Id | Item | Feature / spec | Notes |
|---|---|---|---|
| S-45 | Google's new tab page when Google is the chosen engine | `docs/features/new-tab.md`; S-21 | Choosing Google on the welcome flow (or in settings) switches chrome://newtab to Chromium's first-party page (Google logo, Gmail/Images links, OneGoogleBar requests), not the local third-party page S-21 promised for every provider. Seen 2026-09-05 on the welcome flow's swatch check. Pin the local page whatever the provider (`search::` NTP selection), keep the hint line and the shortcut row |
| S-47 | An input-free settings probe | `tooling/probes/settings.json` | The spec's capture is a typed URL (`tooling/drive`), so it cannot run while someone is at the machine; `chrome://settings/stedding` on the command line opens a new tab instead. Find the input-free way (a switch, or the little-window path) and record the capture line |
| S-48 | Arc data import on a real profile | `docs/features/import.md` I22, I23 | The history and password import is unit-tested on synthetic files; it has not run against a real Arc profile (the keychain prompt, a real Login Data). Operator: a fresh profile, the welcome flow's button, then chrome://history and chrome://password-manager |
| S-51 | Re-encrypt a legacy profile under Stedding's own keychain item | `docs/features/import.md` I25 | Patch 0038 names the keychain item for Stedding and falls back to the Chromium-named one so a beta-1 to beta-3 profile still decrypts, but nothing writes the key back under the new name. Those profiles depend on an item called "Chromium" indefinitely, share it with any real Chromium on the machine, and lose their saved passwords if it is deleted. On first run: read through the legacy item, write the same key under Stedding's name, keep reading either |
| S-52 | Take 153.0.8010.27 | `tooling/chromium-version`; ADR 0007 | The pin is 153.0.8010.12, which was Mac stable when it was taken on 2026-08-30. The line has since moved to .27, and Mac stable itself rolled back to 152.0.7977.x, so the point releases on M153 are reaching Windows and Linux and not us. `tooling/check-pin` reports it and the `upstream` workflow files the issue; `tooling/update-pin --apply` takes it. Timetable: `docs/QUALITY.md`. **The series was tested against 153.0.8010.27 on 2026-09-06 and applies: all 38 patches, four of them (0017, 0019, 0024, 0037) through a three-way merge, which is what `git am --3way` does anyway. Upstream changed 922 files between the two releases but only 8 of the 370 the series touches, all of them taking a new `//chrome/browser/dictation` dependency. So the rebase needs no patch surgery; what it still needs is a build, the suites and a capture pass on the Mac.** |
| S-49 | A builder that can actually build | `docs/ARCHITECTURE.md` "CI reality"; `.github/workflows/checks.yml` | GitHub-hosted runners cannot build Chromium, so every unit test, every capture and every release runs on one Mac and CI checks repository hygiene only. The ADR for a self-hosted or cloud macOS builder was called "due before M1" and M1 is long past; it is a money decision, so it needs the owner. Until it lands, nothing automated verifies the product |
| S-50 | The idle-network audit as a recorded run | ROADMAP M1; `docs/PRIVACY.md` | M1's network criterion is currently answered by reading the code and by the "what a fresh profile at rest actually contacts" list in `docs/PRIVACY.md`. Make it a run: a fresh profile, a capture of what it contacts in the first ten minutes, and the list checked against it, so the claim is evidence |
| S-17 | Signing, notarisation, updater | ROADMAP M7 | Pipeline verified end to end 2026-09-03: `tooling/sign-release release --development` signed and verified the app through Chromium's own signer with the Apple Development identity in this keychain (local use only; it carries a personal Apple ID). A public release needs a Developer ID Application certificate and a notarytool keychain profile: `export STEDDING_SIGN_IDENTITY=... STEDDING_NOTARY_ARGS=--keychain-profile=...` then `tooling/sign-release release`. The updater is decided (ADR 0014, GitHub Releases; stub in patch 0006) |

## Done

| Id | Item | Closed by |
|---|---|---|
| S-46 | Round 7: the operator's look at beta 3 | `docs/ARC-ROUND2.md` round 7 (2026-09-05): the row is the page's colour exactly, square under it, the star and the cluster centred (toolbar T15–T18); the collapsed rail centred and its toggle clear of the traffic lights (sidebar Y6–Y7); Arc's folder and drifted-pin rows (folders F12, pins H12); the folder quit crash (F12); Arc's history and passwords in one click (import I6, I21–I23, welcome W8). Patches 0037 (round 7 across features, as 0013 was for round 5) and 0038 (Arc's data) | Second pass the same evening (the operator's replies on the first fix): the field with no background, 560 DIP and shrinkable; the toggle on the traffic lights' centre; the folder glyph and the sidebar's columns; the keychain named for Stedding; and Chromium's own tab and vertical-strip tests brought in line with the fork. Shipped in `v0.2.0-beta.4`, which is published (2026-09-05): beta 4 is published, unsigned, with the DMG and its sha256 on GitHub Releases.
| S-42 | Space colour on the welcome flow | Patch 0018: the five Space swatches on the appearance step tint the first Space at once (`docs/features/welcome.md` W7) |
| S-41 | Download progress on the sidebar button | Patch 0021: the ring and the started animation on the bottom-left button (`docs/features/toolbar.md` T14, capture `w2_download_ring`) |
| S-44 | Round 6: Zen mods and beyond | Every wave landed, 2026-09-05: patches 0016–0036 (`docs/ROUND6-PLAN.md` carries the landing note per part; each spec its rows); the gaps each spec names stay as `gap` rows |
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
