# Performance measurements

**There is no current measurement.** The budgets in `docs/ROADMAP.md#the-quality-bar` are overhead against vanilla Chromium at the same pin, configuration and hardware. The only comparison on record is from 2026-09-02, below. The pin and the series have moved since (`tooling/dev status`), and nothing has been measured again. That record was taken with the `official` arguments; published releases are `release` on the Mac and `win-release` on Windows (`docs/HANDOFF.md`, "Release channel"), so it is a record of that build, not of a release.

## How to measure

Run `tooling/measure/harness.py` on an otherwise idle Mac, and not while a build is running. It reads a macOS app bundle and stops on any other system, so Windows has no budget measurement yet (`docs/ROADMAP.md`, M8).

```bash
tooling/measure/harness.py all --sites local --app <vanilla app> --out docs/perf/<date>-vanilla-<config>-local.json
tooling/measure/harness.py all --sites local --app <Stedding app> --out docs/perf/<date>-<config>-local.json
```

Measure the two builds one after the other, at the same pin and in the same configuration, the official arguments: `release` leaves out PGO and LTO. `tooling/args/vanilla.gn` has the same arguments as `tooling/args/official.gn`. Build the vanilla app from the checkout detached at the pin, after `tooling/apply-branding --revert`. `tooling/build-chromium` builds only a checkout that is at the pin, or a descendant of it. Name each new file with the build, the configuration and the pin.

`--sites local` loads the ten pages in `tooling/measure/local-sites/` (`sites-local.txt`) as `file:` URLs, with no network. That list is the one for the overhead budgets. `--sites live` loads the ten sites in `tooling/measure/sites.txt`, and needs the network. Warm startup and memory use the list `--sites` names. Cold startup always times a trivial local page. The harness does not measure the sidebar tab switch or the command bar.

What the harness records:

- **Startup** is the time from launch to the first painted frame of a trivial local page, ten runs of each mode. That is the working reading of "first accepted input". One warm-up launch is discarded. A binary's first run also pays to fault it into the page cache, once per machine, not once per start.
- **Memory** is physical footprint, the figure Activity Monitor shows, read with `proc_pid_rusage` and summed over the launched process and its descendants. Each of five runs waits 30 seconds for the pages to load and 60 seconds idle. Summed RSS would count every shared page once per process: the harness recorded 9599 MB of RSS for a session whose footprint was 3104 MB.
- **Processes.** The harness prints how many processes it summed. A count that differs between the two builds is itself a finding.

## The record of 2026-09-02

Apple M1 Max, 64 GB, macOS 26.5.2. Both apps report `153.0.8010.12`. Stedding is the series of 8 patches as it was on 2026-08-31, before Peek and the settings section, built as `official`. Vanilla is the pin, built as `vanilla` with the same arguments.

| File | What it is |
|---|---|
| `2026-09-02-official.json` | Stedding, live sites, 04:39 UTC |
| `2026-09-02-vanilla-official.json` | Vanilla, live sites, 14:16 UTC |
| `2026-09-02-official-rerun.json` | Stedding, live sites, 14:27 UTC, after that vanilla run |
| `2026-09-02-vanilla-official-local.json`, `2026-09-02-official-local.json` | The same two apps, `--sites local`, 17:05 UTC and 17:14 UTC |

The local pair. Medians, with the minimum and maximum. Overhead is (Stedding − vanilla) / vanilla, from the medians:

| Measure | Vanilla | Stedding | Overhead | Budget |
|---|---|---|---|---|
| Cold startup to first paint | 0.65 s (0.57–0.82) | 0.66 s (0.64–0.87) | +2.3% | within 10% |
| Warm startup, ten local pages restored | 0.79 s (0.77–0.93) | 0.78 s (0.70–0.96) | −2.0% | within 10% |
| Physical footprint, ten local pages after 60 s idle | 823 MB (821–825) | 823 MB (819–824) | +0.0% | within 10% |

Both used 17 processes.

The live pair (14:16 UTC and 14:27 UTC):

| Measure | Vanilla | Stedding | Overhead | Budget |
|---|---|---|---|---|
| Cold startup to first paint | 0.67 s (0.62–0.75) | 0.76 s (0.71–0.82) | +12.2% | over 10% |
| Warm startup, ten tabs restored | 0.78 s (0.75–0.96) | 0.77 s (0.74–0.97) | −0.6% | within 10% |
| Physical footprint, ten tabs after 60 s idle | 1.26 GB (1.13–2.13) | 1.71 GB (1.27–1.96) | +35.9% | over 10% (20 and 35 processes) |

The local rows are within 10%, and `S-37` was closed on them. The live cold start and footprint are over 10%. Cold startup does not load the site list, so third-party frames do not explain the live cold miss; the live and local cold runs were hours apart. The live footprint does load the ten sites, and the local footprint shows no overhead. The same Stedding build at 04:39 UTC, on the live list, measured 5697 MB across 107 processes. The live pair's process counts, 20 and 35, were not explained.

Of the six budgets, three were measured. Sidebar tab switching and the command bar have no measurement in the harness.
