# 0019 — Independent Space sessions are StoragePartitions, not Chrome profiles

Status: Accepted. Amended by [ADR 0028](0028-a-spaces-own-essentials.md) (a Space with its own session has its own essentials), [ADR 0025](0025-apps-keep-their-spaces-session.md) (an app keeps that Space's jar) and [ADR 0034](0034-spaces-that-share-a-named-session.md), accepted 2026-11-10 (several Spaces can share one named session). Since 2026-11-13 the product no longer says "Independent session": the menu's Clear Independent Session below is Clear Session Data… (ADR 0034, "The words"; `BACKLOG.md` S-477).
Date: 2026-09-16

## Context

A Space can keep its own cookies, HTTP cache, localStorage, IndexedDB and service workers, so one site can be signed in with different credentials in different Spaces of one window. Extensions, settings, history and saved passwords stay on the profile.

Options considered:

- **A Chromium profile per Space.** Splits extensions, preferences and history, and a tab cannot move between profiles without destroying its `WebContents`.
- **Swapping only the cookie jar.** Leaks on background requests.
- **A `StoragePartition` per Space.** Chromium already shards this data that way.

## Decision

An isolated Space is still one profile. Its web tabs are created with `SiteInstance::CreateForFixedStoragePartition` against `StoragePartitionConfig::Create(context, "spaces", profile_id, /*in_memory=*/false)` (patch 0046; the domain string is `kSpacePartitionDomain`).

`RegistryEntry::profile_id` is that partition name. Empty means the Space has never been isolated. The first time isolation is turned on, a random `base::Token` is written and kept. The `isolated` flag beside it says whether the Space is isolated now, so turning it off and on again reattaches the same jar (patch 0049). A registry written before the flag existed reads a token as on.

Isolation is off until it is turned on for that Space. `stedding.spaces.own_session`, off by default, starts each new Space isolated (patch 0084). The browser's own pages stay on the profile's jar. A private window has no Spaces, and a Blank Window, having no Space registry, offers no session of its own (patch 0071).

Shared essentials stay on the default partition; an essential pinned in a Space with its own session is that Space's, in its partition (patch 0083, ADR 0028). An app made from a page keeps the jar of the Space it was made in (patch 0072, ADR 0025).

`window.open` with an opener keeps the opener's `SiteInstance`. A page opened with no opener is put back in the Space's jar before it loads. No patch edits `web_contents_impl.cc`. Patch 0067 teaches `content/` a Space's sessionStorage and its notifications. Patch 0071 keeps a Space's session cookies across a restart, as the profile's jar does. No patch points the extension cookie API at a Space's jar.

## Consequences

Two isolated Spaces can be signed into the same site at once. Spaces that are not isolated share the profile's jar.

Deleting an isolated Space wipes its partition once its tabs have moved (sessions S17). Clear Independent Session on the chip menu wipes the jar in place and keeps the Space and its `profile_id` (sessions S13). Turning isolation off keeps the jar.

Binding two Spaces to one jar needed a later ADR: [0034](0034-spaces-that-share-a-named-session.md). A Space with its own extension set still would. In [PRODUCT.md](../PRODUCT.md) §2, a Space's own session is this partition.
