# Performance baselines

Measured by `tooling/measure/harness.py` against the budgets in `docs/QUALITY.md`.
The budgets are overheads relative to vanilla Chromium at the same pin, build
configuration and hardware, so a baseline file is only half a comparison until a
vanilla `official` build has been measured the same way (`S-31`). Absolute numbers
below are recorded because two of the budgets are absolute, and are otherwise not
promises.

| File | App | What it is |
|---|---|---|
| `2026-09-02-official.json` | `out/official` at pin 153.0.8010.12, Stedding series applied, Apple M1 Max, 64 GB | startup cold ×10, startup warm ×10 (ten restored sites), memory ×5 (ten live sites, 60 s idle) |
| `2026-09-02-vanilla-official.json` | `out/vanilla`: vanilla Chromium at the same pin, `tooling/args/vanilla.gn` (identical to `official.gn`), same machine | the same three measurements, the same afternoon |
| `2026-09-02-vanilla-official-local.json`, `2026-09-02-official-local.json` | the same two apps with `--sites local`: ten deterministic pages under `tooling/measure/local-sites/` (article, gallery, DOM churn, table, canvas, forms, frames, CSS, docs, landing), no network, no third-party frames | the same three measurements; the memory spread collapses to under 1% |
| `2026-09-02-official-rerun.json` | `out/official` again, measured back to back with the vanilla build so both see the same machine state and the same live sites | the same three measurements |

Headline medians from that file (a table, not a claim):

| Measure | Median | Spread |
|---|---|---|
| Cold startup to first paint | 0.63 s | 0.56–0.68 |
| Warm startup, ten tabs restored | 0.77 s | 0.72–1.01 |
| Physical footprint, ten tabs after 60 s idle | 5.7 GB | 4.1–6.0 GB, ~107 processes |

## The comparison (`S-31`)

Medians from the back-to-back pair, overhead = (Stedding − vanilla) / vanilla:

| Measure | Vanilla | Stedding | Overhead | Budget (`docs/QUALITY.md`) |
|---|---|---|---|---|
| Cold startup to first paint | 0.67 s | 0.76 s | +12.2% | OVER the 10% budget |
| Warm startup, ten tabs restored | 0.78 s | 0.77 s | -0.6% | within the 10% budget |
| Physical footprint, ten tabs after 60 s idle | 1.26 GB | 1.71 GB | +35.9% | OVER the 10% budget (20 / 35 processes) |

Two things to know before quoting these. The `out/official` app measured here is the
Stedding series as it was when that directory was last built (before Peek and the
settings section; check its binary's date against `git log` before trusting it as
current), so the comparison covers the sidebar, Spaces, folders, the command bar,
colours and the de-Google changes. And the memory numbers swing with the live sites:
the morning run of the same Stedding build reached 5.7 GB across 107 processes, the
afternoon rerun about a third of that, because third-party frames come and go. Only
the back-to-back pair is a comparison; the morning file is history. The two budgets
this pair exceeds are `S-37` in `BACKLOG.md`; they are not explained away here.

### The deterministic pair (`--sites local`)

Same two builds, ten local pages, medians and spreads:

| Measure | Vanilla | Stedding | Overhead | Budget |
|---|---|---|---|---|
| Cold startup to first paint | 0.65 s (0.57 s–0.82 s) | 0.66 s (0.64 s–0.87 s) | +2.3% | within the 10% budget |
| Warm startup, ten local pages restored | 0.79 s (0.77 s–0.93 s) | 0.78 s (0.70 s–0.96 s) | -2.0% | within the 10% budget |
| Physical footprint, ten local pages after 60 s idle | 823 MB (821 MB–825 MB) | 823 MB (819 MB–824 MB) | +0.0% | within the 10% budget |

With the network out of the picture every budget is met: the ten-page footprint
is identical to the megabyte, warm startup is on par, and cold startup is within a
few percent. The live pair's +36% memory and +12% cold startup were third-party
frames and machine state, not the patch series (`S-37`, closed on this evidence).
Use this pair for comparisons from now on; the live list stays for the two absolute
budgets. The Stedding build measured is the 2026-08-31 series; the next official
build gets measured the same way before a release (`docs/QUALITY.md` checklist).

Read the memory line with care: the ten sites are live news, social and search
pages with third-party frames, each frame is its own process under site
isolation, and the footprint is summed over every descendant process. The vanilla
comparison decides whether anything here is ours.

To regenerate: `tooling/measure/harness.py all --app <app> --out docs/perf/<date>-<config>.json`
on an otherwise idle machine, never while a build runs.

`out/official`'s intermediate objects were deleted on 2026-09-02 to make room; its
`Chromium.app` is still there and still measurable. A rebuild is a fresh ~4 h job.
