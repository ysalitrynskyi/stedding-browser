# Feature: DRM notice

Status: **Dn1–Dn12 built.** BACKLOG S-421. The Windows half of Dn3 and Dn4 is written and has not been built or run.

Nothing protected by Widevine plays in Stedding yet (BACKLOG S-270), so Netflix and the like load and then fail. The owner decided on 2026-11-05: do not block these sites. A bar says why the video will not play and offers the page in a browser that can play it.

The code is `chrome/browser/ui/stedding/drm_notice.cc`: the table, the list of dismissed sites, the bar, and `DrmNoticeTabHelper`, which `TabFeatures` attaches to every tab. `drm_notice_browser_mac.mm` and `drm_notice_browser_win.cc` hold the other browser.

## Behaviours

| Id | Behaviour | Test | State |
|---|---|---|---|
| Dn1 | When a tab's main frame commits an http or https page on a listed site (Dn2), a bar says "This site uses DRM to protect its video, which Stedding can't play yet." The page keeps loading and stays usable: nothing is blocked, delayed or changed. In a normal window the bar is a pill under the page (toolbar T54). In a little window or a web app's window it is Chromium's band over the page. An error page shows no bar: the site did not answer, so its video is not the trouble. | browser: `DrmNoticeTest.AListedSiteShowsTheBarAndThePageLoads`, `DrmNoticeTest.AnErrorPageShowsNoBar` | built |
| Dn2 | The list is a `constexpr` table in `drm_notice.cc`. netflix.com, disneyplus.com, primevideo.com, hulu.com, max.com, hbomax.com, peacocktv.com, paramountplus.com, tv.apple.com and crunchyroll.com match with their subdomains, on a dot boundary: `www.netflix.com` matches and `notnetflix.com` does not. open.spotify.com matches by its exact host. Plain amazon.com, spotify.com, apple.com and youtube.com are not listed. Only http and https addresses match. | unit: `DrmSitesTest.TheListedSitesMatch`, `DrmSitesTest.ANameThatOnlyLooksListedDoesNot`, `DrmSitesTest.TheBroadSitesAreNotListed`, `DrmSitesTest.OnlyWebAddressesMatch`; browser: `DrmNoticeTest.AnOrdinarySiteShowsNoBar` | built |
| Dn3 | The bar has one button: "Open in Safari" on the Mac, "Open in Edge" on Windows. It opens the page the tab shows now, which may not be the page the bar came up on, in that browser. Safari is found by its bundle id and opened with `base::mac::LaunchApplication`, Chromium's call of `NSWorkspace openURLs:withApplicationAtURL:configuration:completionHandler:`. Edge gets `microsoft-edge:<address>` through `platform_util::OpenExternal`. Only an http or https address leaves. The bar closes, and the tab stays where it is. | browser: `DrmNoticeTest.TheButtonOpensTheCurrentAddressAndTheTabStays`, `DrmNoticeTest.TheButtonNamesThisComputersBrowser` | built |
| Dn4 | If that browser cannot be found, the bar shows with no button: its message, Dn6's link and the close box. On the Mac that means Launch Services knows no `com.apple.Safari`. On Windows it means the `microsoft-edge` protocol is not registered. | browser: `DrmNoticeTest.WithNoOtherBrowserTheBarHasNoButton` | built |
| Dn5 | The bar's close box hides it for this page. Nothing is remembered beyond Dn7's once. | browser: `DrmNoticeTest.CloseHidesTheBarForThisPage` | built |
| Dn6 | "Don't show again", a link on the bar, adds the site, as the table writes it, to `stedding.drm_notice.dismissed_sites`. The bar closes, along with that site's bar in the profile's other tabs, and no tab shows one for that site again. | unit: `DrmDismissedSitesTest.ASiteIsListedOnce`, `SteddingPrefsTest.EveryPreferenceRegistersWithItsDefault`; browser: `DrmNoticeTest.DontShowAgainRemembersTheSite` | built |
| Dn7 | Once per tab per site. The bar stays while the tab moves around the site, and leaves when the tab leaves the site. That tab does not show it for that site again, not after coming back, a reload, or the tab being put to sleep. Another listed site shows its own bar, and so does another tab on the same site. A restart forgets the once: it is not saved. | browser: `DrmNoticeTest.OncePerTabPerSite`, `DrmNoticeTest.AnotherTabOrSiteShowsItsOwnBar`, `DrmNoticeTest.ASleepingTabKeepsItsOnce` | built |
| Dn8 | Settings › Stedding › Pages and menus lists the dismissed sites, "Sites that don't show the DRM notice:" (settings T56), and each has a remove button. With none it says "No sites". That is how a user undoes Dn6: the next tab to open a removed site shows the bar. A tab that already showed it keeps Dn7's once. | browser: `DrmNoticeTest.SettingsListsAndRestoresADismissedSite` | built |
| Dn9 | The feature asks the network for nothing. The table is built in, no list is fetched, and nothing is counted or reported. The one thing that leaves Stedding is the address handed to the other browser when the user presses the button. | browser: `DrmNoticeTest.TheBarAsksTheNetworkForNothing` | built |
| Dn10 | Private and Guest windows show the bar, and the button works there: the press is the user's choice. "Don't show again" in such a window lasts as long as its off-the-record profile. It goes to that profile's preferences in memory, because a site name in the profile's file would be a record of the visit. A site dismissed in a normal window shows no bar in a private window. | browser: `DrmNoticeTest.APrivateWindowShowsTheBarAndForgetsItsAnswer` | built |
| Dn11 | A little window shows the bar, Chromium's band over the page, and a peek in a small window (peek P6) does too, being a little window with one tab. | browser: `DrmNoticeTest.ALittleWindowShowsTheBar`, `DrmNoticeTest.APeekInASmallWindowShowsTheBar` | built |
| Dn12 | A peek over the page (peek P20, the default) shows no bar. Its page is not a tab, and a window draws only its active tab's bars, so nothing could show it. Open as Tab makes the page a tab, and the bar shows then, with no new load. | browser: `DrmNoticeTest.APeekOverThePageHasNoBarUntilItIsATab` | built |

## Why a table

The table is chosen over Encrypted Media Extensions detection. Ad and fingerprinting scripts call `requestMediaKeySystemAccess` on ordinary pages, so detection would show the bar where nothing is wrong. The cost is that a service not listed shows no bar, and adding one takes a release.

## Keyboard

The bar has no chord of its own. It sits in the window's pane cycle (`BrowserView::GetAccessiblePanes`), so F6 reaches it and Tab moves through its controls, as with any Chromium bar. That comes from reading the code. It has not been pressed on a real build.

## Limits

- In a split, a tab's bar shows while that pane is the active one: a window draws its active tab's bars.
- In a narrow window the message is cut short before the button and the link are, as on any Chromium bar. At 760 DIP wide with the sidebar open it read "This si…".
- This feature goes when Widevine plays (BACKLOG S-270).
