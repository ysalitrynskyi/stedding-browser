# tooling/

Scripts that build Stedding. The rule these exist to serve is in `../AGENTS.md`: the
documented procedure and the executed procedure must be the same thing, so anything a
contributor is told to do lives here as a script rather than as prose to be retyped.

Every script is idempotent, fails with the remedy rather than a stack trace, and reads
its configuration from `chromium-version` — never from a value typed twice.

## The files

| File | What it does |
|---|---|
| `chromium-version` | The pinned upstream Chromium version. Single source of truth. Policy: [ADR 0007](../docs/decisions/0007-chromium-version-pin.md). |
| `lib.sh` | Shared paths, logging, and preflight checks. Sourced, never executed. |
| `bootstrap-depot-tools` | Verifies the host toolchain, then installs or updates `depot_tools`. |
| `sync-chromium` | Materialises the Chromium tree at the pin, outside this repository. |
| `build-chromium` | `gn gen` + `autoninja` for a named configuration. |
| `apply-patches` | Replays the patch series onto the pin as commits on `stedding-work`. |
| `update-patches` | Turns those commits back into `../patches/`. |
| `repair-checkout` | Rewrites git cache paths after a checkout is moved. |
| `check-repo` | Repository hygiene: shell portability, links, ADRs, patch series, the pin, no machine paths. |
| `verify-build` | Runs a built browser and checks it renders, does WebGL, and decodes video. |
| `measure/` | Performance harness and the fixed ten-site list for the QUALITY.md budgets. |
| `args/` | `gn` argument files, one per build configuration, with the reasoning per flag. |

## Normal use

```bash
tooling/bootstrap-depot-tools     # once per machine
tooling/sync-chromium             # once per pin change
tooling/build-chromium release    # as often as you like
```

Full prerequisites, measured build times and sizes, and known failure modes are in
[docs/ARCHITECTURE.md](../docs/ARCHITECTURE.md#build-system).

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

## Paths

All overridable by environment variable; defaults suit a fresh machine.

| Variable | Default | What |
|---|---|---|
| `STEDDING_ROOT` | the repository root | This repository |
| `DEPOT_TOOLS_DIR` | `~/depot_tools` | Chromium's `depot_tools` |
| `CHROMIUM_ROOT` | `~/chromium` | `gclient` checkout root |
| `CHROMIUM_SRC` | `$CHROMIUM_ROOT/src` | Chromium source tree |

The Chromium tree is never committed to this repository.
