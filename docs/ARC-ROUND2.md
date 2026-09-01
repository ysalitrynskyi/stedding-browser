# Round 2 — operator feedback from the first DMG (2026-09-01)

Nine defects from real use, windowed and fullscreen, compared against Arc
fullscreen. Each gets fixed and verified by capture; this file tracks status.

| # | Defect | Plan | Status |
|---|---|---|---|
| 1 | Fullscreen: URL bar full width again | Could not reproduce: the cap holds in --start-fullscreen (289 pt) and through a real ⌘L focus cycle (465 pt, centred). What the screenshots show is consistent with the 460 cap filling a modest window; the cap is now 380 (patch 0038). Re-check on the next DMG | needs retest |
| 2 | Space switcher broken | **Fixed** — 28 DIP chips spread across the full width with flexible spacers, + at the end; reserved name row removed (patch 0036) | done |
| 3 | Tab favicons repeat | **Fixed** — DrawImageInt tiled a 16 px bitmap into the 18 px slot (SkTileMode::kRepeat on src/dest mismatch); source rect is now the image's own size, verified crisp at zoom (patch 0033) | done |
| 4 | Site icon clipped in pill | Not reproducible after the tiling fix; pill renders clean at zoom. Re-check on the next DMG | needs retest |
| 5 | One rounded corner looks odd | **Fixed** — the card floats on a mat with all four corners rounded, via MultiContentsView's own layout so the web layer stays in step; orphaned floating corners silenced (patch 0034) | done |
| 6 | Help page error code 0 | **Fixed** — Stedding mac updater stub reports a plain disabled state; Keystone was never shipped (patch 0037) | done |
| 7 | Tab groups are Chromium bubbles; Arc has folders (nesting) | We already carry FOLDER collection + FolderView (patch 0002). Wire a creation UI and Arc-style folder rows; verify nesting | open |
| 8 | Clear line position | **Fixed** — Clear lives on TabStripView's pinned/unpinned separator, which now shows whenever both exist (patch 0035) | done |
| 9 | Our "pinned = above all Spaces" is Arc's *super*-pin (essentials). Regular pin is per-Space, above the Clear line | Two tiers: Chromium pin stays essentials (grid, global). New per-Space pin marker in SpaceModel, persisted; Clear skips them; tab context menu gets the toggle | open |

Method: grok researches seams read-only; implementation and every visual check
here. No fix is done until a capture shows it.
