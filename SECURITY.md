# Security Policy

## Reporting a vulnerability

Report a vulnerability through GitHub private vulnerability reporting on this
repository. Open the **Security** tab and choose **Report a vulnerability**.
That opens a private advisory visible only to you and the maintainer.

Do not open a public issue for a security problem, and do not send it by email
or on social media. The Security tab is the only channel that is watched.

Include:

- What is affected: the component and the version, and a file or document when you know it.
- Steps to reproduce, or a clear explanation of the flaw.
- The impact, as you understand it.
- Whether an AI tool found the issue or wrote the report. Reproduce it on a
  released build before you send it. A report whose tool use was not disclosed, or that its author cannot explain, is
closed ([CONTRIBUTING.md](CONTRIBUTING.md#ai-tools)).

## Response expectations

This is a small project with one maintainer and no security team. Reports are
read and handled as a best effort. There is no set response time.

- We try to acknowledge a report soon.
- Whether a fix is made, and when it ships, depends on its severity and on the
  maintainer's time.
- We try to keep you informed in the private advisory, and to credit you when a
  fix ships, unless you prefer not to be named.

The [BSD-3-Clause licence](LICENSE) provides Stedding as is, without warranty.
That covers a security defect as it covers any other defect.

## Scope

Stedding publishes pre-1.0 binaries on
[Releases](https://github.com/ysalitrynskyi/stedding-browser/releases).
The macOS file is an Apple silicon disk image, signed with the project's
Developer ID and notarized by Apple. The Windows file is an x64 installer.
Linux is not shipped.

In scope:

- The patch series in `patches/`, and the branding applied to a release build.
- Release and supply chain: the workflows in `.github/workflows/`, the scripts
  in `tooling/`, and the SHA-256 checksum published with each file.
- The updaters and their feeds. The Mac uses Sparkle. Its feed is
  `updates/appcast.xml`, written by `tooling/publish-appcast` and fetched from
  `https://raw.githubusercontent.com/ysalitrynskyi/stedding-browser/main/updates/appcast.xml`
  ([ADR 0022](docs/decisions/0022-sparkle-updates-the-mac.md)). Windows uses
  Stedding's own updater. Its feed is `updates/appcast-windows.xml`, written by
  `tooling/win/publish-appcast.ps1` and fetched from
  `https://raw.githubusercontent.com/ysalitrynskyi/stedding-browser/main/updates/appcast-windows.xml`
  ([ADR 0023](docs/decisions/0023-updates-on-windows-and-linux.md),
  [ADR 0026](docs/decisions/0026-a-windows-update-key.md)).
  Each platform trusts its own key. A changed feed or download is not applied
  unless that key's signature verifies. The Windows updater runs an installer
  only when the Windows key's Ed25519 signature on that file verifies.
  stedding.dev is a website and is not on this path
  ([ADR 0014](docs/decisions/0014-github-releases-as-update-channel.md)).
- Text in this repository that would lead someone into an unsafe configuration.

Two properties of the current releases are not vulnerabilities:

- **The Windows installer is not code-signed** ([BACKLOG.md](BACKLOG.md) S-56).
  SmartScreen asks once. The release notes say to click **More info**, then
  **Run anyway**.
- **Safe Browsing is not active.** These builds carry no Google API key, so the
  list update is refused and pages are not checked against the lists
  ([docs/PRIVACY.md](docs/PRIVACY.md), [BACKLOG.md](BACKLOG.md) S-75).

The Chromium pin is checked daily
([`.github/workflows/upstream.yml`](.github/workflows/upstream.yml),
`tooling/check-pin`). When a rebased release is due is in
[docs/ROADMAP.md](docs/ROADMAP.md#the-quality-bar).

Report a vulnerability in upstream Chromium to the
[Chromium security team](https://www.chromium.org/Home/chromium-security/reporting-security-bugs/).
Report it here when a Stedding patch changes the behaviour.

## Supported versions

Only the newest release for a platform is supported. Support means a fix,
when there is one, goes into a newer release. It is not a promise of help or
of a fix.

Not every release includes both platforms, so the newest macOS image and the
newest Windows installer can come from different releases. An older release is
superseded on the day a newer one for that platform is published, and it
receives no fixes. There is no long-term support line, and there will not be
one before 1.0.

| Version | Supported |
|---|---|
| The newest release on [Releases](https://github.com/ysalitrynskyi/stedding-browser/releases) with a file for your platform | Yes |
| Any earlier release | No. Install the newest. |

`VERSION` at the repository root is the version this tree builds.
