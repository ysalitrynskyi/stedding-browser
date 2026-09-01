# The agent loop — how a change gets made here

This is the working procedure for any agent (or human) changing Stedding. It exists
because the previous loop — build, screenshot, look — shipped a Spaces feature whose
core semantics were missing while every capture looked right (`docs/features/spaces.md`,
B1–B5, found 2026-09-01). Screenshots prove pixels. They cannot prove that a tab is in a
Space, that switching changes the active tab, or that nothing is lost on delete. Tests
prove those. So the loop is now test-first, and a capture is the last check, not the
only one.

One entry point runs every step: `tooling/dev`. Prose that tells you to type a
command is a bug; the command lives in the script.

## The loop

```
research  →  spec  →  failing test  →  implement  →  build  →  test  →  capture  →  patch  →  commit
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
   `BrowserWithTestWindowTest` (`space_model_window_unittest.cc` is the template). Put
   the behaviour id in a comment above the test. Run it; watch it fail for the right
   reason.
4. **Implement.** Smallest change that turns the test green. New files in our
   directories; upstream hunks only where the seam is (`docs/ARCHITECTURE.md`, "Where
   patches are allowed to live").
5. **Build and test.** `tooling/dev test <feature>` builds `unit_tests` and runs the
   feature's filter. `tooling/dev test all` before a commit.
6. **Capture, if it is visual.** `tooling/dev capture --features '...'`, then measure
   against `docs/UI-SPEC.md`. Measure pixels; do not eyeball.
7. **Patch.** Commit in the checkout with the `Why:` / `Removable when:` footers. A fix
   to an existing feature is a **fixup into that feature's commit** (`git commit
   --fixup=<sha>` then `git rebase --autosquash`), not a new patch at the end of the
   series. The series is organised by feature, not by date (`patches/README.md`).
   Then `tooling/dev patch` regenerates `patches/` and runs `check-repo`.
8. **Commit this repo.** Docs, spec status, backlog item closed — in the same commit as
   the regenerated patches.

## Rules that are not optional

- **No behaviour ships without a test id in its feature spec.** A row whose Test column
  says "none yet" is a `gap` and gets a backlog item.
- **Never edit the checkout while a build runs.** siso samples sources at build start;
  a mid-build edit silently misses the binary. `tooling/dev build` refuses to start
  while another build is running.
- **Numbers in docs come from `tooling/status`.** Do not hand-type test counts, patch
  counts, or the pin. `tooling/check-repo truth` fails on known stale phrases.
- **One backlog.** `BACKLOG.md`. `AGENTS.md`, `HANDOFF.md` and feature specs cite ids
  (`S-12`), they do not carry their own lists.
- **Anything that owns a tab needs a test, not a screenshot** (trap 2 in
  `docs/HANDOFF.md`; the folder close-crash was invisible to every capture).

## Roles, when more than one agent is working

| Role | Does | Does not |
|---|---|---|
| explorer | Reads the pinned tree; returns `file:line` seams, churn numbers, precedents | Edit anything |
| builder | Steps 2–8 for one feature spec row or backlog id | Widen scope, touch unrelated files |
| reviewer | Reads the diff against the spec; runs `tooling/dev test all`; checks upstream hunks are minimal | Fix things silently — it reports |

A builder's handoff is: the backlog id, the behaviour ids now green, the test command,
and the patch numbers. Nothing else needs to be in anyone's head.

## Cheap checks before you claim done

```bash
tooling/dev test all        # every Stedding test, filtered from unit_tests
tooling/dev check           # check-repo, check-shell
tooling/dev status          # what the repo actually contains, for docs
```
