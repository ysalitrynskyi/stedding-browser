# 0014 — GitHub hosts updates; stedding.dev is a website

Status: Accepted, partly superseded. The check itself (its endpoint, and on by default) is [0022](0022-sparkle-updates-the-mac.md) on the Mac and [0023](0023-updates-on-windows-and-linux.md) and [0026](0026-a-windows-update-key.md) on Windows. Amended 2026-11-03 by [0031](0031-main-and-side-releases.md): only main releases use the `v<x.y.z[-beta.n]>` tag and reach the feeds. What stands is the host.
Date: 2026-08-31

## Context

An appcast server or Omaha would be a service this project had to run, on the path of a security update. The release files already live on GitHub. A website on the path of an update fails closed when the site is down.

## Decision

**GitHub hosts the release files and the update feeds. The project runs no update server.** stedding.dev, in its own repository, is the website. An update does not ask the site whether a newer version exists. `tooling/publish-release` tags `v<major>.<minor>.<patch>`, with an optional `-beta.<n>`.

The first cut also had the browser ask the GitHub Releases API, off until a settings row existed. That part was replaced: the Mac reads `updates/appcast.xml` with Sparkle (0022), Windows reads `updates/appcast-windows.xml` with Stedding's own updater (0023, 0026), and the check is on by default. What it sends is in [PRIVACY.md](../PRIVACY.md) ("The update check").

## Consequences

There is no update server to run. The feeds are files in this repository, read from GitHub; the image is the release's own file. If the site is down, the update still installs. The feed URL is in the build, so pointing updates somewhere else is a release.
