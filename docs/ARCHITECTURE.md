# Architecture

Engineering strategy for Stedding Browser. Companion docs: `PRODUCT.md` (what we
build), `PRIVACY.md` (defaults and de-Googling policy), `ROADMAP.md` (when),
`decisions/` (ADRs for anything hard to reverse).

## Fork strategy: minimal patch series on Chromium stable

We are not a hard fork. We track the Chromium **stable channel** and carry a small,
ordered, documented patch series on top of it — the Brave/Helium model. The measure of
success is boring rebases: when upstream ships a new stable, our patches apply with
little or no manual work.

### Repository layout

```
tooling/          Scripts: sync, build, patch series, checks, measurement   exists
docs/             This documentation                                        exists
patches/          Ordered patch series: NNNN-short-slug.patch               from M1
branding/         Icons, names, strings, installer assets replacing Chromium's   from M1
```

`patches/` and `branding/` are empty until the first branding patch at M1; the tooling
that reads them (`tooling/apply-patches`, `tooling/update-patches`) already exists and
treats an absent series as a valid, empty one.

The Chromium source tree itself is never committed here. A pinned upstream version
(exact commit and tag, recorded in `tooling/chromium-version`) is fetched at build
time. The pin is updated deliberately, never implicitly — see
`decisions/0007-chromium-version-pin.md`.

### Patch discipline

- **One logical change per patch.** A patch does one thing: adds one flag, reroutes one
  service, brands one surface. Never a grab-bag.
- **Every patch carries a header**: what it does, why it exists, and what would let
  us delete it (e.g. an upstream flag landing) — as `Why:` and `Removable when:` in
  the commit message, which `tooling/update-patches` refuses to export without. Which
  upstream files a patch touches is answered by the diffstat `git format-patch` writes
  under the message, so it is not restated by hand where it could drift.
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
and the executed procedure cannot drift apart. The scripts are also the reference for
what the underlying `gclient` and `gn` invocations are: they are short, commented, and
meant to be read. There is no separate list of hand-run commands, because a second
copy of the procedure is a second copy to go stale.

### Layout

The Chromium tree lives **outside** this repository and is never committed here.

| Path | Default | Override |
|---|---|---|
| This repository | wherever you cloned it | `$STEDDING_ROOT` |
| depot_tools | `~/depot_tools` | `$DEPOT_TOOLS_DIR` |
| gclient checkout root | `~/chromium` | `$CHROMIUM_ROOT` |
| Chromium source | `~/chromium/src` | `$CHROMIUM_SRC` |
| depot_tools git cache | `~/chromium/.git-cache` | `$GIT_CACHE_PATH` |

### The pinned version

`tooling/chromium-version` is the single source of truth for what upstream version we
build. It is read by every script. A version number written anywhere else is a bug.
Policy for moving the pin: `decisions/0007-chromium-version-pin.md`.

### Prerequisites (macOS arm64)

- **Full Xcode** — not just the Command Line Tools. Install it from the App Store (or
  from Apple's developer downloads), launch it once so it installs its additional
  components, and accept the licence:

  ```bash
  sudo xcodebuild -license accept
  sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
  ```

  That last line matters: installing the Command Line Tools points `xcode-select` at
  `/Library/Developer/CommandLineTools`, and Chromium will not build against that.
  `xcode-select -p` must print a path inside `Xcode.app`.
- **Python 3** and **git** on `PATH` (depot_tools brings its own copies of both for the
  build itself, but the bootstrap needs a system pair).
- **Disk:** `tooling/sync-chromium` refuses to start below 150 GB free on the volume
  holding `$CHROMIUM_ROOT`, and `tooling/build-chromium` wants 60 GB of its own before
  it starts. Measured: the checkout is 65 GB and a release build adds 9.3 GB — see
  "Measured results".
- **No `node_modules` in any directory above the checkout.** Chromium's TypeScript
  build resolves modules the way node does — by walking up parent directories — so a
  stray `node_modules` in your home directory leaks its `@types` into the build. The
  tooling checks for this before it does anything expensive; see "Known failure
  modes".
- **RAM:** 16 GB is the practical floor. Compilation parallelism is what consumes it,
  and the failure is not a clean error — the machine swaps and the build slows by an
  order of magnitude, or the OOM killer takes a compiler process and ninja reports a
  confusing failure. If you have less, cap parallelism rather than hoping:
  `autoninja -j4`. Not checked by any script; a recommendation, not a gate.

These are checked in two places, and each fails with the exact remedy rather than
letting a build die hours later:

| Check | Where |
|---|---|
| Full Xcode, accepted licence, `git`, `python3`, arm64 macOS | `tooling/bootstrap-depot-tools` |
| 150 GB free disk, no ancestor `node_modules` | `tooling/sync-chromium` |
| Tree is on the pin, no ancestor `node_modules` | `tooling/build-chromium` |

### Reference hardware

The machine every measured number in this document was taken on. Nothing here is
normative — it is the answer to "compared to what?":

| | |
|---|---|
| Machine | Apple M1 Max, 10 cores, 64 GB RAM |
| OS | macOS 26.5.2, arm64 |
| Xcode | 26.5 (17F42) |
| Command Line Tools | 26.6.0.0.1781586589 |
| depot_tools | `f70835271105ca56d2cd5382a0118152bc2bdeea` (2026-08-27) — observed, **not a pin**: `bootstrap-depot-tools` tracks upstream `main` |
| Chromium | `153.0.8010.12` (M153 stable) |

### The build, end to end

Every command is run **from the root of this repository**, not from the Chromium tree.

```bash
# 1. Install depot_tools and verify the host toolchain. Idempotent. Seconds.
tooling/bootstrap-depot-tools

# 2. Check out Chromium at the pinned version and resolve its dependencies.
#    Long: downloads tens of GB. Safe to re-run; moves an existing tree to the pin.
#    Measured on the reference machine, from nothing: ~25 min to bootstrap the git
#    cache, then ~19 min for the dependencies and hooks. It prints little during the
#    cache download — that is normal, see "Known failure modes".
tooling/sync-chromium

# 3. Build. Config is one of release (default), debug, official.
tooling/build-chromium release

# 4. Check that what you built actually works. This is M0's acceptance criterion,
#    not step 5's eyeball test.
tooling/verify-build --app ~/chromium/src/out/release/Chromium.app

# 5. Run it.
open ~/chromium/src/out/release/Chromium.app
```

To put the checkout somewhere other than `~/chromium`, set `CHROMIUM_ROOT` on the
sync — you only need it once, because sync records the location in `.stedding-local`
and every later command reads it back:

```bash
CHROMIUM_ROOT=/Users/Shared/chromium tooling/sync-chromium
```

### Why everything goes through the git cache

`tooling/sync-chromium` does not clone `chromium/src` from the server. It populates
depot_tools' **git cache** and clones from that instead. This is not a speed
optimisation; on the reference machine it is the difference between working and not
working. A direct `git clone` of `chromium/src` — plain, shallow, or partial alike —
stalls in the server-side ref advertisement, because the repository carries on the
order of a hundred thousand tags and advertising them dominates the exchange. The
cache bootstraps from a prepackaged bundle on Google Storage over ordinary HTTP, which
saturates the link.

Two consequences worth knowing:

- We fetch the one tag we build (`--no-fetch-tags --ref refs/tags/<pin>`) rather than
  all of them. `tooling/sync-chromium --all-tags` overrides this when tag archaeology
  is genuinely needed.
- `gclient` reads `GIT_CACHE_PATH` from the environment, so every dependency is routed
  through the same cache. The cache survives pin changes, which is what makes moving
  the pin cheap — and moving the pin often is the entire premise of ADR 0003.

`tooling/build-chromium` copies `tooling/args/<config>.gn` verbatim into the output
directory as `args.gn`, so the configuration of any build is recoverable from the build
itself. It also refuses to build a tree whose provenance is unclear: the checkout must
be either vanilla at the pin or a descendant of it — that is, the pin with our patch
series applied, which is what `apply-patches` produces. It reports which of the two it
found, and how many patches are applied. Anything else — a stray branch, a different
pin, upstream commits mixed in — is refused.

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

Measured on the reference hardware above, at `153.0.8010.12`, from an empty directory.
Nothing here is an estimate; anything not yet measured says so.

| | |
|---|---|
| git cache bootstrap (first sync only) | ~25 min |
| `gclient sync` after the cache exists | ~19 min |
| git cache size | 25 GB |
| Chromium source incl. dependencies | 55 GB |
| Checkout total (cache + source) | 65 GB |
| `gn gen` wall time | 6–12 s (32,499 targets from 4,955 files) |
| First `release` build, cold | **3 h 29 min** (13:57 → 17:26) |
| `release` object files | 46,555 |
| `out/release` size | 9.3 GB |
| `Chromium.app` size | 530 MB |
| Incremental build, one `.cc` touched | TBD |
| First `official` build wall time | TBD |

The 150 GB floor `sync-chromium` enforces is not arbitrary: the checkout alone is
65 GB, a release build adds 9.3 GB, and an official build adds more on top of that,
before leaving any room to work in.

PGO profiles are two ~300 MB files (x86-64 and arm64) that `gclient runhooks`
downloads only when the solution requests them — see the note on
`checkout_pgo_profiles` under "Known failure modes".

### Known failure modes

Recorded as they were actually hit on the reference machine, not imagined.

- **`Undeclared dependencies to definition files` from `ts_library.py`,** naming
  packages nobody asked for (`undici-types`, `buffer`, `@types/node`). Chromium's
  TypeScript build walks up parent directories looking for `node_modules`, exactly as
  node does, so any `node_modules` *above* the checkout contributes its `@types` to
  every TypeScript target. On the reference machine a 1 GB `~/node_modules` — left by
  some past `npm install` in the home directory — broke the build about ninety seconds
  in, after the whole checkout had been made. The message names the leaked packages
  rather than the cause, so `tooling/lib.sh` checks every ancestor directory during
  preflight and fails immediately with the remedy. Put the checkout somewhere with no
  `node_modules` above it:

  ```bash
  CHROMIUM_ROOT=/Users/Shared/chromium tooling/sync-chromium
  ```

  Note that *every* ancestor counts, so no path under a contaminated home directory
  will do.

- **`git clone` of `chromium/src` hangs with no output.** The connection is
  established and a few megabytes arrive, then nothing, indefinitely. This is the
  ref advertisement, not a network fault: the repository has an enormous number of
  tags. Observed identically with a plain clone, `--depth 1 --branch <tag>`, and
  `--filter=blob:none`. The fix is not to clone from the server at all — see "Why
  everything goes through the git cache" above. Any instructions elsewhere on the
  internet that begin with `git clone https://chromium.googlesource.com/chromium/src`
  will appear to hang for the same reason.

- **`gclient` appears to hang for minutes on a fresh machine.** It is bootstrapping
  `cipd` and `vpython`, which download a Python distribution and wheels before any
  Chromium code is fetched. First run only, and it does finish.

- **`cipd` retries with `dial tcp [2607:f8b0:...]:443: connect: bad file descriptor`
  or `i/o timeout`.** Google's infrastructure advertises AAAA records; on a host with
  degraded IPv6 reachability the client works through a 1s→2s→4s→8s→16s backoff before
  falling back to IPv4. It does succeed, but the first sync is noticeably slower and
  it looks exactly like a hang. To tell "backing off, wait" from "the network is
  down, stop", time a real download of a real file — note the `200`, which is the
  point, since a 404 returns an error page in milliseconds and reports a transfer
  rate that means nothing:

  ```bash
  curl -s -o /dev/null -w 'http=%{http_code} speed=%{speed_download} B/s\n' \
    --max-time 20 https://dl.google.com/go/go1.22.0.darwin-arm64.tar.gz
  ```

  Several MB/s with `http=200` means the host is fine and cipd will get there. Near
  zero means it will not.

- **Moving a checkout breaks it quietly.** gclient clones every dependency from the
  git cache and records the cache location as an *absolute* path, in each
  dependency's `.git/objects/info/alternates` and `.git/config` — 298 files on the
  reference checkout. Move or rename the tree and all of them go stale at once. Git
  then reports `unable to normalize alternate object path` and `fatal: bad object
  HEAD`, but the build largely carries on, because the working trees still hold real
  files. That is the dangerous part: version stamping gets it wrong rather than
  stopping. `tooling/repair-checkout` rewrites the paths (`--check` reports without
  writing), and it verifies the repair by making real dependencies resolve their own
  HEAD rather than assuming.

- **`mapfile: command not found`.** macOS ships bash 3.2, and `#!/usr/bin/env bash`
  resolves to it. Anything needing bash 4 works on a machine with Homebrew bash and
  fails on a stock one — which is the machine a new contributor has. `tooling/check-repo
  shell` rejects bash-4-only constructs so this cannot come back.

- **`gn gen` fails on an official build with a missing PGO profile**, telling you to
  run `gclient runhooks`. Running it changes nothing on its own: the profile hook is
  gated on the gclient solution asking for it, and a solution created without
  `checkout_pgo_profiles` never will. Add it to `.gclient` and re-run hooks — which
  `tooling/sync-chromium` now does for new checkouts and repairs in existing ones.
  The cost of getting this wrong is that the failure appears at `gn gen` for a
  configuration you may not build until much later.

- **Editing a `tooling/` script while it is running corrupts the running shell.**
  bash reads a script incrementally, by byte offset, as it executes. Editing the file
  shifts those offsets, so a long-running script resumes mid-statement and dies with a
  syntax error — after the work is done but before it reports. This cost us a completed
  three-and-a-half-hour Chromium build whose success went unnoticed, because the script
  died on the line that would have announced it. `build-chromium` and `sync-chromium`
  now wrap their bodies in a `main()` called on the last line, so bash parses the whole
  file before running any of it. Prefer that shape for any script that runs for hours.

- **The build crawls while something else runs, even on an idle-looking machine.**
  `autoninja` deliberately runs the compile at **nice 5**, so anything at normal
  priority outcompetes it — a code-search tool, an indexer, another agent. Observed
  here: two `ripgrep` processes scanning the Chromium tree took roughly 3.6 cores and
  dropped total `clang` CPU from about 588% to 130%, with the object count nearly
  flat for half an hour. Nothing was broken and no error appeared; the build simply
  starved. Check with:

  ```bash
  ps -Ao %cpu,ni,command | sort -rn | head
  ```

  Anything above the compilers at a lower `ni` value is the problem. `renice +20 -p
  <pid>` on the offender restores it without killing anything — total `clang` CPU went
  back to 380% immediately. Worth knowing before concluding a build has hung.

- **`gsutil` warns that `~/.boto` authentication is deprecated.** Harmless; the
  bootstrap download proceeds anyway.

- **`gn` warns that a build argument "has no effect".** The argument no longer exists
  upstream. Hit at M0 with `enable_nacl`, which is inert now that Native Client has
  been removed from Chromium. Delete the argument rather than silencing the warning:
  a gn arg that does nothing is a comment pretending to be configuration.

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

### Surfaces, as they actually are at the pin

Surveyed against the checkout at M0 and spot-verified file by file. Paths are relative
to the Chromium source root. This is a survey, not a decision — the branding itself
lands at M1.

| Surface | Where | How |
|---|---|---|
| Product name, company, bundle id, copyright | `chrome/app/theme/chromium/BRANDING` | asset replacement |
| macOS app icon | `chrome/app/theme/chromium/mac/` — `app.icns`, `AppIcon.icon`, `Assets.car`, `Assets.xcassets` | asset replacement |
| Product name in UI strings | `IDS_PRODUCT_NAME` in `chrome/app/chromium_strings.grd` | asset replacement |
| Version | `chrome/VERSION` | set by the pin; never edited by hand |
| About page | `chrome://settings/help` (macOS has no separate About panel) | grd/png replacement |
| User agent | — | **leave alone** |

`BRANDING` is a ten-line key/value file — `PRODUCT_FULLNAME`, `PRODUCT_SHORTNAME`,
`COMPANY_FULLNAME`, `MAC_BUNDLE_ID`, `COPYRIGHT` and a few more — and it drives most of
the macOS bundle. Replacing it is the single highest-leverage branding change available,
and it costs no patches.

Three findings worth knowing before M1 is planned:

- **There is no third-brand path.** Upstream's branding switch is boolean
  (`is_chrome_branded`), selecting `chrome/app/theme/chromium/` or
  `chrome/app/theme/google_chrome/`. Adding a *third* directory is not supported: grit
  includes hardcode `chromium/`. So our assets overwrite the `chromium/` tree in place
  rather than sitting beside it — which is exactly what the `branding/` copy step does,
  and why it must run before `gn gen`.
- **Three identifiers do not follow `MAC_BUNDLE_ID`.** Most do: the main app, every
  helper, the framework, PWA and app-shim ids, Mach and mojo rendezvous names, the
  keychain groups under `chrome/`, and the Crashpad filename all derive from it, and
  cost nothing. Three do not, and each was verified in the tree at the pin:

  | Where | What | Why it matters |
  |---|---|---|
  | `build/apple/tweak_info_plist.py:299` | matches the literal `org.chromium.Chromium` to decide the direct-launch URL scheme | change the bundle id and the scheme silently vanishes from `Info.plist`, while `chrome/browser/shell_integration_mac.mm` still returns `"chromium"` — the plist and the code disagree |
  | `net/device_bound_sessions/unexportable_key_service_factory.cc:30` | hardcodes `.org.chromium.Chromium` for the keychain group | its own comment says it cannot depend on `//chrome`, so it cannot derive the value |
  | `content/browser/media/capture/desktop_capture_util_mac.mm:77` | lists `org.chromium.Chromium` among known browser prefixes | our own helpers and PWAs stop being recognised as this browser for audio capture |

  Two more surfaces hardcode ids — `chrome/updater/branding.gni` and
  `chrome/enterprise_companion/branding.gni` — but neither ships for us:
  `enable_updater = is_chrome_branded && …` (`chrome/browser/buildflags.gni:16`), and we
  build unbranded. They become relevant only if the Chromium updater is adopted at M7,
  which is an open ADR.

  Some hardcoded `org.chromium.*` strings should deliberately **stay**: the
  `org.chromium.extension` and `org.chromium.shortcut` UTIs and the clipboard pasteboard
  types are interoperability identifiers shared with other Chromium browsers, not
  branding. Renaming them would break interchange for no user-visible gain.
- **Icons are copied, not compiled** — the build takes prebuilt `app.icns` and
  `Assets.car`. The newer vector `.icon` sources *are* compiled at build time, but
  overwriting the sources is still asset replacement, not a patch.

On the user agent: stock Chromium already emits a Chrome-compatible `Chrome/<version>`
token. There is no gn arg to change it, and adding a novel product token would be both
a patch and a site-compatibility regression. Leaving it alone is the decision.

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
