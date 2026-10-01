# The agent loop — how a change gets made here

This is the working procedure for any agent (or human) changing Stedding. It has two
halves. The first, below, is how to spend a session: what to ask, what to run first, how
to wait. The second, from "The loop", is how one change is made.

The first half exists because of 2026-09-29 to 30, the longest unattended run this
project has had: a checkout moved to a new Chromium, built from nothing, three test
configurations built and run, and the product used for real. The slow parts were mostly
not the builds. Hours went to a build that could never finish three of its steps, to
polling, to fixing one failure per rebuild, to search commands that timed out, and to
questions asked after the work that needed their answers. The fixes are rules below, each
with the number that earned it. The second half exists because the loop before it — build,
screenshot, look — shipped a Spaces feature whose core semantics were missing while every
capture looked right (`docs/features/spaces.md`, B1–B5, 2026-09-01). Screenshots prove
pixels. Tests prove behaviours. Neither proves the product works for a person, and on
2026-09-30 the only thing that found five visible faults in a build that passed everything
was using it.

One entry point runs the routine steps: `tooling/dev`. Prose that tells you to type a
command is a bug; the command lives in the script.

## Ask once, up front

Before the first long job, one message to the operator with every decision you would
otherwise meet later:

- May I drive the screen and keyboard (real input, guarded, `tooling\win\drive.ps1`)? On
  2026-09-30 the answer was yes, given hours in; until then the product was tested only
  through posted messages and captures.
- May I push, and release when everything is done? Neither happens without a yes in chat.
- Which output directories may I delete? (Yours, from this session: yes. Anything else: ask.)
- Is the machine mine overnight, and does a reboot need a reason?
- Is there a setting I need you to flip (Windows clipboard history, for the Win+V check)?
  System settings are not yours to change.
- Will you close your own Stedding when I tell you the installer test is next? A release
  on the same Chromium number as the one installed installs as a repair and cannot replace
  a running browser (trap 62); your installed build is your daily browser and is never
  mine to close. Waiting for it cost 2.5 hours on 2026-09-30, with a watcher on "no
  Stedding process" so that nothing else waited.

One message at the start costs a minute. The same six answers found out one by one cost
the session most of a night.

## Order of evidence

Cheapest and most revealing first. Measured on this project, Windows, 2026-09-29 to 30:

| Step | Cost | What it found |
|---|---|---|
| Use the product: launch, click, drag, type, look, light and dark, a fresh profile | 30 min | five faults no test had asked about: Mac wording on Windows (welcome flow, a tooltip, three command-bar rows), inactive rows' text unreadable in light mode, a command bar clipped at the window's edge, an infobar left in full screen, doubled hover names |
| Suites on the shipping configuration (`tooling/dev test all`) | unit 12 s, browser 2.5 min | regressions; none of the above |
| A build with DCHECKs and the dangling-pointer detector (`win-checks`) | 3 h 20 min from nothing, 3 min to rebuild after an edit; both suites 5 min | twelve defects, eight in the product: a contrast recipe reading a transparent fill as black, permission defaults that contradicted each other, pointers left dangling when the window switched to horizontal tabs, two views with no accessible name, text drawn on a transparent ground |
| ASan (`win-asan`) | 5 h from nothing, 15 min to rebuild; browser suite 12 min | one use-after-free, in a test, and a hazard in `RemoveSpace` |
| A debug build | hours | nothing the DCHECK build had not; built only if a check names it |

The order follows yield per hour. The DCHECK build is the cheapest sanitizer and the first
to run; ASan went first this time because the plan listed it first, and cost five hours
before it found one thing. Use the product before any of them.

## Long jobs: supervise, do not poll

- **One detached job, one status file, one finish line.** `tooling\win\build-until-done.ps1`
  runs `build.ps1` chunk after chunk with no gap between them, writes
  `out\<config>\supervisor.log`, and ends it with `SUPERVISOR_EXIT=<code>`. Start it
  detached (the tool that started it must not be able to take it down, trap 54) and wait
  for that line in a background call, not with a clock. Polling by hand every fifteen
  minutes left the machine idle between a chunk's end and the next poll, forty times.
- **The budget is a dead-man's switch, not a schedule.** It kills the steps in flight, so each
  stop costs their minutes; a long chunk wastes less than a short one. Chunks of 45 minutes.
- **Watch for a step that never finishes.** The same steps "failed" at the end of three
  chunks in a row were killed before they could finish, every time. The supervisor stops with
  exit 4 and names them. On 2026-09-30 three assembler steps of an ASan build did this for five
  chunks, about two and a half hours, because the failures at each stop were assumed to be
  in-flight kills (they were, of the same steps). Time one by hand (trap 57).
- **A status line before any wait over ten minutes,** with a number in it (steps done,
  tests run, minutes to go). The operator asked twice in one evening whether it was stuck.
- **Waits that are not builds** (a test suite, a sync) follow the same shape: start detached
  with `run_in_background` or `Start-Process`, get a notification or wait on the finish line.
  `sleep` in the foreground is refused by the tool and a tool call ends at ten minutes.

## One pass should find everything

- A check that aborts on its first failure (a DCHECK, a dangling pointer, ASan) hides the
  rest. Fixing one site per rebuild cost a dozen rebuild-and-run cycles on 2026-09-30, most
  of an hour; the failures were all there on the first run.
- Get every distinct failure per run: `--test-launcher-print-test-stdio=always` (output of
  passing tests too), or make the check log instead of abort in a local edit you then revert
  (keep the original beside it, and check `git status` is clean for the file before folding).
  Crash identity goes through `tooling/digest-sanitizer <log>`: each distinct DCHECK once with
  the first frames that are this project's, each dangling pointer as a pair (who freed it, who
  still held it), each ASan report's head. A fixture member is told from a product bug by the
  pair: freed in the window's teardown, released in the fixture's destructor, is the fixture.
- Fix in batches, then rerun once. Fold each fix into its owning patch (`tooling/fold-fix`;
  the last patch takes what has no other owner, and a conflict in the owner means use the last).

## Real use, safely

The product is used for real with `tooling\win\drive.ps1` (the pointer and keyboard) when the
operator has said yes, and with `capture.ps1`, `cdp.ps1`, `hit-test.ps1` (no input) when not.
What to do and what to look for:

- A fresh profile, no seed, no start URL: the first launch is what a user has. Click through
  the welcome flow. Then the same in light and dark (`browser.theme.color_scheme2` in the
  profile's Preferences, 1 is light).
- Every gesture the specs name, with the real pointer: click each kind of row open and in the
  rail, drag a row onto a folder and onto a Space chip, switch Spaces by chip and by key, copy
  the link, take the screenshot, go full screen on a video, resize. Prove state with DevTools
  (`Drive-Visible`) or UI Automation, not with a picture.
- Read the strings. Wording written on one platform reads wrong on the other.
- Two browsers from one executable with the same `--remote-debugging-port` leave the second
  with a window and no UI (black). Stop the first, or give each a port.

Guards in `drive.ps1` are not optional: input goes only while the window under test is in
front, and only while the operator's own last input is old. A screenshot is of the window,
only while it is in front (the operator's other windows were in the first picture, once).

## Search and read cheaply

- `git grep -n <pattern> -- <dir>` in the Chromium checkout: 7 s for `chrome/`, 32 s for the
  whole tree. `grep -r` and `find` over the tree timed out at two minutes four times on
  2026-09-30, each a wasted call and a retry.
- Cap the output of any command you have not run before (`| head -40`, `Select-Object -First`).
  A UI Automation listing once printed the same six rows a hundred and thirty times.
- A script longer than three lines is a file (the Write tool), not a heredoc: backslashes in
  Windows paths and regexes broke inline Python and sed seven times.
- Screenshots cost about the same as two thousand words each. Crop to the window, look only
  after a state change, and read text from UI Automation or DevTools where it can be had.

## The loop

```
research  →  spec  →  failing test  →  implement  →  build  →  test  →  use it  →  patch  →  commit
```

1. **Research the seam, read-only.** Find the upstream machinery to reuse before writing
   anything (`docs/IMPLEMENTATION.md` is the precedent: every feature there names the
   files it edits and their churn). Measure churn before touching a file:
   `git log --oneline --since=1.year -- <file> | wc -l`. Anything over ~150 is a file
   we avoid; put the code in a new file under a Stedding directory and call it from one
   hunk.
2. **Spec the behaviour.** Add or update `docs/features/<feature>.md`: one numbered
   behaviour per row (B1, B2, …), each phrased so a test can decide it without a human.
   The spec is the definition of done. If you cannot write the behaviour as a sentence a
   test can check, you do not yet know what you are building.
3. **Write the failing test.** Model logic → `space_model_unittest.cc` style (no window).
   Anything about the active tab, visibility, or what the user sees →
   `BrowserWithTestWindowTest` (`space_model_window_unittest.cc` is the template), or a
   browser test for a click or a drag (`chrome/test/stedding/`). Put the behaviour id in a
   comment above the test. Run it; watch it fail for the right reason.
4. **Implement.** Smallest change that turns the test green. New files in our
   directories; upstream hunks only where the seam is (`docs/ARCHITECTURE.md`, "Where
   patches are allowed to live").
5. **Build and test.** `tooling/dev test <feature>` builds `unit_tests` and runs the
   feature's filter; `tooling/dev test all` before a commit. On a sanitizer output
   directory (`STEDDING_TEST_OUT=win-checks` or `win-asan`) the same command runs with the
   detector on and prints the digest.
6. **Use it, and capture if it is visual.** Launch the build and do the thing (above). For
   pixels, `tooling/dev capture --assert tooling/probes/window.json` checks every probe in
   the spec; measure, do not eyeball. `tooling/capture-state` photographs any state a
   feature param can recreate without input. A spec row that says "live" names its steps.
7. **Patch.** Commit in the checkout with the `Why:` / `Removable when:` footers. A fix to an
   existing feature is folded into that feature's commit (`tooling/fold-fix <commit> <files>`
   with the fix in the tree: no other file's modification time changes, so nothing else
   rebuilds; `git commit --fixup` + `rebase --autosquash` touches every file the later
   commits touch). The series is organised by feature, not by date (`patches/README.md`).
   Then `tooling/dev patch` regenerates `patches/` and runs `check-repo`.
8. **Commit this repo.** Docs, spec status, backlog item closed, in the same commit as the
   regenerated patches.

## Rules that are not optional

- **No behaviour ships without a test id in its feature spec.** A row whose Test column
  says "none yet" is a `gap` and gets a backlog item.
- **Nothing runs unattended without a number moving.** Every build and test command prints
  a metric at least every minute (objects built, tests run), and has a budget that stops it
  when nothing has moved; the budget is a safety, and the supervisor restarts what it
  stops (above). A job with no metric moving is stuck: kill it and say so.
- **Never edit the checkout while a build runs.** siso samples sources at build start; a
  mid-build edit silently misses the binary. `tooling/dev build` refuses to start while
  another build is running.
- **Numbers in docs come from `tooling/dev status`.** Do not hand-type test counts, patch
  counts, or the pin. `tooling/check-repo truth` fails on known stale phrases.
- **One backlog.** `BACKLOG.md`. `AGENTS.md`, `HANDOFF.md` and feature specs cite ids
  (`S-12`), they do not carry their own lists.
- **Anything that owns a tab needs a test, not a screenshot** (trap 2 in
  `docs/HANDOFF.md`; the folder close-crash was invisible to every capture), and **anything a
  person clicks needs to have been clicked** (trap 58).

## Roles, when more than one agent is working

| Role | Does | Does not |
|---|---|---|
| explorer | Reads the pinned tree; returns `file:line` seams, churn numbers, precedents | Edit anything |
| builder | Steps 2–8 for one feature spec row or backlog id | Widen scope, touch unrelated files |
| reviewer | Reads the diff against the spec; runs `tooling/dev test all`; checks upstream hunks are minimal | Fix things silently — it reports |

A builder's handoff is: the backlog id, the behaviour ids now green, the test command,
and the patch numbers. Nothing else needs to be in anyone's head. Independent work is worth
a subagent; the critical path is not (a subagent needs the context you already have).

## Cheap checks before you claim done

```bash
tooling/dev test all        # every Stedding test, filtered from unit_tests
tooling/dev check           # check-repo, check-shell
tooling/dev status          # what the repo actually contains, for docs
tooling/check-repo          # 12 checks, 3 seconds
```
