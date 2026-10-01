# AGENTS.md — start here

You are an AI agent (or a human) opening this repository cold. This file is the brief:
what the project is, the rules, how to work, where to look. It is model-agnostic and
tool-agnostic; everything you need is in this repo, nothing depends on a particular
assistant, session or machine. What was built and when is `docs/PROJECT-LOG.md`; the order
of work is `PLAN.md`; the procedure is `docs/AGENT-LOOP.md`; the traps are `docs/HANDOFF.md`.

## What this project is

**Stedding Browser** — a fully open-source, Chromium-based desktop browser with an
Arc-style interface: sidebar with vertical tabs, workspaces, split view, and a command
bar. Built for technical users who want privacy, control, and a modern, productive UI —
without trusting a VC-funded company's roadmap or telemetry.

- Site: **https://stedding.dev** — live since 2026-09-16 from its own private repository
  (`ysalitrynskyi/stedding.dev`: Astro, static, Cloudflare Pages; it reads the latest
  release from the GitHub Releases API at build time and is not on the update path,
  ADR 0014). The website's own rules and deployment steps are in that repository
  (`AGENTS.md`, `docs/DEPLOYMENT.md`); DNS on Cloudflare.
- Repo: `ysalitrynskyi/stedding-browser` on GitHub
- License: **BSD-3-Clause** (permissive; closed-source or paid add-ons may exist later,
  the core stays BSD — see `docs/decisions/0005-open-core.md`)
- Started: 2026-08-30

The name: *Stedding* means a haven, a settled, kept place. It is shaped on the English
word "steading" (a farmstead or homestead), which comes from "stead", an old word for a
place. The meaning: a place to use the web where surveillance and vendor control cannot
reach. Say it STED-ding, rhyming with "wedding". The name was chosen after vetting
candidate names against browser, software, trademark, SEO, and pronunciation criteria —
full record in `docs/NAMING.md`. Only the word "Stedding" is used, as this browser's
name. No artwork, names, quotations or other material from any book, film, game or other
brand, and no claimed affiliation with anyone (`docs/BRAND.md`).

## The mandate — read this twice

We are building a **ready-to-use product**, not a tech demo, not a proof of concept,
not a config for enthusiasts. The bar is: a technical user downloads an installer,
opens it, imports their profile, and prefers it to Chrome/Arc within a day. Every
milestone must end in something installable and usable. When choosing between
"interesting" and "shippable and polished", choose shippable and polished.

Concretely (full detail in `docs/QUALITY.md`):

- Every merged change keeps the browser buildable and runnable.
- Features ship complete: keyboard shortcuts, settings entry, edge cases, polish —
  or they don't ship.
- No telemetry by default. Privacy defaults are product features, not afterthoughts
  (`docs/PRIVACY.md`).
- Full Chrome extension compatibility is a hard requirement — it is a top reason to
  base on Chromium at all.

## Technical direction (summary — details in docs/ARCHITECTURE.md)

- Base: **Chromium, stable channel, minimal patch-set fork** (the Brave/Helium model,
  not a hard fork). UI work lives as high in the stack as possible (views/WebUI/top
  chrome) to keep rebases cheap.
- Patches are maintained as an ordered, documented series; tracking upstream stable is
  a recurring scheduled task, not an emergency.
- Considered and rejected: Electron/CEF wrapper (no real extension support, worse
  performance), Firefox base (extension ecosystem, and Zen already owns that lane).
- Target platforms in order: **macOS first, then Windows, then Linux.**

## Your first fifteen minutes

1. `tooling/dev status`: the pin, the patch count, whether the checkout and the test
   binaries exist. Every number in a doc comes from here or from a command, never from prose.
2. `PLAN.md`: the owner's decisions and the status block at the top, then the work order
   until its Phase 1 is done; `BACKLOG.md` after that.
3. `docs/HANDOFF.md`: the "Fast path" and the trap index at its top. Read a trap when its
   topic comes up; there are about sixty.
4. Ask the operator **once**, in one message, for what you would otherwise find out hours in
   (the list under "How to work", rule 2).
5. Use the product before any long job: launch it, click it, look at it.

## How to work here

The short form. `docs/AGENT-LOOP.md` has the detail and the numbers behind each rule; they
come from the long run of 2026-09-29 to 30, in which the slowest parts were not the builds.

1. **Cheapest evidence first.** Launch the build and use it. Half an hour of that, with the
   real pointer and keyboard, found five faults (Mac wording on Windows, unreadable light-mode
   text, a clipped command bar, an infobar left in full screen, doubled hover names) that
   thousands of passing test runs had not, because the tests asked other questions. Then the
   suites on the shipping configuration; then a build with DCHECKs and the dangling-pointer
   detector (release speed; found twelve defects, eight in the product); then ASan (slow; found
   one, in a test, and a hazard in `RemoveSpace`); a debug build only if a check needs one.
2. **Ask once, up front.** May you drive the screen and keyboard. May you push, and release
   when done (neither happens without a yes in chat, ever). Which output directories may you
   delete. Is the machine yours for the night. Is there a setting only the operator may flip
   (Windows clipboard history, for the Win+V check). Will they close their own Stedding for
   the installer test (a release on the same Chromium number installs as a repair, trap 62).
   A list asked at the start costs one message; asked when blocked it cost hours.
3. **Supervise long jobs; do not poll them.** A build or run past a few minutes is one
   detached job that writes a status file and a last line (`tooling\win\build-until-done.ps1`,
   `tooling/dev`), waited for by that line and never by the clock. Post one status line, with a
   number in it, before any wait over ten minutes. The same steps killed at the end of three
   chunks in a row are stuck, not slow: time one by hand (trap 57).
4. **One pass should find everything.** A check that aborts at its first failure hides the
   rest; every fix then costs a rebuild and a rerun to find the next. Collect every distinct
   failure per run, read them through `tooling/digest-sanitizer` (five lines where the raw
   output is sixty frames times the number of tests), fix in batches.
5. **Every finding gets a test, and its fix goes into the patch that owns the code**
   (`tooling/fold-fix`). Then use the product again: a fix is done when the thing you saw
   has stopped happening on the real build.
6. **Read and search cheaply.** `git grep` in the checkout (7 s for `chrome/`, 32 s for the
   whole tree, where `grep -r` timed out four times); cap the output of any command you have
   not run before; a script of more than three lines goes in a file, not a heredoc (seven round
   trips lost to backslash quoting); crop screenshots to the window and look at text, not
   pictures, where UI Automation or DevTools can give it.
7. **Say what was and was not verified,** result first, in plain sentences, in the register
   the operator's own agent instructions set (their "Response contract").

## Red lines

| | |
|---|---|
| Release, tag, publish, upload an installer | Only when the operator has said so in chat for this release. `tooling/publish-release` is the one way. A release is tried the way a user gets it (trap 47) |
| Push | Only when asked. Never force. Stage only your own paths |
| Attribution | Commit messages, PR text, release notes, docs and comments credit the author alone: no co-author trailers, no "generated by" footers, no tool names |
| Secrets, machine paths, personal data | Never committed: this repo is public |
| Real input (pointer, keyboard) | Only with the operator's yes, and guarded: only into the window under test, only while the operator's hands are off. `tooling\win\drive.ps1` does both |
| Deleting | Your own build output and scratch only. Ask before anything else |
| System settings | Not yours to change, including the default browser and clipboard history: ask the operator to flip them |
| A number or a claim you did not measure | `TBD`, never a guess (and never typed into a doc that `tooling/dev status` can derive) |

## Where things stand

Kept short on purpose: a paragraph that restates the state goes stale within a day, and
`docs/PROJECT-LOG.md` exists for the record.

- The pin and the series: `tooling/dev status`. The Windows PC is the development machine
  since 2026-09-29; the Mac holds the Mac-only checks (`PLAN.md` lists which).
- The work order: `PLAN.md`. Phase 0 is the proof that what exists works; its status block
  says what each item still waits on.
- What is released: `docs/release-notes/` has one file per release; `gh release list` is
  the truth. The site (`stedding.dev`) reads the same list.
- What is open: `BACKLOG.md`, by id.

## Map of the docs

| File | What's in it |
|---|---|
| `docs/README.md` | The index of everything under `docs/`, grouped by who it is for |
| `docs/INSTALL.md`, `docs/SHORTCUTS.md`, `docs/FAQ.md` | The user-facing pages the README links: installing and verifying, every shortcut on both platforms, questions and answers. Plain language; keep them true when behaviour changes |
| `docs/AGENT-LOOP.md` | **The working procedure**: order of evidence, ask once, supervise long jobs, one pass finds everything, then research → spec → test → implement → patch |
| `docs/features/` | One spec per feature; numbered behaviours, each with its test id. The definition of done |
| `BACKLOG.md` | The one list of open work, by id. Other docs cite ids |
| `docs/HANDOFF.md` | Where things live, the fast path, dev parameters, the traps already paid for (with an index) |
| `docs/PROJECT-LOG.md` | What was built, round by round, with the evidence. History, not instructions |
| `docs/VISION.md` | Why this exists, values, explicit non-goals |
| `docs/PRODUCT.md` | Full feature spec: sidebar, workspaces, split view, command bar, settings, import |
| `docs/ARCHITECTURE.md` | Fork strategy, build system, patch management, updater, signing |
| `docs/ROADMAP.md` | Milestones M0→1.0 with acceptance criteria |
| `docs/QUALITY.md` | The "ready-to-use" bar: performance budgets, release checklist |
| `docs/PRIVACY.md` | Privacy principles and concrete defaults |
| `docs/COMPETITORS.md` | Arc, Dia, Zen, Helium, Vivaldi, Brave, Thorium — and our gap |
| `docs/NAMING.md` | The naming decision record: candidates, vetting criteria, outcome |
| `docs/BRAND.md` | Name meaning, voice, taglines, trademark hygiene |
| `docs/decisions/` | ADRs — every irreversible decision gets one |
| `CONTRIBUTING.md` | How to contribute |
| `SECURITY.md` | How to report vulnerabilities |

## Conventions for agents working here

- **Write docs and code in plain, correct English.** Terse is fine; cryptic is not.
- **Decisions get ADRs.** Anything hard to reverse (dependency, base version policy,
  naming, licensing) goes in `docs/decisions/NNNN-slug.md` before or with the change.
- **Never commit secrets, machine-specific paths, or personal operational data.**
  This repo is public.
- **Don't fabricate.** No invented benchmarks, dates, user counts, or claims. If a doc
  needs a number we don't have, mark it `TBD`.
- **Keep this file true, and short.** If you change direction (platforms, fork strategy,
  license), update AGENTS.md and the relevant ADR in the same commit. Put history in
  `docs/PROJECT-LOG.md`, status in `PLAN.md`, and nothing dated or counted here.
- Commit messages: conventional, imperative, explain why when it isn't obvious.
- When a task is ambiguous, the tiebreaker is the mandate above: what gets a polished,
  installable browser into users' hands sooner?
