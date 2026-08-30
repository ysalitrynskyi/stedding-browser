# Architecture

Engineering strategy for Stedding Browser. Companion docs: `PRODUCT.md` (what we
build), `PRIVACY.md` (defaults and de-Googling policy), `ROADMAP.md` (when),
`decisions/` (ADRs for anything hard to reverse).

## Fork strategy: minimal patch series on Chromium stable

We are not a hard fork. We track the Chromium **stable channel** and carry a small,
ordered, documented patch series on top of it — the Brave/Helium model. The measure of
success is boring rebases: when upstream ships a new stable, our patches apply with
little or no manual work.

### Repository layout (planned; docs/ is all that exists pre-M0)

```
patches/          Ordered patch series: NNNN-short-slug.patch
branding/         Icons, names, strings, installer assets that replace Chromium's
tooling/          Scripts: fetch/sync wrappers, apply-patches, update-patches, build
docs/             This documentation
```

The Chromium source tree itself is never committed here. A pinned upstream version
(exact commit/tag, recorded in a single versions file under `tooling/`) is fetched at
build time. The pin is updated deliberately, never implicitly.

### Patch discipline

- **One logical change per patch.** A patch does one thing: adds one flag, reroutes one
  service, brands one surface. Never a grab-bag.
- **Every patch carries a header**: what it does, why it exists, which upstream files
  it touches, and what would let us delete it (e.g. an upstream flag landing).
- **Script-driven, not manual.** `tooling/apply-patches` applies the series onto a
  clean checkout at the pinned version; `tooling/update-patches` regenerates the series
  from a working branch after a rebase. Applying patches by hand is a bug in the tooling.
- **Ordered and numbered.** Renumbering is allowed; silent reordering is not. The
  series must always apply cleanly from 0001 upward on the pinned version.

### Where patches are allowed to live

Preferred layers, in order:

1. **New files** — new features go in new directories/files wherever possible; new
   files never conflict on rebase.
2. **`chrome/browser/ui` and top chrome** (Views, browser frame, tab strip area) —
   this is where the sidebar, split view, and command bar live.
3. **WebUI** (settings pages, internal pages) — HTML/TS surfaces are cheap to extend.
4. **Feature flags and build-time gn args** — prefer flipping an existing switch over
   patching the code behind it.
5. **`chrome/browser` service wiring** — for disabling or rerouting Google services.

Avoid patching if at all possible: `content/`, `third_party/blink/`, `net/`, `v8/`,
and anything else deep in the engine. These are security-critical, churn constantly,
and conflicts there are expensive. A product feature that seems to require an engine
patch should first be redesigned to not require one; if it truly does, that is an ADR.

## Build system

Chromium builds with Google's standard toolchain: `depot_tools` (which supplies
`gclient`, `gn`, `autoninja`, and a pinned Python), a `gclient sync` to materialise the
source and its dependencies, `gn gen` with our args, and `autoninja` to build. Google's
remote execution backends (RBE/reclient) are not available to us, so every build is
local; `use_remoteexec = false` is set in all of our gn args files.

Everything below is driven by scripts in `tooling/`, so that the documented procedure
and the executed procedure cannot drift apart. Running the commands by hand is a
supported fallback, not the normal path.

### Layout

The Chromium tree lives **outside** this repository and is never committed here.

| Path | Default | Override |
|---|---|---|
| This repository | wherever you cloned it | `$STEDDING_ROOT` |
| depot_tools | `~/depot_tools` | `$DEPOT_TOOLS_DIR` |
| gclient checkout root | `~/chromium` | `$CHROMIUM_ROOT` |
| Chromium source | `~/chromium/src` | `$CHROMIUM_SRC` |

### The pinned version

`tooling/chromium-version` is the single source of truth for what upstream version we
build. It is read by every script. A version number written anywhere else is a bug.
Policy for moving the pin: `decisions/0007-chromium-version-pin.md`.

### Prerequisites (macOS arm64)

- **Full Xcode** — not just the Command Line Tools. `xcode-select -p` must point inside
  `Xcode.app`; the licence must be accepted (`sudo xcodebuild -license accept`).
- **Command Line Tools** installed alongside it.
- **Python 3** and **git** on `PATH` (depot_tools brings its own copies of both for the
  build itself, but the bootstrap needs a system pair).
- **Disk:** `tooling/sync-chromium` refuses to start below 150 GB free on the volume
  holding `$CHROMIUM_ROOT`. Measured usage: TBD at M0 completion.
- **RAM:** 16 GB is the practical floor; linking is the memory-hungry step.

`tooling/bootstrap-depot-tools` checks all of the above and fails with the exact
remedy rather than a build error hours later.

### Reference hardware

Measurements in this document were taken on:

| | |
|---|---|
| Machine | Apple M1 Max, 10 cores, 64 GB RAM |
| OS | macOS 26.5.2, arm64 |
| Xcode | 26.5 (17F42) |
| Command Line Tools | 26.6.0.0.1781586589 |
| depot_tools | `f70835271105ca56d2cd5382a0118152bc2bdeea` (2026-08-27) |
| Chromium | `153.0.8010.12` (M153 stable) |

### The build, end to end

```bash
# 1. Install depot_tools and verify the host toolchain. Idempotent.
tooling/bootstrap-depot-tools

# 2. Check out Chromium at the pinned version and resolve its dependencies.
#    Long: downloads tens of GB. Safe to re-run; moves an existing tree to the pin.
tooling/sync-chromium

# 3. Build. Config is one of release (default), debug, official.
tooling/build-chromium release

# 4. Run it.
open ~/chromium/out/release/Chromium.app
```

`tooling/build-chromium` copies `tooling/args/<config>.gn` verbatim into the output
directory as `args.gn`, so the configuration of any build is recoverable from the build
itself. It also refuses to build a tree that is not sitting on the pin — a binary whose
provenance is unclear is worse than no binary.

### Build configurations

| Config | Purpose | Notes |
|---|---|---|
| `release` | Day-to-day development | Optimised, no symbols, single binary. **Never quote performance numbers from this config.** |
| `debug` | Debugging Chromium and our patches | Component build: one target relinks a small library, not the browser. |
| `official` | Anything a user or benchmark sees | `is_official_build` — PGO with upstream's profile for the pin, plus ThinLTO. Slow, memory-hungry link. |

The full args, with the reasoning for each, are in `tooling/args/`.

`autoninja` selects Chromium's build executor. Which one it resolves to on this
configuration, and whether `cc_wrapper=ccache` measurably helps on macOS, is recorded
below once measured.

### Codecs

The M0 build is vanilla: upstream defaults, which means `ffmpeg_branding = "Chromium"`
and no proprietary codecs. Video plays via VP8/VP9/AV1/Opus, so WebM and YouTube work,
but H.264 and AAC do not. Shipping a browser without H.264 is not viable for a real
product, and enabling it carries patent-licensing consequences rather than merely
technical ones. That decision is deliberately not made here — it belongs to M1, with
an ADR, and it needs a human to weigh the licensing position.

### Measured results

Filled in when M0 completes. Nothing here is an estimate.

| | |
|---|---|
| `gclient sync` wall time | TBD |
| Checkout size after sync | TBD |
| `gn gen` wall time | TBD |
| First `release` build wall time | TBD |
| `out/release` size | TBD |
| `Chromium.app` size | TBD |
| Incremental build, one `.cc` touched | TBD |
| First `official` build wall time | TBD |
| Peak disk during a release build | TBD |

### Known failure modes

Recorded as they are actually hit, not imagined.

- **`gclient` appears to hang for minutes with no output on a fresh machine.** It is
  bootstrapping `cipd` and `vpython`, which download a Python distribution and wheels
  before any Chromium code is fetched. First run only.
- **`cipd` retries with `dial tcp [2607:f8b0:...]:443: connect: bad file descriptor`
  or `i/o timeout`.** Google's infrastructure advertises AAAA records; on a host with
  degraded IPv6 reachability the client burns through a 1s→2s→4s→8s→16s backoff before
  falling back to IPv4. It does succeed. Observed on the reference machine; it makes
  the first sync noticeably slower and looks exactly like a hang.

## De-Googling stance

Policy lives in `PRIVACY.md`; this section covers the mechanics and the honest
tradeoffs. The principle: **no request leaves the machine to Google (or anyone) unless
the user asked for something that requires it** — but we do not sacrifice safety
features that users expect from a real product just to make a purity claim.

- **Google API keys: not shipped.** Consequence: Google account sign-in, Chrome Sync,
  and Google geolocation are absent. Chrome Sync against Google servers is not our
  product anyway; a future sync story is its own project.
- **Telemetry, crash reporting to Google, field trials (Finch), RLZ, promo/brand
  pings: removed or disabled.** Features are controlled by build flags and our own
  defaults, never by server-side experiments. Opt-in crash reporting to *our*
  infrastructure may come later (per `PRIVACY.md`).
- **Safe Browsing: kept, hash-prefix variant.** Dropping it silently makes users
  less safe; keeping Google's real-time endpoints leaks browsing signals. The
  decision is recorded in `PRIVACY.md`: standard hash-prefix Safe Browsing on by
  default, real-time "Enhanced" modes never shipped.
- **Component updater: kept, pointed at infrastructure we control where feasible.**
  Some components matter for security and site compatibility (certificate revocation
  lists, Widevine for DRM playback). Each shipped component is enumerated in
  `PRIVACY.md` with its endpoint.
- **Default search, suggestions, spellcheck, translate, DNS/preconnect defaults:**
  privacy-preserving defaults per `PRIVACY.md`; nothing phones home out of the box.

Ungoogled-Chromium is prior art we learn from, but our bar is different: it optimizes
for maximal removal and accepts breakage; we optimize for a polished product with
honest, documented network behavior.

## Branding

Chromium branding is scattered but well-known: `chrome/app/theme/` (icons, logos),
grit/grd string resources (product name strings), `chrome/installer/` and macOS bundle
metadata (bundle id, app name), plus the user agent and version strings. We build with
Chromium (not Chrome) branding, then apply ours on top.

Approach, patch-light in this order: build-time **asset replacement** from `branding/`
(a script copies our icons/strings over the checkout before `gn gen` — zero patches),
then **gn args** where upstream exposes branding knobs, and only last actual patches
for names baked into code. Renaming every internal occurrence of "Chromium" is
explicitly a non-goal; user-visible surfaces (app name, menus, About, installer,
settings) are the bar. The user agent stays Chrome-compatible per site-compat norms —
we do not advertise a novel UA token by default.

## Updates and distribution

macOS distribution for real users requires an Apple Developer ID, **code signing, and
notarization** — without them, Gatekeeper blocks the app. Per `ROADMAP.md`,
signing/notarization lands at M7. Builds before that — including M2, the first public
pre-alpha — ship unsigned, with the Gatekeeper bypass documented alongside each
release.

Auto-update engine is an **open decision needing an ADR** before the first
auto-updating release (M7): **Sparkle** (standard, well-understood on macOS, appcast + EdDSA signatures)
vs **Chromium's own open-source updater** (`chrome/updater`, cross-platform, heavier
to operate). Evaluation criteria: patch cost, operational burden of the update server,
Windows/Linux story, delta-update support. Full-size updates first; **delta updates
are a later optimization** (a Chromium app is large, so deltas matter, but correctness
and signature verification come first).

## Upstream tracking

- **Policy: follow Chromium stable.** Every upstream stable release, including
  security point releases, gets evaluated the day it ships.
- **Security bumps are rebased, rebuilt, and shipped within days**, not weeks. This is
  the strongest argument for the minimal-patch-series design: a browser that lags
  upstream security fixes is worse than no browser.
- **A minor rebase must usually be zero-touch.** The pin moves, `apply-patches` runs
  clean, CI builds, release ships. If a routine point release regularly causes manual
  conflict resolution, the offending patches are in the wrong layer — fix the patch,
  not the process.
- Major-version rebases (new stable milestone) are scheduled, budgeted work with a
  checklist, performed on a branch and merged only when the full series applies and
  the browser passes the release checklist in `QUALITY.md`.

## CI reality

GitHub-hosted runners cannot practically build Chromium: default runners have tens of
GB of disk and modest CPU against a checkout+build that needs roughly an order of
magnitude more disk and hours of compute. Even a bare source checkout exceeds the
default runner disk. Pretending otherwise produces a CI that is always red or always
skipped.

Plan: **self-hosted or cloud macOS builders** (own Apple-silicon hardware, or a Mac
cloud provider) for real builds — provider and topology are an open decision, ADR
before M1. Until then, hosted CI still earns its keep with what it *can* do:

- Lint and test the tooling scripts (shellcheck, dry runs against fixtures).
- Docs checks: markdown lint, internal link validation, ADR format.
- Patch hygiene: series is contiguous, numbered, each patch has a header.
- Patch-apply dry runs against the pinned source — requires a cached partial checkout
  or runs on the self-hosted builder; mechanism TBD with the builder ADR.

## Rejected alternatives

**Electron/CEF wrapper.** A browser-shaped app on Electron or CEF cannot deliver full
Chrome extension compatibility — extension APIs are implemented in Chrome's browser
layer, not in the embedding APIs — and it inherits a permanent performance and
memory penalty plus a second-class multi-process model. Our hard requirement (real
extension support) rules this out on its own; the rest just makes it worse.

**Firefox base.** Gecko is a credible engine, but Chrome extension compatibility
would mean WebExtensions-only with real gaps, and the users we target live in the
Chrome extension ecosystem. Zen Browser already executes the Arc-style-UI-on-Firefox
idea well; competing there means fighting for the smaller lane against an incumbent.
Our differentiation depends on Chromium compatibility with none of Chrome's strings
attached.

**Hard fork of Chromium.** Diverging from upstream (own engine changes, own release
cadence) means absorbing Chromium's full security-response burden with a team of
approximately one. Chromium ships security fixes continuously; a hard fork falls
behind within months and becomes dangerous to recommend. The minimal patch series
keeps upstream doing the engine work while we do the product work — that asymmetry is
the entire strategy.
