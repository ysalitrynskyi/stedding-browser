# Round 2 — operator feedback from the first DMG (2026-09-01)

Nine defects from real use, windowed and fullscreen, compared against Arc
fullscreen. Each gets fixed and verified by capture; this file tracks status.

| # | Defect | Plan | Status |
|---|---|---|---|
| 1 | Fullscreen: URL bar full width again | Could not reproduce: the cap holds in --start-fullscreen (289 pt) and through a real ⌘L focus cycle (465 pt, centred). What the screenshots show is consistent with the 460 cap filling a modest window; the cap is now 380 (patch 0002). Retested 2026-09-02 in real fullscreen by capture: holds, centred, focused and not | done |
| 2 | Space switcher broken | **Fixed** — 28 DIP chips spread across the full width, + at the end; hover floats the Space's name in a pill above the chip with no layout shift, verified by synthetic hover (patch 0004) | done |
| 3 | Tab favicons repeat | **Fixed** — DrawImageInt tiled a 16 px bitmap into the 18 px slot (SkTileMode::kRepeat on src/dest mismatch); source rect is now the image's own size, verified crisp at zoom (patch 0002) | done |
| 4 | Site icon clipped in pill | Not reproducible after the tiling fix; pill renders clean at zoom. Retested 2026-09-02 in real fullscreen by capture: clean | done |
| 5 | One rounded corner looks odd | **Fixed** — the card floats on a mat with all four corners rounded, via MultiContentsView's own layout so the web layer stays in step; orphaned floating corners silenced (patch 0002) | done |
| 6 | Help page error code 0 | **Fixed** — Stedding mac updater stub reports a plain disabled state; Keystone was never shipped (patch 0006) | done |
| 7 | Folders | **Deferred to its own milestone, with the map drawn.** Research confirmed nothing constructs a FOLDER today, and true nesting means threading a folder id through TabStripCollection::MoveTabsRecursive/GetMovePosition the way TabGroupId is — invariant-heavy model surgery that should not ride a ten-fix batch. The group-creation pipeline to mirror is recorded in the research; groups remain the interim container | planned |
| 8 | Clear line position | **Fixed** — Clear lives on TabStripView's pinned/unpinned separator, which now shows whenever both exist (patch 0004) | done |
| 9 | Pin tiers | **Fixed** — Chromium pin = essentials (grid, global); new per-Space pin in SpaceModel, persisted and restored, Clear skips it, tab context menu carries Pin/Unpin to This Space (patch 0004) | done |

Method: grok researches seams read-only; implementation and every visual check
here. No fix is done until a capture shows it.


## Round 3 — folders and colours (operator request, 2026-09-01)

| Item | State |
|---|---|
| Colours | **Done** (patch 0007) — light #C8B377; dark a #21263A→#31243A top-left→bottom-right gradient painted once by `SteddingWindowBackground` on BrowserView, with sidebar, top container and mat invisible over it so it reads as one surface. Both modes verified by pixel probe and capture |
| Folders: create | **Done** (patch 0008) — tab context menu → Move Tab to New Folder; `TabStripModel::AddToNewFolder` wraps `MoveTabsToNewFolderRecursive`, which attaches through the same primitive as detached groups |
| Folders: nest | **Done** — a folder made from a tab already in a folder nests inside it; verified by capture (outer folder holding a tab + a nested folder holding its own tab) and by the model unit test |
| Folders: header/collapse/rename | **Done** — chevron+name header one tab-row tall, click collapses (hidden from Ctrl+Tab via the IsTabHidden contract, nested included), double-click renames in place |
| Folders: persistence | **Built, unit-verified** — per-tab folder ancestry in session extra data, rebuilt after restore through the same AddToNewFolder path; `FolderSessionTest.RebuildsNestedFoldersFromParkedPaths` covers the nested round trip. A live restart check is pending a real menu-quit: SIGTERM from this harness does not reliably flush Chromium's session files, which is a harness limit, not a product path |
| Folders: drag-into | Not built — moving into folders is menu-driven this round; drag targets on folder rows are the natural follow-up |

Known interim: the tab-strip mojo API maps FOLDER to its plain-container
variant until the mojom grows a Folder type (recorded in patch 0008).
