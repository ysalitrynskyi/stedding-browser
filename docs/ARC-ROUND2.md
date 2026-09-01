# Round 2 — operator feedback from the first DMG (2026-09-01)

Nine defects from real use, windowed and fullscreen, compared against Arc
fullscreen. Each gets fixed and verified by capture; this file tracks status.

| # | Defect | Plan | Status |
|---|---|---|---|
| 1 | Fullscreen: URL bar full width again | Find why the flex cap dies in fullscreen (immersive top container?), fix in the same seam | open |
| 2 | Space switcher bottom-left broken: icons cramped, clipped, not spread across the sidebar like Arc | Redesign: icons spread evenly across full sidebar width, bigger targets, floating hover name (no reserved row) | open |
| 3 | Tab favicons "repeat themselves" | Reproduce zoomed; suspect double-paint from the 18 DIP favicon change in tab_icon.cc | open |
| 4 | Site icon in the URL pill clipped | 25 DIP bar squeezes the 16 DIP icon + insets; fix insets or bar height, verify at zoom | open |
| 5 | Only top-left contents corner rounded looks odd | Match Arc: float the content card — inset from sidebar/right/bottom, round all four corners | open |
| 6 | chrome://settings/help shows "error code 0" | No Keystone in an unsigned build; stub the Mac VersionUpdater: no error, say updates ship via GitHub Releases | open |
| 7 | Tab groups are Chromium bubbles; Arc has folders (nesting) | We already carry FOLDER collection + FolderView (patch 0002). Wire a creation UI and Arc-style folder rows; verify nesting | open |
| 8 | Clear line is at the top in Arc, separating pinned from unpinned — not above New Tab | Move the Clear row to the tabs_separator_ slot inside TabStripView (13 commits/yr) | open |
| 9 | Our "pinned = above all Spaces" is Arc's *super*-pin (essentials). Regular pin is per-Space, above the Clear line | Two tiers: Chromium pin stays essentials (grid, global). New per-Space pin marker in SpaceModel, persisted; Clear skips them; tab context menu gets the toggle | open |

Method: grok researches seams read-only; implementation and every visual check
here. No fix is done until a capture shows it.
