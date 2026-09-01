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

## Where it stands

![The Stedding window today](images/ui-current.png)

Captured with `tooling/capture-ui` at 1400x880. Numbers below are measured from
that image, not estimated.

## Tuning these numbers costs nothing

The contents corner radius, the tab row height and the tab pill radius are
feature parameters, not constants, so a value can be tried against a build that
already exists:

```
tooling/capture-ui --features \
  'SteddingArcStyleWindow:contents_corner_radius/16/vertical_tab_height/48'
```

Change a number, capture, measure, repeat — no compile, no link. Defaults are
the shipping values in the table below. See patch 0007.

## Progress

Measured against the table above, not against "looks closer".

| Item | State |
|---|---|
| Contents corner nearest the tab strip | Done — 12 px, `SteddingBrowserViewLayout`, measured at 12 pt in the capture |
| Sidebar width | Done — 352 px, measured in the capture |
| Tab row height | Done — 44 px, measured in the capture (Chromium's default is 30) |
| Active tab pill radius | Done — 10 px |
| Favicon size | **Deliberately not done.** 16 px, not 18. `gfx::kFaviconSize` is global and the image would not scale with the slot |
| Bare-host URL | Done — unfocused only; the full URL returns on focus. Verified in the capture |
| Sign-in promo pill | Removed — Chromium advertises Google sign-in in the toolbar by default |
| Centred URL | **Deferred, on purpose** — see below |
| Space switcher | Unblocking — the model half is in (patches 0008-0010): every window has a SpaceModel, tabs carry a Space, the tab strip hides tabs outside the active one, and traversal skips them. The switcher itself is next |
| Favorites row | Partly free — pinned tabs in the vertical strip **already** lay out as a grid (`pinned_tab_container_view.cc`, 11 commits/yr). What is left is tile size: Chromium's are 32x32 centred favicons, Arc's are roughly twice that. Not yet changed, because it cannot be checked — see below |
| Window background tinted per space | Not started — now unblocked by the same patches. `Widget::SetUserColorOverride` is the hook |

## Pinned tabs cannot be seeded for a screenshot

Checking the Favorites grid means having pinned tabs, and pinning is a UI
gesture. The obvious shortcut — writing `pinned_tabs` into a throwaway profile's
`Preferences`, which is the pref `PinnedTabCodec` reads at startup — does not
work: Chromium's tracked-preference protection rejects a value it did not write
itself, and the key comes back empty. That is the anti-tampering feature doing
its job, and not something to work around.

So the tile-size change waits until it can be looked at, either from a real
profile or through UI automation. The mechanism is already known to be there.

## Why the centred URL is deferred

Everything else in the table was reachable either through a subclass or by
moving a default. Centring the URL is not: it needs two flexible spacer views
either side of the location bar and a changed flex rule, and `InitLayout()` is
private and non-virtual, so it cannot be done from a subclass.

That means editing `toolbar_view.cc` — 2,010 lines and **205 commits a year**,
the most-churned file this project would touch. `ARCHITECTURE.md` asks for a
minimal patch series that rebases cheaply, and this would be the single most
expensive patch in it, bought for the least visible of the four differences.

It is deferred until either the toolbar grows a seam we can subclass, or the
rest of the sidebar is done and this is genuinely the last thing left.

## Known gaps

The sidebar's top area still holds Chromium's collapse button and the tab-group
and tab-search combo buttons, where Arc has the space switcher. The toolbar is
still Chromium's, left-aligned, with the omnibox pill. There is no favorites
grid and no bottom app-icon row.

The space switcher is deliberately not built yet. A row of pills that changes an
active id without moving any tabs would be a picture of a feature, and this
project ships features complete or not at all — see the mandate in AGENTS.md.
It lands with the tab-parking work, not before.
