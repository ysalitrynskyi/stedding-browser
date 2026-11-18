# 0018 — Windows: Chromium’s own installer, per user, under Stedding’s name

Status: Accepted. Windows applies updates itself: [0023](0023-updates-on-windows-and-linux.md) and [0026](0026-a-windows-update-key.md), in the product since patch 0073. Signing is still open (`BACKLOG.md` S-56).
Date: 2026-09-09

## Context

Chromium’s `mini_installer` is a self-extracting archive of `setup.exe` and the browser. It installs per user without elevation, registers the browser with the shell, and uninstalls cleanly. Google’s updater is a separate component.

An MSIX package needs a signing certificate before it is useful. A second installer, such as Inno Setup or NSIS, would repeat what `setup.exe` already does. A zip registers nothing and cannot be the default browser.

Before patch 0041 the Windows build was Chromium in every key Windows uses: `%LOCALAPPDATA%\Chromium`, the name, the ProgIDs, the COM classes and the sandbox prefix. An installer from that build would have replaced a Chromium install.

## Decision

- **The installer is Chromium’s `mini_installer`.** It is built from `win-release` ([win-release.gn](../../tooling/args/win-release.gn): non-component, no symbols) by `tooling/win/build.ps1`, packaged as `dist/Stedding-<VERSION>-win-x64.exe` with its sha256 by `tooling/win/package-installer.ps1`, and published by `tooling/publish-release`. A release the other platform already made is joined.
- **The published install is per user.** The browser is `%LOCALAPPDATA%\Stedding\Application`. The profile is `%LOCALAPPDATA%\Stedding\User Data` ([windows.md](../features/windows.md) N3, N6). A system-wide install is not part of what we publish (`BACKLOG.md` S-169).
- **The install mode is Stedding’s** (`chrome/install_static/chromium_install_modes.h`, patch 0041). The product path, app name, app id and ProgIDs (`SteddingHTM`, `SteddingPDF`) are Stedding’s, the launch scheme is `stedding:`, and the Active Setup GUID, the toast activator, the elevator, the tracing service and the sandbox SID prefix are Stedding’s own. A Stedding install and a Chromium install share no registry key, COM class or app container.
- **The installer is unsigned.** SmartScreen warns. Each release's notes give the two clicks: More info, then Run anyway. Signing is S-56.
- **Windows updates itself.** The updater, the feed and the key are 0023 and 0026. [ROADMAP.md](../ROADMAP.md) M8: from 0.2.0 beta 19.

## Consequences

`tooling/publish-release --check` refuses the installer when the checksum does not match the file, the notes do not carry that checksum, the tree is dirty, or the commit is not pushed. The same checks apply to the Mac image.

`win-release` is not the Mac’s `official` configuration. That one carries PGO and ThinLTO (`tooling/args/official.gn`). Performance numbers are not taken from `win-release`. M8 still has signing, CI and the Windows performance budgets left ([ROADMAP.md](../ROADMAP.md)).

A machine can have Stedding and Chromium installed together (windows N3).
