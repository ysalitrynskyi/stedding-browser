# Architecture

Engineering strategy for Stedding Browser. What the product does is
[PRODUCT.md](PRODUCT.md). Privacy defaults are [PRIVACY.md](PRIVACY.md). When
things ship is [ROADMAP.md](ROADMAP.md). Anything hard to reverse is an ADR in
[decisions/](decisions/).

## Fork strategy: minimal patch series on Chromium stable

Stedding tracks Chromium's stable channel and carries an ordered, documented
patch series on a pinned version: the Brave/Helium model
([ADR 0003](decisions/0003-chromium-minimal-patch-fork.md)). A new stable
should be a boring rebase. The pin moves, the series applies, and the build
machines build.

The pin lives only in [`tooling/chromium-version`](../tooling/chromium-version)
([ADR 0007](decisions/0007-chromium-version-pin.md)). On 2026-10-28 it is
`157.0.8103.31`, M157's stable cut, merged before Google's stable rollout on
2026-11-03. `tooling/check-pin` reports that pin ahead until Mac stable serves
M157. The latest release is Stedding 0.3.0 beta 22 (`v0.3.0-beta.22`), built
on Chromium `156.0.8078.48`, for macOS and Windows. The series on `main` is
this pin, and it is not what that release shipped. The product version a build
stamps is the `VERSION` file in this repository.

### Repository layout

```
tooling/     Scripts: sync, build, the patch series, checks
docs/        These documents
patches/     Ordered series: NNNN-short-slug.patch
branding/    Icons, names, strings and installer assets that replace Chromium's
```

The Chromium tree is never committed here. `tooling/apply-patches` puts the
series on the checkout. `tooling/apply-branding` copies `branding/` over it
before `gn gen`. `tooling/dev status` counts the patches. The working branch
in the checkout is `stedding-work` ([patches/README.md](../patches/README.md)).

### Patch discipline

- **One logical change per patch.** A patch does one thing. A round of feedback
  that touches many features at once is one patch when folding each part back
  would conflict with later patches.
  [patches/README.md](../patches/README.md) says so; the patch's message says
  what it covers.
- **Every patch carries a header.** `Subject:`, `Why:` and `Removable when:`
  are required. `tooling/update-patches` will not export without the last two,
  and `tooling/check-repo patches` checks the same. The diffstat under the
  message is the list of files. It is not copied into the header, where it
  would drift.
- **The scripts apply and export the series.** `tooling/apply-patches` applies
  it onto a clean checkout at the pin. `tooling/update-patches` regenerates it
  from the working branch. Applying a patch by hand is a bug in the tooling.
  `apply-patches` also refuses a branch that holds commits the series does not
  account for.
- **Numbered from 0001, with no gaps.** Renumbering is allowed. Silent
  reordering is not. The series must apply from 0001 upward on the pin.

### Where patches are allowed to live

Preferred layers, in order:

1. **New files.** New code goes in new files wherever it can. New files do not
   conflict on rebase.
2. **`chrome/browser/ui` and top chrome** (Views, the browser frame, the tab
   strip). The sidebar, split view and command bar live here.
3. **WebUI** for settings and other internal pages.
4. **Feature flags and gn args,** ahead of a patch to the code behind a switch
   that already exists.
5. **`chrome/browser` service wiring,** for disabling or rerouting a Google
   service.

Avoid `content/`, `third_party/blink/`, `net/`, `v8/`, and the rest of the
engine. Those trees are security-critical and they churn. A feature that seems
to need a patch there is redesigned first. One that truly needs it is an ADR.

The series does touch the engine in these places.

**The network stack** (`net/`, `services/`), three changes, each named in its
patch header. [ADR 0027](decisions/0027-changes-to-the-network-stack.md) records
them and the rule for the next one.

1. **Patch 0073, S-72.** On Windows, `chrome/VERSION` carries Stedding's product
   version so two releases on one Chromium pin install in order.
   `version_info::GetChromiumVersionNumber()` still returns Chromium's version,
   and that is what the user agent, client hints, and Google's services see,
   including the root store's version rules. On the Mac the two versions are
   the same.
2. **Patch 0074, S-236, S-237.** Features Chrome has launched for every Stable
   user by field trial, Google's static key pins, and Certificate Transparency.
   The certificate audit reports Chrome sends stay off in code. Stedding
   receives no trials, so `tooling/field-trials` compares Chrome Stable's seed
   with the pin's defaults at every pin move (S-240).
3. **Patch 0077, S-251.** The certificate verifier tells the network context of
   a setup change only after it has verified a certificate. Two changes arrive
   in the first second of a launch, and they were dropping the connections
   opened ahead for tabs given on the command line.

The next change under `net/` or `services/network/` follows ADR 0027: a fault a
user can see, or a promise in [PRIVACY.md](PRIVACY.md), with a test that fails
without it and a line in that ADR.

**`content/`.** Patch 0058 (import I26) sends a negative document sequence
number to the renderer as 0, so a tab the Arc import created unloaded does not
come back from a restart as a crashed page. Patch 0067 keeps `sessionStorage`
and notifications for a Space with its own cookies in that Space's partition
(sessions S28, S30): `content/browser/dom_storage/stedding_session_storage.cc`
and `content/browser/notifications/stedding_notification_partition.cc`.

**Blink.** Patch 0089 (S-89, clean-links Cl12) adds
`URLLoaderThrottle::WillRestartWithURLReset`, so a throttle that rewrote the
URL in `WillStartRequest` keeps that URL when the loader restarts.

No patch in the series touches `v8/`.

## Build system

Chromium builds with `depot_tools` (`gclient`, `gn`, `autoninja`, and a pinned
Python), a `gclient sync`, `gn gen`, and `autoninja`. Google's remote execution
is not available. Every file in `tooling/args/` sets `use_remoteexec = false`.
Every build is local.

Scripts in `tooling/` are the procedure. A second list of hand-run commands
would go stale.

### Layout

The Chromium tree lives outside this repository.

| Path | Default | Override |
|---|---|---|
| This repository | the clone | `$STEDDING_ROOT` |
| depot_tools | `~/depot_tools` | `$DEPOT_TOOLS_DIR` |
| gclient checkout root | `~/chromium` | `$CHROMIUM_ROOT` |
| Chromium source | `~/chromium/src` | `$CHROMIUM_SRC` |
| depot_tools git cache | `~/chromium-git-cache` | `$GIT_CACHE_PATH` |

Those defaults are what `tooling/lib.sh` uses. Set `CHROMIUM_ROOT` on the first
sync and it records the location in `.stedding-local`. Later commands read that
file. `.stedding-local` is local state and is never committed.

On Windows the PowerShell build has no default path.
`STEDDING_CHROMIUM_SRC` is the checkout's `src`, `STEDDING_DEPOT_TOOLS` if
depot_tools is not on `PATH`, and `STEDDING_VPYTHON_ROOT` a short directory for
vpython ([HANDOFF.md](HANDOFF.md#the-windows-build), trap 34). The bash scripts
take `CHROMIUM_ROOT` as a POSIX path (`/c/...`). There is no git cache:
`tooling/sync-chromium` unsets `GIT_CACHE_PATH`, fetches one commit of the
pinned tag, and syncs dependencies with `--no-history`.

### The pinned version

`tooling/chromium-version` is the only pin. Every script reads it.
`tooling/check-repo version` fails if a non-documentation file hard-codes a
Chromium version. Policy for moving the pin is ADR 0007.

### Prerequisites (macOS arm64)

`tooling/bootstrap-depot-tools` checks the host, then clones or updates
depot_tools from upstream `main`. That revision is observed, not pinned.

- **Full Xcode**, not only the Command Line Tools. `xcode-select -p` must be a
  path inside an Xcode bundle. Accept the licence if it has not been accepted:

  ```bash
  sudo xcodebuild -license accept
  sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
  ```

  The Command Line Tools leave `xcode-select` at
  `/Library/Developer/CommandLineTools`, and Chromium does not build against
  that.
- **Python 3 and git** on `PATH` for the bootstrap. The build itself uses the
  copies depot_tools brings.

### Disk

`tooling/sync-chromium` refuses to start below 150 GB free on the volume that
holds `$CHROMIUM_ROOT`. `STEDDING_SYNC_MIN_FREE_GB` can lower that, and never
under 100. The script's working set, which the floor still uses, was measured
at `153.0.8010.12`: 65 GB for the checkout, 9.3 GB for a release build, and
about 10 GB for `unit_tests`, about 85 GB together. Those sizes have not been
re-measured on the current pin ([docs/perf/README.md](perf/README.md)).

A point release on the milestone the checkout already holds is
`tooling/sync-chromium --point-release`, which `tooling/update-pin --apply`
passes for a same-milestone bump. The floor is then 25 GB
(`STEDDING_SYNC_POINT_RELEASE_MIN_FREE_GB`, never under 20; trap 45). A missing
checkout, or one on another milestone, is a full sync and keeps the 150 GB
floor. Trap 44 is the full disk floor a fresh checkout needs.

`tooling/build-chromium` wants 60 GB free before it starts.
`STEDDING_MIN_FREE_GB` lowers that, never under 20.

On Windows the same 150 GB sync floor applies. The script's figure for the
shallow tree is about 26 GB of source, against the Mac's 65. What a milestone
move costs that checkout, and what a full build costs in memory, is in
[HANDOFF.md](HANDOFF.md) (traps 53 and 54).

**No `node_modules` above the checkout.** Chromium's TypeScript build walks
parent directories the way node does, so a `node_modules` in a parent
contributes its `@types`. `tooling/lib.sh` fails the preflight when it finds
one.

**RAM.** 16 GB is the practical floor. Nothing checks it. With less, cap
parallelism (`autoninja -j4`) rather than swapping through the build.

| Check | Where |
|---|---|
| Full Xcode, accepted licence, `git`, `python3`, arm64 macOS | `tooling/bootstrap-depot-tools` |
| Free disk at the sync floor, no ancestor `node_modules` | `tooling/sync-chromium` |
| Tree is the pin or a descendant of it, no ancestor `node_modules`, free disk at the build floor | `tooling/build-chromium` |

### The build, end to end

Run these from the root of this repository.

```bash
# Install depot_tools and check the host toolchain. Idempotent.
tooling/bootstrap-depot-tools

# Check out Chromium at the pin and resolve its dependencies.
# Safe to re-run; an existing tree is moved to the pin.
tooling/sync-chromium

# Series first, then branding. Branding dirties tracked files on purpose,
# and apply-patches refuses a dirty tree. Branding must be in place before gn gen.
tooling/apply-patches
tooling/apply-branding

# The name is a file in tooling/args/. release is the default.
tooling/build-chromium release

# Launch, a page, WebGL, a royalty-free video frame, and H.264 with AAC.
tooling/verify-build --app ~/chromium/src/out/release/Stedding.app

open ~/chromium/src/out/release/Stedding.app
```

On Windows the same series builds with Visual Studio's toolchain
(`DEPOT_TOOLS_WIN_TOOLCHAIN=0`) and the Windows SDK, through
`tooling\win\build.ps1` (one chunk) or `tooling\win\build-until-done.ps1` (the
whole build). The steps are in [HANDOFF.md](HANDOFF.md#the-windows-build).

To put the checkout somewhere other than `~/chromium`, set `CHROMIUM_ROOT`
once. Sync records it:

```bash
CHROMIUM_ROOT=/Users/Shared/chromium tooling/sync-chromium
```

### Why the Mac sync goes through the git cache

On the Mac, `tooling/sync-chromium` does not clone `chromium/src` from the
server. It fills depot_tools' git cache and clones from that. A direct clone
stalls in the server-side ref advertisement, because the repository carries on
the order of a hundred thousand tags. The cache bootstraps from a bundle on
Google Storage over HTTP.

The sync fetches the one tag it builds (`--no-fetch-tags --ref refs/tags/<pin>`).
`tooling/sync-chromium --all-tags` fetches every tag. On Windows `--all-tags`
is refused, because that checkout has no cache.

`gclient` reads `GIT_CACHE_PATH`, so dependencies use the same cache. The cache
survives a pin move, so the next fetch is not a full download.

`tooling/build-chromium` copies `tooling/args/<config>.gn` into the output
directory as `args.gn`. It builds a tree that is vanilla at the pin, or a
descendant of the pin. A stray branch, a different pin, or upstream commits
mixed in are refused.

### Build configurations

Every file in `tooling/args/` sets `disable_fieldtrial_testing_config`, so
Chromium's field-trial testing config is not applied (privacy Q10). The full
args, and the reason for each, are in those files.

| Config | Purpose | Notes |
|---|---|---|
| `release` | Day-to-day work on the Mac, and the published Mac images | Optimised, no symbols, a single binary, no PGO or LTO. Performance numbers are not quoted from this config. |
| `debug` | Debugging on the Mac | A component build: one target relinks a small library. |
| `official` | Performance baselines on the Mac | `is_official_build`: PGO with upstream's profile for the pin, and ThinLTO. Which configuration should ship is open (`BACKLOG.md` S-168). Published images so far are `release` and `win-release` ([HANDOFF.md](HANDOFF.md#release-channel)). |
| `vanilla` | The vanilla half of a performance comparison | The same args as `official`, built from the checkout detached at the pin with branding reverted ([docs/perf/README.md](perf/README.md)). |
| `win-release` | The Windows build and its installer | The Mac's `release` on Windows: non-component, no symbols, no PGO ([ADR 0018](decisions/0018-windows-installer.md)). |
| `win-asan` | AddressSanitizer on Windows | `is_asan`, line-table symbols. `tooling/args/win-asan.gn` names the lifetime tests it is for (TAB-7, TAB-8, SPC-1, SPC-2, SPC-3, WIN-1, WIN-2, WEB-2). Test targets only. The Mac has no ASan configuration. |
| `win-checks` | Dangling-pointer detector and DCHECKs on Windows | Release code with `dcheck_always_on` and BackupRefPtr. Run with `--enable-features=PartitionAllocBackupRefPtr,PartitionAllocDanglingPtr`. `win-checks.gn` names TAB-7, TAB-8, TAB-9 and WIN-2. Test targets only. |
| `mac-checks` | The same checks on the Mac | The Mac's own code paths, which `win-checks` never compiles. No line tables, so the output fits beside `out/release`. `STEDDING_TEST_OUT=mac-checks tooling/dev test` adds the same run-time flag. Test targets only. |
| `win-debug` | A Windows debug build | A component build, for WIN-2 and for debugging. Test targets only. The largest output this project asks a disk for. |

`win-asan`, `win-checks`, `mac-checks` and `win-debug` are throwaway: build the
test targets, run them, and delete the output directory.

In every configuration without DCHECKs, including `release` and `win-release`,
a soft check (`CHECK(..., base::NotFatalUntil::M<n>)`, `DUMP_WILL_BE_CHECK`,
`DUMP_WILL_BE_NOTREACHED`) logs and writes a dump without crashing, as in an
official build. The checks configurations still stop on one. A soft check whose
milestone has passed is fatal everywhere, as upstream (patch 0069,
[ADR 0024](decisions/0024-soft-checks-report-in-releases.md)).

`autoninja` selects Chromium's build executor. At this pin that executor is
siso, on both platforms (`tooling/build-chromium`; [HANDOFF.md](HANDOFF.md)
traps 1 and 54).

### Codecs

Every file in `tooling/args/` sets `proprietary_codecs = true` and
`ffmpeg_branding = "Chrome"`
([ADR 0008](decisions/0008-proprietary-codecs.md)). Upstream's default,
`ffmpeg_branding = "Chromium"`, plays VP8, VP9, AV1 and Opus, and does not
play H.264 or AAC. `tooling/verify-build` requires an H.264 and AAC frame.

Distributing binaries that decode H.264 and AAC carries patent obligations,
administered by Via LA. Terms and cost are TBD. ADR 0008 says they are recorded
before the 1.0 checklist in [ROADMAP.md](ROADMAP.md#the-quality-bar).

### Measured results

The disk floors above are the current gates. The checkout and release sizes
they cite were measured at `153.0.8010.12` and are what
`tooling/sync-chromium` still names. Wall-clock times from that pin are not
repeated here. Nothing has been re-measured on the current pin
([docs/perf/README.md](perf/README.md)).

PGO profiles are downloaded by `gclient runhooks` only when the solution asks
for them. See `checkout_pgo_profiles` under Known failure modes.

## Known failure modes

These are the failures the scripts still guard, or that a build will hit again.
The longer record is [HANDOFF.md](HANDOFF.md).

- **A `node_modules` above the checkout breaks the TypeScript build.** The
  error names leaked packages (`undici-types`, `@types/node`) and not the
  parent directory. `tooling/lib.sh` checks every ancestor and stops with the
  remedy. The checkout has to sit where no ancestor has a `node_modules`.

- **A direct `git clone` of `chromium/src` stalls.** The connection comes up,
  a few megabytes arrive, and the ref advertisement then sits there. Plain,
  shallow and partial clones do this. The Mac sync uses the git cache, above.

- **The first `gclient` run is quiet for minutes.** It is fetching `cipd` and
  `vpython` before any Chromium code. It does finish.

- **Moving a checkout breaks it quietly.** gclient records the git cache as an
  absolute path in each dependency's `.git/objects/info/alternates` and
  `.git/config`. After a move, git reports `unable to normalize alternate
  object path` while the working trees still hold files, so version stamping
  can go wrong without the build stopping. `tooling/repair-checkout` rewrites
  the paths. `--check` reports and does not write.

- **`mapfile: command not found`.** macOS ships bash 3.2, and `#!/usr/bin/env bash`
  resolves to it. `tooling/check-repo shell` rejects bash-4-only constructs.

- **`gn gen` of an official build fails for a missing PGO profile.** Running
  `gclient runhooks` does nothing if `.gclient` never asked for
  `checkout_pgo_profiles`. `tooling/sync-chromium` sets that for a new Mac
  checkout and repairs an existing one. Windows checkouts do not request the
  profiles: the Windows configurations are not official builds.

- **Editing a long-running script corrupts the running shell.** bash reads a
  script by byte offset. `build-chromium` and `sync-chromium` wrap the body in
  `main()` and call it on the last line, so the file is parsed before it runs.
  A script that runs for hours should do the same.

- **An unsigned Mac build can hang on its first Keychain access.** Cookie
  encryption goes through OSCrypt. A new unsigned binary is a stranger to the
  Keychain, macOS raises a prompt, and a headless run waits with no crash and
  no pages loading. Incognito does not touch that store. `--use-mock-keychain`
  is the flag for an unattended test. It is not a setting for a build a person
  uses: cookies are then not encrypted at rest. Released Mac builds are signed,
  which removes the prompt for them. Any unattended test of a freshly built
  browser needs the mock keychain, a person to authorise the binary once, or
  signing.

- **`gn` says a build argument "has no effect".** Upstream removed the
  argument. Delete it. A gn arg that does nothing is not configuration.

## De-Googling stance

The policy is [PRIVACY.md](PRIVACY.md). This section is the mechanics.

Requests that leave by default are listed in [PRIVACY.md](PRIVACY.md): the
update check, thank-you pages, security component updates, Safe Browsing list
updates, and a network-time query. Nothing else leaves unless the user asked
for something that requires it. Safety features a browser is expected to have
stay, and the tradeoff is written down there.

- **Google API keys are not shipped.** Google account sign-in and Chrome Sync
  are absent. Sync of the sidebar is a folder the user picks (patch 0101,
  [ADR 0029](decisions/0029-sidebar-sync-through-a-folder.md)), not Chrome Sync.
- **Telemetry, crash reports to Google, field trials (Finch), RLZ and promo
  pings are off.** Features follow build flags and Stedding's defaults. Opt-in
  crash reporting to infrastructure of ours may come later
  ([PRIVACY.md](PRIVACY.md)). A crash dump stays on the machine.
- **Certificate Transparency and Google's static key pins are on,** as in
  Google Chrome (patch 0074, S-236, S-237). The certificate audit reports that
  go with them are off in code.
- **Features Chrome launches by field trial have their code defaults turned
  on** where the launch needs no Google service (patch 0074). `tooling/field-trials`
  is re-run at every pin move (S-240).
- **Safe Browsing is the hash-prefix variant, and it does not update in these
  builds.** The lists need a Google API key. On a running build the first
  update was refused with HTTP 400, and the lists stay empty
  ([PRIVACY.md](PRIVACY.md), Safe Browsing;
  [docs/history/plan-2026-09-26.md](history/plan-2026-09-26.md) WEB-5). Local
  warnings for dangerous file types remain. Enhanced Safe Browsing, which sends
  full URLs, is never the default. The intent, once a working list source
  exists, is hash-prefix Safe Browsing on by default.
- **The component updater stays.** Every component Stedding registers still
  comes from Google. Which ones to mirror, proxy or remove is `BACKLOG.md`
  S-241, before 1.0.
- **Widevine is not built.** No file in `tooling/args/` sets `enable_widevine`.
  Nothing protected by Widevine plays, including Netflix, Disney+, Prime Video
  and Spotify's web player (`BACKLOG.md` S-270). Shipping it needs a licence
  from Google.
- **Search and suggestion defaults** are in [PRIVACY.md](PRIVACY.md).
  Translate and preconnect are unchanged from Chromium
  ([PRIVACY.md](PRIVACY.md), Still to do). A fresh profile does not check
  Google's account list and does not register with Google's push service
  (privacy Q11, Q12).

Ungoogled-Chromium removes more, and it accepts the breakage. Stedding's bar
is a polished browser whose network behaviour is the list in PRIVACY.md.

## Branding

The build is Chromium branding (`is_chrome_branded` off), then Stedding's
assets on top. First `tooling/apply-branding` copies `branding/` over the
checkout before `gn gen`. Then gn args, where upstream has a branding knob.
A patch is last, for a name baked into code. Renaming every internal
"Chromium" is not a goal. The user-visible surfaces are the bar: the app name,
menus, About, the installer and settings.

The user agent stays a Chrome-compatible `Chrome/<version>` token. There is no
gn arg for a different one, and a new product token would be a patch and a
site-compatibility regression. On Windows that version is Chromium's, not
Stedding's product version (patch 0073).

### Surfaces

Paths are relative to the Chromium source root.

| Surface | Where | How |
|---|---|---|
| Product name, company, bundle id, copyright | `chrome/app/theme/chromium/BRANDING` | asset replacement |
| macOS app icon | `chrome/app/theme/chromium/mac/` (`app.icns`, `AppIcon.icon`, `Assets.car`) | asset replacement |
| Product name in UI strings | `IDS_PRODUCT_NAME` in `chrome/app/chromium_strings.grd`, its siblings, and each locale's `.xtb` | `tooling/brand/product_name.py`, from `tooling/apply-branding` |
| Windows app, document and PDF icons, and the tiles | `chrome/app/theme/chromium/win/` | asset replacement |
| Windows install mode: paths, app id, ProgIDs, GUIDs, sandbox prefix | `chrome/install_static/chromium_install_modes.h` | patch 0041 ([ADR 0018](decisions/0018-windows-installer.md)) |
| Version | `chrome/VERSION` | The pin, on the Mac. On Windows, `tooling/win/build.ps1` writes Stedding's product version before the build and keeps Chromium's on `CHROMIUM_VERSION` (patch 0073, S-72). Not edited by hand. |
| About | The About menu opens `chrome://settings/help` | grd and icon replacement |
| User agent | — | Left as Chromium emits it |

`BRANDING` is a short key/value file. `PRODUCT_FULLNAME` and
`PRODUCT_SHORTNAME` are `Stedding`. `MAC_BUNDLE_ID` is `dev.stedding.Stedding`.
`COMPANY_FULLNAME` is `The Stedding Authors`
([ADR 0009](decisions/0009-macos-bundle-identifier.md)). Replacing that file
drives most of the macOS bundle and costs no patch.

**There is no third brand directory.** Upstream's switch is
`is_chrome_branded`, choosing `chrome/app/theme/chromium/` or
`chrome/app/theme/google_chrome/`. Grit includes hard-code `chromium/`.
Stedding's assets overwrite the `chromium/` tree in place, which is what
`tooling/apply-branding` does, and why it runs before `gn gen`.

### Three identifiers do not follow `MAC_BUNDLE_ID`

Most ids derive from `MAC_BUNDLE_ID`: the app, the helpers, the framework, PWA
and app-shim ids, Mach and Mojo rendezvous names, the keychain groups under
`chrome/`, and the Crashpad filename.

Three files still hard-code `org.chromium.Chromium` (`BACKLOG.md` S-175;
SER-3 in [docs/history/plan-2026-09-26.md](history/plan-2026-09-26.md)). No
patch in the series changes those comparisons.
[ADR 0009](decisions/0009-macos-bundle-identifier.md) records that they do not
follow `MAC_BUNDLE_ID`.

| Where | What |
|---|---|
| `build/apple/tweak_info_plist.py` | Matches the literal `org.chromium.Chromium` when it decides the direct-launch URL scheme. Patch 0068 edits this file only to set `CFBundleVersion`. Change the bundle id and the scheme can drop out of `Info.plist` while `chrome/browser/shell_integration_mac.mm` still returns `"chromium"`. |
| `net/device_bound_sessions/unexportable_key_service_factory.cc` | Hard-codes `.org.chromium.Chromium` for the keychain group. It cannot depend on `//chrome`, so it cannot read `MAC_BUNDLE_ID`. |
| `content/browser/media/capture/desktop_capture_util_mac.mm` | Lists `org.chromium.Chromium` among known browser prefixes, so Stedding's helpers and apps made from pages are not recognised for system audio capture ([docs/features/web-apps.md](features/web-apps.md)). |

Chromium's own updater is not what Stedding ships. No file in `tooling/args/`
enables it. The Mac uses Sparkle
([ADR 0022](decisions/0022-sparkle-updates-the-mac.md)). Windows uses Stedding's
updater (patch 0073, [ADR 0023](decisions/0023-updates-on-windows-and-linux.md)).
The updater and enterprise-companion branding files upstream keeps for a
Chrome-branded build are unused here.

Some hard-coded `org.chromium.*` strings stay on purpose. The
`org.chromium.extension` and `org.chromium.shortcut` UTIs, and the clipboard
pasteboard types, are shared with other Chromium browsers (ADR 0009). Renaming
them would break interchange.

**Icons are copied, not compiled.** `tooling/apply-branding` overwrites the
prebuilt `app.icns` and `Assets.car`, and the `.icon` sources. Overwriting a
source the build compiles is still asset replacement, not a patch.

## Updates and distribution

macOS builds that ship are signed with a Developer ID, notarized and stapled.
That has been true since beta 10 (2026-10-01). `tooling/sign-release` runs
Chromium's signer (`chrome/installer/mac/signing`). After stapling, `spctl`
must answer `accepted, source=Notarized Developer ID`, or the script fails.
The identity, the notary profile and the App ID's provisioning profile are
`STEDDING_SIGN_IDENTITY`, `STEDDING_NOTARY_ARGS` and
`STEDDING_PROVISION_PROFILE`, from the operator's environment, never from this
repository. The profile is what lets Touch ID passkeys work
([ADR 0033](decisions/0033-passkeys-and-the-signing-team.md)), and it names the
certificate, so a new certificate needs a new profile.

Patch 0051 is what makes that signer work with a Developer ID on current
macOS. Upstream assessed the app with Gatekeeper before notarizing it, which
rejects every unnotarized Developer ID app, and it dropped the notarization
level from the per-distribution config
([HANDOFF.md](HANDOFF.md) trap 49). The signer waits two hours for Apple at
most. A team's first submission can take longer, and a timed-out run loses its
signed copy with the signer's work directory, so the rerun signs again.

From 0.3.0 beta 16 the disk image is signed, notarized and stapled as well
(`tooling/package-dmg`), with the same two variables. Gatekeeper checks the
app inside. The image's own signature is for whatever inspects the download
before it is opened.

Windows code signing is still open (`BACKLOG.md` S-56).

**Update checks go to GitHub.** There is no update server of ours
([ADR 0014](decisions/0014-github-releases-as-update-channel.md), partly
superseded by [ADR 0022](decisions/0022-sparkle-updates-the-mac.md) and
[ADR 0023](decisions/0023-updates-on-windows-and-linux.md)). The feeds are
files in this repository, served from GitHub:
`updates/appcast.xml` on the Mac and `updates/appcast-windows.xml` on Windows,
both from `raw.githubusercontent.com`. No account, no identifier, no telemetry.
GitHub sees an IP and a timing pattern, and [PRIVACY.md](PRIVACY.md) names the
endpoints.

On the Mac, Sparkle reads the signed feed. Updates are on by default, with a
switch in Settings › Stedding › Updates. The browser checks at a launch when
the last check is more than an hour old, and every six hours while it runs
(patch 0078; the owner, 2026-10-21). Sparkle checks the image's EdDSA signature
and the app's Developer ID. A downloaded update installs at quit, or from the
sidebar's pill ([docs/features/updates.md](features/updates.md), ADR 0022). An
unsigned local build does not start Sparkle, so a development copy does not
replace itself.

On Windows, Stedding's own updater has done this since 0.2.0 beta 19 (patch 0073,
ADR 0023, [ADR 0026](decisions/0026-a-windows-update-key.md) for its key). It
uses the same schedule (patch 0078), checks the feed's Ed25519 signature
against the key every Windows build carries, checks the installer's length and
signature, and runs the installer while the browser is open. The sidebar's
pill offers the restart.

Linux has no build yet. Packages and their updates are planned (`BACKLOG.md`
S-216, ADR 0023).

Updates are full-size. A delta format waits on that path being correct, and on
the signature check.

**stedding.dev is a website.** Its repository is `ysalitrynskyi/stedding.dev`:
Astro, static, Cloudflare Pages. It carries the download link, release notes,
the security policy and the source link. It is not on the update path
(ADR 0014). If the site is down, updates still work.

## Upstream tracking

The pin follows the newest Chromium stable for these platforms, once that
build is on more than 1% of a platform's stable users (ADR 0007). Extended
stable is not the channel. A security point release is rebased, rebuilt and
shipped on the timetable in [ROADMAP.md](ROADMAP.md#the-quality-bar): 7 days
for an in-the-wild fix, 14 days otherwise. `tooling/check-pin` and the
`upstream` workflow are the clock.

A point release on the same milestone should apply with no manual conflict. A
conflict that shows up on a routine point release means the patch is in the
wrong layer.

A new milestone is scheduled work, done on a branch and merged when the series
applies and the browser passes the release checklist in ROADMAP.md ("The
quality bar"). Merging M157 on 2026-10-28, before its stable rollout, is the
exception ADR 0007 records.

## CI reality

A GitHub-hosted runner cannot build Chromium. The checkout and a build need
more disk, and more hours, than a default runner has. A self-hosted or cloud
builder, macOS for the Mac image and Windows for the Windows image, is
`BACKLOG.md` S-49. It costs money, so it is the owner's decision. It was
written here as an ADR due before M1. M1 is past, and that ADR does not exist.

Until it lands, builds, test runs and releases are made on the two machines.
The Windows build is made on a Windows PC. The Mac build is made on a Mac. No
workflow builds or tests the browser. Hosted CI does what a small runner can
do (`.github/workflows/`):

- **`checks`**, on push and pull request: `tooling/check-shell` (shellcheck at
  the version in `tooling/shellcheck-version`, and bash syntax),
  `tooling/check-repo` (links, ADR format, patch numbering and headers, no
  machine paths, the traps, the tests the specs cite, line endings),
  `tooling/check-pin --self-test`, and `tooling/check-disclosure --self-test`.
- **`disclosure`**, on a pull request: `tooling/check-disclosure`, the rule in
  [CONTRIBUTING.md](../CONTRIBUTING.md).
- **`series`**: `tooling/apply-patches --check` against the pinned tree, fetched
  at depth 1 and cached under the pin. No build
  ([HANDOFF.md](HANDOFF.md#what-needs-which-machine)).
- **`upstream`**: a daily `tooling/check-pin`. One tracking issue stays open
  while the pin is not current, and is closed when it is.

## Rejected alternatives

**Electron or CEF.** A shell on either one cannot offer full Chrome extension
compatibility. Those APIs live in Chrome's browser layer, not in the embedding
APIs. The extra runtime also costs memory and process behaviour. Extension
compatibility is a hard requirement of this project, which rules the wrapper
out on its own.

**Firefox.** Gecko is a real engine. Chrome extension compatibility there means
WebExtensions, with gaps, and the people this browser is for live in the Chrome
extension ecosystem. Zen Browser already does an Arc-style interface on
Firefox. The lane Stedding is in is Chromium compatibility without Chrome's
services attached.

**A hard fork of Chromium.** An engine of our own, on our own release clock,
means carrying Chromium's security response with a very small team. Chromium
ships security fixes continuously. A hard fork falls behind. The patch series
leaves the engine work with upstream and keeps the product work here.
