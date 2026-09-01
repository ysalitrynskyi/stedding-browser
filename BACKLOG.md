# Backlog

The one list. Other documents cite ids from here; they do not keep lists of their own.
Ids are stable: never renumber, never reuse. Close an item by moving it to the Done
table with the commit or patch that closed it.

Priority order within Open is the order to pick work up. Feature behaviour ids (`B<n>`)
refer to `docs/features/<feature>.md`.

## Open

| Id | Item | Feature / spec | Notes |
|---|---|---|---|
| S-3 | Live restart check for Spaces and folders through a real ⌘Q | spaces B9, folders | harness must quit via the menu (HANDOFF trap 4) |
| S-19 | Live drag harness in tooling: launch, activate, synthetic drag, capture (the scratch script that verified S-2) | tooling | `tooling/dev drag` wrapping `capture-window.py` + Quartz events; needs the window key, so never on a machine someone is using |
| S-20 | Folder drop highlight: capture mid-drag to verify the header tint | folders F7 | needs S-19 |
| S-4 | Folder variant in the tab-strip mojom (FOLDER maps to the plain container today) | folders | patch 0042 note |
| S-5 | New Tab row under the Clear line, above unpinned | ui-spec | Arc order |
| S-6 | Session-compaction audit for per-tab extra data | spaces, folders | ADR 0015 carries the reasoning |
| S-7 | Command bar: choosing a tab in another Space switches and activates it (test) | spaces B13 | behaviour exists, untested |
| S-8 | Popup and app windows have no switcher (test) | spaces B14 | |
| S-9 | Operator retest: fullscreen URL width | ARC-ROUND2 #1 | needs next DMG |
| S-10 | Operator retest: pill site icon | ARC-ROUND2 #4 | needs next DMG |
| S-11 | Squash the patch series into per-feature patches | patches | rule in `docs/AGENT-LOOP.md` step 7; 0044 folds into the Spaces patch when this happens |
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
| S-2 | Drag a tab onto a folder header to move it in | patch 0045, `folder_drag_target_unittest.cc` (folders F7–F9), verified live by synthetic drag |
| S-1 | Spaces core semantics: membership on insert, active tab follows the switch, empty Space opens a tab, delete moves tabs | patch 0044, `space_model_window_unittest.cc` (spaces B1–B8) |
