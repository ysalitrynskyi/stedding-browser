# The agent loop — how a change gets made here

The working procedure for a change to Stedding, for a person or an agent. `tooling/dev`
runs the routine steps; a command that exists only in prose is a bug.

Screenshots prove pixels. Tests prove behaviours. Using the product shows that it works
for a person (trap 2, trap 58).

## Ask once, up front

Before the first long job, one message to the operator with every decision the job needs:

- May I drive the screen and keyboard (`tooling\win\drive.ps1`, `tooling/drive`)? Real
  input only with a yes, and only into the window under test.
- May I push, and release when the work is done? Neither happens without a yes in chat.
- Which output directories may I delete? Your own build output: yes. Anything else: ask.
- Is the machine mine overnight? A Windows build can grow the page file until a restart
  (trap 54).
- Is there a setting only you can flip (Windows clipboard history, for Win+V)? System
  settings are not yours to change.
- Will you close your own Stedding for the installer test? `tooling\win\test-installer.ps1`
  refuses while one runs; only an installer of the installed version repairs (trap 62).
  The installed build is the operator's daily browser: never yours to close.
- Will you quit Arc and any clipboard manager before the keyboard checks? Arc takes ⌥⌘N
  (trap 64); a clipboard manager such as Maccy takes ⇧⌘C from every app (trap 94).

## Order of evidence

Cheapest and most revealing first. Use the product before any suite.

| Step | What to run | What it is for |
|---|---|---|
| Use the product | A fresh profile; click, drag, type; light and dark | Faults no test asked about: platform wording, contrast, clipping |
| Shipping suites | `tooling/dev test all` | Regressions in the tests that exist |
| Checks build | `STEDDING_TEST_OUT=win-checks` or `mac-checks` | DCHECKs and dangling pointers |
| ASan | `STEDDING_TEST_OUT=win-asan` | Memory errors |
| Debug | `tooling/args/debug.gn`, `win-debug.gn` | Only when a check names that build |

A change to who owns or frees a tab, its contents or a view runs its suites on the checks
build, and under ASan before a release (`PLAN.md`, "When an item is done", rule 4).

## Long jobs

- **One detached job, one status file, one finish line.** `tooling\win\build-until-done.ps1`
  runs `build.ps1` chunk after chunk, writes `out\<config>\supervisor.log` and ends it with
  `SUPERVISOR_EXIT=<code>` (codes in its header). Start it detached (trap 54) and wait for
  that line. Exit 4: the same steps were killed at the end of three chunks; time one by
  hand (trap 57). A suite or a sync has the same shape.
- **Cap the jobs.** siso's default parallelism runs a full Windows build out of memory
  (trap 54); the supervisor defaults to 12 jobs, 45-minute chunks. ASan at 10.
- **A status line before any wait over ten minutes,** with a number in it.
- **A finished job leaves nothing behind.** `tooling/leftovers --clean` on the Mac and
  `tooling\win\leftovers.ps1 -Clean` on the PC end with "nothing left over". On the Mac a
  browser leg starts only under 12,000 WindowServer windows; past about 17,900 the login
  session ends (trap 147).
- On Windows each test binary runs under `timeout` for `STEDDING_TEST_BUDGET_S` seconds
  (900 by default), which also lets the tests that need a really active window pass
  (trap 56). A `win-asan` browser suite needs a longer budget (`docs/HANDOFF.md`, "The
  Windows build").

## One pass should find everything

A check that stops at its first failure hides the rest. Take every distinct failure from
the run, fix them together, rerun once.

- The browser legs' failures run again alone at the end of the same sweep
  (`STEDDING_RERUN_ALONE`, 2 runs). The summary marks each "fails alone" (a real failure),
  "fails alone k of n" (a race), or "passed alone" (it failed only among the others: it
  belongs in `SERIAL_BROWSER_TESTS`, or its race wants finding). All three are failures
  (`docs/history/plan-2026-09-26.md` PLT-12); the summary only says where to look.
- `tooling/dev` prints `tooling/digest-sanitizer` when the log holds a DCHECK, a dangling
  pointer or an ASan report: each distinct one once, with this project's first frames.
  `STEDDING_TEST_LOG` keeps the raw log, one file per binary.
- To see past the first abort, make the check log instead of abort in a local edit and
  revert it before folding.
- Fold each fix into the patch that owns the code (`tooling/fold-fix`; it stops on a
  conflict and moves nothing, trap 22). A fold that would conflict with a later patch on
  the same lines becomes its own patch (`patches/README.md`).

## Real use, safely

On Windows, `tooling\win\drive.ps1` with the operator's yes; `capture.ps1`, `cdp.ps1` and
`hit-test.ps1` without. On the Mac, `tooling/drive` with a yes and nobody at the machine
(trap 27: it does not watch the operator's input as `drive.ps1` does); `tooling/capture-state`
without. `drive.ps1` sends input only while its window is in front and the operator's last
input is six seconds old; captures are of the window only (trap 133).

Before a release, and for the core-loop gate (`S-173`), run the scripts in
`docs/features/acceptance.md` and record each run there.

- A fresh profile, no seed: the welcome flow, in light and in dark
  (`tooling/capture-state --seed light|dark`).
- Every gesture the specs name, with the real pointer: each kind of row in the sidebar and
  the rail; drags onto a folder, a Space chip and the page; Space switches by chip, key and
  wheel; Copy Link; the screenshot; full screen on a video; resize.
- Read the state from the browser, not a picture: `Drive-Visible` and `Drive-Rows` on
  Windows, `shot` and `capture-state` on the Mac. Read the strings: wording from one
  platform reads wrong on the other.
- Two browsers from one executable on the same `--remote-debugging-port` leave the second
  without UI (trap 61).

## Search and read cheaply

- In the Chromium checkout, `git grep -n <pattern> -- <dir>`; `grep -r` and `find` time out.
- Cap the output of a command you have not run before.
- A script longer than three lines is a file, not a heredoc.
- Read text from UI Automation or DevTools where either can give it.

## The loop

```
research  →  spec  →  failing test  →  implement  →  build  →  test  →  use it  →  patch  →  commit
```

1. **Research the seam, read-only.** Find the upstream machinery to reuse and name the
   files the change edits. A file with more than ~150 commits in a year
   (`git log --oneline --since=1.year -- <file> | wc -l`) is one to avoid: put the code in
   a new Stedding file and call it from one hunk.
2. **Spec the behaviour** in `docs/features/<feature>.md`: one numbered behaviour per row,
   each a sentence a test can decide. The spec is the definition of done.
3. **Write the failing test.** Model logic: `space_model_unittest.cc` (no window). The
   active tab or what the user sees: `BrowserWithTestWindowTest`
   (`space_model_window_unittest.cc`). A click or a drag: a browser test in
   `chrome/test/stedding/`. The behaviour id goes in a comment above the test. Watch it
   fail for the right reason.
4. **Implement** the smallest change that turns it green: new files in Stedding's
   directories, an upstream hunk only at the seam (`docs/ARCHITECTURE.md`, "Where patches
   are allowed to live").
5. **Build and test.** `tooling/dev test <feature>` (the Mac builds first; on Windows build
   with `build-until-done.ps1 -Targets unit_tests,stedding_browser_tests` and pass
   `--no-build`). `tooling/dev test all` before a commit. `STEDDING_TEST_OUT` points the
   same command at a checks or ASan build.
6. **Use it.** Launch the build and do the thing. Pixels on the Mac:
   `tooling/dev capture --assert tooling/probes/window.json`, `tooling/capture-state`; on
   Windows, `capture.ps1` and `drive.ps1`'s window shot. Measure.
7. **Patch.** Commit in the checkout with `Why:` and `Removable when:` footers. A fix folds
   into its feature's commit with `tooling/fold-fix <commit> <files>`, which rewrites no
   other file (a `--fixup` rebase touches them all, trap 44). Then `tooling/dev patch`
   regenerates `patches/` and runs `check-repo`.
8. **Commit this repo:** the spec, the backlog row and the regenerated patches together.

## How the tests are shaped

- **A unit test names one behaviour and fails for one reason.** Near-copies with different
  inputs are one table-driven test with a `SCOPED_TRACE` per row.
- **A browser test is a scenario.** Steps that share a setup are one test, each step with
  its own `SCOPED_TRACE`, the state put back between steps. Keep a body near 150 lines.
  A `PRE_` chain is one test.
- **Extend before adding.** A new step in an existing scenario, or a new row in a table, is
  the default; a new test needs a setup no other test has.
- **Size a timing test for the slow builds.** A test that measures speed asserts its clock
  only where `DCHECK_IS_ON()` and `ADDRESS_SANITIZER` are off, and makes less work there:
  the 443-pin test ran a checks build out of time and an ASan run out of memory.
- **Which leg runs it.** The browser suite runs four at a time on the Mac and two on
  Windows (`STEDDING_BROWSER_JOBS`, trap 88), then `SERIAL_BROWSER_TESTS` one at a time:
  the real pointer, the active window, the clipboard, picture-in-picture, a page that must
  paint, a command bar held open, frames counted on screen, full screen, a minimised
  window. A new fixture of that kind goes on that list. `upstream` is Chromium's own suites
  over the code the series changes; `tooling/dev test rebase` is the wider ring after a
  pin bump (trap 31).

## Rules that are not optional

- **No behaviour ships without a test id in its spec.** A row whose test is "none yet" is
  a gap with a backlog item.
- **Nothing runs unattended without a number moving;** a budget stops what stands still.
- **Never edit the checkout while a build runs** (trap 1). `tooling/dev build` refuses to
  start beside another build.
- **Every pin move reads Chrome's field trials:** `tooling/field-trials --save <dir>` after
  `tooling/update-pin --apply`; a 100% launch that needs no Google service is taken, or a
  backlog row says why not (`S-240`; that is how `S-236` was missed).
- **Numbers in docs come from `tooling/dev status`.** `tooling/check-repo truth` fails on
  known stale phrases.
- **One backlog:** `BACKLOG.md`, by S- id. The 2026-09-26 audit's ids (TAB-1, PLT-3)
  resolve in `docs/history/plan-2026-09-26.md`. Other docs cite ids, never their own lists.
- **Anything that owns a tab needs a test** (trap 2). **Anything a person clicks needs to
  have been clicked** (trap 58).

## Several agents at once

| Role | Does | Does not |
|---|---|---|
| explorer | Reads the pinned tree; returns `file:line` seams, churn, precedents | Edit |
| builder | Steps 2–8 for one spec row or backlog id | Widen scope |
| reviewer | Reads the diff against the spec; runs `tooling/dev test all` | Fix silently |

A builder hands back the backlog id, the behaviour ids now green, the test command and
the patch numbers. The critical path stays in the session that has the context.

- **One build at a time** (`out/<config>/.stedding-build.lock.d`; `tooling/dev build`
  refuses beside another). No checkout edits during a build (trap 1).
- **One user of the screen at a time.** Browser tests open windows and the drive scripts
  move the pointer; take turns.
- **Drive a copy beside the owner's Stedding:** `tooling/test-copy make` after each build,
  `tooling/test-copy launch` (its pid; the flags that keep the owner's keychain and firewall
  quiet), `tooling/test-copy quit`. `python3 tooling/drive-window.py <pid> <steps>` drives it.
- **See the new test fail:** put the fixed files back to `HEAD`, build, run the new tests,
  then restore and rebuild before any run that counts (trap 52).

## Cheap checks

```bash
tooling/dev test all        # the release sweep (--no-build on Windows)
tooling/dev check           # check-repo, check-shell
tooling/dev status          # what the repo actually contains, for docs
tooling/check-repo          # every hygiene check
```

What Arc switchers asked for in 2026-08 is `docs/history/arc-switchers-2026-08-31.md`.
