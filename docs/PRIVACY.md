# Privacy principles and defaults

Privacy in Stedding is a set of shipped defaults, not a mode you enable. This
document states the principles, then the concrete behavior — split into what ships
by default and what is available by choice. The implementation (which Google
services are removed or replaced in the Chromium base, and how) lives in
ARCHITECTURE.md under de-Googling; this document is the product contract that
implementation must satisfy.

Anything the shipping browser does on the network that is not listed here is a
bug. Report it through SECURITY.md.

## Principles

1. **No telemetry, ever, by default.** The browser sends no usage metrics, no
   analytics, no A/B experiment data, no unique identifiers. There is no
   "anonymized" or "aggregated" exception.
2. **Every network connection is enumerated.** A user must be able to read this
   document and know every host their browser talks to and why. The list is short:
   update checks (browser, components, Safe Browsing lists, installed extensions)
   and the user's own browsing — nothing else. The authoritative enumeration is
   the connections table below.
3. **Defaults are the product.** A privacy feature that must be discovered and
   enabled protects almost nobody. Protections ship on; conveniences that cost
   privacy ship off.
4. **Honesty over purity.** Where a real trade-off exists (Safe Browsing, extension
   stores), we document the trade-off and pick a defensible default rather than
   pretending the trade-off away.
5. **Verifiable.** The entire browser, UI included, is open source (BSD-3-Clause).
   Claims in this document can be checked against the code and on the wire.

## Network connections the browser makes

### Shipped by default

| Connection | To | Contains | Why |
|---|---|---|---|
| Browser update check | Stedding infrastructure | Version, platform, architecture. No unique ID, no cookies. | Security updates are non-negotiable for a Chromium fork. |
| Security component updates | Stedding infrastructure (mirrored) | Component name and version. | Chromium ships security-critical data as components (e.g. certificate revocation sets). We mirror the ones we keep; the exact list is documented in ARCHITECTURE.md before 1.0. Components fetched from Google by stock Chromium are proxied or removed. |
| Safe Browsing list updates | See Safe Browsing section | Hashed URL prefixes, not URLs. | Phishing/malware protection. |
| The user's own browsing | Sites the user visits | Whatever the user does. | This is a web browser. Includes the DNS, TLS (OCSP/CT), and favicon traffic that browsing implies. |
| Extension install/update | Chrome Web Store (Google) | Standard store traffic. | Only once the user installs an extension. See extension note below. |

### Never

- No telemetry or metrics endpoints.
- No first-run "ping" with an installation or user ID.
- No field-trial/experiment ("Finch") downloads.
- No new-tab-page network requests: the new tab page is fully local. No sponsored
  tiles, no news feed, no background promotions — not opt-out, but absent. This is
  permanent; see docs/decisions/ for the ADR when recorded.
- No search or URL-bar keystrokes sent anywhere until the user submits (search
  suggestions are off by default; see below).

## Concrete stances

### Crash reporting — opt-in only

Off by default. First run may offer it once, default unchecked, and never ask
again. When enabled, reports go to Stedding infrastructure (endpoint documented in
ARCHITECTURE.md; TBD until built), contain stack traces and version info, and are
scrubbed of URLs and form data to the extent Chromium's crash pipeline allows.
Disabling it is one switch in settings.

### Default search engine — chosen by the user

First run shows a search engine chooser. The list order is randomized, no engine
is preselected, and no engine has paid for placement — no search deal exists, and
if that ever changes it will be disclosed in this document and in release notes
before shipping. Until the user chooses, no search query leaves the machine.
Search suggestions (sending keystrokes to the chosen engine) are off by default
and can be enabled in settings.

### Safe Browsing — on by default, documented honestly

The trade-off: Safe Browsing protects against phishing and malware, but the
standard implementation checks URLs against Google-operated lists. The standard
(v4/"Update API") protocol downloads hashed prefix lists locally and only contacts
the server for hash-prefix matches — Google does not receive your browsing
history, but does receive occasional partial-hash queries and your IP.

Our stance:

- **Shipped by default:** standard, hash-prefix Safe Browsing, because shipping a
  browser to non-hypothetical users with phishing protection off is not a
  defensible default. Whether list traffic can be proxied through Stedding
  infrastructure so Google never sees user IPs is an open implementation question
  — tracked in ARCHITECTURE.md, TBD.
- **Available by choice:** turning it off entirely, one switch, clearly explained.
- **Never:** "Enhanced" Safe Browsing modes that send full URLs or page content in
  real time. Not shipped at all.

### Google account sync — not available

Google shut off access to its private Sync APIs for third-party Chromium builds in
2021; forks cannot offer Chrome sync legitimately, and we will not pretend
otherwise. Signing into Google *websites* works normally — this only concerns
browser-level account integration, which the de-Googling work removes
(ARCHITECTURE.md). A Stedding-run sync service (end-to-end encrypted, opt-in) is a
possible future milestone — see ROADMAP.md; TBD, no commitment here. Today:
import/export and profile migration are the supported paths.

### WebRTC IP handling

Chromium's default mDNS obfuscation of local IP addresses is kept, so sites using
WebRTC see mDNS hostnames rather than your LAN IPs, and calls still work (the
ready-to-use mandate applies to privacy features too). Shipped as a visible
setting, off by default: stricter policies for VPN users ("public interface only",
"disable non-proxied UDP") that prevent WebRTC from bypassing a VPN at the cost of
breaking some calls.

### Global Privacy Control — on by default

Stedding sends the GPC signal (`Sec-GPC` header and
`navigator.globalPrivacyControl`) by default. It is a legally meaningful opt-out
in several jurisdictions and costs users nothing. A settings switch can disable
it.

### Extensions — compatibility with a caveat

Full Chrome extension compatibility is a core feature, and it has privacy
consequences we will not hide:

- Installing and updating extensions talks to the Chrome Web Store, a Google
  service. That traffic exists only when you use extensions.
- Extensions are third-party code running with the permissions you grant. An
  extension can read and transmit anything its permissions allow, and Stedding
  does not audit, vet, or sandbox extensions beyond what Chromium provides.
  Review permissions before installing; prefer open-source extensions.
- Whether extension update traffic can be proxied through Stedding infrastructure
  is an open question — TBD in ARCHITECTURE.md.

## Summary: default vs. choice

| Behavior | Shipped by default | Available by choice |
|---|---|---|
| Telemetry / metrics | None (does not exist) | — |
| Crash reporting | Off | Opt in |
| Update checks | On (no identifiers) | — (required for a safe product) |
| Search engine | User chooses at first run | Change anytime |
| Search suggestions | Off | Opt in |
| Safe Browsing | On (hash-prefix only) | Turn off |
| Google sync | Not available | — |
| WebRTC local IPs | Hidden (mDNS) | Stricter VPN-safe policies |
| Global Privacy Control | On | Turn off |
| New-tab sponsored content | Never (no network on NTP) | — |
| Extensions | None installed | User installs; store traffic follows |

Changes to any default in this table require an ADR in docs/decisions/ and a
release-notes entry.

---

## The update check

Stedding checks for updates against the GitHub Releases API
(`decisions/0014-github-releases-as-update-channel.md`). This is the only endpoint
this project deliberately adds to Chromium, so it is described exactly.

| | |
|---|---|
| Endpoint | `https://api.github.com/repos/ysalitrynskyi/stedding-browser/releases/latest` |
| Sends | a plain HTTPS GET. No account, no install id, no machine id, no usage data, no query parameters. |
| Receives | the latest release tag, which is compared against the running version. |
| Frequency | at most once a day, and only while enabled. |
| Default | **off**, until it has a settings entry — `QUALITY.md` requires one before any feature ships. |

**What GitHub can see.** An IP address and a timing pattern. Over time that is
enough to infer roughly where an installation is and that it is still running.
That is a real cost and it is written here rather than hidden behind the phrase
"no telemetry", which would be technically true and misleading.

**What it is not.** It is not a check-in, a licence check, or an analytics event.
Nothing identifies the installation, and the response is the same for everybody.

**Why GitHub rather than our own server.** Running an update service means
running infrastructure that knows who is asking. The release artifacts already
live on GitHub, so the update metadata and the download are the same objects, and
there is no additional party — including us — learning anything. If GitHub ever
becomes unacceptable, the check is one URL to move.

**Turning it off.** The settings entry disables it completely; there is no
"reduced" mode that still calls home. A build with the check off makes no request
to GitHub at all.

## Implementation status against the current build

Everything above is a product commitment. This section says how much of it is *already
true* of the vanilla Chromium we build today, and what each remaining item actually
costs. It was produced by auditing the Chromium source at the pin, not from memory, and
every mechanism named below was located in the tree.

It exists because the two are easy to confuse. Building unbranded Chromium
(`is_chrome_branded=false`, no Google API keys) already removes a great deal — but it
removes far less than a reader of the Principles section would assume, and the gap is
the M1 work.

### Already true, because we build unbranded

Metrics and UMA/UKM reporting, crash upload to Google, RLZ, the variations/Finch seed
fetch, Google account sign-in and Sync, and the browser updater are all absent or
inert without Google branding and API keys. `enable_updater` is literally
`is_chrome_branded && …`, so no updater is even compiled.

### Still to do, with the mechanism

| Commitment | Costs |
|---|---|
| Search suggestions off until the user opts in | `search.suggest_enabled` defaults to **true**; flip the default |
| No Google New Tab Page network | `kNtpLogo`, `kNtpOneGoogleBar`, `kNtpMiddleSlotPromo` are enabled by default; disable or replace the NTP |
| Default search engine chosen by the user | interim: DuckDuckGo is the prepopulated default (patch 0003), which also keeps the new tab page local; the first-run chooser is `S-26` |
| Global Privacy Control on | currently off — `IsGlobalPrivacyControlEnabled()` is gated behind a Force/Test feature flag, and the pref path is an unfinished upstream TODO |
| Translate off by default | `translate.enabled` defaults to true |
| No navigation prediction / preconnect | `net.network_prediction_options` defaults to standard preloading |
| Network time queries off | enabled by default on desktop, and not gated on branding |
| Component updates from our infrastructure | component updater is on by default; needs an endpoint swap and a component allowlist |
| No dummy API keys in request URLs | the placeholder key is still appended to some Google requests |

### What a fresh profile at rest actually contacts today

This is the list the M1 network capture is checked against, and the reason that
criterion is worth having. On an idle, freshly-created profile, an unbranded build
still reaches out for: **component updater checks** (first at about one minute, then
roughly every five hours, including the certificate CRLSet), **Safe Browsing list
updates**, and **network time**. Opening the New Tab Page adds Google requests for the
logo and the One Google Bar.

Nothing here is telemetry. But "no telemetry" and "contacts nothing" are different
claims, and only the first one is currently true — which is exactly why
`docs/QUALITY.md` makes an unexplained endpoint a release blocker rather than trusting
the intent in this document.
