# Contributing to Stedding Browser

Thanks for your interest. The project is at **milestone M0** — there is build
tooling but no installable browser yet (see [README.md](README.md) and
[docs/ROADMAP.md](docs/ROADMAP.md)). That shapes what kinds of contributions are
useful right now.

## What helps now

- **Discussions and issues.** Questions, critiques of the plan, prior art we missed,
  Chromium fork experience, packaging and signing knowledge — open a GitHub issue or
  discussion. Disagreement with a documented decision is welcome; argue against the
  reasoning in the relevant ADR.
- **Documentation PRs.** Fixes and improvements to anything in `docs/`, this file, or
  the README: factual errors, unclear wording, broken links, missing considerations.
  Small focused PRs are easiest to review.
- **Design input.** The feature spec (`docs/PRODUCT.md`) and privacy defaults
  (`docs/PRIVACY.md`) are living documents until code freezes them into behavior.

- **Build tooling.** `tooling/` exists and is exercised on macOS arm64 only. Fixes
  to the scripts, and reports of what breaks on a machine unlike the reference one,
  are useful now. Run `tooling/check-repo` and `shellcheck -x tooling/*` before
  opening a PR; CI runs both. Note that macOS ships bash 3.2, so the scripts must
  work there.

## What comes later

**Browser code contributions become meaningful once M0 lands** — that is, once the
vanilla Chromium build is verified and the patch series has somewhere to sit. The
patch workflow (`tooling/apply-patches`, `tooling/update-patches`) is already built
and documented in [tooling/README.md](tooling/README.md); it simply has an empty
series so far. The first patches arrive with branding at M1.

## Ground rules

- **Decisions go through ADRs.** Anything hard to reverse — dependencies, base
  version policy, licensing, naming — is recorded in `docs/decisions/NNNN-slug.md`
  before or with the change. If your proposal alters a recorded decision, the PR
  should update or supersede the ADR, not silently contradict it.
- **English.** All docs, code comments, commit messages, and issues are written in
  plain, correct English.
- **No fabrication.** No invented benchmarks, dates, user counts, or claims in any
  document. Unknown numbers are marked `TBD`.
- **This repo is public.** Never commit secrets, machine-specific paths, or personal
  operational data.
- **Do not copy code from other browsers into this repository.** Studying how another
  project solved something is encouraged; transcribing its implementation is not. The
  licences differ in ways that matter: this project is BSD-3-Clause (ADR 0002), while
  Zen Browser is MPL-2.0 and Vivaldi's UI is proprietary. MPL-2.0 is file-level
  copyleft — a file containing MPL code stays MPL and its source must be distributed —
  so pasting it here would either breach the licence or force those files out of the
  BSD core we committed to. Chromium itself is the exception and the reason: it is
  BSD-3-Clause, which is why we can build on it at all.

  In practice: read other browsers for product and architectural decisions, write our
  own implementation, and say in the commit message where an idea came from.

## Commit style

- Conventional, imperative subject line: `docs: clarify M0 acceptance criteria`,
  `fix: correct link to PRIVACY.md`.
- Keep the subject under about 72 characters.
- Add a body when the *why* is not obvious from the diff.

## License and CLA

There is **no CLA**. By contributing you agree that your contributions are licensed
under the project's [BSD-3-Clause license](LICENSE), the same terms as the rest of
the repository.
