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
| Y6 | The collapsed rail (⌘S) is read against the card's edge, gutter included: its rows, the toggle and the bottom buttons are centred in the rail plus the gutter, not in the rail alone (3 DIP left of centre until 2026-09-05). | live: `r7_collapsed` (the favicon column's centre at 31 DIP against the card's edge at 62, the toggle's top at 34 DIP) | built |
| Y8 | In the rail the toggle, the New Tab row and the Archived row centre in the column a size up, the Archived row as its icon alone; the Space switcher stacks its chips in a column with no spacers, the downloads button above it. Keyed on the width being drawn, not the collapse state: expanded on hover the state stays collapsed while the rows are at the open width. | none; live: `w8_collapsed`, `w8_hover` (Windows, 2026-09-08) | partial · no unit test yet (S-49); the tab pill itself is S-53 |
| Y9 | The strip's button glyphs are 22 DIP under the Arc window, in step with the rail's favicons (`IconDesignWidth() + 4` in the rail) and the switcher's chips. | none; live: `w8_collapsed` | partial · no unit test yet (S-49) |
| Y10 | Expanded on hover the strip is opaque: its background, invisible so the window's gradient shows through (HANDOFF trap 8), is visible exactly while the strip is collapsed by state and drawn wider than the rail. The page read through every row until 2026-09-08. | none; live: `w8_hover` (Windows) | partial · no unit test yet (S-49) |
| Y7 | The sidebar's toggle shares the caption row with the traffic lights and takes their own vertical centre — the exclusion macOS reports is a box with an equal margin on every side, so its vertical padding is the gap above the first glyph and the glyphs are macOS's 12 DIP circles; half the exclusion's height sat the toggle 3 DIP low against a capture of the real window; it sat on the container's centre, a few DIP low, until 2026-09-05. Collapsed with the row hidden the rail stays at the window's top, and a button never sits under the lights: leaving expand-on-hover drops it below them. | `VerticalTabStripTopContainerTest.ToggleTakesTheCaptionButtonsOwnCentre`, `VerticalTabStripTopContainerTest.CollapsedButtonClearsTheCaptionButtonsByTheirOwnHeight`; live: `r7_collapsed`, `ui-current` | built |

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
