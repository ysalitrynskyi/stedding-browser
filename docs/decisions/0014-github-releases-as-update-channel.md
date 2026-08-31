# 0014 — GitHub Releases is the update channel; stedding.dev is a website

Status: Accepted
Date: 2026-08-31

## Context

`ARCHITECTURE.md` left the updater as an open decision between Sparkle and
Chromium's own updater, and both assume infrastructure we would have to run: an
appcast or Omaha server, its hosting, its TLS, its availability, and its
security. For a project whose whole argument is that no company stands between
the user and the browser, running a fleet-management service is the wrong shape
as well as the wrong cost.

The artifacts already live somewhere with an API: GitHub Releases, which is
where `.dmg` files and their checksums are published anyway.

The question of what stedding.dev is for is separate, and conflating the two is
how projects end up with a marketing site on the critical path of a security
update.

## Decision

**Update checks go to the GitHub Releases API.** The browser asks
`api.github.com` for the latest release of `ysalitrynskyi/stedding-browser`,
compares the tag to its own version, and tells the user when a newer one exists.

- **No account, no identifier, no telemetry.** The request carries what an
  ordinary HTTPS request carries and nothing added: no install id, no machine
  id, no usage data. It is a version comparison, not a check-in.
- **GitHub sees an IP address and a timing pattern.** That is a real privacy
  cost and it goes in `PRIVACY.md` with the endpoint named, rather than being
  described as "no telemetry" and left there.
- **The check is off by default until it has a settings entry**, per the UX
  completeness rule in `QUALITY.md`. A browser that phones anywhere the user did
  not ask it to is the thing this project exists not to be.
- **Downloading and applying an update is a later step.** Knowing a newer
  version exists is useful on its own and is a fraction of the work; silent
  self-replacement needs signing (M7), a rollback path, and the n-1 test.

**stedding.dev is a website, not infrastructure.** Its own repository, built
with Astro, static, deployed from that repo. It carries the download link,
release notes, the security policy and the source link. It is deliberately
*not* on the path of an update check — if the site is down, updates still work.

## Consequences

- No update server to run, secure, or pay for, and none to be compromised. The
  release artifacts and the update metadata are the same objects.
- We inherit GitHub's availability and its rate limits. Unauthenticated
  `api.github.com` is limited per IP; a daily check is far inside that, but the
  client must treat a rate-limit response as "unknown", never as "up to date".
- If GitHub ever becomes unacceptable as a dependency, the check is one URL and
  a version comparison. That is a cheap thing to move, unlike a fleet of
  installed clients pointed at an Omaha server.
- The site being a separate repository keeps a marketing change from touching
  the browser's history, and keeps browser CI from waiting on a site build.
- This supersedes the Sparkle-versus-Chromium-updater question for *checking*.
  Whether we ever ship automatic *applying* — and with which mechanism — stays
  open and belongs to M7 alongside signing.
