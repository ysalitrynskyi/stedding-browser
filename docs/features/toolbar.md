# Feature: Toolbar and page bar

Status: **T1–T6 built**; T7 is a gap.
Owner docs: `docs/UI-SPEC.md`. Patches: `0002` (layout), `0007` (colours).

The address row is the top of the page card, not a strip above it: no gap, no hairline,
the same 8 DIP side gutters as the card, and the page's own colour when the page declares
one. Arc's window reads the same way.

## Behaviours

| Id | Behaviour | Test | State |
|---|---|---|---|
| T1 | The content card starts directly under the address row: no gap, no hairline between them. | `tooling/probes/window.json` (content top at the toolbar's bottom) | built |
| T2 | The row keeps the card's 8 DIP side gutters, so the omnibox and the page share edges. | probes: toolbar row left/right | built |
| T3 | A page with a `theme-color` on the same side of the contrast line as the theme (dark colour in dark mode, light in light) colours the row and the card's top corners with it, blended 85 % toward the ground. `PageThemeColorController` follows the active tab and repaints on change. | live: `tooling/drive` on github.com (dark) vs example.com (none); `tooling/probes/window.json` keeps example.com's row on the ground | built |
| T4 | A page with no theme colour, or one that would swallow the toolbar icons, leaves the row on the window ground. | probes 5 and 12 on example.com | built |
| T5 | The omnibox has no pill of its own: text on the bar, a quiet tint on hover. | capture | built |
| T6 | In macOS immersive fullscreen the row moves into the overlay; the sidebar's top row stays as compact as outside fullscreen. The sidebar cannot reach the overlay's 33 DIP (platform: the window's content view starts below it). | live capture (⌃⌘F) | built |
| T7 | The row's icon and text colours follow the page colour through the ColorProvider (today the icons keep the theme's colours; the blend and the contrast gate keep them readable). | none yet | gap |
