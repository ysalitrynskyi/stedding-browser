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

Headline medians from that file (a table, not a claim):

| Measure | Median | Spread |
|---|---|---|
| Cold startup to first paint | 0.63 s | 0.56–0.68 |
| Warm startup, ten tabs restored | 0.77 s | 0.72–1.01 |
| Physical footprint, ten tabs after 60 s idle | 5.7 GB | 4.1–6.0 GB, ~107 processes |

Read the memory line with care: the ten sites are live news, social and search
pages with third-party frames, each frame is its own process under site
isolation, and the footprint is summed over every descendant process. The vanilla
comparison decides whether anything here is ours.

To regenerate: `tooling/measure/harness.py all --app <app> --out docs/perf/<date>-<config>.json`
on an otherwise idle machine, never while a build runs.
