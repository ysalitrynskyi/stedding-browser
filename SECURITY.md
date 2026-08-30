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

The project is **pre-release: there are no shipped binaries yet**. Until the first
release, the realistic scope is:

- The contents of this repository (documentation, and later build scripts and the
  patch series).
- The project's release and supply-chain setup as it comes into existence
  (CI, signing, update mechanism).

Vulnerabilities in upstream Chromium should be reported to the
[Chromium security team](https://www.chromium.org/Home/chromium-security/reporting-security-bugs/),
not here. Once Stedding ships binaries, anything in a Stedding release — including
Stedding-specific patches on top of Chromium — is in scope.

## Supported versions

No versions have been released. This section will list supported release lines once
the first release exists.
