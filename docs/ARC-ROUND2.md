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


## Round 4 — visual audit (2026-09-02)

A pass over every surface by capture on the release build, dark mode first.

| Item | State |
|---|---|
| Hovered / selected tab rows turned Material blue | **Fixed** (patch 0007) — hover and select tint with the row's own text colour at a low alpha; measured (50, 52, 71) on the navy ground instead of (29, 73, 116) |
| Command bar: saturated blue chosen row, tiny type, fixed near-black panel | **Fixed** (patch 0005) — theme dialog colours, text-tinted highlight, +3 pt type, 44 px rows |
| Space menu: bare emoji rows, colour names without swatches | **Fixed** (patch 0004) — "🏠 Home" style labels, a circle swatch beside each colour; the first attempt used a generator-backed icon and crashed Cocoa's menu controller, so the swatch is a plain image |
| Tab-strip background menu offered "Show Tabs Horizontally" and Google's feedback link | **Fixed** (patch 0001) — both gone in Stedding mode; Collapse and auto-expand stay |
| Light mode: settings header and About page showed Chromium's own small logo (the 1x/2x scaled assets live in `default_{100,200}_percent/chromium/`, outside the directory branding covered) | **Fixed** (branding) — the mark rasterised at 16/32 px for 1x and 2x, plus a "Stedding" wordmark for the payment sheet; verified in light |
| Light mode audit: tab rows, hover tint, command bar, Space menu, settings, peek | All hold in light; captures 2026-09-02 |
| Fullscreen: nav buttons sit over the sidebar column instead of over the content | **Fixed** (patch 0002) — in immersive fullscreen the layout starts the overlay's toolbar where the strip ends; captured in real fullscreen (⌃⌘F): nav buttons right of the sidebar, omnibox centred over the content |
| Space tint lands on the page (the new tab page goes plum) rather than on the sidebar as Arc does | **Fixed** (patch 0007) — the active Space's colour blends into the window ground; the new tab page keeps a neutral ground; verified with two Spaces in dark and light |
| Light mode: hairline between toolbar and the content card | **Fixed** (patch 0007) — separator takes the toolbar colour |


## Round 4 sign-off (2026-09-02, release build, captures via `tooling/drive`)

Every surface looked at in both modes; "holds" means no defect found against
`docs/UI-SPEC.md` and the Arc reference at 2× zoom.

| Surface | Dark | Light | Verdict |
|---|---|---|---|
| Window ground, sidebar, mat, content card corners | captured | captured | holds; probes 14/14 |
| Tab rows: active, inactive, hover, selected, favicon, close glyph | captured | captured | holds after the neutral hover/select tint |
| "+ New Tab" row, essentials grid, Clear line | captured | captured | holds |
| Tab context menu, strip background menu | captured | captured | holds; no horizontal-tabs or feedback items |
| Space switcher: chips, hover name pill, context menu (icons, swatches) | captured | captured | holds; menu no longer crashes |
| Space tint (two Spaces) on the ground; new tab page neutral | captured | captured | holds |
| Command bar: panel, field, rows, chosen row | captured | captured | holds |
| New tab page: hint line, shortcuts, neutral ground | captured | captured (earlier in the day) | holds |
| Peek: card, header, buttons, scrim | captured | captured | holds |
| chrome://settings: Stedding section, landing page, header logo, About | captured | captured | holds; logo branded in both modes |
| Fullscreen: toolbar placement, omnibox cap, pill icon | captured | — | holds after patch 0002's overlay inset |
| Toolbar/content hairline | — | captured | gone |

Not changed on purpose: the light-mode sand (`#C8B377`) is the operator's
colour choice (round 3); a softer sand is a one-constant change in patch 0007
if ever wanted.
