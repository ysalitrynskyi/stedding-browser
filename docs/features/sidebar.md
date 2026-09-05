# Feature: Sidebar density and text size

Status: **Y1–Y5 planned** (round 6, `docs/ROUND6-PLAN.md` R6-27).
Owner docs: `docs/UI-SPEC.md` (the measured Arc match), `docs/PRODUCT.md` §2. Patch: TBD.

The sidebar's rows are Arc's: 44 DIP with an 18 DIP favicon, measured in
`docs/UI-SPEC.md`. Two browser-wide settings let a user trade that for more rows on the
screen, or a larger title: a density preset and one text-size step. Comfortable is the
measured match and stays exactly as it is.

## Behaviours

| Id | Behaviour | Test | State |
|---|---|---|---|
| Y1 | "Sidebar density: Comfortable / Compact / Dense" (`stedding.sidebar.density`, local state, 0/1/2) sets rows 44/36/30 DIP, the favicon 18/16/16, the essentials card 50/40/34 and the row corner radius 10/8/6. The Stedding layout constants (`kVerticalTabHeight`, `kVerticalTabPinnedHeight`, `kTabFaviconSize`, `kVerticalTabCornerRadius`) read a process-wide cache that the local-state preference fills, the way they read the feature params today; a change re-lays out every window at once, like the width slider. Comfortable is untouched. | `SidebarDensityTest.PresetsGiveTheMeasuredMetrics`; live: `w3_density_compact`, `w3_density_dense` | planned |
| Y2 | "Sidebar text size" 12 / 13 / 14 / 15 (`stedding.sidebar.text_size`, local state, default 12) sizes tab titles, the Space title row, folder headers, the New Tab row and the Clear line; a row is never shorter than its text plus insets, so nothing clips. | `SidebarDensityTest.RowsNeverClipTheText`; captures at 12 and 15 (`w3_density_text15`) | planned |
| Y3 | Folder headers, the Space title row, the New Tab row and the Clear line take the row height of the preset, so Dense looks even. | capture at Dense | planned |
| Y4 | ⌘T actions "Sidebar density: Comfortable / Compact / Dense". | `CommandBarViewTest.DensityActionsSetThePreset` | planned |
| Y5 | The essentials grid's columns, the toolbar and the command bar do not move with the preset. | the window probes for those regions are unchanged | planned |

## Notes

- The preferences are local state (browser-wide): a window's rows should not differ
  by profile, and the cache is process-wide, read from every window's layout.
- The cache is filled at startup and on every change of either preference by a
  `SidebarDensity` observer on local state; the change walks the browser list and
  invalidates each window's layout, which re-reads the constants.
