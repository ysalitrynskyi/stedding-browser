# Feature: Routing sites to Spaces

Status: **D1–D4, D6–D8, D10, D11 built; D5 partial; D9 withdrawn** (round 6, `docs/ROUND6-PLAN.md` R6-23; D9 cut in patch 0055).
Owner docs: `docs/PRODUCT.md` §2, `docs/ROADMAP.md`. Patch: 0027.

Arc calls it Air Traffic Control: a site opens in the Space it belongs to, wherever
the link came from. Stedding keeps a small list of rules in the profile — a site, a
substring or an exact address, and the Space it goes to — plus one default Space for
links from other apps. A tab that opens with a matching address moves to its Space
at once; a toast says where it went and undoes it.

## Behaviours

| Id | Behaviour | Test | State |
|---|---|---|---|
| D1 | `spaces::SpaceRouter` is a pure function over the profile pref `stedding.spaces.routes` (a list of `{match: site \| contains \| equals \| host \| host-suffix, pattern, space}`) plus `stedding.spaces.external_default` (the Space for links from other apps; empty means the active Space). The first matching route wins, and a route wins over the default. A `site` rule matches the address's registrable domain (eTLD+1, or the host when it has no registry); `contains` matches anywhere in the address; `equals` the whole address; `host` matches `url.host()` (and optional `:port` when the pattern has one); `host-suffix` matches that host or a subdomain of it. | SpaceRouterTest.MatchTable, SpaceRouterTest.HostAndHostSuffix, SpaceRouterTest.PrefsRoundTrip | built |
| D2 | The routes are followed when a tab is made (PLAN.md SPC-12, CMD-8). A tab Stedding makes for an address -- a link opened in a new tab, a target=_blank link, ⌘T, a link from another app -- is made in the Space its route names, in that Space's cookie jar, before it loads anything; a foreground one brings that Space on screen a turn later, and the toast of D4 follows. A typed address in a fresh tab -- one showing a new-tab page, a blank page, or nothing committed yet -- gets new contents in the routed Space's jar and moves there before the address loads. A tab that arrives any other way -- dragged in from another window, moved, restored from a session or the recently-closed list -- is never routed, and a settings page or any other page the user is on is never moved under them. A route whose Space is not in the window is ignored. | `SpaceWindowTest.InsertedTabFollowsRoute`, `SpaceWindowTest.RestoredTabIsNotRouted`, `SpaceWindowTest.TypedAddressInAFreshTabFollowsRoute`, `SpaceWindowTest.ARoutedTabIsMadeInItsSpacesJar`, `SpaceWindowTest.ATypedRoutedAddressMovesTheFreshTabsContents`, `SpaceWindowTest.ATabNotMadeHereIsNotRouted`; browser: `SpaceJarTest.ARoutedLinkCarriesItsSpacesCookies`, `SpaceJarTest.ATypedRoutedAddressLoadsInItsSpacesJar`, `SpaceJarTest.TypingOnSettingsDoesNotMoveTheTab`, `SpaceJarTest.ADraggedRoutedTabIsNotRoutedAgain` | built |
| D3 | Links from other apps (`application:openURLs:` → `openStartupTabsReplacingNTP:`) are tagged for a moment, so a tab they open lands in `external_default` when no route matches. | SpaceRouterTest.ExternalOpenIsTakenOnce, SpaceWindowTest.ExternalOpenLandsInTheDefaultSpace; live: `w3_route_external` (`open -a Stedding` with the dropdown set to Space 2 lands the tab there) | built · the Mac only: on Windows, links from other apps open as tabs (S-56) |
| D4 | A toast "Opened in <Space> · Undo" follows a routed open; Undo returns the tab to the Space it opened in and switches back. | SpaceWindowTest.UndoMovesTheTabBack; live: `w3_route_toast_screen` (the toast after "Always Open example.com in ▸ Space 2") | built |
| D5 | Rules are made in place: the tab menu's "Always Open <site> in ▸" lists the window's Spaces and writes a site rule (eTLD+1, no regex) that routes the tab now; chrome://settings/stedding shows each Space's routes under its row with a remove control and an add field. The Space menu's "Route sites here…" and "Sort open tabs by these rules now" are a second pass. | SpaceRouterTest.RuleFromTabIsSiteScoped; live: `w3_route_menu_screen` (the tab menu's submenu), `w3_route_settings` (the rule under Space 2, the add field, the dropdown) | partial · the tab menu and the settings list; "Route sites here…" on the Space menu and "Sort open tabs by these rules now" are the second pass |
| D6 | Peek precedes routing: a link that leaves a pinned tab's site peeks and no tab is inserted, so no route runs; routing applies to new tabs only. | SpaceRouterTest.PeekPrecedesRoutes | built · does not arise while Peek is off (peek.md) |
| D7 | A `host` rule matches `url.host()` case-insensitively. `staging.example.com` does not match a `site` rule for `example.com` unless a `host` or `host-suffix` rule is listed first. | SpaceRouterTest.HostAndHostSuffix | built |
| D8 | A `host-suffix` rule matches the host itself or a host that ends with `.` plus the pattern. `foo.staging.example.com` matches suffix `staging.example.com`; `example.com` does not. | SpaceRouterTest.HostAndHostSuffix | built |
| D9 | A host rule would be written from the address's host. The menu and settings write site rules (D5). A host rule already in the pref still matches (D7). | `SpaceRouterTest.RuleFromTabIsSiteScoped` | planned · withdrawn, HostRouteFor is not in the product |
| D10 | `host` and `host-suffix` round-trip through the pref (`match` names `host` and `host-suffix`). Unknown match names are still skipped. | SpaceRouterTest.PrefsRoundTrip | built |
| D11 | A search typed in the address bar (a generated address) follows site, host and exact rules, and not `contains` rules, which would match the words searched for (PLAN.md CMD-8). | `SpaceWindowTest.ASearchIsNotRoutedByAContainsRule` | built |

## Notes

- Routes name a Space by its registry id, so they apply in every normal window (not
  in a Blank Window's own Spaces), and the
  window that receives an external link is the one macOS hands it to (the last
  active). Duplicating a Space-pinned tab whose site is routed, versus activating
  the pin, is TBD (critic #26).
- Selection: the multi-select rule (`docs/features/tabs.md`, R6-20) applies to every
  verb here; "Always Open <site> in ▸" from a multi-selection writes one rule per
  site.
- The insert hook runs inside the tab strip's notification, so a route changes
  membership at once but the Space switch and the toast are posted a turn later,
  the way `EnsureActiveSpaceHasAVisibleTab` is (spaces B4). The importer holds a
  `ScopedRoutingPause`: its tabs already know their Space.
- A fresh tab is one whose last committed address is empty, `about:blank` or a
  new-tab page; a typed or generated omnibox navigation in it is routed, a link
  click or a redirect is not (the page the user is on is not moved under them).
  A settings page is not fresh (PLAN.md CMD-8).
- The external-open mark lives ten seconds and is spent by the first insert of
  that address, so a link opened twice from another app routes twice only if
  macOS hands it over twice.
