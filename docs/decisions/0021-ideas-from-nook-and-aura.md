# 0021 — Ideas from Nook and Aura: rebuilt, never copied

Status: Accepted. Ad blocking's rule is [ADR 0030](0030-ad-and-tracker-blocking.md). A Space's own essentials are [ADR 0028](0028-a-spaces-own-essentials.md).
Date: 2026-10-11

## Context

Nook (`nook-browser/Nook`) is a WebKit browser for macOS, in Swift, GPL-3.0, with its name and icon reserved. Aura (`doorhinge-apps/Aura-Browser`) is an archived iPad-first WebKit app in Swift, MPL-2.0 since 2025-06-06 (GPL-3.0 before that; the rewrite has no license). Neither shares code with this Chromium series. GPL-3.0 would make every Stedding binary GPL-3.0. An MPL-2.0 file keeps its own license and its source obligation, so the core would no longer be all BSD-3-Clause ([ADR 0002](0002-license-bsd-3-clause.md), [ADR 0005](0005-open-core.md)).

## Decision

Their behaviours are rebuilt from written descriptions. Nothing of theirs is copied: no code, scripts, data files, shortcut tables, icons or layout constants, and no translation of those.

A third-party piece comes from its own project, under its own license, and gets an ADR first. Ad and tracker blocking is [ADR 0030](0030-ad-and-tracker-blocking.md): Chromium's subresource filter, lists fetched at run time, nothing from a list built in.

AI stays out ([ADR 0020](0020-no-bundled-model.md)). Boosts stay deferred ([ADR 0012](0012-defer-boosts-and-easels.md)). If they return, the shape is a live preview while typing and a switch per site in the page menu, with the CSS applied as the page starts loading.

The behaviours are on [ROADMAP.md](../ROADMAP.md) M10. Each one stands on its own spec rows. [PRODUCT.md](../PRODUCT.md) §12 counts shortcut customisation, the Site Control Center, Developer Mode, extensions and import toward 1.0.

Read, and left out:

- YouTube and social-site tweaks, including hiding Shorts and sponsored posts, and SponsorBlock. That is a script host per site, the reason Boosts are deferred, and extensions already do it.
- A cookie and cache inspector, and a score of how risky a site is. Chromium's site-data pages cover the data.
- An address field in the sidebar. The address row stays on the page card (toolbar T1 to T5). Amended 2026-11-18: later built as an option, off by default, as at the top of Arc's sidebar (sidebar Y46, GitHub issue 45).
- Daily sidebar backups, cut on 2026-09-26 (import I17, I19).
- A history of its own per Space. Essentials of a Space with its own session were later taken ([ADR 0028](0028-a-spaces-own-essentials.md)).
- Drag previews that change shape, and trackpad haptics.

## Consequences

Whoever builds one of these works from the descriptions in [BACKLOG.md](../../BACKLOG.md) and [VISION.md](../VISION.md#competitors), and does not open the other project's files.

What blocking changes in the privacy defaults is [ADR 0030](0030-ad-and-tracker-blocking.md).
