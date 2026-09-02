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
| S-21 | De-Google the new tab page and omnibox: Google NTP with AI Mode, "Ask Google" placeholder, "Press tab then enter to ask AI" | PRIVACY, degoogle | a Stedding NTP (blank or minimal) and no AI Mode entry point |
| S-22 | Essentials as a grid of ~150×50 cards, not one full-width tile per pinned tab | ui-spec | |
| S-23 | Sidebar top row still Chromium's: collapse button, tab-group and tab-search combo buttons | ui-spec "Known gaps" | Arc has none of these |
| S-24 | Default Space chips are plain circles; a new Space should get a default glyph or its initial | spaces B11 | |
| S-25 | Command bar: no "open what you typed" row when nothing matches; the list is empty until Enter | commandbar | show the typed text as the first row |
| S-4 | Folder variant in the tab-strip mojom (FOLDER maps to the plain container today) | folders | patch 0008 note |
| S-5 | New Tab row under the Clear line, above unpinned | ui-spec | Arc order |
| S-7 | Command bar: choosing a tab in another Space switches and activates it (test) | spaces B13 | behaviour exists, untested |
| S-8 | Popup and app windows have no switcher (test) | spaces B14 | |
| S-9 | Operator retest: fullscreen URL width | ARC-ROUND2 #1 | needs next DMG |
| S-10 | Operator retest: pill site icon | ARC-ROUND2 #4 | needs next DMG |
| S-12 | `capture-ui --assert`: pixel probes from a JSON spec, golden diff | tooling | replaces eyeballing |
| S-13 | Performance baselines from `out/official` | QUALITY | then the M1 network audit |
| S-14 | Peek | ROADMAP M4 | |
| S-15 | Settings surface | ROADMAP M5 | |
| S-16 | Import from Chrome / Arc | ROADMAP M6 | |
| S-17 | Signing, notarisation, updater | ROADMAP M7 | help page points at GitHub Releases until then |
| S-18 | Proprietary-codecs licensing decision | decisions/0008 | needs a human |

## Done

| Id | Item | Closed by |
|---|---|---|
| S-3 | Live restart check for Spaces and folders through a real quit | `tooling/drive` scenario: quit via AppleEvent, three relaunches, list intact (spaces B9) |
| S-6 | Session-compaction audit | Found the bug: the rebuild dropped every Stedding extra-data command; fixed by the rebuild provider registry plus writing the Space list on the first insert (`SessionRebuildTest.*`, `FolderSessionTest.RebuildReemitsFolderPaths`) |
| S-19 | Live drag/click/key harness as a tool | `tooling/drive` + `tooling/drive-window.py` |
| S-11 | Squash the patch series into per-feature patches | 45 chronological patches → 8 feature patches (tabs, ui, sign-in, spaces, commandbar, updater, colours, folders); final tree byte-identical; old branch kept as `stedding-work-pre-squash` |
| S-2 | Drag a tab onto a folder header to move it in | patch 0008, `folder_drag_target_unittest.cc` (folders F7–F9), verified live by synthetic drag |
| S-1 | Spaces core semantics: membership on insert, active tab follows the switch, empty Space opens a tab, delete moves tabs | patch 0004, `space_model_window_unittest.cc` (spaces B1–B8) |
