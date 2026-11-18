# 0031 — Main and side releases, and an important update shown as one

Status: Accepted (the owner, 2026-11-03). Amends ADR 0014 on tags and ADR 0022 and 0023 on what the feeds may carry. Built in 0.4.0 beta 8 (S-405, S-406).
Date: 2026-11-03

## Context

Stedding will publish builds that are not the next version for everyone: a Linux build, a Windows build for ARM, a test build for the Mac or Windows. The owner, 2026-11-03: none of them may reach the updaters, the site, Homebrew or the README, a test copy must not update by surprise, and the system has to hold for every release to come.

What read the releases on 2026-11-03:

- **The browsers** read only the two feeds on main (ADR 0022, ADR 0023). A GitHub release of any kind offers nobody an update; only a commit to a feed does.
- **The site, Homebrew and the README** read `/releases/latest`. The site fills a platform that release lacks from older releases by file name, and its what's-new code throws on a tag that is not `v<x.y.z[-beta.n]>`.
- **`tooling/publish-release`** joins an existing release of the same tag, and **`tooling/check-repo`** wants one notes file in `docs/release-notes/`.
- **The Windows updater** takes items whose `sparkle:os` is `windows-x64` and refuses a feed whose newest version is older than one it has seen (its replay guard), so a test item put in the feed and taken out again would stop that copy's updates for good.
- **Neither feed** said whether an update matters more than another.

## Decision

1. **Two kinds of release.** A *main* release is the next version for everyone: a tag `v<x.y.z[-beta.n]>`, made by `tooling/publish-release`, GitHub's latest, in the feeds, on the site, in Homebrew and in the README, with its notes in `docs/release-notes/`. Every other build is a *side* release.
2. **A side release never touches the main line.** `tooling/publish-side` makes it: a GitHub pre-release never marked latest, under a `side-` tag (`side-linux-0.4.0-beta.8.1`), with files named `Stedding-side-…` and its notes on its GitHub page. It refuses a main tag, a main file name and a tag that exists, and never writes a feed, the site, the cask or the README.
3. **The feeds carry main releases only.** A test item is never added to a feed, not even briefly. A test of the updater runs against a copy of the feed (`--stedding-update-feed`).
4. **Every reader keys on the main tag.** The site reads only main tags that are not pre-releases; the README's badge stops counting pre-releases.
5. **A side build's own updates.** A side build with an updater keeps reading the main feed, so the next main release returns it to the main line. A build for another architecture reads only items for its own `sparkle:os` (S-404). A Linux build is updated by its package system (S-216).
6. **An important update.** `tooling/publish-appcast --important "<reason>"` marks a release's items, as Sparkle's `criticalUpdate` with the reason beside it. The browser shows it strongly and never forces it (the owner): the sidebar's pill turns red as "Important update", and a bar under the page at every launch gives the reason with Restart now, until it is installed. A copy with automatic updates off is not reached.

## Consequences

- A Linux, ARM or test build can be published at any time without a release of the main line; the tool refuses what would leak.
- The site, Homebrew and the README stay on the main line however many side releases there are.
- `docs/HANDOFF.md` ("After a release") names both tools. The `updates.md` spec has rows for the important update.
- The feeds' format grows one element; `tooling/appcast.py` keeps it when it rewrites a feed.
