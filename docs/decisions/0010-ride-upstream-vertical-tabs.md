# 0010 — Build the sidebar on upstream's vertical tabs, not on a replaced tab strip

Status: Accepted
Date: 2026-08-30

## Context

`ROADMAP.md` M2 says the horizontal tab strip is removed and replaced by our own
Arc-style sidebar. That was written when Chromium had no vertical tab support. It does
now, and the survey of the tree at `153.0.8010.12` found a landed, shipping feature
rather than an experiment:

- `chrome/browser/ui/views/frame/vertical_tab_strip_region_view.{h,cc}` — the view,
  with `vertical_tab_style_views.{h,cc}` and a background blur backdrop.
- `chrome/browser/ui/tabs/vertical_tab_strip_state_controller.*` — collapse/expand and
  width state, persisted.
- `kVerticalTabsLaunch` is `FEATURE_ENABLED_BY_DEFAULT`
  (`chrome/browser/ui/tabs/features.cc:31`); `IsVerticalTabsFeatureEnabled()` is true
  out of the box. The remaining switch is the user pref `prefs::kVerticalTabsEnabled`.
- A settings toggle already exists in `appearance_page.ts`, there is an in-product-help
  controller promoting the feature to users, metrics, and interactive UI tests with a
  dedicated test mixin.
- `kVerticalTabsExpandOnHover` exists as a separate feature.

Measured churn on the files a replacement would touch, over the last year:
`browser_view.cc` 412 commits, `vertical_tab_strip_region_view.cc` 181,
`tab_strip.cc` 119. `kTabStripUnification` is present but disabled
(`features.cc:96`); when it lands, both orientations share one view and a fork of the
old `TabStrip` stops applying at all.

## Decision

**M2 rides `VerticalTabStripRegionView`.** Concretely: default the
`vertical_tabs.enabled` pref on, and put any look-and-feel divergence in a subclass in
a new directory. `TabStripModel` — the data — is untouched, as it always was going to be.

We do **not** fork or replace `TabStrip`, do not add a third tab renderer, and do not
put tabs in `SidePanel`.

## Consequences

- M2 collapses from a large patch series to roughly a pref default plus new files,
  which is the cheapest bucket in `../ARCHITECTURE.md`. Collapse, pin, drag-reorder,
  favicons, audio indicators and persisted state come from upstream already built.
- We inherit upstream's maintenance of the hardest part, and the `kTabStripUnification`
  transition becomes someone else's problem instead of a rebase cliff.
- The rebase risk moves to a specific, avoidable place: editing `browser_view.cc` or
  `vertical_tab_strip_region_view.cc` in place would fight 412 and 181 commits a year.
  Product logic goes in new files; touching those two is a design failure to be
  reviewed, not a routine step.
- **This weakens the product's stated differentiation, and that part is not settled
  here.** `VISION.md` and `COMPETITORS.md` present the Arc-style sidebar as the reason
  Stedding exists. If Chromium ships vertical tabs by default, the sidebar alone is no
  longer a differentiator, and what remains is workspaces, the command bar and split
  view — plus privacy defaults and governance. That is a product-positioning judgement
  with money and strategy attached, so it belongs to a human and to its own ADR. This
  one records only the engineering decision, which is correct either way: even a
  project that wants a wholly custom sidebar should start from the upstream view rather
  than from a fork of `TabStrip`.
