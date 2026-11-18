# 0007 — Chromium version pin: newest stable, single source of truth

Status: Accepted
Date: 2026-08-30

## Context

[ADR 0003](0003-chromium-minimal-patch-fork.md) chose Chromium stable as the base. The pin is which build the patch series sits on. A pin that lags means a larger rebase, and it means shipping known vulnerabilities ([ROADMAP.md](../ROADMAP.md#the-quality-bar), security).

## Decision

Pin to the newest build on Chromium's stable channel for the platforms we ship. The only copy is [`tooling/chromium-version`](../../tooling/chromium-version). [`tooling/lib.sh`](../../tooling/lib.sh) reads it. [`tooling/check-repo`](../../tooling/check-repo) `version` fails if any file that is not documentation hard-codes the version. Documentation may quote the pin.

At or below 1% of a platform's stable users, a build is a partial rollout (early stable, or a respin being tried). [`tooling/check-pin`](../../tooling/check-pin) names it and leaves the pin. The pin follows that build once it reaches more than 1% of users. The verdict follows Mac stable, the first platform we ship ([ADR 0006](0006-platform-order-macos-first.md)). Windows uses the same pin. Linux is consulted so a point release on our milestone is seen when a Mac rollout is pulled. Extended stable is out.

Moving the pin is its own commit. The file records the tag, the milestone, the upstream commit, the channel and the date. The pin stays back only for a named, fixed blocker, written in that commit.

A stable cut may be merged before Mac stable serves it, as the owner did with M157's, 157.0.8103.31, on 2026-10-28. The file then records the channel as beta, `tooling/check-pin` reports `ahead`, and the pin still moves to the build Mac stable serves once that build is past 1%. Amended 2026-11-18: the pin has since moved to an M157 build on the stable channel (2026-11-12); `tooling/chromium-version` has the current one.

A security update on stable is a rebased release within 7 days when the fix is in the wild, and within 14 days otherwise ([ROADMAP.md](../ROADMAP.md#the-quality-bar)). `tooling/check-pin` runs daily. The `upstream` workflow opens one issue while the pin is not current, and closes it when the pin is current.

## Consequences

One file answers which Chromium a checkout is on. Rebases stay small, which is the point of the series in ADR 0003. A pin ahead of Mac stable is work in the tree. Shipping it is a separate step.
