# 0019 — Independent Space sessions are StoragePartitions, not Chrome profiles

Status: Accepted. Amended by [ADR 0028](0028-a-spaces-own-essentials.md) (a Space with its own session has its own essentials), [ADR 0025](0025-apps-keep-their-spaces-session.md) (an app keeps that Space's jar) and [ADR 0034](0034-spaces-that-share-a-named-session.md), proposed 2026-11-05 (several Spaces can share one session).
Date: 2026-09-16

## Context

A Space can keep its own cookies, HTTP cache, localStorage, IndexedDB and service workers, so one site can be signed in with different credentials in different Spaces of one window. Extensions, settings, history and saved passwords stay on the profile.

A full Chromium profile per Space would split extensions, preferences and history, and a tab cannot move between profiles without destroying its `WebContents`. Swapping only the cookie jar leaks on background requests. Chromium already shards this data by `StoragePartition`.

## Decision

An isolated Space is still one profile. Its web tabs are created with `SiteInstance::CreateForFixedStoragePartition` against `StoragePartitionConfig::Create(context, "spaces", profile_id, /*in_memory=*/false)` (patch 0046; the domain string is `kSpacePartitionDomain`).

`RegistryEntry::profile_id` is that partition name. Empty means the Space has never been isolated. The first time isolation is turned on, a random `base::Token` is written and kept. A value already stored stays the partition name as it is. The `isolated` flag beside it says whether the Space is isolated now, so turning it off and on again reattaches the same jar (patch 0049). A registry written before the flag existed reads a token as on (`SpaceRegistryTest.OldRegistryTokenMeansIsolated`). The value is the partition name only.

Isolation is off until it is turned on for that Space. `stedding.spaces.own_session`, off by default, starts each new Space isolated (patch 0084). The browser's own pages stay on the profile's jar (`SpaceStoragePartitionTest.OnlyTheWebLivesInASpacesJar`). A private window has no Spaces. A Blank Window has no Space registry, so it offers no Independent session (`SpaceMenuJarTest.ABlankWindowOffersNoIndependentSession`, patch 0071).

Shared essentials stay on the default partition. An essential pinned in a Space with its own session is that Space's, in its partition (`stedding.own_essential`, patch 0083, [ADR 0028](0028-a-spaces-own-essentials.md)). An app made from a page keeps the jar of the Space it was made in while that session is on (patch 0072, [ADR 0025](0025-apps-keep-their-spaces-session.md)).

`window.open` with an opener keeps the opener's `SiteInstance`. A page opened with no opener is put back in the Space's jar before it loads. No patch edits `web_contents_impl.cc`. Patch 0067 teaches `content/` a Space's sessionStorage and its notifications. Patch 0071 keeps a Space's session cookies across a restart, in `chrome/browser/net/profile_network_context_service.cc`, as the profile's jar does.

Saved passwords, history, extensions and preferences stay on the profile. No patch points the extension cookie API at a Space's jar.

## Consequences

Two isolated Spaces can be signed into the same site at once. Spaces that are not isolated share the profile's jar.

Deleting an isolated Space wipes its partition once its tabs have moved (sessions S17). Clear Independent Session on the chip menu wipes the jar in place and keeps the Space and its `profile_id` (sessions S13). Turning isolation off keeps the jar.

Binding two Spaces to one jar, or giving a Space its own extension set, needs a later ADR. In [PRODUCT.md](../PRODUCT.md) §2, a Space's own session is this partition.
