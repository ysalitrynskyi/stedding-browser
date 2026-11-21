# AGENTS.md — start here

This is the brief for anyone opening this repository cold, a contributor or the tools
they work with: what the project is, the rules, how to work, where to look. Everything
needed is in this repo; nothing depends on a particular editor, tool, session or
machine. What was built and when is `docs/PROJECT-LOG.md`; the order
of work is `BACKLOG.md`; the owner's decisions and the rules of done are `PLAN.md`; the
procedure is `docs/AGENT-LOOP.md`; the traps are `docs/HANDOFF.md`.

## What this project is

**Stedding Browser** is an open-source, Chromium-based desktop browser: a sidebar of
vertical tabs, Spaces, pinned tabs, folders, split view and a command bar. It is the
interface Arc's users are used to. macOS (Apple silicon) and Windows.

- Site: **https://stedding.dev** — its own private repository
  (`ysalitrynskyi/stedding.dev`: Astro, static, Cloudflare Pages; DNS on Cloudflare,
  ADR 0004). It reads the latest release from the GitHub Releases API at build time
  and is not on the update path (ADR 0014). That repository's `AGENTS.md` and
  `docs/DEPLOYMENT.md` are its own rules.
- Repo: `ysalitrynskyi/stedding-browser` on GitHub
- License: **BSD-3-Clause** (ADR 0002). The core stays BSD; closed-source or paid
  add-ons may exist only beside it (ADR 0005).
- Started: 2026-08-30

Say it STED-ding, rhyming with "wedding": a haven, a settled place, from the English
word "steading". Only the word "Stedding" is used. No artwork, names, quotations or
other material from any book, film, game or other brand, and no claimed affiliation
with anyone. The record is `docs/VISION.md` ("The name", "Brand and voice") and ADR 0001.

## The mandate

A technical user downloads an installer, opens it, imports their profile, and prefers
it within a day. Every milestone ends in something installable and usable. Shippable
and polished wins over interesting.

Concretely:

- Every merged change keeps the browser buildable and runnable.
- A feature is shipped only when the UX completeness list in `docs/ROADMAP.md`
  ("The quality bar") is met. Missing any item on it, the feature is not shipped.
  The list starts with keyboard shortcuts, a settings entry and edge cases.
- No telemetry by default. Privacy defaults are product features (`docs/PRIVACY.md`).
- Full Chrome extension compatibility is a hard requirement, and a reason for the
  Chromium base (ADR 0003).

## Technical direction

Details are in `docs/ARCHITECTURE.md`.

- Base: **Chromium stable, minimal patch-set** (ADR 0003, ADR 0007), the Brave/Helium
  model. UI work lives as high in the stack as possible (views, WebUI, top chrome)
  so rebases stay cheap. A hard fork, an Electron or CEF wrapper, and a Firefox base
  were rejected (ADR 0003).
- Patches are an ordered, documented series. Tracking upstream stable is a scheduled
  task. The pin lives in `tooling/chromium-version`. A stable cut may be merged before
  that milestone is on stable for users; `tooling/check-pin` says whether the pin is
  current, behind or ahead (ADR 0007).
- Platforms, in order: **macOS, then Windows, then Linux** (ADR 0006). macOS and
  Windows ship. Linux does not (`docs/ROADMAP.md` M9). Each shipped platform is built
  on its own machine.
- Updates: both shipped platforms update themselves from feeds in `updates/`, served
  from GitHub. Sparkle on the Mac (`updates/appcast.xml`, ADR 0022); Stedding's own
  updater on Windows (`updates/appcast-windows.xml`, ADR 0023). The site is not on
  that path (ADR 0014).

## Your first fifteen minutes

1. `tooling/dev status`: the pin, the patch count, the checkout, and whether the test
   binaries exist. Every number in a doc comes from this, or from a command, never from
   prose. The pin on main may not be the pin of the latest release: `gh release list`
   is what users have. `VERSION` names the latest release until the next one is cut;
   `tooling/publish-release` tags `v<VERSION>`.
2. `PLAN.md` (the owner's decisions, and when an item is done), then `BACKLOG.md`.
3. `docs/HANDOFF.md`: the "Fast path" and the trap index at its top. Read a trap when
   its topic comes up.
4. Ask the operator **once**, in one message, for what you would otherwise find out
   hours in (`docs/AGENT-LOOP.md`, "Ask once, up front").
5. Use the product before any long job: launch it, click it, look at it.

## How to work here

The short form. `docs/AGENT-LOOP.md` has the detail.

1. **Cheapest evidence first.** Use the build, with the real pointer and keyboard,
   light and dark. Then the suites on the shipping configuration (`release` on the
   Mac, `win-release` on Windows). Then a build with DCHECKs and the dangling-pointer
   detector (`win-checks`, or `mac-checks` on the Mac). Then ASan (`win-asan`). A
   debug build only if a check needs one.
2. **Ask once, up front:** driving the screen, pushing and releasing, what you may
   delete, the machine overnight, settings only the operator flips, closing their own
   Stedding for the installer test, quitting Arc and clipboard managers before the
   keyboard checks. The list, with its reasons, is in `docs/AGENT-LOOP.md`.
3. **Supervise long jobs; do not poll them.** A build or run past a few minutes is one
   detached job. On Windows, `tooling\win\build-until-done.ps1` writes a status file
   and ends it with `SUPERVISOR_EXIT=`. Wait for that line. Post one status line, with a number in it, before
   any wait over ten minutes. A step killed at the end of three chunks in a row is
   stuck: the supervisor stops with exit 4 and names it (trap 57). Time that step by hand.
4. **One pass should find everything.** A check that aborts at its first failure hides
   the rest. Collect every distinct failure per run, read them through
   `tooling/digest-sanitizer`, and fix in batches. A browser sweep runs its failures again
   alone and says which fail on their own; all of them stay failures.
5. **Every finding gets a test, and its fix goes into the patch that owns the code**
   (`tooling/fold-fix`). Then use the product again: a fix is done when the thing you
   saw has stopped happening on the real build.
6. **Read and search cheaply.** `git grep` in the checkout. Cap the output of any
   command you have not run before. A script of more than three lines goes in a file.
   Captures are of the window (trap 133). Read text from UI Automation or DevTools
   when they can give it.
7. **Say what was and was not verified,** result first, in plain sentences.

## Red lines

| | |
|---|---|
| Release, tag, publish, upload an installer | Only when the operator has said so in chat for this release. `tooling/publish-release` is the one way. A release is tried the way a user gets it (trap 47) |
| The version number | The next patch number after the latest release (0.7.1 after 0.7.0), whatever the release carries. A new minor or major only when the owner names it in chat for that release (`PLAN.md` decision 28); `tooling/publish-release` refuses anything else |
| Push | Only when asked. Never force. Stage only your own paths |
| GitHub issues | An issue a user files is a suggestion unless it reports a bug. Fix bugs; ask the owner before building a feature an issue asks for. Never comment on or close an issue; label one only when the owner asks (`PLAN.md` decision 16) |
| Attribution | Release notes, docs and code comments name no tool. No commit names a tool as a co-author or carries a "generated by" footer. A pull request from outside the project made with an AI tool's help says so the one way `CONTRIBUTING.md` ("AI tools") sets out, and `tooling/check-disclosure` fails one that does not |
| Secrets, machine paths, personal data | Never committed: this repo is public |
| What lives in this repository | The product, its tooling, its specs and its user docs, kept concise. Anything else stays outside it |
| Screen captures and recordings | The window under test only, taken by its window id: `tooling/capture-windows` (stills, through `tooling/capture-state` and `tooling/drive`'s `shot`) and `tooling/record-window` (video). Never the screen, never another app's window, never a recording of the whole display cropped afterwards (trap 133) |
| Real input (pointer, keyboard) | Only with the operator's yes, and only into the window under test. `tooling\win\drive.ps1` also waits until the operator's hands are off (trap 27). `tooling/drive` on the Mac does not watch for that, and it runs only when nobody is at the machine (trap 3) |
| Deleting | Your own build output and scratch only. Ask before anything else |
| System settings | Not yours to change, including the default browser and clipboard history: ask the operator to flip them |
| A number or a claim you did not measure | `TBD`, never a guess (and never typed into a doc that `tooling/dev status` can derive) |

## Where things stand

No counts here: they go stale, and `docs/PROJECT-LOG.md` is the record. Read the
commands.

- The pin and the series: `tooling/dev status`. What users have: `gh release list`.
  The two can differ (ADR 0007).
- Windows is built and tested on a Windows PC. The Mac builds the macOS image and
  holds the Mac-only checks, signing and notarization (`BACKLOG.md` names which rows
  wait on it). Linux is not shipped.
- The work order: `BACKLOG.md`, in priority order. New features wait for the
  core-loop gate, S-173, under "Checks still owed", unless the operator asks
  (`PLAN.md`).
- What is released: `docs/release-notes/` has the current release's notes. Every
  release's notes are on
  [GitHub Releases](https://github.com/ysalitrynskyi/stedding-browser/releases).
  The site and the Homebrew tap (`ysalitrynskyi/homebrew-stedding`) follow that list.
  `docs/HANDOFF.md` ("After a release") lists every place a release must reach.
- What is open: `BACKLOG.md`, by id. Closed items are in `docs/history/archive.md`.

## Map of the docs

| File | What's in it |
|---|---|
| `docs/README.md` | The index of everything under `docs/`, grouped by who it is for |
| `docs/INSTALL.md`, `docs/SHORTCUTS.md`, `docs/FAQ.md` | Installing and verifying, every shortcut on both platforms, questions and answers. Plain language; keep them true when behaviour changes |
| `docs/AGENT-LOOP.md` | The working procedure: ask once, order of evidence, long jobs, one pass finds everything, then research, spec, test, implement, patch |
| `docs/features/` | One spec per feature: numbered behaviours, each with its test. `acceptance.md` holds the scripts run on a real build before a release, and the record of each run |
| `PLAN.md` | The owner's standing decisions, and when an item counts as done |
| `docs/history/` | `plan-2026-09-26.md`, the 2026-09-26 audit (TAB-1, SPC-4, ...), which the code cites by that path; `archive.md`, the closed backlog (S-179 to S-210 are the code review); what Arc switchers asked for in 2026-08 |
| `BACKLOG.md` | The one list of open work, by id, in priority order. Other docs cite ids; closed items move to `docs/history/archive.md` |
| `docs/HANDOFF.md` | Where things live, the fast path, dev parameters, the traps already paid for (with an index) |
| `docs/PROJECT-LOG.md` | What was built since 2026-10-15, round by round, with the evidence. History, not instructions |
| `docs/VISION.md` | Why this exists, values, non-goals; the name, the brand and voice, the competitors |
| `docs/PRODUCT.md` | The feature spec: sidebar, Spaces, split view, command bar, settings, import; the UI spec |
| `docs/ARCHITECTURE.md` | Fork strategy, build system, patch management, updater, signing |
| `docs/ROADMAP.md` | Milestones M0 through 1.0, with acceptance criteria; the quality bar |
| `docs/PRIVACY.md` | Privacy principles and concrete defaults |
| `docs/perf/` | How to measure the performance budgets. No current measurement |
| `docs/decisions/` | ADRs. Every irreversible decision gets one |
| `CONTRIBUTING.md` | How to contribute, and the rules for pull requests made with an AI tool's help |
| `SECURITY.md` | How to report vulnerabilities |

## Conventions for contributors

- **Write docs and code in plain, correct English.** Terse is fine; cryptic is not.
- **Decisions get ADRs.** Anything hard to reverse (dependency, base version policy,
  naming, licensing) goes in `docs/decisions/NNNN-slug.md` before or with the change.
- **Never commit secrets, machine-specific paths, or personal operational data.**
  This repo is public.
- **Don't fabricate.** No invented benchmarks, dates, user counts, or claims. If a doc
  needs a number we don't have, mark it `TBD`.
- **Keep this file true, and short.** If you change direction (platforms, fork strategy,
  license), update AGENTS.md and the relevant ADR in the same commit. Put history in
  `docs/PROJECT-LOG.md`, open work in `BACKLOG.md`, and nothing dated or counted here.
- Commit messages: conventional, imperative, explain why when it isn't obvious.
- **A pull request from outside, made with an AI tool's help,** follows
  `CONTRIBUTING.md` ("AI tools"): the form's AI assistance box ticked, with the tool,
  the model and what it did; every such commit ending with
  `Assisted-by: AGENT_NAME:MODEL_VERSION`, never `Co-authored-by:`; a person who has
  read and tested all of it and answers the review; nothing posted by an agent on its
  own.
- When a task is ambiguous, the tiebreaker is the mandate above: what gets a polished,
  installable browser into users' hands sooner.
