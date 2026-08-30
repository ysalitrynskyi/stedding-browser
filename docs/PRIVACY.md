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
