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
| depot_tools git cache | `~/chromium/.git-cache` | `$GIT_CACHE_PATH` |

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

Recorded as they were actually hit on the reference machine, not imagined.

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
  it looks exactly like a hang. Confirm the host is healthy by timing an ordinary
  download from `dl.google.com` before concluding anything is wrong: a 404 response
  reports a meaningless transfer rate, which is an easy way to misdiagnose this.

- **`gsutil` warns that `~/.boto` authentication is deprecated.** Harmless; the
  bootstrap download proceeds anyway.
