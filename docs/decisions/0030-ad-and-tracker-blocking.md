# 0030 — Ad and tracker blocking on Chromium’s subresource filter, with lists fetched at run time

Status: Proposed. Phase 1 is in the product (patch 0098, `docs/features/blocker.md` Bk1–Bk13), released in 0.3.0 beta 16, off by default. The owner has not accepted this record (Bk0, `BACKLOG.md` `S-88`). On 2026-11-02 the owner asked for the switch to be offered in the welcome flow, with how it works and that an extension can block more; it stays off until the user chooses it there or in Settings (`docs/features/welcome.md` W19, `PLAN.md` decision 20).
Date: 2026-10-25

## Context

`BACKLOG.md` `S-88` asks for ad and tracker blocking built in, with a switch for each site. ADR 0021 requires an ADR before any of that code ships, with the filter lists fetched at run time and never built in. ADR 0017 makes privacy defaults preference defaults. `docs/PRIVACY.md` lists every connection the browser makes.

The lists are EasyList and EasyPrivacy, from `easylist.to`, each “GPL-3.0-or-later or CC BY-SA 3.0”. Chromium’s subresource filter (`components/subresource_filter`, BSD-3-Clause) is already in the binary: a memory-mapped ruleset shared by every renderer, indexed by `RulesetService`, with the `ADS` content setting as its per-site switch.

## Options

- **A. A separate Rust filter engine under MPL-2.0.** Fuller matching (element hiding, scriptlets, `$redirect`, `$removeparam`), but a vendored crate, a C++ bridge, a check of every subresource in the browser or network process, and an MPL obligation inside a BSD core.
- **B. Chromium’s subresource filter, fed with the lists converted in the browser.** BSD code already in the binary; matching runs in the renderer; the per-site switch exists. Limits: one ruleset for the whole browser; no scriptlets, `$redirect` or `$removeparam`; rules with unknown options skipped; element hiding dropped in this slice.
- **C. Leave it to extensions.** Not built in, and an extension brings Web Store traffic.

## Decision

B, as follows.

1. **Off by default.** One switch, `stedding.blocker.enabled`, in local state. Nothing is fetched, converted or filtered until the user turns it on. No filter list, or anything derived from one, is in the binary or this repository.
2. **Lists fetched at run time.** While blocking is on, EasyList and EasyPrivacy are fetched from `https://easylist.to/easylist/`, again when each list’s `! Expires:` line says (clamped to one to fourteen days, four when missing). The request is conditional, with no cookies, no cache, no query string and Chromium’s own user agent; a failure backs off from an hour up to the list’s expiry. The lists are kept in `<user data>/Stedding Blocker` with a LICENSE file naming each list and its licence.
3. **Converted in the browser,** on a background sequence, by Chromium’s EasyList parser into one unindexed ruleset of URL rules. A download that is not a filter list is refused and the previous ruleset kept. The ruleset goes to `RulesetService` under a content version from the lists’ SHA-256.
4. **Google’s “Subresource Filter Rules” component is not registered.** A ruleset it installed earlier stays published until Stedding’s first one is indexed; while blocking is off only Chromium’s ad-tagging dry run reads it, which blocks nothing, and between turning blocking on and the first lists arriving, pages are filtered by it. A fresh profile loads pages unfiltered until Stedding’s lists are indexed (Bk11).
5. **Stedding decides each page while blocking is on.** An embedder factory on `ContentSubresourceFilterThrottleManager` replaces the Safe Browsing throttle with Stedding’s: enabled for an http or https page that is not a sign-in step and has no exception, otherwise the dry run. While blocking is off the factory is cleared and Chromium’s own path runs.
6. **Nothing is written for each site visited.** No “ads blocked” icon, no ads intervention, no `ADS_DATA`. The only thing stored for a site is an exception the user made.
7. **The per-site switch is the `ADS` content setting, user entries only,** for the site’s registrable domain, subdomains included: a shield in the address row, a command bar row and a list in Settings.

`components/` is not `net/` or `services/`, so ADR 0027’s list does not apply. The hunks outside Stedding’s own files are the throttle manager’s factory, the removed component registration, the start beside the ruleset service, the settings allowlist, the shield in the toolbar and the settings handler.

## Consequences

- `docs/PRIVACY.md` lists `easylist.to`, only while blocking is on, and Google’s ruleset component is not registered.
- While blocking is on, Chromium’s phishing and “abusive site” activation lists and the ads intervention are dropped for those pages; both are inert while Safe Browsing has no key. When `S-75` makes Safe Browsing work, Stedding’s decision is chained after its throttle instead.
- A skipped `$badfilter` can leave active a rule the list meant to cancel. Parse rate, index size, indexing time and cost per page are TBD until measured.
- A new ruleset reaches pages loaded after it is published.
- Element hiding, a page for a blocked top-level load, optional lists and a count are Bk20–Bk23.
- A pin move re-applies the throttle-manager hunk; a conflict is resolved by reading the upstream change first.
- Still the owner’s, before the default is turned on: whether fetching from `easylist.to`, with the attribution, meets the lists’ licences; whether Chromium’s “Intrusive ads” page is relabelled; and this record as a whole.
