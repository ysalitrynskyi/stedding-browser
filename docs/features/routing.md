# Feature: Routing sites to Spaces

Status: **D1–D6 planned** (round 6, `docs/ROUND6-PLAN.md` R6-23).
Owner docs: `docs/PRODUCT.md` §2, `docs/ROADMAP.md`. Patch: TBD.

Arc calls it Air Traffic Control: a site opens in the Space it belongs to, wherever
the link came from. Stedding keeps a small list of rules in the profile — a site, a
substring or an exact address, and the Space it goes to — plus one default Space for
links from other apps. A tab that opens with a matching address moves to its Space
at once; a toast says where it went and undoes it.

## Behaviours

| Id | Behaviour | Test | State |
|---|---|---|---|
| D1 | `spaces::SpaceRouter` is a pure function over the profile pref `stedding.spaces.routes` (a list of `{match: site \| contains \| equals, pattern, space}`) plus `stedding.spaces.external_default` (the Space for links from other apps; empty means the active Space). The first matching route wins, and a route wins over the default. A `site` rule matches the address's registrable domain (eTLD+1, or the host when it has no registry); `contains` matches anywhere in the address; `equals` the whole address. | SpaceRouterTest.MatchTable, SpaceRouterTest.PrefsRoundTrip | planned |
| D2 | On the insert of a tab that has an address, and on the first navigation of a fresh tab (a typed address in a new-tab page), a match moves the tab with `SetSpaceForTab` and switches Space when the open was foreground. A tab rebuilt from a session is never routed (spaces B2). A route whose Space is not in the window is ignored. | SpaceWindowTest.InsertedTabFollowsRoute, SpaceWindowTest.RestoredTabIsNotRouted, SpaceWindowTest.TypedAddressInAFreshTabFollowsRoute | planned |
| D3 | Links from other apps (`application:openURLs:` → `openStartupTabsReplacingNTP:`) are tagged for a moment, so a tab they open lands in `external_default` when no route matches. | SpaceRouterTest.ExternalOpenIsTakenOnce, SpaceWindowTest.ExternalOpenLandsInTheDefaultSpace; live: `open -a Stedding https://…` | planned |
| D4 | A toast "Opened in <Space> · Undo" follows a routed open; Undo returns the tab to the Space it opened in and switches back. | SpaceWindowTest.UndoMovesTheTabBack; live capture | planned |
| D5 | Rules are made in place: the tab menu's "Always Open <site> in ▸" lists the window's Spaces and writes a site rule (eTLD+1, no regex) that routes the tab now; chrome://settings/stedding shows each Space's routes under its row with a remove control and an add field. The Space menu's "Route sites here…" and "Sort open tabs by these rules now" are a second pass. | SpaceRouterTest.RuleFromTabIsSiteScoped; live: the tab menu and the settings captures | planned |
| D6 | Peek precedes routing: a link that leaves a pinned tab's site peeks and no tab is inserted, so no route runs; routing applies to new tabs only. | SpaceRouterTest.PeekPrecedesRoutes | planned |

## Notes

- Routes name a Space by its id, which today is per window (`SpaceModel`); until the
  registry (R6-31) a route only applies in a window that holds its Space, and the
  window that receives an external link is the one macOS hands it to (the last
  active). Duplicating a Space-pinned tab whose site is routed, versus activating
  the pin, is TBD (critic #26).
- Selection: the multi-select rule (`docs/features/tabs.md`, R6-20) applies to every
  verb here; "Always Open <site> in ▸" from a multi-selection writes one rule per
  site.
