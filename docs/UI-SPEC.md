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
not meet the top-left corner of the window.** They sit on a rounded card below the
address row, with the window background as a mat at the sides and the bottom. Since
round 5 (`docs/ARC-ROUND2.md`) the card starts directly under the row — no gap, no
hairline — and the row takes the page's theme colour when the page declares one that
suits the colour scheme, so the row reads as the top of the page; otherwise it stays
on the window ground and the card's top corners show the mat. That one change
accounts for most of "looks like Arc".

## Sidebar

Top to bottom. This order is corrected from a reference screenshot; an earlier
version of this file put the space switcher at the top, which is wrong.

| Element | Value |
|---|---|
| **Essentials** | A grid of large rounded cards at the very top, ~150x50, radius ~12. These are pinned tabs that live **above all Spaces** — they are visible whichever Space is active. Icon only, no label |
| Space-pinned tabs | Below the essentials: ordinary rows, favicon plus label, pinned **within the current Space** |
| Divider | 1 px hairline with a `Clear` at its right end, which closes this Space's tabs and leaves the essentials. **Done** (patch 0004) |
| `New Tab` row | Plus glyph plus label, muted, **above** the unpinned tabs |
| Tab row height | ~48 px |
| Favicon | ~18 px, left inset ~28 px |
| Active tab | Filled rounded rect, radius ~10, inset ~10 from the sidebar edges |
| **Space switcher** | At the **bottom**, not the top: a row of small icons, ~24 px, one per Space, with a trailing `+`. Hovering one raises a pill showing that Space's name |
| Space identity | Each Space has a name **and an icon**, both user-set. Hovering an icon raises its name above the row |

The two things this project got wrong first time, recorded so they are not
repeated: the essentials row is not the same thing as pinned tabs (essentials
are global, pinned tabs are per-Space), and the Space switcher is at the bottom
of the sidebar, shown as icons rather than named pills.

## Toolbar

Thin — noticeably thinner than Chromium's. Back, forward and reload at the left.
The URL is **centred** and shows the bare host with a small link glyph.
Extension and plugin icons are in the **top right**, on the same row.

No omnibox chrome: no pill background, no border.

## Command bar

![The command bar](images/ui-command-bar.png)


⌘T opens a centred overlay, not a focused omnibox: a dark rounded panel with
`Search or Enter URL...` and a result list beneath it.

The results are the important part. They mix:

- open tabs in the current Space, actioned as `Switch to Tab`
- tabs in **other** Spaces, labelled with the name of the Space they are in
- ordinary suggestions and search

So the command bar searches across every Space, which is why `TabStripModel`
holding all Spaces' tabs (ADR 0015) is the right shape rather than a limitation.

## Driving the real UI

Screenshots cannot show whether something is clickable. Synthetic mouse events
posted with `CGEventPostToPid` reach the browser's own process without moving
the operator's pointer or touching their other windows, which is enough to
verify hover behaviour -- and it is how the Space icons were found to jump out
from under the pointer when their name appeared.

Clicks do not register this way: they need the window to be key, which means
taking focus on a machine somebody else is using. So anything behind a click is
tested in `unit_tests` instead -- which is how drag-to-Space was verified without
a drag, by giving its drop handler a fake drag controller and checking the tab
comes back.

## How this gets checked

Screenshot the built browser at the reference window size, put it beside the Arc
reference, and compare. Differences are logged here as they are fixed. "Looks
close" is not a check — the comparison image goes in the pull request.

## Where it stands

![The Stedding window today](images/ui-current.png)

With four Spaces and a pinned essential (`--features
'SteddingArcStyleWindow:extra_spaces/3/pin_tabs/1'`):

![Three Spaces](images/ui-spaces.png)

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
the shipping values in the table below. See patch 0002.

## Progress

Measured against the table above, not against "looks closer". The measurements
that matter are probes in `tooling/probes/window.json`; `tooling/dev capture
--assert tooling/probes/window.json` checks them against a fresh capture.

| Item | State |
|---|---|
| Contents corners | Done — 12 px on all four, `SteddingBrowserViewLayout` merges its radius per corner with whatever upstream set (glass mode sets a lower-left radius every layout, which once masked the other three); probed |
| Sidebar width | Done — 352 px, measured in the capture |
| Tab row height | Done — 44 px, measured in the capture (Chromium's default is 30) |
| Active tab pill radius | Done — 10 px |
| Favicon size | **Done** — 18 px (patch 0002). The earlier claim that the image would not scale was wrong: TabIcon draws through DrawImageInt, scaled to its bounds |
| Bare-host URL | Done — unfocused only; the full URL returns on focus. Verified in the capture |
| Sign-in promo pill | Removed — Chromium advertises Google sign-in in the toolbar by default |
| Command bar (⌘T) | **Done** — centred overlay, searches every Space and names the Space a result is in, opens URLs and searches (patch 0005) |
| Centred URL | **Done** — capped by a flex rule, spacers either side; measured centre 890 against a content centre of 876 (patch 0002) |
| Space switcher | **Done** — a row of icons at the **bottom** of the sidebar, active one full strength, plus a button that makes a new Space (patch 0004). The first attempt put named pills at the top, which was wrong |
| Essentials row | **Done** — pinned tabs are exempt from the Space filter, so they sit above all Spaces, and their tiles are 50 DIP tall so they read as cards (patch 0004) |
| Essentials grid | **Done** — two cards per row at the sidebar width, ~165 DIP wide, 50 tall; a lone card stays card-sized (patch 0002) |
| New Tab row | **Done** — "+ New Tab", muted, one tab-row tall, under the Clear line and above the unpinned tabs; opens the command bar; the bottom "+" pill is gone (patch 0002) |
| Sidebar top row | **Done** — Chromium's tab-group/tab-search combo and the hairline under the row are hidden; only the collapse button remains (`S-27`) (patch 0002) |
| Toolbar right cluster | **Done** — no profile avatar; the app menu only (patch 0002) |
| Window background tinted per space | **Done** — `Widget::SetUserColorOverride` from the active Space's colour, and the colour is settable from the Space's context menu (patch 0004). A window with one Space is left untinted |

## Still not the reference

Every item in the tables above is built, every deviation that was once written
off has been fixed, and the toolbar now matches. What a side-by-side shows:

- The toolbar is **33 DIP**, matching the reference, down from Chromium's 46.

  It sat at 39 for a while because two floors were the same number. The top
  container is sized as `max(caption-button height, its own minimum)` when the
  window has a leading exclusion; on macOS that exclusion is 38, and the
  toolbar's own preferred height was also 38. Every experiment changed one side
  and so measured 39, which produced two confident and wrong explanations before
  a probe printing `preferred_h`, `minimum_h` and `lead_excl_h` from a running
  browser showed all three were 38.

  Both sides now move: the top container skips the exclusion when a vertical tab
  strip already covers the traffic lights, and the toolbar's content comes down
  through the metrics parameters.

- Tabs move between Spaces by dragging one onto a Space icon, or from a Space's
  context menu. Chromium's decision to consult the drop target mid-drag is the
  one part not covered by a test; if it never fires, the drag does nothing.


## Pinned tabs cannot be seeded for a screenshot

Writing `pinned_tabs` into a throwaway profile's `Preferences`, which is the
pref `PinnedTabCodec` reads at startup, does not work: Chromium's
tracked-preference protection rejects a value it did not write itself and the
key comes back empty. That is the anti-tampering feature doing its job, and not
something to work around.

The way round it is a parameter on our own code — `pin_tabs` — which pins the
first N tabs once the window has them. That defeats nothing; it is the same
trade as `extra_spaces` and the tunable metrics.

## The centred URL was deferred, wrongly

This file previously argued the centred URL was not worth doing: it needed
spacers around the location bar, `InitLayout()` is private and non-virtual so no
subclass could reach it, and `toolbar_view.cc` takes 205 commits a year.

The premise was right and the conclusion was wrong. It is not a rewrite of the
layout: it is a flex rule on a child that is already there, plus two empty
views. Recorded because the reasoning -- "this file is expensive, therefore do
not touch it" -- is worth applying to the size of the change rather than to the
file.

## Known gaps

The sidebar's top-left still shows Chromium's collapse button (`S-27`). The new
tab page is Chromium's local third-party page (dark, a Web Store shortcut), not
a Stedding page (`S-28`). Everything else in the tables above is built and
measured, and `tooling/probes/window.json` checks it.
