# Security Policy

## Reporting a vulnerability

Please report vulnerabilities through **GitHub private vulnerability reporting** on
this repository: go to the **Security** tab and click **Report a vulnerability**.
This creates a private advisory visible only to you and the maintainers.

Please do not open public issues for security problems, and do not report them by
email or social media — the Security tab is the only monitored channel.

A good report includes:

- What is affected (file, document, or — once code exists — component and version).
- Steps to reproduce, or a clear explanation of the flaw.
- Impact as you understand it.

## Response expectations

This is a small project without a dedicated security team. Honestly stated:

- We aim to acknowledge reports within **7 days**.
- Triage and a fix timeline depend on severity and maintainer availability; there is
  no guaranteed SLA.
- We will keep you informed inside the private advisory and credit you in the fix
  (unless you prefer otherwise).

## Scope

Stedding ships **unsigned beta binaries** for macOS (Apple silicon) and a Windows x64
preview on [Releases](https://github.com/ysalitrynskyi/stedding-browser/releases).
Anything in one of those builds is in scope:

- The Stedding patch series on top of Chromium (`patches/`) and the branding applied to
  the build — our code, our bugs.
- The release and supply-chain setup: CI, the release scripts in `tooling/`, the
  checksums published beside each image, and the update mechanism as it lands.
- The contents of this repository, including documentation that would lead a user into
  an unsafe configuration.

Two things about the current builds that are not vulnerabilities, because they are
documented properties of a beta:

- **The builds are unsigned and unnotarised** (`BACKLOG.md` S-17). macOS refuses them
  on a double-click and the release notes give the per-app right-click bypass. Signing
  lands at M7.
- **There is no auto-updater yet.** A build does not update itself, so an installed
  beta stays on the Chromium version it was cut from until it is replaced by hand. The
  pin is watched daily (`.github/workflows/upstream.yml`, `tooling/check-pin`) and the
  rebase timetable is in `docs/QUALITY.md`.

Vulnerabilities in upstream Chromium should be reported to the
[Chromium security team](https://www.chromium.org/Home/chromium-security/reporting-security-bugs/),
not here — unless the Stedding patch series changes the behaviour, in which case it is
ours.

## Supported versions

Only the most recent pre-release is supported. Older betas are superseded on the day a
new one is published and receive no fixes; there is no long-term support line, and
there will not be one before 1.0.

| Version | Supported |
|---|---|
| Latest pre-release on [Releases](https://github.com/ysalitrynskyi/stedding-browser/releases) | Yes |
| Any earlier pre-release | No — install the latest |

`VERSION` at the repository root is the version this tree builds.
