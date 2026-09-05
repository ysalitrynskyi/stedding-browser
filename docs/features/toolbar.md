# Feature: Toolbar and page bar

Status: **T1–T3, T5, T6 built**; **T4, T7 planned** (round 6, the page-colour row, 2026-09-04).
Owner docs: `docs/UI-SPEC.md`. Patches: `0002` (layout), `0007` (colours).

The address row is the top of the page card, not a strip above it: no gap, no hairline,
the same gutter as the card on its three free sides (6 DIP, the `card_gutter` parameter; 8 until 2026-09-05, when the top had none), and the page's own colour when the page declares
one. Arc's window reads the same way.

## Behaviours

| Id | Behaviour | Test | State |
|---|---|---|---|
| T1 | The content card starts directly under the address row: no gap, no hairline between them. | `tooling/probes/window.json` (content top at the toolbar's bottom) | built |
| T2 | The row keeps the card's gutters (`card_gutter`, 6 DIP) at the sides and sits the same gutter below the window's top edge, so the omnibox and the page share edges and the distance from the window's top to the row equals the right and bottom borders (operator, 2026-09-05). | probes: toolbar row left/right/top | built |
| T3 | A page whose colour — its `theme-color`, or, without one, its own background (`WebContents::GetBackgroundColor`, the way Safari tints its bar) — sits on the same side of the contrast line as the theme (dark in dark mode, light in light) colours the row that colour, blended 85% over the ground, so the row reads as the top of the page: white for chrome://settings or Wikipedia in light, GitHub's dark in dark. | live: `tooling/drive` on github.com (dark) vs example.com (none); `tooling/probes/window.json` keeps example.com's row on the ground | built |
| T4 | A page whose colour is on the other side of the contrast line (a dark page in light mode, a white page in dark) colours the row all the same, and the row's icons and text flip for contrast (T7), as Safari does; until 2026-09-04 such a row stayed on the ground. A page with no colour leaves the row on the ground (probes 5 and 12 on example.com). | probes 5 and 12 on example.com; live: github.com in light mode, the row dark and the back arrow light (a probe on the arrow) | built |
| T5 | The omnibox has no pill of its own: text on the bar, a quiet tint on hover. The page-info chip ("Stedding" on chrome:// pages) keeps 21 DIP for its 16 DIP icon inside the 25 DIP location bar (found clipped 2026-09-04). | capture | built |
| T6 | In macOS immersive fullscreen the row moves into the overlay; the sidebar's top row stays as compact as outside fullscreen. The sidebar cannot reach the overlay's 33 DIP (platform: the window's content view starts below it). | live capture (⌃⌘F) | built |
| T7 | The row's icon and text colours follow the page colour through the ColorProvider: `PageBarColorSupplier` rides on the window's `ColorProviderKey` as its app controller (the slot web apps use for their theme colour) and remaps the toolbar's icon, text and omnibox ids to the colour with most contrast against the painted bar; the sidebar's buttons use the tab-strip control ids and keep theirs. A page-colour change re-themes the window the way a web app's theme-colour change does. | live: github.com (dark) in light mode and example.com; probe on the back arrow's pixel, dark and light | built |
