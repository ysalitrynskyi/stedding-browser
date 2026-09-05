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


## Round 5 — operator feedback on beta 1 (2026-09-03)

Sixteen items from real use, against Arc side by side. Each is fixed and verified by
capture or test before it is marked done; the release that carries them is
`v0.2.0-beta.1` (`docs/release-notes/`).

| # | Item | Status |
|---|---|---|
| 1 | First-run screen: a Stedding welcome flow (search engine, import, appearance, default browser, shortcuts) | **Fixed** (patch 0015) — `chrome://stedding-welcome` in a child window over a profile's first window; five steps with Skip and Back; verified live 2026-09-03: engines listed outside the chooser regions too, Light applied at once, Skip records the flow, Quit works with it open, no return on relaunch. `--stedding-welcome` forces it, `--no-first-run` suppresses it |
| 2 | ⌘T treated random text as a URL | **Fixed** (patch 0013) — the omnibox classifier decides; verified live: "dfsfsfsdfdsfcvv3233" searches DuckDuckGo |
| 3 | ⌘S toggles the sidebar; Save Page moves to ⇧⌘S | **Fixed** (patch 0013) — verified live |
| 4 | Tab hover/selected/active highlights | **Fixed** (patch 0013) — every state a tint of the row's text colour; active a translucent pill in dark, white card in light; favicon column widened to the 18 px icon |
| 5 | Address row must sit on the page and take its colour | **Fixed** (patch 0013) — no gap above the content card, a bar in the page's theme colour painted by the window background when the page declares one that suits the colour scheme (github.com in dark), the ground otherwise (example.com); transparent omnibox; verified live 2026-09-03; see `docs/features/toolbar.md` |
| 6 | Space icons: no discs, centred emoji, like Arc | **Fixed** (patch 0013) — bare 16 px emoji, inactive at 50 %, even spacing |
| 7 | Pin to this Space showed nothing; Clear line missing | **Fixed** (patch 0013) — the pinned run sits under the Space title with the Clear line beneath it, then "+ New Tab", then the rest; verified live |
| 8 | Split view like Arc | **Verified** (Chromium 153 split view, no Stedding code) — a tab's context menu "Add Tab to New Split View" pairs it with the active tab, the panes take the card look, the sidebar shows the pair as one row; ⇧⌘O promotes a peek into a split (peek P9); checked live 2026-09-03 |
| 9 | Screenshots | **Fixed** (patch 0014) — ⇧⌘2 the visible page, ⌥⇧⌘2 a dragged region, ⇧⌘1 the full document; PNG to Downloads and the clipboard; verified live 2026-09-03 (2064×1678, a 600×400 crop, 2064×7712 for the Wikipedia main page). ⇧⌘3–6 are macOS's own screenshot keys and never reach an application, hence the other two keys; `docs/features/screenshot.md` |
| 10 | Fullscreen: sidebar toggle below the address row | **Partly** (patch 0013) — the strip's top row is now as compact as windowed; the 33 DIP above it is the macOS immersive overlay, outside the window's content view (`docs/features/toolbar.md` T6) |
| 11 | General design drift from Arc | addressed by 4–7, 12–16 |
| 12 | Downloads at the bottom-left | **Fixed** (patch 0013) — a downloads button at the left of the Space row (icon and tooltip from `kActionShowDownloads`, a press runs the toolbar controller's `InvokeUI`, so the bubble opens above the button; the anchor is resolved lazily because the sidebar is built before the download controller exists); verified live 2026-09-03 |
| 13 | Space name above the tabs | **Fixed** (patch 0013) — icon + name row above the pinned tabs once there are two Spaces; click opens the Space menu |
| 14 | One pinned essential took half the row | **Fixed** (patch 0013) — a lone card spans the row, two share it |
| 15 | Sidebar edge cannot be dragged | **Fixed** (patch 0013) — 12 DIP handle at the strip's right edge; verified live by dragging to 260 |
| 16 | Swipe on the sidebar switches Spaces | **Fixed** (patch 0013) — two-finger horizontal swipe, no wrap; `SpaceModelTest.SwitchToNeighbour*` |

## Round 5 audit (2026-09-04, release build, every surface in dark and light)

Captured through `tooling/drive` on a profile with an essential, a Space-pinned tab,
two Spaces, a folder, a split, and a peek: the window, the command bar (empty and
typed), the tab and Space context menus, a chip hover, a tab hover with its card,
peek, the collapsed sidebar, the app menu, a narrowed sidebar, the settings and
About pages, and macOS fullscreen. Then the same in light.

Passed as they are: everything above except the four below.

| Found | Fix |
|---|---|
| The Space name pill drew at the top of the sidebar on chip hover: the switcher now sits in the bottom row, and the pill was placed with row-relative bounds. | Converted into the sidebar's coordinates first (patch 0013). |
| An essential's hover card opened below the card, over the Space title and the first rows (Chromium's placement for pinned tabs). | Every vertical tab's card opens beside the sidebar (patch 0013, `TabView::GetAnchorPosition`). |
| Welcome step 5 and the settings hint named ⇧⌘L, which is bound to nothing. | ⌘S is the collapse key; the step lists ⌥⌘N (split) instead (patches 0013, 0015). |
| The About page says "Developer Build" after the Chromium version. | Open as `S-43`. |

Noted, not changed: with two Spaces the light ground blends the Space colour at 22%,
which turns sand olive under the default slate; the round-4 sign-off accepted it. A
Space-pinned tab that joins a split leaves the pinned run for the split's row.

## Beta 2 feedback (2026-09-04)

Three things from the operator's first look at beta 2, each fixed and captured:

| Found | Fix |
|---|---|
| "Everything in the address bar is broken or doesn't fit": the chrome:// chip ("Stedding") drew as a white box with the mark cut off. The 25 DIP location bar left the chip 15 DIP tall around a 16 DIP icon. | The chip's vertical padding is 2 (Chromium's 5), so it keeps 21 DIP (patch 0013, `layout_constants.cc`). |
| "Not changing colour like Arc": only pages with a `theme-color` coloured the row; chrome://settings, Wikipedia and most sites left it on the ground. | The page's own background is the fallback (`WebContents::GetBackgroundColor`), the way Safari tints its bar; the scheme-match rule stays (toolbar T3/T4). |
| "Spaces very weirdly centred at the bottom": the chips were spread evenly across the row. | Chips sit together in the middle with a fixed gap, "+" at the right, downloads at the left (spaces B11). |

## Round 7 — the operator's look at beta 3 (2026-09-05)

Six things from real use, and a crash found while capturing them. Each is fixed,
tested and captured without a hand on the machine: `tooling/capture-ui` with feature
params for the state, and an AppleEvent quit (the operator was at the keyboard, and a
synthetic key that missed the browser once landed in their chat — `docs/HANDOFF.md`,
trap 22).

| # | Found | Fix |
|---|---|---|
| 1 | The address row was a different colour from the page: even a plain white page got a grey row (the page colour was blended 85% over the ground). | The row is the page's colour exactly, with one hairline where it meets the page (toolbar T15: `PageBarColorSupplier`, `PaintPageBar`). |
| 2 | The page's top corners were rounded under the row, showing the row's colour through them wherever a page's header is not its theme colour. | Square top corners on the content whenever the row shows; the row keeps the card's rounded top (toolbar T16). |
| 3 | The address text sat off-centre and the star was nearly invisible. | The star and the row's page actions take the bar's contrast colour (T17); the location bar sizes to its content and sits on the row's centre, so chip, address and star read as one centred cluster (T18). |
| 4 | Collapsed, the rail's rows sat a little left of centre, the toggle sat too low, and the toggle could pass under the traffic lights. | Rows centred against the card's edge, gutter included (sidebar Y6); the toggle clears the traffic lights by their own height and never crosses the caption row, expand-on-hover's exit included (Y7). |
| 5 | Folders did not look like Arc's. | Folder glyph (closed / open), semibold title, the rows' hover tint (folders F12); a drifted pin shows Arc's slash between favicon and title (pins H12). |
| 6 | Moving from Arc should be one click. | The welcome flow's Arc block moves Spaces, pins, folders, tabs, history and passwords with one button; the settings row and the ⌘T action move everything too (import I6, I21–I23, patch 0038). |
| — | Quitting with a folder in the sidebar aborted (`bad_variant_access`): the page-colour re-theme ran inside the tab strip's close-all notification and reached a folder header whose folder was already gone. | The re-theme is posted after the change and skipped while the window empties; the header gives no folder for a node that is not one (folders F12). |
