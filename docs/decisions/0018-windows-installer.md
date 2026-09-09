# 0018 — Windows: Chromium's own installer, per user, under Stedding's name

Status: accepted
Date: 2026-09-09

## Context

M8 (`docs/ROADMAP.md`) ends in something a Windows user installs. Round 8 had the
series building and running on Windows (patch 0039, `docs/features/windows.md`
N1–N2) as a "Chromium" build in every way Windows can see: the name, the icon, the
install and profile directory `%LOCALAPPDATA%\Chromium`, the registry keys, the COM
classes and the sandbox's app container prefix. An installer made from that would
have installed on top of a Chromium install, not beside it.

Chromium ships an installer of its own: `mini_installer.exe`, a self-extracting
archive that carries `setup.exe` and the browser, installs per user without
elevation or system-wide with it, registers the browser with the shell (ProgIDs,
default-browser candidacy, the uninstall entry), and uninstalls cleanly. Google's
updater is a separate component the installer does not need.

The alternatives were an MSIX package (store-friendly and sandboxed, but useless
without a signing certificate and a stranger to Chromium's own registration code),
a third-party wrapper such as Inno Setup or NSIS (a second installer around the
browser's own, duplicating what `setup.exe` already does), and a zip (nothing
registered, nothing to uninstall, and no way to set the browser as the default).

## Decision

- **The installer is Chromium's `mini_installer`**, built from the `win-release`
  configuration (`tooling/args/win-release.gn`, non-component, no symbols, no PGO)
  by `tooling/win/build.ps1`, packaged as `dist/Stedding-<VERSION>-win-x64.exe`
  with its sha256 by `tooling/win/package-installer.ps1`, and published beside the
  Mac's DMG by `tooling/publish-release`, which now joins a release the other
  platform created rather than refusing it.
- **Per-user installs.** `%LOCALAPPDATA%\Stedding\Application` for the browser,
  `%LOCALAPPDATA%\Stedding\User Data` for the profile; no elevation, no system-wide
  install offered until the build is signed.
- **The install mode is Stedding's** (`chrome/install_static/chromium_install_modes.h`,
  patch 0041): the product path, app name, app id and ProgIDs are Stedding's, and
  the Active Setup GUID, the toast activator, elevator and tracing service CLSIDs
  and IIDs, and the sandbox SID prefix are fresh, so a Stedding install and a
  Chromium install on one machine share no key, class or container.
- **Unsigned, and the notes say so.** SmartScreen shows "Windows protected your PC"
  until a code-signing certificate exists; the release notes carry the two clicks
  past it, as the Mac notes carry the Gatekeeper right-click. Signing is `S-17`'s
  Windows half when the Mac's is settled.
- **No auto-update on Windows yet.** Chromium's Windows updater is Google's; a
  Stedding updater against GitHub Releases, like the Mac's stub, is its own decision
  later. Until then a new beta is a new download.

## Consequences

- Every Windows release is one file, and `tooling/publish-release --check` refuses
  it for the same reasons it refuses a DMG: the wrong image, a checksum the notes do
  not carry, an unpushed commit.
- A Windows user who also runs Chromium keeps both; a user who installed the round-8
  experiment as "Chromium" has a stray profile under `%LOCALAPPDATA%\Chromium` that
  nothing migrates, since that build was never published.
- The `win-release` build is not the Mac's `official` (no PGO, no LTO): performance
  numbers are not quoted from it, and the Windows quality gates (`docs/ROADMAP.md`
  M8) wait for a configuration that can be.
