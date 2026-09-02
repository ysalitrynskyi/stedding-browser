# Feature: Peek

Status: **P1–P7, P10 built and tested**; P8–P9 are gaps (`S-34`, `S-35`).
Owner docs: `docs/PRODUCT.md` ("Peek": what makes pinned tabs behave like apps). Patch: `0009`.

A link from a pinned tab that would leave the pinned site opens in a peek: a page over the
window, not a tab. Escape or a click outside dismisses it; ⌘O (or the button) promotes it to a
real tab, moving the same page into the strip so nothing reloads. "Pinned" means either tier:
Chromium-pinned (the essentials row) or pinned within a Space.

The decision is a navigation throttle (`PeekNavigationThrottle`, registered from Chromium's
throttle list for renderer-initiated main-frame navigations in pinned tabs). The overlay is
`PeekView`, a layered child of the browser view like the command bar; it owns its WebContents
and hands it to the tab strip on promotion.

## Behaviours

| Id | Behaviour | Test | State |
|---|---|---|---|
| P1 | A link click from a pinned tab to a different site (eTLD+1) opens a peek instead of navigating the tab. | `ShouldPeekTest.LinkToAnotherSiteFromAPinnedTab`; live: `tooling/drive` pins a page with a cross-site link, clicks it, the peek appears and the tab's URL is unchanged | built |
| P2 | Links that stay on the pinned site (other paths, subdomains, http→https) navigate the tab as always. | `ShouldPeekTest.StayingOnTheSiteNavigatesTheTab`, `PeekThrottleTest.PinnedTabStaysOnItsSite` | built |
| P3 | Unpinned tabs are never throttled; the throttle is not even registered for them. | `ShouldPeekTest.UnpinnedTabsFollowLinks`, `PeekThrottleTest.UnpinnedTabIsNotThrottled` | built |
| P4 | Typed URLs, script redirects (sign-in bounces) and form posts navigate the pinned tab; only a user's link click peeks. | `ShouldPeekTest.TypedUrlsScriptRedirectsAndPostsNavigateTheTab`, `PeekThrottleTest.ScriptRedirectFromPinnedTabProceeds` | built |
| P5 | Only http(s) pages peek; chrome://, file: and blank pages never do. | `ShouldPeekTest.OnlyHttpPagesPeek` | built |
| P6 | A peek owns a page of its own at the link's URL; the window's tabs are untouched while it is open. | `PeekViewTest.PeekLoadsItsOwnPage` | built |
| P7 | Promoting (⌘O, the button) moves the very same page into a new active tab and closes the peek. | `PeekViewTest.PromotingMovesThePageIntoANewActiveTab`; live: ⌘O in the peek | built |
| P8 | Links from a pinned tab that open a new tab (`target=_blank`, ⌘-click) also peek, as in Arc. | none yet | gap |
| P9 | A peek can be promoted into a split instead of a tab (needs split view, ROADMAP M5). | none yet | gap |
| P10 | The chrome://settings "Stedding" switch turns Peek off; pinned tabs then follow links like any other. | `ShouldPeekTest.SettingOffFollowsLinks`; settings T3 | built |
