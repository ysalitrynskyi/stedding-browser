# The agent loop — how a change gets made here

This is the working procedure for a change to Stedding, for a person or an agent.
`tooling/dev` runs the routine steps. A command that exists only in prose is a bug:
the command lives in the script.

The sections through "Cheap checks" are how to spend a session and how one change is
made. "Evidence" is what Arc switchers asked for on 2026-08-31, and where the product
stands on it.

Screenshots prove pixels. Tests prove behaviours. Using the product is what shows that
it works for a person (trap 2, trap 58).

## Ask once, up front

Before the first long job, one message to the operator, with every decision the job
will need:

- May I drive the screen and keyboard? On Windows, `tooling\win\drive.ps1`. On the Mac,
  `tooling/drive`. Real input only with a yes, and only into the window under test.
- May I push, and release when the work is done? Neither happens without a yes in chat.
- Which output directories may I delete? This session's own build output: yes. Anything
  else: ask.
- Is the machine mine overnight, and does a reboot need a reason? A Windows build can
  grow the page file, and that space stays until a restart (trap 54).
- Is there a setting only you can flip? Windows clipboard history, for the Win+V check.
  System settings are not yours to change.
- Will you close your own Stedding for the installer test?
  `tooling\win\test-installer.ps1` refuses to upgrade, install or uninstall while one is
  running. A later release installs beside a running copy. An installer of the version
  already installed still repairs (trap 62). The installed build is the operator's
  daily browser, and it is never yours to close.
- Will you quit Arc and any clipboard manager before the keyboard checks? While Arc
  runs it takes ⌥⌘N (trap 64). A clipboard manager such as Maccy takes ⇧⌘C from every
  app (trap 94).

## Order of evidence

Cheapest and most revealing first. Use the product before any suite.

| Step | What to run | What it is for |
|---|---|---|
| Use the product | Launch a fresh profile. Click, drag, type. Light and dark | Faults no test asked about: wrong platform wording, contrast, clipping, a control left up |
| Shipping suites | `tooling/dev test all` | Regressions in the tests that exist |
| Checks build | `win-checks` or `mac-checks`, via `STEDDING_TEST_OUT` | DCHECKs and dangling pointers. The first sanitizer to run |
| ASan | `win-asan`, via `STEDDING_TEST_OUT` | Memory errors, before a release when the change touches lifetimes |
| Debug | `tooling/args/debug.gn` or `win-debug.gn` | Only when a check names that build |

A change to who owns or frees a tab, its contents or a view — an unload that puts new
contents in a tab, a strip torn down while it animates, a view rebuilt under an
observer — runs its suites on `win-checks` or `mac-checks`, and under ASan (`win-asan`)
before a release (`PLAN.md`, "When an item is done", rule 4).

## Long jobs

- **One detached job, one status file, one finish line.**
  `tooling\win\build-until-done.ps1` runs `tooling\win\build.ps1` chunk after chunk,
  writes `out\<config>\supervisor.log`, and ends it with `SUPERVISOR_EXIT=<code>`.
  Start it detached, so the tool that started it cannot take it down (trap 54), and
  wait for that line. The script's header lists the exit codes. Exit 4 means the same
  steps were killed at the end of three chunks in a row: time one of them by hand
  before building on (trap 57).
- **The budget is a dead-man's switch.** It kills the steps in flight, so each stop
  costs their minutes. The supervisor's default is 12 jobs and chunks of 45 minutes.
  Cap the jobs: a full Windows build at siso's default parallelism runs out of memory
  (trap 54). `build.ps1` prints a progress line every minute.
- **A status line before any wait over ten minutes,** with a number in it (steps done,
  tests run, minutes to go).
- **A wait that is not a build** (a suite, a sync) has the same shape: start it
  detached, and wait on its finish line.

On Windows, `tooling/dev` runs each test binary under `timeout` for
`STEDDING_TEST_BUDGET_S` seconds (900 by default). That parent is also what lets the
tests that need a real active window pass (trap 56). A browser suite on `win-asan`
needs a longer budget (`docs/HANDOFF.md`, "The Windows build").

## One pass should find everything

A check that stops at its first failure hides the rest. Take every distinct failure
from the run, fix them together, and rerun once.

`tooling/dev` prints `tooling/digest-sanitizer` when the log contains a DCHECK, a
dangling pointer or AddressSanitizer. The digest gives each distinct DCHECK once, with
the first frames that are this project's; each dangling pointer as the pair of who
freed the memory and who still held it; each ASan report's head. Set
`STEDDING_TEST_LOG` to keep the raw log, one file per binary. To see past the first
abort, make the check log instead of abort in a local edit, keep the original beside
it, and revert that edit before folding. `git status` on the file is clean of that
edit first.

Fold each fix into the patch that owns the code (`tooling/fold-fix`). The script stops
on a conflict and moves nothing (trap 22). When a fold into the owner would conflict
with a later patch on the same lines, the change is its own patch (`patches/README.md`).

## Real use, safely

Use the product with `tooling\win\drive.ps1` when the operator has said yes, and with
`tooling\win\capture.ps1`, `cdp.ps1` and `hit-test.ps1` when input is not allowed. On
the Mac, `tooling/drive` when input is allowed, and `tooling/capture-state` when it is
not. `tooling/drive` moves the real pointer and runs only with nobody at the machine
(trap 27). It does not watch the operator's last input the way `drive.ps1` does.

Before a release, and for the core-loop gate (`S-173`), run the scripts in
`docs/features/acceptance.md` (`tooling/acceptance/mac/run-mac.sh`,
`tooling/acceptance/win/s173-live.ps1`) and record each run in that file.

- A fresh profile, no seed, no start URL. Click through the welcome flow. Then the
  same in light and dark. `browser.theme.color_scheme2` in the profile's Preferences
  is 1 for light and 2 for dark. `tooling/capture-state --seed light` and `--seed dark`
  write those values.
- Every gesture the specs name, with the real pointer: open each kind of row, in the
  sidebar and in the rail; drag a row onto a folder, onto a Space chip and onto the
  page; switch Spaces by chip, by key and by the wheel (`tooling/drive`'s `wheel` step
  on the Mac); copy the link; take the screenshot; go full screen on a video; resize.
- Read the state from the browser, not from a picture. On Windows, `Drive-Visible`
  (the page DevTools says is on screen) and `Drive-Rows` (UI Automation). On the Mac,
  `shot` and `capture-state`.
- Read the strings. Wording written on one platform reads wrong on the other.
- Two browsers from one executable with the same `--remote-debugging-port` leave the
  second with a window and no UI. Stop the first, or give each a port (trap 61).

`drive.ps1` sends input only while the window it launched is in front, and only while
the operator's own last input is at least six seconds old. Its screenshot is that
window's rectangle, taken only while the window is in front. On the Mac, `shot` and
`capture-state` photograph the launched pid's windows by id. `capture-state` fails if
that app becomes the frontmost app.

## Search and read cheaply

- In the Chromium checkout, `git grep -n <pattern> -- <dir>`. `grep -r` and `find`
  over that tree time out.
- Cap the output of a command you have not run before.
- A script longer than three lines is a file, not a heredoc. Backslashes in Windows
  paths and in regexes break inline Python and sed.
- Crop a screenshot to the window. Read text from UI Automation or DevTools where
  either can give it.

## The loop

```
research  →  spec  →  failing test  →  implement  →  build  →  test  →  use it  →  patch  →  commit
```

1. **Research the seam, read-only.** Find the upstream machinery to reuse, and name
   the files the change edits. Measure churn before touching a file:
   `git log --oneline --since=1.year -- <file> | wc -l`. Anything over ~150 is a file
   to avoid: put the code in a new file under a Stedding directory and call it from
   one hunk.
2. **Spec the behaviour.** Add or update `docs/features/<feature>.md`: one numbered
   behaviour per row (the spec's ids, such as B1), each a sentence a test can decide.
   The spec is the definition of done.
3. **Write the failing test.** Model logic follows `space_model_unittest.cc` (no
   window). The active tab, visibility, or what the user sees follows
   `BrowserWithTestWindowTest` (`space_model_window_unittest.cc` is the template).
   A click or a drag is a browser test in `chrome/test/stedding/`. Put the behaviour
   id in a comment above the test. Run it, and watch it fail for the right reason.
4. **Implement.** The smallest change that turns the test green. New files in
   Stedding's directories. An upstream hunk only where the seam is
   (`docs/ARCHITECTURE.md`, "Where patches are allowed to live").
5. **Build and test.** `tooling/dev test <feature>` runs that feature's `unit_tests`
   filter, and its `components_unittests` filter when `tooling/dev` has one. On the
   Mac the command builds those binaries. On Windows, `tooling/dev build` refuses:
   build with `tooling\win\build-until-done.ps1 -Targets unit_tests,stedding_browser_tests`
   (or one chunk of `build.ps1`) and pass `--no-build`. Browser tests are
   `tooling/dev test browser` or `tooling/dev test all`. Run `tooling/dev test all`
   before a commit. On a sanitizer directory
   (`STEDDING_TEST_OUT=win-checks`, `mac-checks` or `win-asan`) the same command
   points at that output and prints the digest when the run reports a finding.
6. **Use it.** Launch the build and do the thing (above). For pixels on the Mac,
   `tooling/dev capture --assert tooling/probes/window.json` checks the probes in
   the spec, and `tooling/capture-state` photographs a state a feature param can
   recreate without input. On Windows, `tooling\win\capture.ps1`, and `drive.ps1`'s
   window-only shot (`docs/HANDOFF.md`, "The Windows build"). Measure. A spec row
   that says "live" names its steps.
7. **Patch.** Commit in the checkout with the `Why:` and `Removable when:` footers.
   A fix to an existing feature is folded into that feature's commit
   (`tooling/fold-fix <commit> <files>`, with the fix in the tree). The script
   rewrites no other file, so nothing else rebuilds. `git commit --fixup` and
   `rebase --autosquash` touch every file the later commits touch (trap 44). The
   series is organised by feature (`patches/README.md`). Then `tooling/dev patch`
   regenerates `patches/` and runs `check-repo`.
8. **Commit this repo.** The docs, the spec, and the backlog row, in the same commit
   as the regenerated patches.

## How the tests are shaped

The suites were cut by merging and deleting what repeated itself. Keep them that way.

- **A unit test names one behaviour and fails for one reason.** Near-copies with
  different inputs are one table-driven test (a struct array, a loop, `SCOPED_TRACE`
  per row). A unit test is cheap to run, so different behaviours stay in different
  tests.
- **A browser test is a scenario.** Each one starts a browser, so steps that share a
  setup are one test. Each step has its own `SCOPED_TRACE` and its own expectations,
  and the state is put back between steps. Keep a body near 150 lines; past that,
  split along the steps. A `PRE_` chain is one test however many restarts it has.
- **Before adding a test, look for the one it extends.** A new step in an existing
  scenario, or a new row in an existing table, is the default. A new test needs a
  setup no other test has.
- **Which leg runs it.** `tooling/dev` runs the browser suite four at a time on
  the Mac and two at a time on Windows (`STEDDING_BROWSER_JOBS`; trap 88), then the
  fixtures in `SERIAL_BROWSER_TESTS` one at a time: the real pointer, the active
  window, the clipboard, picture-in-picture, a page that must paint, a command bar
  held open, frames counted on a window that is on screen, and full screen. A new
  fixture of that kind goes on that list. `S-178` is the Mac's remaining
  consolidation of that shape (`BACKLOG.md`). The `upstream` line is Chromium's own
  suites over the code the series changes, and `tooling/dev test all` includes it.
  `tooling/dev test rebase` is the wider ring, after a pin bump (trap 31).

## Rules that are not optional

- **No behaviour ships without a test id in its feature spec.** A row whose Test
  column says "none yet" is a `gap` and gets a backlog item.
- **Nothing runs unattended without a number moving.** A build or a test prints a
  metric at least every minute, and a budget stops it when nothing has moved. The
  supervisor restarts what the budget stops. A job whose metric is still is stuck:
  kill it and say so.
- **Never edit the checkout while a build runs.** siso samples sources at the start;
  a mid-build edit misses the binary (trap 1). `tooling/dev build` refuses to start
  while another build is running.
- **Every pin move reads Chrome's field trials.** After `tooling/update-pin --apply`,
  run `tooling/field-trials --save <dir>`. Stedding receives no trials
  (`docs/PRIVACY.md`), so a launch Chrome makes that way reaches it only when
  upstream flips the default. That is how `S-236` was missed. `tooling/field-trials
  --min 100` lists what Chrome sets for every client. A row at 100% that needs no
  Google service is taken in the series, or a backlog row says why it is not. The
  standing step is `S-240`.
- **Numbers in docs come from `tooling/dev status`.** Do not hand-type test counts,
  patch counts, or the pin. `tooling/check-repo truth` fails on known stale phrases.
- **One backlog.** `BACKLOG.md`, by S- id, is the order of work. Ids of the 2026-09-26
  audit (TAB-1, PLT-3) are cited as they are and resolve in
  `docs/history/plan-2026-09-26.md`. `AGENTS.md`, `docs/HANDOFF.md` and the feature
  specs cite ids. They do not carry their own lists.
- **Anything that owns a tab needs a test** (trap 2). **Anything a person clicks
  needs to have been clicked** (trap 58).

## Roles

When more than one agent is working:

| Role | Does | Does not |
|---|---|---|
| explorer | Reads the pinned tree; returns `file:line` seams, churn numbers, precedents | Edit anything |
| builder | Steps 2–8 for one feature spec row or backlog id | Widen scope, touch unrelated files |
| reviewer | Reads the diff against the spec; runs `tooling/dev test all`; checks upstream hunks are minimal | Fix things silently — it reports |

A builder's handoff is the backlog id, the behaviour ids now green, the test command,
and the patch numbers. A subagent is for a separate question. The critical path stays
in the session that already has the context.

Several agents on one machine share one checkout and one screen:

- **One build at a time.** On the Mac, `tooling/build-chromium` holds
  `out/<config>/.stedding-build.lock.d` (a directory made with `mkdir`, with the
  build's pid inside) and `tooling/dev build` refuses while a build is running. Do
  not edit the checkout during a build (trap 1).
- **One user of the screen at a time.** Browser tests open windows. `tooling/drive`
  and `drive.ps1` move the pointer. The scripts do not take a screen lock: take turns,
  so one agent's pointer does not land in another's window.
- **Drive a copy beside the owner's own Stedding.** An APFS clone (`cp -c`) of
  `out/release/Stedding.app`, given a bundle id of its own (`PlistBuddy`), then an
  ad-hoc `codesign`, placed at `<dir>/out/release/Stedding.app` and run with
  `CHROMIUM_SRC=<dir>`. `tooling/drive` and `tooling/capture-state` then drive it
  without the owner's bundle id. Make the copy again after each build.
- **See the new test fail.** Save a copy of the fixed files, put those paths back to
  the checkout's `HEAD`, build, and run the new tests. Restore the files and rebuild
  before any run that counts: the negative check leaves its objects behind (trap 52).

## Cheap checks

```bash
tooling/dev test all        # the release sweep (--no-build on Windows)
tooling/dev check           # check-repo, check-shell
tooling/dev status          # what the repo actually contains, for docs
tooling/check-repo          # every hygiene check
```

## Evidence

What Arc switchers asked for, gathered 2026-08-31 from the issues and discussions of
`github.com/zen-browser/desktop` and from Zen's own documentation. Numbers are reaction
and upvote counts on that date. No Zen source was read or reused. Zen is MPL-2.0;
Stedding is BSD-3-Clause (`CONTRIBUTING.md`).

The table is that snapshot. Counts are a demand signal, not a specification. A feature
nobody upvoted can still be essential, and a popular request can still be wrong for
this product. The sections after the table are the product as it stands.

### The ranking

| Rank | Thing | Signal |
|---|---|---|
| 1 | Vertical sidebar: Spaces, Favorites, pinned tabs, **folders** | Folders discussion **412** upvotes — opener: "If you add this, i think lot of ARC users are going to pass into Zen" |
| 2 | Session restore that never loses a tab | Highest historical bug **182** reactions, 180 comments |
| 3 | Command bar | **203** upvotes for a command palette, plus **136** for "Arc's command bar" |
| 4 | Peek | Shipped by Zen and used; users insist it is **not** Little Arc |
| 5 | Cross-device sync of Spaces and pinned tabs | **475** upvotes, still open after ~two years — the largest single number found |

Workspace-adjacent requests are the top cluster. Folders were the highest Arc-named
request, and users said they would not leave Arc without collapsible pinned folders.

### Where it stands

**Folders ship**, including a folder in the pinned run (`docs/features/folders.md` F38).
`PRODUCT.md` marks them [1.0] and not deferrable.

**Session restore ships with the sidebar** (`docs/features/spaces.md` B2, B9). The
snapshot's largest bug cluster was tabs lost across windows, spaces and favorites.

**A Blank Window has Spaces of its own** (`docs/features/windows.md` G4): ⌥⇧⌘N on the
Mac, Ctrl+Alt+Shift+N on Windows (`docs/SHORTCUTS.md`). The snapshot had **155** upvotes
asking to turn synced windows off by default.

**Peek and a little window are different, and both ship** on macOS and Windows. The
related requests had **87** and **74** upvotes. Peek is a little window over the pinned
tab's window, on by default (`PLAN.md` decision 2), released in 0.3.0 beta 16
(`docs/features/peek.md`, `S-93`). A little window is its own window for a link from
another application: on the Mac from the start, on Windows since 0.3.0 beta 7
(`docs/features/little.md`).

**Sync has no Stedding account and no Stedding server** (`docs/ROADMAP.md`,
`docs/PRIVACY.md`). The answer to the **475** is a folder the user's own sync tool
keeps: the sidebar syncs through it, off by default
(`docs/decisions/0029-sidebar-sync-through-a-folder.md`, released in 0.3.0 beta 16; the owner's acceptance of the ADR is still open). A Space also exports and imports as a file. What is still owed
is `S-282`.

### Deferred

Boosts and Easels stay deferred (`docs/decisions/0012-defer-boosts-and-easels.md`,
`docs/ROADMAP.md`). Extensions already answer Boosts.

- **Boosts: 4 upvotes.** Zen shipped this. Almost nobody asked.
- **Easels: 41 upvotes**, with the community calling it extension-shaped and expensive.

The same snapshot has 412 for folders and 475 for sync.

### Decisions around the ranking

**Horizontal tabs: 253 upvotes, and Zen declined.** Chromium's own switch stays
(`PLAN.md` decision 1). Spaces, pins and folders work in horizontal mode. Stedding
builds no horizontal layout of its own
(`docs/decisions/0010-ride-upstream-vertical-tabs.md`).

**Tree-style tabs: 280 upvotes.** Folders shipped. A link opened in a new tab is drawn under its opener only while "Show tabs under the tab that opened them" is on (`docs/features/tabs.md` R56–R59, settings T26, `S-92`). That setting is off by default, and while it is off a new link is no one's child. Back at a child's first
page, which closes the child, is still open (R60).

**A bundled model: ~20 upvotes**, with pushback. ADR 0020: Stedding ships no bundled
model.
