# Feature: Independent Space sessions

Status: **S1–S13, S17, S19 built** (with the open findings in PLAN.md); **S16 partial, model only**; **S14, S15, S18 withdrawn**; S24, S25 planned, written, not yet run (ADR 0019). Patches: 0046 (S1–S12), 0047 (S13–S17), the 2026-09-18 audit (S18–S19).
Owner docs: `docs/decisions/0019-space-sessions-are-storage-partitions.md`,
`docs/PRODUCT.md` §2, `docs/features/spaces.md`, `docs/features/windows.md` G5.

A Space can keep its own cookies, HTTP cache and site storage so the same site
can be signed into with different credentials in different Spaces of one window.
Off by default. Extensions, settings, history and saved passwords stay on the
profile.

This file is the definition of done. A behaviour is shipped when its test id is
green.

## What isolation is

Chromium already shards cookies, cache, localStorage, IndexedDB and service
workers by `StoragePartition`. An isolated Space's tabs are created in a
non-default partition named by that Space's `profile_id`. A Space with an empty
`profile_id` uses the profile's default partition, which is what every Space
does today.

Isolation is a property of the Space at tab creation. `window.open` inherits
the opener's partition. Essentials are in every Space (spaces B6) and stay on
the default partition.

## Behaviours

| Id | Behaviour | Test | State |
|---|---|---|---|
| S1 | A new Space has an empty `profile_id`. Its tabs use the default storage partition. | `SpaceRegistryTest.RoundTrip` (empty `profile_id`, G5); `SpaceWindowTest.SharedSpaceStaysOnDefaultPartition` | built |
| S2 | Turning isolation on writes a non-empty `profile_id` (a random token) and sets the `isolated` flag; both survive the registry round trip. Turning it on again when a token is already set leaves that token, so the Space reattaches the jar it had. | `SpaceRegistryTest.IsolatedProfileIdRoundTrips` | built |
| S3 | Two isolated Spaces get different `profile_id`s. | `SpaceRegistryTest.TwoIsolatedSpacesGetDifferentIds` | built |
| S4 | A tab opened while an isolated Space is active is created in that Space's storage partition (`partition_domain` `spaces`, `partition_name` the `profile_id`, on disk). | `SpaceWindowTest.IsolatedSpaceTabUsesItsPartition` | built |
| S5 | A tab opened in a shared Space uses the default partition even when another Space in the same window is isolated. | `SpaceWindowTest.SharedSpaceStaysOnDefaultPartition` | built |
| S6 | Two tabs of the same http(s) site in two isolated Spaces have different storage partitions, so they do not share cookies. | `SpaceWindowTest.TwoIsolatedSpacesDoNotShareAPartition` | built |
| S7 | Turning isolation off clears the `isolated` flag and keeps `profile_id`: a tab opened after that uses the default partition, and turning it on again reattaches the same jar with its logins. The on-disk jar stays until Clear Independent Session (S13) or the Space's deletion (S17). | `SpaceWindowTest.TurningIsolationOffUsesTheDefaultPartition`; `SpaceWindowTest.TurningIsolationOffKeepsTheJarForNextTime` | built |
| S8 | An essentials (Chromium-pinned) tab always uses the default partition, including when the active Space is isolated. | `SpaceWindowTest.EssentialTabStaysOnTheDefaultPartition` | built |
| S9 | Moving a tab into or out of an isolated Space rebinds it to the destination jar: its history travels as session restore carries it (serialized entries, nothing of the old jar), a sleeping tab stays asleep and keeps its title, an awake one reloads, and the user's name for the tab comes along. | `SpaceWindowTest.MovingATabIntoAnIsolatedSpaceRebindsIt`; `SpaceWindowTest.RebindKeepsASleepingTabAsleepWithItsHistory` | built |
| S10 | Isolation is a Space menu check item ("Independent session"), a toggle on each Space in chrome://settings/stedding, and an Independent Session row in the command bar. Off by default. Turning it on or off asks first when open pages of the Space would reload, and says how many (new-tab pages and the browser's own pages are not counted); with none, it applies at once (PLAN.md SPC-9). | `CommandBarViewTest.ActionRowsListSpacesAndCaptures`; browser: `SpaceJarTest.TheIsolationQuestionCountsOpenPages`; live: the Space menu, the command bar and the settings toggle ask | partial · the count is tested; the three questions (menu, command bar, settings) are not yet seen on a build |
| S11 | A page a tab opens lands in that tab's jar. `window.open` with an opener reuses the opener's `SiteInstance`. A page opened without an opener -- a target=_blank link, a noopener popup -- which content makes in the profile's jar, is made again in its Space's jar before it loads anything, and goes where a route names; a popup window, which has no Spaces, keeps what it opens in its opener's jar (PLAN.md SPC-12). | `SpaceWindowTest.WindowOpenFromIsolatedTabKeepsThePartition`; browser: `SpaceJarTest.ABlankTargetLinkKeepsItsSpacesJar`, `SpaceJarTest.ANoopenerPopupKeepsItsSpacesJar` | built |
| S12 | A restored tab in an isolated Space is created in that Space's partition, not the default. | `SpaceWindowTest.RestoredTabInIsolatedSpaceUsesItsPartition`; browser: `RestoreTest.TheSidebarComesBack` and its three `PRE_` steps (PLAN.md TST-4) (the isolated Space's pin reads its jar's cookie after the restart) | built |
| S13 | **Clear Independent Session** on the Space chip menu (enabled only on an isolated Space) wipes that partition's site data and its HTTP cache and keeps the Space and its `profile_id`. Tabs in the Space reload in the empty jar, in every window that shows the Space. Shared Spaces have no wipe. | `SpaceWindowTest.WipeIsolatedSessionKeepsTheSpaceAndTheId`; `SpaceStoragePartitionTest.WipeSharedSpaceIsNoOp`; browser: `SpaceJarTest.ClearingTheSessionReloadsEveryWindow`; live: the chip menu | built |
| S14 | Copying a tab into an isolated Space inserts a new tab in the destination jar. The source tab, its URL and its partition are unchanged. Essentials are refused. | none | withdrawn · Copy Tab to Space was cut in patch 0055 (owner decision, 2026-09-26) |
| S15 | Opening a URL signed-out is S14 into a new or existing isolated Space. The user clicks; there is no headless twin. | none | withdrawn · with S14 |
| S16 | Isolated chrome is a mark: `IsolationMarkForSpace` is "Independent session" iff the Space is isolated, empty otherwise. Shared Spaces show nothing. | `SpaceStoragePartitionTest.IsolationMarkFollowsProfileId` | partial · model only, nothing paints the mark yet; the chip menu's check item is the one visible sign |
| S17 | Deleting an isolated Space wipes its partition once, from the window that deleted it, after every window has moved its tabs out (the rebinds are posted, so the wipe is posted behind them). The wipe clears site data with storage cleanup and the HTTP cache, and reports done when both have finished. | `SpaceWindowTest.DeletingAnIsolatedSpaceWipesItsPartition` | built |
| S18 | A Blank Window's Spaces could have their own jars. They cannot: a Blank Window has no Space registry, so turning isolation on for one of its Spaces does nothing (PLAN.md SPC-32). | none | withdrawn · in-memory isolation was cut in patch 0055; the toggle still shows there (SPC-32) |
| S19 | A registry written before the `isolated` flag existed (beta 7) reads a Space with a token as isolated, so an update loses nobody's jar. | `SpaceRegistryTest.OldRegistryTokenMeansIsolated` | built |
| S20 | A Space's jar holds the web (http, https, file, data, about:blank). The browser's own pages -- settings, extension pages, DevTools, the welcome page and the new tab page -- keep the profile's jar in every Space, so opening them in an isolated Space splits no extension storage, and a jar change never moves or reloads them. The first web page a tab leaves one of them for -- a typed address, a link, a most-visited tile -- is made in its Space's jar (PLAN.md SPC-9, SPC-12). | `SpaceStoragePartitionTest.OnlyTheWebLivesInASpacesJar`; browser: `SpaceJarTest.ANewTabInAnIsolatedSpaceShowsTheNewTabPage`, `SpaceJarTest.AnAddressTypedInTheNewTabPageUsesTheJar`, `SpaceJarTest.ALinkFromTheNewTabPageUsesTheJar`, `SpaceJarTest.TheWebFromSettingsInASpaceUsesItsJar` | built |
| S21 | A jar change moves the Space's tabs off screen asleep: they load in the new jar when the user comes to them, so turning isolation on or off reloads only the page on screen. A page holding changes the user has not saved -- it could ask "Leave site?", or has form input -- is not reloaded under them, on screen or off: it keeps its jar until it is left, and its next navigation (a link, a reload, a typed address, a step back) runs in the new jar, after the page's own "Leave site?". A form such a page sends goes in the session it was filled in, and the tab moves at the navigation after it; a download link from it moves the tab too, and the page reloads in the new jar (PLAN.md SPC-9). | `SpaceWindowTest.RebindKeepsASleepingTabAsleepWithItsHistory`; browser: `SpaceJarTest.APageWithChangesKeepsItsJarUntilLeft`, `SpaceJarTest.AnEssentialWithChangesKeepsItsJarUntilLeft`, `SpaceJarTest.TurningIsolationOffKeepsAPageWithChanges`, `SpaceJarTest.AFormFromAPageWithChangesUsesItsSession`, `SpaceJarTest.APageWithoutChangesMovesAtOnce` | built |
| S22 | Isolation turned on or off, and Clear Independent Session, apply in every window: each window rebinds its tabs of that Space and shows the mark, and each window reloads its tabs of a Space whose jar was cleared (PLAN.md SPC-13). | `SpaceWindowTest.IsolationReachesEveryWindow`; browser: `SpaceJarTest.IsolationChangesReachEveryWindow`, `SpaceJarTest.ClearingTheSessionReloadsEveryWindow` | built |
| S23 | A tab whose contents are replaced -- on the desktop a sleep swaps in new contents, and so does a jar rebind -- keeps its name, has its Space's session keys written for the new contents, and returns to its Space's jar (a discard makes the new contents in the profile's jar) (PLAN.md SPC-8, TAB-15). | `SpaceWindowTest.ReplacedContentsKeepTheNameAndTheJar`; browser: `RestoreTest.TheSidebarComesBack` (a named tab asleep), `RestoreTest.ANameSurvivesASleepAndAWake`, `SpaceJarTest.ASleptTabWakesInItsJarSignedIn` (asleep and awake in Work's jar, still signed in), `RestoreTest.ReplacedContentsAreWrittenAgain` (a named Space pin slept through Chromium's own `TabLifecycleUnitExternal::DiscardTab` and a tab rebound by turning on the Space's session: the session file a restart reads holds the Space, pin, home and name of the one and the Space of the other; without the re-write it holds none of them) | built |
| S24 | Delete browsing data reaches every Space's jar. A removal that names no storage partition -- Settings' dialog, `chrome.browsingData`, deleting a site's data -- is made again for each Space the registry gives a jar, whether its isolation is on now or off: the same time range, the part of the mask that lives on a partition (cookies, cache, site storage), and the caller's own origin filter. A removal aimed at one partition stays there, and a private profile has no Space jars (PLAN.md SPC-11). | `SpaceJarChromeBrowsingDataRemoverDelegateTest.RemovalReachesEverySpaceJar`, `SpaceJarChromeBrowsingDataRemoverDelegateTest.RemovalThatNamesAPartitionOrNothingOnOneStaysPut`, `SpaceJarChromeBrowsingDataRemoverDelegateTest.UnfilteredRemovalEmptiesTheSpaceJar`, `SpaceJarChromeBrowsingDataRemoverDelegateTest.FilteredRemovalKeepsWhatTheFilterSpares`; `SpacePartitionsTest.RegistryNamesEveryJar` ; browser: `SpaceJarTest.DeletingBrowsingDataReachesSpaceJars` (an unfiltered removal, then a reload of Work's signed-in tab), `SpaceJarTest.SettingsDeleteBrowsingDataSignsWorkOut` (Settings' own message, "All time", cookies and other site data) | built |
| S25 | Chromium's storage-partition garbage collection, which an extension or app uninstall schedules for the next start, keeps every Space's jar: `Storage/ext/spaces` is on its allowlist, so a Space with no tab open keeps its cookies (PLAN.md SPC-10). | `SpaceJarChromeBrowsingDataRemoverDelegateTest.EverySpaceJarIsInsideOneDirectory`; browser: `SpaceJarRestartTest.ASpacesJarOutlivesTheCollection` (a Space with its own jar, a cookie in it and no tab open, then a start that collects: the directory and the cookie are still there); upstream's own case in browser_tests (garbage_collect_storage_partitions_command_browsertest.cc) is in no leg | built |
| S26 | A tab's Space, and so its jar, is chosen before its contents exist: the Space a route names, else the Space of the tab it came from, else the window's active Space; an essential is made on the shared jar. The first request of a routed link, of a Shift-click from a Space with its own session (the new window shows that Space) and of a routed address typed into a fresh tab carries that Space's cookies (PLAN.md SPC-12, CMD-8). | `SpaceWindowTest.ARoutedTabIsMadeInItsSpacesJar`; browser: `SpaceJarTest.ARoutedLinkCarriesItsSpacesCookies`, `SpaceJarTest.ATypedRoutedAddressLoadsInItsSpacesJar`, `SpaceJarTest.ANewWindowFromASpaceShowsThatSpace` | built |

"built" means the test exists in the series and passes on the pinned tree. "gap"
is a behaviour we ship without a test — each one is a backlog follow-up. "partial
· model only" means the helper exists and its unit test is green, but no menu,
key or setting reaches it: the row is not shipped to a user until it says built
(`docs/HANDOFF.md`, trap 46).

## Out of scope here

A Chromium Profile per Space (separate extensions, history, prefs). Cookie-only
swapping. Binding two Spaces to one jar. Extension `chrome.cookies` seeing
isolated jars. Per-Space proxies or fingerprints. A persistent intern or model
that holds a Space's cookies (ADR 0020). Temporary in-memory jars are
`docs/features/throwaway.md`.

## Running the tests

```bash
tooling/dev test sessions
tooling/dev test spaces
tooling/dev test windows
```
