# 0030 — Ad and tracker blocking on Chromium’s subresource filter, with lists fetched at run time

Status: Proposed. Phase 1 is in the product (patch 0098, `docs/features/blocker.md` Bk1–Bk13), released in 0.3.0 beta 16, off by default. The owner has not accepted this record (Bk0, `BACKLOG.md` `S-88`). On 2026-11-02 the owner asked for the switch to be offered in the welcome flow, with how it works and that an extension can block more; it stays off until the user chooses it there or in Settings (`docs/features/welcome.md` W19, `PLAN.md` decision 20).
Date: 2026-10-25

## Context

`BACKLOG.md` `S-88` asks for ad and tracker blocking built in, with a switch for each site. ADR 0021 requires an ADR before any of that code ships, with the filter lists fetched at run time and never built in. ADR 0017 makes privacy defaults preference defaults. `docs/PRIVACY.md` lists every connection the browser makes.

The lists are EasyList and EasyPrivacy, from `easylist.to`, each “GPL-3.0-or-later or CC BY-SA 3.0” (the strings in patch 0098). Chromium’s subresource filter (`components/subresource_filter`, BSD-3-Clause) is already in the binary. Its ruleset is a memory-mapped index shared by every renderer. `RulesetService::IndexAndStoreAndPublishRulesetIfNeeded` indexes an unindexed ruleset. The per-site switch is the `ADS` content setting.

## Options

**A. A separate Rust filter engine under MPL-2.0.** Fuller matching, including element hiding, scriptlets, `$redirect` and `$removeparam`. It means vendoring a crate, a C++ bridge, and checking every subresource in the browser or network process: engine work `docs/ARCHITECTURE.md` says to avoid, and an MPL obligation inside a BSD core.

**B. Chromium’s subresource filter, fed with EasyList and EasyPrivacy converted in the browser.** BSD code already in the binary. Matching runs in the renderer. The per-site switch already exists. Limits: one ruleset for the whole browser; no scriptlets, `$redirect` or `$removeparam`; rules with unknown options are skipped; element-hiding rules are dropped in this slice.

**C. Leave it to extensions.** No product code. It is not built in, and an extension brings Web Store traffic.

## Decision

B, as follows.

1. **Off by default.** One switch, `stedding.blocker.enabled`, in local state, off. Nothing is fetched, converted or filtered until the user turns it on in Settings › Stedding › Privacy. No filter list, and nothing derived from one, is in the binary or in this repository. The test lists are written for the tests.
2. **Lists fetched at run time.** While blocking is on, EasyList (`stedding.blocker.list.easylist`) and EasyPrivacy (`stedding.blocker.list.easyprivacy`) are on and are fetched from `https://easylist.to/easylist/` (`easylist.txt` and `easyprivacy.txt`). Each is fetched again when its own `! Expires:` line says, clamped to one to fourteen days, four when the line is missing. The request is conditional (If-None-Match, If-Modified-Since): no cookies, no cache, no query string, Chromium’s own user agent. A failed fetch is retried after an hour, then twice as long each time, up to the list’s expiry. The lists are kept in `<user data>/Stedding Blocker`, with a LICENSE file naming each list, its homepage and its licence.
3. **Converted in the browser.** On a background sequence, Chromium’s EasyList parser turns the lists into one unindexed ruleset of URL rules. Element-hiding rules are dropped in this slice (Bk3). Lines the parser cannot read are counted, not logged. A download that is not a filter list (no `[Adblock` header, or fewer than 1000 URL rules) is refused and the previous ruleset kept. The ruleset goes to `RulesetService`, with a content version made from the lists’ SHA-256 and a salt. A version the service never indexed is made again under a new salt.
4. **Google’s “Subresource Filter Rules” component is not registered.** The call in `chrome/browser/component_updater/registration.cc` is removed. A ruleset Google’s component installed in an earlier version stays published until Stedding’s first one is indexed: while blocking is off only Chromium’s ad-tagging dry run reads it, which blocks nothing; in the minutes between turning blocking on and the first lists arriving, pages are filtered by it. A fresh profile loads pages unfiltered until Stedding’s lists are indexed (Bk11).
5. **Stedding decides each page, while blocking is on.** `ContentSubresourceFilterThrottleManager` takes an embedder factory (`SetPageActivationThrottleFactory`). While that factory is set, Stedding’s throttle replaces the Safe Browsing one and reports through `SubresourceFilterObserverManager`: enabled where blocking applies (the switch, an http or https page, not a sign-in step, no exception for the site) or where DevTools forced it; otherwise the ad-tagging dry run. While blocking is off the factory is cleared and Chromium’s own path runs.
6. **Nothing is written for each site visited.** While the factory is set, the throttle manager shows no “ads blocked” icon and triggers no ads intervention, and Stedding’s throttle does not call `ProfileInteractionManager`, so no `ADS_DATA` is written. The only thing stored for a site is an exception the user made. Chromium’s heavy-ad intervention keeps its own list of hosts, cleared with browsing data.
7. **The per-site switch is the `ADS` content setting, user entries only.** ALLOW for the site’s registrable domain turns blocking off there, subdomains included. The content setting’s default is not read. A private window writes to its own session. The switch is a shield in the address row, a command bar row and a list in Settings. It is not in page info.

`components/` is not `net/` or `services/`, so ADR 0027’s list does not apply. The hunks outside Stedding’s own files are the factory and its guards in `components/subresource_filter/content/browser/content_subresource_filter_throttle_manager.{h,cc}`, the removed registration in `chrome/browser/component_updater/registration.cc`, the start beside the ruleset service in `chrome/browser/chrome_browser_main.cc`, the settings allowlist in `chrome/browser/extensions/api/settings_private/prefs_util.cc`, the shield in `chrome/browser/ui/views/toolbar/toolbar_view.cc`, and the settings handler in `chrome/browser/ui/webui/settings/settings_ui.cc`.

## Consequences

- `docs/PRIVACY.md` lists `easylist.to`, only while blocking is on, and Google’s ruleset component is not registered.
- Replacing the Safe Browsing activation while blocking is on drops Chromium’s phishing and “abusive site” activation lists, and the ads intervention, for those pages. Both are inert while Safe Browsing has no key (`docs/PRIVACY.md`). When `S-75` makes Safe Browsing work, Stedding’s decision is chained after the Safe Browsing throttle instead of replacing it.
- Rules with unknown options are skipped. A skipped `$badfilter` can leave active a rule the list meant to cancel. The parse rate, the indexed size, the indexing time and the cost per page are TBD until measured on the real lists.
- A new ruleset reaches pages loaded after it is published. Open pages keep the old one until they reload.
- Element hiding, a page for a blocked top-level load, optional lists and a count of blocked requests are Bk20–Bk23.
- A pin move re-applies the throttle-manager hunk. A conflict there is resolved by reading the upstream change first.
- Still the owner’s, before the default is turned on: whether fetching from `easylist.to`, with the attribution in the LICENSE file and in Settings, meets the lists’ licences; whether Chromium’s “Intrusive ads” page is relabelled, now that it lists Stedding’s exceptions; and this record as a whole.
