# tooling/

Scripts that build Stedding. The rule these exist to serve is in `../AGENTS.md`: the
documented procedure and the executed procedure must be the same thing, so anything a
contributor is told to do lives here as a script rather than as prose to be retyped.

Every script is idempotent, fails with the remedy rather than a stack trace, and reads
its configuration from `chromium-version` — never from a value typed twice.

## The files

| File | What it does |
|---|---|
| `dev` | **Start here.** `build`, `test <feature>`, `capture`, `patch`, `check`, `status` — the loop in [docs/AGENT-LOOP.md](../docs/AGENT-LOOP.md) as one command. Owns the feature→gtest-filter table. |
| `assert-capture` | Checks a capture against a probe spec (points in DIPs with expected colour or luminance), optionally against a golden PNG. `--record` fills a spec from a capture you have inspected. `tooling/dev capture --assert <spec>` runs the spec's own capture command and checks it. |
| `probes/` | Probe specs. `window.json` is the reference window: sidebar edge, content corner radius, toolbar height, essentials grid, no Chromium buttons, switcher at the bottom. |
| `drive` | Drives the built browser with synthetic clicks, drags and keys from a steps file, captures after steps, quits through a real AppleEvent so session files flush. The live half of every feature spec. Never on a machine someone is using. |
| `status` | Prints what the repo and checkout actually contain (pin, patch count, tests per feature, backlog). Docs quote this instead of typing numbers. |
| `chromium-version` | The pinned upstream Chromium version. Single source of truth. Policy: [ADR 0007](../docs/decisions/0007-chromium-version-pin.md). |
| `lib.sh` | Shared paths, logging, and preflight checks. Sourced, never executed. |
| `bootstrap-depot-tools` | Verifies the host toolchain, then installs or updates `depot_tools`. |
| `sync-chromium` | Materialises the Chromium tree at the pin, outside this repository. |
| `build-chromium` | `gn gen` + `autoninja` for a named configuration. |
| `apply-branding` | Copies `../branding/` assets over the checkout. Not a patch. |
| `apply-patches` | Replays the patch series onto the pin as commits on `stedding-work`. |
| `update-patches` | Turns those commits back into `../patches/`. |
| `repair-checkout` | Rewrites git cache paths after a checkout is moved. |
| `update-pin` | Moves the Chromium pin to the newest stable and checks the series still applies. |
| `package-dmg` | Packages a built app into an installable `.dmg`. |
| `brand/generate.py` | Regenerates the whole brand system from one geometry file. |
| `check-repo` | Repository hygiene: shell portability, links, ADRs, patch series, the pin, no machine paths. |
| `verify-build` | Runs a built browser and checks it renders, does WebGL, and decodes video. |
| `measure/` | Performance harness and the fixed ten-site list for the QUALITY.md budgets. |
| `args/` | `gn` argument files, one per build configuration, with the reasoning per flag. |

## Normal use

```bash
tooling/bootstrap-depot-tools     # once per machine
tooling/sync-chromium             # once per pin change
tooling/apply-patches             # our patch series
tooling/apply-branding            # our name and icon
tooling/build-chromium release
tooling/verify-build --app ~/chromium/src/out/release/Stedding.app
tooling/package-dmg release
```

## Following upstream

```bash
tooling/update-pin                # is there a newer stable? changes nothing
tooling/update-pin --apply        # take it, sync, check the series still applies
```

A scheduled workflow (`.github/workflows/upstream.yml`) runs this comparison daily and
opens a single tracking issue when we fall behind. A patch that conflicts on a routine
point release is in the wrong layer — see
[docs/ARCHITECTURE.md](../docs/ARCHITECTURE.md).

Full prerequisites, measured build times and sizes, and known failure modes are in
[docs/ARCHITECTURE.md](../docs/ARCHITECTURE.md#build-system).

## Branding

Branding is asset replacement, not patching: upstream's switch is boolean and grit
hardcodes the `chromium/` theme path, so our files overwrite that tree in place. It
must run before `gn gen`, and it leaves the Chromium checkout dirty on purpose so
`git status` shows exactly what changed.

```bash
tooling/apply-branding --check     # what would change; touches nothing
tooling/apply-branding             # copy branding/ into the checkout
tooling/apply-branding --revert    # restore Chromium's originals
```

Order matters when both are in play: `apply-patches` first (it requires a clean tree),
then `apply-branding`, then build.

## Patch workflow

Commits are the working representation; `../patches/` is the serialised form.

```bash
tooling/apply-patches             # series -> commits on stedding-work
# ... edit, commit, reorder, rebase ...
tooling/update-patches            # commits -> series
tooling/check-repo patches        # verify the result
```

Every patch commit message must carry `Why:` and `Removable when:` fields.
`update-patches` refuses to export a series without them, because a patch nobody can
justify or delete is how a minimal patch set stops being minimal.

### `capture-ui`

Screenshots the built browser's own window and nothing else, so UI changes can be
compared against `docs/UI-SPEC.md` without photographing whatever else is on the
screen. Works on a window that is behind others or on another macOS Space, so it
never raises the window or takes focus.

```
tooling/capture-ui --out /tmp/now.png --size 1400x880
```


## Paths

All overridable by environment variable; defaults suit a fresh machine.

| Variable | Default | What |
|---|---|---|
| `STEDDING_ROOT` | the repository root | This repository |
| `DEPOT_TOOLS_DIR` | `~/depot_tools` | Chromium's `depot_tools` |
| `CHROMIUM_ROOT` | `~/chromium` | `gclient` checkout root |
| `CHROMIUM_SRC` | `$CHROMIUM_ROOT/src` | Chromium source tree |

The Chromium tree is never committed to this repository.
