# UI specification — matching Arc

The target is a **pixel-accurate match of Arc's window chrome**, measured from
reference screenshots of Arc running on macOS. This document is the spec that
work is checked against; where it disagrees with a screenshot, the screenshot
wins and this file gets corrected.

Chromium's built-in vertical tab strip is *not* the target. It supplies the tab
model — see `decisions/0010-ride-upstream-vertical-tabs.md` — and almost none of
the appearance. Treating "vertical tabs are on" as "the sidebar is done" was an
early mistake in this project and is recorded here so it is not repeated.

## Layout, at a 2000×1293 reference window

Measurements are from the reference screenshot. They are ratios and radii, not
fixed pixel counts, except where a constant is genuinely constant.

```
┌──────────────────────────────────────────────────────────────┐
│                     window background (dark)                 │
│ ┌───────────┐  ┌──────────────────────────────────────────┐  │
│ │           │  │  toolbar strip — on the dark ground      │  │
│ │  sidebar  │  ├──────────────────────────────────────────┤  │
│ │           │  │                                          │  │
│ │           │  │  web contents — light, rounded top-left  │  │
│ │           │  │                                          │  │
│ └───────────┘  └──────────────────────────────────────────┘  │
└──────────────────────────────────────────────────────────────┘
```

| Element | Value |
|---|---|
| Sidebar width | ~352 px, user-resizable, persisted |
| Window top strip above contents | ~48 px |
| Toolbar row height | ~44 px, sitting on the window background |
| Contents corner radius | ~12 px, **top-left only** in the reference — contents meet the right and bottom window edges |
| Window background | dark slate, near `#1E2029`; the space's theme colour tints this |
| Contents background | the page's own; the browser draws no frame around it |

The single most important difference from stock Chromium: **the web contents do
not meet the top-left corner of the window.** They are inset below a toolbar
strip and rounded, so the window background reads as a mat around the page. That
one change accounts for most of "looks like Arc".

## Sidebar

| Element | Value |
|---|---|
| Space switcher | row of rounded pills at the top, ~150×50 px, radius ~12 px, active pill lighter |
| Tab row height | ~48 px |
| Favicon | ~18 px, left inset ~28 px |
| Label | ~15 px, left inset ~52 px, single line, ellipsised |
| Active tab | filled rounded rect, radius ~10 px, inset ~10 px from the sidebar edges |
| Hover | same shape, lower opacity |
| Section divider | 1 px hairline at ~12% opacity, above `New Tab` |
| `New Tab` row | plus glyph plus label, same height as a tab row, muted |
| Bottom bar | row of small app icons, ~24 px, plus a trailing `+` |

Pinned tabs sit above the divider, unpinned below. There is no horizontal tab
strip anywhere.

## Toolbar

Back, forward and reload at the left. The URL is **centred** and shown as the
bare host — `example.com`, not the full URL — with a small link glyph. Extension
icons are right-aligned. No omnibox chrome: no pill background, no border.

This is not Chromium's toolbar restyled. Chromium centres nothing and always
shows a full omnibox.

## How this gets checked

Screenshot the built browser at the reference window size, put it beside the Arc
reference, and compare. Differences are logged here as they are fixed. "Looks
close" is not a check — the comparison image goes in the pull request.

## Progress

Measured against the table above, not against "looks closer".

| Item | State |
|---|---|
| Contents corner nearest the tab strip | Done — 12 px, `SteddingBrowserViewLayout`, measured at 12 pt in the capture |
| Sidebar width | Done — 352 px default, still resizable and pref-backed |
| Tab row height | Done — 44 px (Chromium's default is 30) |
| Active tab pill radius | Done — 10 px |
| Favicon size | **Deliberately not done.** 16 px, not 18. `gfx::kFaviconSize` is global and the image would not scale with the slot |
| Bare-host URL | Done — unfocused only; the full URL returns on focus. Verified in the capture |
| Centred URL | Not started — needs spacers in `ToolbarView`'s flex layout |
| Space switcher | Not started — blocked on Spaces actually switching tabs |
| Favorites row | Not started |
| Window background tinted per space | Not started — `Widget::SetUserColorOverride` is the hook |

## Known gaps

The sidebar's top area still holds Chromium's collapse button and the tab-group
and tab-search combo buttons, where Arc has the space switcher. The toolbar is
still Chromium's, left-aligned, with the omnibox pill. There is no favorites
grid and no bottom app-icon row.

The space switcher is deliberately not built yet. A row of pills that changes an
active id without moving any tabs would be a picture of a feature, and this
project ships features complete or not at all — see the mandate in AGENTS.md.
It lands with the tab-parking work, not before.
