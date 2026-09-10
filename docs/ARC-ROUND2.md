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

## Round 9 — the operator's look at the Windows preview (2026-09-09)

Three minutes of clicking in the installed beta 5 on Windows, and the keyboard map it
did not have. Six findings from the operator, the rest from the pass that followed the
same night; every fix verified on captures the tooling took itself with no focus and
no input (trap 36), the keyboard map by the reference page it feeds and the unit tests
written for it (not yet run on a Windows runner, `S-49`). Patches 0043 (the keyboard
map and the shortcut reference on every platform), 0044 (the first start) and 0045
(the rail). Published as beta 6 from Windows.

| # | Found | Fix |
|---|---|---|
| 1 | No Stedding keys on Windows: Chromium's chords stood in (the notes said so). | Arc's Windows keyboard in the views accelerator table (windows N7, patch 0043): Ctrl+S the sidebar, Ctrl+D the pin, Ctrl+Shift+D the address row, Alt+1–9 the Spaces, Ctrl+Alt+←/→ between them and Ctrl+Alt+Shift+←/→ the tab across, Ctrl+Alt+↑/↓ the rows and Ctrl+Alt+Shift+↑/↓ their move, Ctrl+Shift+K Clear, Ctrl+Shift+C the link and Ctrl+Alt+Shift+C as Markdown, Ctrl+Shift+2 / Ctrl+Alt+Shift+2 / Ctrl+Shift+1 the screenshots, Ctrl+Shift+P the palette, Ctrl+Alt+Shift+N a Blank Window; Ctrl held shows the row numbers. Chromium refuses Ctrl+Alt in that table (AltGr), so the Ctrl+Alt rows go in past its check the way its debug map does (trap 42). The shortcut reference reads the platform's table and its block is on chrome://settings/stedding on Windows (shortcuts Z6); the settings sub-labels and the welcome flow say Ctrl where they said ⌘. |
| 2 | The first window opened on Google's search page, with a "Google API keys are missing. Some functionality of Stedding will be disabled" bar over it. | Google had been chosen on the welcome flow, and for Google alone Chromium's first-party page stood in for the local one (`S-45`, open since 2026-09-05): the local third-party page for every provider now (new-tab N1). The infobar is gone: the keys are for Google's services (welcome W9). Patch 0044. |
| 3 | Collapsed, the tabs were a little too close to each other. | The rail's rows sit 6 DIP apart, not the open sidebar's 2 (sidebar Y12, patch 0045). |
| 4 | Hovering a Space in the rail floated its name over the downloads button. | No floating name in the rail; the chip's tooltip names the Space (sidebar Y14). |
| 5 | Adding Spaces while collapsed pushed the "+" past the window's bottom; open and collapse again and it was fine. | The switcher's stack kept a fixed height that counted every chip full while the inactive ones were dots, and the row it sits in kept a height set by hand at construction and at each collapse. The stack measures itself, dots and all, and the row takes its height from its layout, with the switcher's flex (the open row's width) off in the rail -- left on, a BoxLayout hands the row everything under the Archived row (sidebar Y13, trap 43). |
| 6 | Collapsed, the Space's icon at the top had "…" after it. | The title row is its glyph alone in the rail, centred and a size up; the name comes back with the open sidebar (sidebar Y13). |
| 7 | Choosing a theme "as the browser suggests" changed nothing much, and a popup in it drew white text on a white ground ("You can find older colors in the Chrome Web Store"). | That was Chromium's Customize Chrome panel behind the "Theme" row of Settings › Appearance, whose colours barely reach a window the Space tints and whose promos point at the Web Store, one as a toast the panel styles itself. The row is hidden (settings T12); the plain toast ground takes the dialog colour in the mixer too. Patch 0044. |
| 8 | Found in the pass: the reference's ⇧⌘D row said "unbound" on the Mac, where ⇧⌘D shows the address row (toolbar T10). | The row names the address row on both platforms, from the table (shortcuts Z2). |
| 9 | Found in the pass: Chromium's tab-group chords (Alt+Shift+C/P/X/Z/W) were live on Windows while the group rows are hidden (menus M6). | Linux's alone now, as the Mac's were removed with the rows. |
| 10 | Found in the pass: the tab menu showed no chord beside Pin to This Space, Copy Link or Copy Link as Markdown -- on the Mac too -- while Close had its Ctrl+W. | The verbs map to the browser commands their keys are bound to (`ContextMenuCommandToBrowserCommand`), which is where the menu reads chords from (menus M1; patch 0043). |

## Round 8 — the first Windows build (2026-09-08)

The series built for Windows for the first time -- M8 in `docs/ROADMAP.md` had not
started -- on the operator's PC, with Visual Studio 2026 Build Tools and Windows SDK
10.0.28000 installed for it. Nine portability errors first, all one cause; then the
operator's look at the running window: five things, and two more found while
capturing them. Every fix was verified on captures the tooling took itself
(a `SendInput` driver with a foreground check, after a
launch where the browser stayed behind and the clicks landed in the operator's own
app), at 1400x880 with a device scale factor of 1 so the mac probes run on them
unchanged: 20 of `tooling/probes/window.json`'s 23 pass, the three others being state
or platform, and the card's edges, gutters and 12.00 DIP corner are the mac's to the
pixel. Patch 0039. The operator's reply the same afternoon -- the rail's pill
still narrow, no address bar in the rail -- and a startup crash found on the way
are rows 6 to 8, in the same patch; those captures were taken with no focus and
no input at all (`PrintWindow`, HANDOFF trap 36), with the operator at the
machine.

| # | Found | Fix |
|---|---|---|
| — | `base::FilePath::Append("Default")` and seven more did not compile: `FilePath` is `std::wstring` on Windows. | `FILE_PATH_LITERAL`, `FromUTF8Unsafe`, `AppendASCII`, `AsUTF8Unsafe` in the Arc importers, the sidebar backups and the screenshot file name. Nothing changes on the Mac (windows N1). |
| 1 | The window's own buttons are on the right on Windows, and the address row ran under them. | The row stops short of the frame's trailing exclusion, the card's exposed top-right corner rounds, and with the row hidden the empty top container keeps the caption strip's height -- from the rail the window could not be closed at all (toolbar T19, windows N2). |
| 2 | Clicking the address bar turned it dark. | Focused, the location bar borrows the results dropdown's background, which the page-bar supplier never set. The dropdown follows the page too, in the bar's contrast colour (toolbar T20). |
| 3 | Reloading a white page turned the row dark and left it so. | A new Page starts with no colour and the WebContents announces a background only when it differs from the last one it sent, so white reloading to white is never announced. The controller keeps its colour while the page loads and re-reads the Page at first paint and at load end (toolbar T21). |
| 4 | Collapsed, the icons were small and sat left in the column, and the Space switcher ran out of the rail and drew its "+" over the page. | The toggle, the New Tab and Archived rows centre in the rail a size up, the Archived row as its icon alone; the switcher stacks its chips in a column and the downloads button stacks above it -- all keyed on the width being drawn, not the collapse state, after a first cut centred the toggle in the hover overlay (sidebar Y8, Y9). The collapsed tab's own pill stays 25 DIP wide: `S-53`. |
| 5 | Hovering the rail expanded it, and the page showed through every row. | The strip's background, invisible so the window's gradient shows through (trap 8), is visible exactly while the strip is collapsed by state and drawn wider than the rail (sidebar Y10). |
| 6 | The rail's tab pill was still 26 DIP wide in the 62 DIP column, the "+" above it clipped to 10 DIP, the toggle 3.5 DIP right of the rows' centre. | The width a rail row gets is decided in the unpinned container's layout, not the strip's, which is why the first cut changed nothing. Every container's side padding is 3 DIP in the rail, keyed on the width being laid out, and `TabView::CollapsedWidth` says the same 44, so a rail row is a 44 DIP square around a 22 DIP favicon, centred in the rail plus the gutter; the "+ New Tab" row is its plus alone at that width, unclipped; the button containers sit on the same column, so the toggle centres with the rows (sidebar Y8; S-53 closed). |
| 7 | In the rail there was no address bar at all: the row hidden with the sidebar (T8) left an empty 35 DIP band under the caption buttons. | The rule keeps the row while the frame's own buttons sit over its column -- Windows' caption buttons, the trailing exclusion -- since the strip exists whatever the sidebar does; the toggle still wins (toolbar T22, `AddressRowRulesTest.KeptUnderTheCaptionButtons`). macOS is unchanged. |
| 8 | A profile killed while the sidebar was collapsed never opened again: `Check failed: element` in `AppMenuButton::GetAnchor` on every launch. | The crashed-session "Restore pages?" bubble anchors to the app menu button before the window is shown; with the row hidden the button is not drawn, and the fallback anchor is a tracked element the tracker does not know until the widget is visible. The button anchors such a bubble to the top container instead (toolbar T23, HANDOFF trap 35). Found on the round's own test profile, which the driver had killed; a Mac in the rail is the same path. |
| 9 | The row stopped short of the caption buttons and its end read as a cut corner beside them (the operator's second reply). | The bar runs on under the buttons to the card's edge -- the contents still stop short -- with the card's top-right corner rounded as on the Mac; the buttons paint their glyphs in the bar's contrast colour through the page-bar supplier, and the address field centres on the bar rather than on the contents' width (toolbar T19, T18). Looked at across scales 1, 1.25, 1.5 and 2, a narrow window and a maximised one (`w8_matrix`). |
| 10 | Found in that look: in a 900 DIP window with the sidebar open the address field sat over the back, forward and reload buttons. | Round 7's centring (toolbar T18) read the two spacers' bounds after the layout had dropped them -- hidden, at the origin -- for want of width, and clamped the field to x 0; with the reserve for the caption buttons the row reached that state at ordinary widths. The field keeps the layout's position when the spacers are gone. Read off the laid-out bounds through a temporary layout dump, which is how a views layout question gets answered on a build with no test runner (HANDOFF trap 37). |
| 11 | An "Action required" chip on the app menu, taller than the row (the operator's third reply). | Chromium's registry loader reads Google Chrome's own key, `Software\Google\Chrome\Extensions`, whatever the branding; Adobe's installer had put its Acrobat extension there, and the browser was fetching it from Google's update server and asking. The provider is gone on Windows (privacy Q9, HANDOFF trap 38). The chip itself, for the errors that are real, is the toolbar buttons' height (toolbar T25). |
| 12 | The caption buttons sat higher than the row's centre. | They stretched from the window's top edge to the frame's height; they now centre on the row's centre line at their own height (toolbar T19). |

## Round 7 — the operator's look at beta 3 (2026-09-05)

Six things from real use, and a crash found while capturing them. Each is fixed,
tested and captured without a hand on the machine: `tooling/capture-ui` with feature
params for the state, and an AppleEvent quit (the operator was at the keyboard, and a
synthetic key that missed the browser once landed in their chat — `docs/HANDOFF.md`,
trap 27).

| # | Found | Fix |
|---|---|---|
| 1 | The address row was a different colour from the page: even a plain white page got a grey row (the page colour was blended 85% over the ground). | The row is the page's colour exactly, with one hairline where it meets the page (toolbar T15: `PageBarColorSupplier`, `PaintPageBar`). |
| 2 | The page's top corners were rounded under the row, showing the row's colour through them wherever a page's header is not its theme colour. | Square top corners on the content whenever the row shows; the row keeps the card's rounded top (toolbar T16). |
| 3 | The address text sat off-centre and the star was nearly invisible; then, on the fix: "still too short, make the font smaller", and "no margin before en.wikipedia.org — remove that background, and make sure it shrinks when a user has many plugins". | The star and the row's page actions take the bar's own colours (T17). The field is 560 DIP on the row's centre with no background at all, the address centred in it one point smaller than Chromium's, the page actions at its right edge, and the flex rule gives the width back when the toolbar is tight (T5, T18). |
| 4 | Collapsed, the rail's rows sat a little left of centre, the toggle sat too low, and the toggle could pass under the traffic lights; then, on the fix: "the icon is too low, not vertically aligned with the close button". | The rail centres its rows against the card's edge, and the toggle takes the traffic lights' own vertical centre on the caption row, clear of them when it must sit below (Y6, Y7). |
| 5 | Folders did not look like Arc's; then, on the fix: "why did + New Tab and folders move right? change the folder icon". | Arc's folder row: macOS's own "folder" symbol in the favicon column, a semibold title, no chevron, and the header, the New Tab row and the Space title row all on the tab rows' own 8 DIP column — the folder header had been indented with its children since patch 0008 (F12, Y3). |
| 6 | Moving from Arc should be one click. | The welcome flow's Arc block moves Spaces, pins, folders, tabs, history and passwords with one button; the settings row and the ⌘T action move everything too (import I6, I21–I23, patch 0038). |
| — | Quitting with a folder in the sidebar aborted (`bad_variant_access`): the page-colour re-theme ran inside the tab strip's close-all notification and reached a folder header whose folder was already gone. | The re-theme is posted after the change and skipped while the window empties; the header gives no folder for a node that is not one (folders F12). |
| — | macOS asked for a keychain and named the product "Chromium" during an import. | The keychain item is Stedding's own, with the Chromium item as a fallback so an earlier beta's passwords still decrypt (import I24). |
