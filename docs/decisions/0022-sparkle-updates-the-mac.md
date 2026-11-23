# 0022 — Sparkle updates the Mac, from a signed feed in this repository

Status: Accepted. Partly supersedes [ADR 0014](0014-github-releases-as-update-channel.md): the check's endpoint, and updates on by default. The site stays off the update path. Windows is [ADR 0023](0023-updates-on-windows-and-linux.md) and [ADR 0026](0026-a-windows-update-key.md).
Date: 2026-10-16

## Context

[ADR 0014](0014-github-releases-as-update-channel.md) chose GitHub Releases as the channel and left applying an update for later. GitHub's latest-release endpoint returns only full releases, and Stedding's releases were then pre-releases. That endpoint also cannot carry a signature made with a key only the project holds. The Mac image has been signed and notarized since beta 10, so an update can be checked before it replaces the app.

## Decision

Sparkle 2.10.1 applies updates on the Mac. `tooling/fetch-sparkle` takes that release's archive, checked against the digest GitHub publishes for it, and the build bundles `Sparkle.framework` without its XPC services. The browser drives Sparkle. No Sparkle window opens. The sidebar, the command bar, the About page and the app menu show what it is doing ([updates](../features/updates.md)).

The feed is `updates/appcast.xml`, read from `main` on `raw.githubusercontent.com`. `tooling/publish-appcast` writes it after a release. The image and the feed are both signed with the project's EdDSA key (`SURequireSignedFeed` and `SUVerifyUpdateBeforeExtraction` in `chrome/app/app-Info.plist`). The private key is in the publishing Mac's login keychain, account `stedding` (`tooling/publish-appcast`). It is not in this repository.

Automatic updates are on by default (`stedding.updates.automatic`, registered `true`), with a switch in Settings › Stedding › Updates. Ten seconds after a launch, when the last check is more than an hour old or there is none, the browser asks Sparkle to check. Sparkle then checks every six hours (`SUScheduledCheckInterval` 21600, `stedding::kUpdateCheckInterval`, patch 0078, updates Up1). With the switch off, Sparkle is not started, so there is no update request until the user chooses Check for Updates.

Only a bundle signed by a team starts the updater. A copy built locally, signed ad hoc, does not replace itself.

The thank-you pages are on stedding.dev and are not on the update path. When the welcome flow ends, the browser opens `https://stedding.dev/thanks/` once per installation. On the first launch of a later version it opens `https://stedding.dev/thanks/updated/#v` plus the version. The version is in the fragment. If the site is down, the update still installs.

`CFBundleVersion` carries Stedding's version as `<100000 + 10000 × major + 100 × minor + patch>.<n>`, with 999 for a release (0.7.1 is 100701.999). Sparkle and LaunchServices compare that key (updates Up11). Up to 0.7.0 it was `<10000 + 1000 × major + 10 × minor + patch>.<n>` (0.2.0-beta.16 is 10020.16), which gave a patch above 9 no number of its own. Every number of the new form is above every number of the old, so an installed copy sees the next release as newer.

## Consequences

With the switch on, the browser requests the feed from `raw.githubusercontent.com`, and the image from `github.com` when a newer one is listed. [PRIVACY.md](../PRIVACY.md) names both, and the two pages.

A release is offered with `tooling/publish-appcast --push` after it has been tried as a user gets it. Leaving it out of the feed holds it. The feed keeps the newest five releases. Sparkle does not install an older version over a newer one. A bad release is taken back by removing it from the feed and fixing it in a later version ([ROADMAP.md](../ROADMAP.md#the-quality-bar)).

A fork that keeps this feed URL and this public key is updated to this project's releases. A fork changes both in `chrome/app/app-Info.plist`.
