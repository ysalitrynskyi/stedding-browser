# Feature: Sidebar density, text size and the collapsed rail

Status: **Y1–Y7 built** (Y1–Y5 round 6, `docs/ROUND6-PLAN.md` R6-27; Y6–Y7 round 7, `docs/ARC-ROUND2.md`, 2026-09-05).
Owner docs: `docs/UI-SPEC.md` (the measured Arc match), `docs/PRODUCT.md` §2. Patches: 0031, 0037 (Y6–Y7).

The sidebar's rows are Arc's: 44 DIP with an 18 DIP favicon, measured in
`docs/UI-SPEC.md`. Two browser-wide settings let a user trade that for more rows on the
screen, or a larger title: a density preset and one text-size step. Comfortable is the
measured match and stays exactly as it is.

## Behaviours

| Id | Behaviour | Test | State |
|---|---|---|---|
| Y1 | "Sidebar density: Comfortable / Compact / Dense" (`stedding.sidebar.density`, local state, 0/1/2) sets rows 44/36/30 DIP, the favicon 18/16/16, the essentials card 50/40/34 and the row corner radius 10/8/6. The Stedding layout constants (`kVerticalTabHeight`, `kVerticalTabPinnedHeight`, `kTabFaviconSize`, `kVerticalTabCornerRadius`) read a process-wide cache that the local-state preference fills, the way they read the feature params today; a change re-lays out every window at once, like the width slider. Comfortable is untouched. | `SidebarDensityTest.PresetsGiveTheMeasuredMetrics`; live: `w3_density_compact`, `w3_density_dense` (the rows, the card and the favicons at each preset) | built |
| Y2 | "Sidebar text size" 12 / 13 / 14 / 15 (`stedding.sidebar.text_size`, local state, default 12) sizes tab titles, the Space title row, folder headers, the New Tab row and the Clear line; a row is never shorter than its text plus insets, so nothing clips. | `SidebarDensityTest.RowsNeverClipTheText`; live: `w3_density_text15` | built |
| Y3 | Folder headers, the Space title row, the New Tab row and the Clear line take the row height of the preset, so Dense looks even. | live: `w3_density_dense` (the pinned cards, the Clear line, the folder header, its tab and the New Tab row all at the preset's height; `w3_density_compact` the same at 36) | built |
| Y4 | ⌘T actions "Sidebar density: Comfortable / Compact / Dense". | `CommandBarViewTest.DensityActionsSetThePreset` | built |
| Y5 | The essentials grid's columns, the toolbar and the command bar do not move with the preset. | `SidebarDensityTest.PresetsGiveTheMeasuredMetrics` (the essentials height per preset); live: the toolbar keeps its height and the page card its place in `w3_density_dense` against `w3_density_before` | built |
| Y6 | The collapsed rail (⌘S) is read against the card's edge, gutter included: its rows, the toggle and the bottom buttons are centred in the rail plus the gutter, not in the rail alone (3 DIP left of centre until 2026-09-05). | live: `r7_collapsed` (the active row's pill and the favicon column centred between the window edge and the card; pending: the screen was locked when this landed on 2026-09-05; taken at the next unlock) | built · capture pending |
| Y7 | Collapsed, the sidebar's toggle clears the traffic lights by their own height plus the collapsed padding, not by the toolbar's height (which carries the card gutter and sat it lower after T2); on the way out of expand-on-hover it drops below them instead of passing under them. | `VerticalTabStripTopContainerTest.CollapsedButtonClearsTheCaptionButtonsByTheirOwnHeight`, `VerticalTabStripTopContainerTest.LeavingExpandOnHoverNeverSitsOnTheCaptionRow`; live: `r7_collapsed` (pending: the screen was locked when this landed on 2026-09-05; taken at the next unlock) | built |

## Notes

- The collapsed rail (Y6, Y7) is laid out by `VerticalTabStripRegionView`
  (an interior margin of the card gutter while collapsed) and
  `VerticalTabStripTopContainer` (the caption clearance, fed the traffic
  lights' height by `SteddingBrowserViewLayout`); `tooling/dev test sidebar`
  runs the top container's tests.
- The preferences are local state (browser-wide): a window's rows should not differ
  by profile, and the cache is process-wide, read from every window's layout.
- The cache is filled at startup and on every change of either preference by a
  `SidebarDensity` observer on local state; the change walks the browser list and
  invalidates each window's layout, which re-reads the constants.
