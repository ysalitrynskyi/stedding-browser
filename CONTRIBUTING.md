# Contributing to Stedding Browser

Stedding ships releases for macOS (Apple silicon) and Windows (x64), before 1.0. Downloads are on the
[Releases page](https://github.com/ysalitrynskyi/stedding-browser/releases). The Mac image
is signed and notarized. The Windows installer is not code-signed
([BACKLOG.md](BACKLOG.md) S-56). Both update themselves. Linux is not shipped.

The browser is a patch series on the Chromium release named in `tooling/chromium-version`
([ADR 0007](docs/decisions/0007-chromium-version-pin.md)). `main` can be ahead of the
latest release. A release's notes name the Chromium version that download was built on.
How to build is in the [README](README.md#building-from-source). Open work is
[BACKLOG.md](BACKLOG.md), the milestones are [docs/ROADMAP.md](docs/ROADMAP.md), and
`tooling/dev status` prints the live counts.

## What helps now

- **Using the latest release and saying what is wrong.** Install the latest release, use
  it, and open an issue for each thing that is worse. That is the fastest way to help.
- **Bugs and ideas.** An issue that reports a bug is fixed. An issue that asks for a
  feature is a suggestion: it is built only after the owner agrees
  ([PLAN.md](PLAN.md), decision 16).
- **Questions and disagreement.** Questions, critiques of the plan, prior art, Chromium
  fork experience, packaging and signing: open a GitHub issue. To disagree with a
  recorded decision, argue against the reasoning in its ADR.
- **Documentation.** Fixes to `docs/`, this file or the README: factual errors, unclear
  wording, broken links. A small pull request is easier to review.
- **Design.** Comments on [docs/PRODUCT.md](docs/PRODUCT.md),
  [docs/ROADMAP.md](docs/ROADMAP.md) and [docs/PRIVACY.md](docs/PRIVACY.md) are welcome.
  A change to behaviour updates the feature spec under `docs/features/` together with
  the code.
- **Build tooling.** The Mac build is made on a Mac. The Windows build is made on
  Windows (`tooling/win/`). Fixes to the scripts, and reports of what breaks on another
  machine, help. Run `tooling/check-repo` and `tooling/check-shell` before a pull
  request. The scripts must work under macOS's bash 3.2.

Hosted CI does not build Chromium ([docs/ARCHITECTURE.md](docs/ARCHITECTURE.md#ci-reality),
[BACKLOG.md](BACKLOG.md) S-49). `.github/workflows/` runs:

- `checks`, on every push to `main` and every pull request: `tooling/check-shell`,
  `tooling/check-repo`, `tooling/check-pin --self-test` and
  `tooling/check-disclosure --self-test`.
- `disclosure`, on every pull request: `tooling/check-disclosure` on the description and
  the commits, from the base branch's copy of the script ("AI tools" below).
- `series`, when `patches/`, `tooling/chromium-version`, `tooling/apply-patches` or
  `.github/workflows/series.yml` changes, and weekly: `tooling/apply-patches --check`.
- `upstream`, daily: `tooling/check-pin` against Chromium stable.

## Browser code

The series is organised by feature, with the exceptions named in
[patches/README.md](patches/README.md). `tooling/dev status` counts it. A change follows
[docs/AGENT-LOOP.md](docs/AGENT-LOOP.md): a row in the feature's spec under
`docs/features/`, a failing test (a unit test for model logic, a browser test for a
click or a drag), then the code on the `stedding-work` branch in the Chromium checkout.
A fix is folded into that feature's patch. A new feature adds one patch. Every patch
carries `Why:` and `Removable when:`. `tooling/dev patch` regenerates `patches/`. Do not
edit a `.patch` file by hand. Anything visual is tried on a real build and captured from
that window, as the same procedure describes. [docs/HANDOFF.md](docs/HANDOFF.md) has the
dev parameters and the traps.

## Ground rules

- **Decisions go through ADRs.** Anything hard to reverse — a dependency, the base
  version, licensing, naming — is recorded in `docs/decisions/NNNN-slug.md` before or
  with the change. A proposal that alters a recorded decision updates or supersedes
  that ADR in the same change.
- **English.** Docs, code comments, commit messages and issues are plain, correct
  English.
- **No fabrication.** No invented benchmarks, dates, user counts or claims. An unknown
  number is `TBD`.
- **This repository is public.** Never commit secrets, machine-specific paths or
  personal data.
- **Do not copy code from other browsers.** Reading how another project solved a
  problem is fine. Transcribing its implementation is not. This project is BSD-3-Clause,
  the same license as Chromium, so a patch carries no license friction in either
  direction ([ADR 0002](docs/decisions/0002-license-bsd-3-clause.md)). Chromium's
  third-party components keep their own licenses. Nook is GPL-3.0 and Aura is MPL-2.0
  ([ADR 0021](docs/decisions/0021-ideas-from-nook-and-aura.md)): GPL-3.0 on code here
  would make the binaries GPL-3.0, and an MPL-2.0 file keeps that license and its
  source obligation, so the core would no longer be all BSD-3-Clause (ADR 0005). Zen
  Browser is MPL-2.0 and Vivaldi's UI is proprietary
  ([docs/VISION.md](docs/VISION.md#competitors)). Rebuild ideas from written
  descriptions. Do not open Nook's or Aura's files. Name where an idea came from in
  the commit message.

## AI tools

You may use an AI tool (a coding agent, a chat assistant, or completion of more than a
line) to help with a pull request, an issue or a security report. These rules cover
every such contribution from outside the project. `tooling/check-disclosure` holds
every pull request to the first two. The form is
[.github/pull_request_template.md](.github/pull_request_template.md).

1. **Say so in the pull request.** The form has an **AI assistance** section. Tick
   exactly one box. If a tool helped, name the tool and the model and say what it did
   (wrote the fix, wrote the tests, drafted the description, reviewed the change).
2. **Mark every commit.** If a tool helped, each commit in the pull request ends with
   a trailer, in the form the Linux kernel uses:

   ```
   Assisted-by: AGENT_NAME:MODEL_VERSION [OTHER_TOOLS]
   ```

   If no tool helped, no commit carries that trailer. The check fails when the section
   is unanswered, the boxes are not exactly one, or the commits disagree with the box.
   Not `Co-authored-by:`: a tool is not an author and cannot agree to the license
   below. No "Generated with" footer or link either. Compilers, editors, formatters
   and spell checkers are not listed.
3. **A person answers for it.** You have read every line, can explain what it does and
   why without the tool, ran the checks and tests the change needs
   ([docs/AGENT-LOOP.md](docs/AGENT-LOOP.md)), and answer review yourself. Write the
   description yourself: what changed, why, and how you tested it.
4. **No agent acts alone.** No pull request, issue, comment or review is posted by an
   agent without a person reading it first. An agent never signs anything for you.
5. **The copying rule above applies to what a tool writes.** No code from another
   project, whether you or a tool reproduced it.
6. **No generated images.** A screenshot or a recording is of the window under test,
   from a real build: `tooling/capture-windows` and `tooling/record-window` on the Mac,
   `tooling/win/capture.ps1` and `tooling/win/drive.ps1` on Windows. No generated
   artwork, icons or video.
7. **Security reports.** Say whether a tool found the issue or wrote the report, and
   reproduce it on a released build before sending it ([SECURITY.md](SECURITY.md)).

A contribution whose tool use was not disclosed, or that its author cannot explain, is
closed.

## Commit style

- Conventional, imperative subject: `docs: correct the install steps`,
  `fix: keep a pinned tab's title`.
- Keep the subject under about 72 characters.
- Add a body when the why is not obvious from the diff.
- A commit an AI tool helped with ends in an `Assisted-by:` trailer ("AI tools" above).

## License and CLA

There is no CLA. By contributing you agree that your contributions are licensed under
the project's [BSD-3-Clause license](LICENSE), the same terms as the rest of the
repository: offered as is, without warranty. The project may accept, change or remove
any contribution, and takes on no duty to maintain or support it.
