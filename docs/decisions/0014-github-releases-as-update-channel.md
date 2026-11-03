# 0014 — GitHub hosts updates; stedding.dev is a website

Status: Accepted. The check’s endpoint, its default and applying an update are [0022](0022-sparkle-updates-the-mac.md) on the Mac and [0023](0023-updates-on-windows-and-linux.md) and [0026](0026-a-windows-update-key.md) on Windows. Linux is 0023 and is not shipped. The site stays off the update path. Amended 2026-11-03 by [0031](0031-main-and-side-releases.md): only main releases use the `v<x.y.z[-beta.n]>` tag; side releases use `side-<kind>-<version>` and never reach the feeds.
Date: 2026-08-31

## Context

An appcast server or Omaha would be a service this project had to run, on the path of a security update. The release files already live on GitHub.

stedding.dev is a separate question. A website on the path of an update fails closed when the site is down.

## Decision

**GitHub hosts the release files and the update feeds. The project runs no update server.** stedding.dev, in its own repository, is the website. An update does not ask the site whether a newer version exists.

What stands of the first cut is that choice of host. The check itself is no longer a call to the GitHub Releases API, and it is no longer off until a settings row exists:

- The Mac applies updates with Sparkle from `updates/appcast.xml` (0022).
- Windows applies them with Stedding’s own updater from `updates/appcast-windows.xml` (0023, 0026).
- The check is on by default. What it sends is in [PRIVACY.md](../PRIVACY.md) (“The update check”).

`tooling/publish-release` tags `v<major>.<minor>.<patch>`, with an optional `-beta.<n>`.

## Consequences

There is no update server to run. The feeds are files in this repository, read from GitHub; the image is the release’s own file ([PRIVACY.md](../PRIVACY.md)).

If the site is down, the update still installs. The thank-you pages on stedding.dev are not part of the check (0022).

The feed URL is in the build (0022, 0023). Pointing updates somewhere else is a release.
