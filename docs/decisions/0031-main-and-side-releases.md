# 0031 — Main and side releases, and an important update shown as one

Status: Accepted (the owner, 2026-11-03). Amends ADR 0014 on tags and ADR 0022 and 0023 on what the feeds may carry. Being built in 0.4.0 beta 8 (`BACKLOG.md` S-405, S-406).
Date: 2026-11-03

## Context

Stedding will publish builds that are not the next version for everyone: a Linux build, a
Windows build for ARM, a test build for the Mac or Windows. The owner, 2026-11-03: none of
them may reach the updaters, the site, Homebrew or the README, a test copy must not update
by surprise, and the system has to hold for every release to come.

What reaches whom today, read on 2026-11-03:

- **The browsers** read only the two feeds on main, `updates/appcast.xml` (Sparkle, ADR 0022)
  and `updates/appcast-windows.xml` (Stedding's own updater, ADR 0023). A GitHub release of
  any kind, draft, pre-release or full, offers nobody an update. Only a commit to a feed does.
- **The site** reads `/releases/latest`, and fills a platform that release lacks from older
  releases by file name (`Stedding-<version>-arm64.dmg`, `-win-x64.exe`). Its what's-new code
  throws on a tag that is not `v<x.y.z[-beta.n]>`, which would stop every later build.
- **Homebrew** reads `/releases/latest` and its DMG's checksum.
- **The README** links to `/releases/latest`; its badge counts pre-releases.
- **`tooling/publish-release`** joins an existing release of the same tag and keeps its flags.
- **`tooling/check-repo`** wants one notes file in `docs/release-notes/`, the latest release's.
- **The Windows updater** takes items whose `sparkle:os` is `windows-x64`, a constant, and
  refuses a feed whose newest version is older than one it has seen (its replay guard), so a
  test item put in the feed and taken out again would stop that copy's updates for good.
- **Neither feed** says whether an update matters more than another; the sidebar's pill reads
  the same for every update.

## Decision

1. **Two kinds of release.** A *main* release is the next version for everyone: a tag
   `v<x.y.z[-beta.n]>`, made by `tooling/publish-release`, GitHub's latest, in the feeds, on
   the site, in Homebrew and in the README, with its notes in `docs/release-notes/`. Every
   other build is a *side* release.
2. **A side release never touches the main line.** `tooling/publish-side` makes it: a GitHub
   pre-release that is never marked latest, under a tag that starts `side-`
   (`side-linux-0.4.0-beta.8.1`), with files named `Stedding-side-…`, so no rule that looks
   for a main file matches them, and its notes kept on its GitHub page, not in the
   repository. It refuses a main tag, a main file name, and a tag that already exists. It
   never writes a feed, the site, the cask or the README.
3. **The feeds carry main releases only.** A test item is never added to a feed, not even
   briefly: the Windows replay guard would hold it against every later feed. A test of the
   updater runs against a copy of the feed (`--stedding-update-feed`, ADR 0023).
4. **Every reader keys on the main tag.** The site reads only releases whose tag is a main
   tag and that are not pre-releases; the README's badge stops counting pre-releases.
5. **A side build's own updates.** A side build of a platform with an updater keeps reading
   the main feed: it is offered the next main release once that is newer, which returns it to
   the main line. A build for another architecture reads only items for its own (`sparkle:os`
   `windows-arm64` beside `windows-x64`) before it ships (S-404). A Linux build has no
   updater; the package system updates it (S-216).
6. **An important update.** `tooling/publish-appcast --important "<reason>"` marks a release's
   items, as Sparkle's `criticalUpdate` with the reason beside it. A browser offered one shows
   it strongly and never forces it (the owner, 2026-11-03): the sidebar's pill turns red as
   "Important update", and a bar under the page at every launch gives the reason in one line
   with Restart now, until it is installed. Nothing restarts by itself. A copy with automatic
   updates off makes no requests and is not reached; that switch stays the user's.

## Consequences

- A Linux, ARM or test build can be published at any time without a release of the main line,
  and without a step that can be forgotten: the tool refuses what would leak.
- The site, Homebrew and the README stay on the main line however many side releases there
  are.
- `docs/HANDOFF.md` ("After a release") names both tools. The `updates.md` spec gains rows for
  the important update.
- The feeds' format grows one element; `tooling/appcast.py` keeps it when it rewrites a feed.
