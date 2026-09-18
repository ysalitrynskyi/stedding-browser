# 0019 — Independent Space sessions are StoragePartitions, not Chrome profiles

Status: accepted
Date: 2026-09-16

## Context

PRODUCT §2's "Per-Space Profiles" and ADR 0016's empty `profile_id` on a
registry Space exist so a Space can eventually own its own logins. The operator
asked for the behaviour users actually want: optional, per-Space isolation of
cookies, HTTP cache, localStorage, IndexedDB and service workers, so the same
site can be signed into with different credentials in different Spaces of one
window. Extensions, settings, history, saved passwords and the rest of the
profile stay shared.

Three designs were weighed.

- **A full Chromium Profile per Space.** Chrome's `Browser` is 1:1 with a
  Profile. Tabs cannot move between Profiles without destroying the
  `WebContents`. Extensions, prefs and history would split. That is more than
  was asked, and it fights ADR 0016 (one sidebar per profile).
- **Cookie-store swapping** (SessionBox and similar extensions). The Web Store
  copies were removed; MV3 cannot keep inactive tabs on a different jar.
  Background requests leak. Rejected.
- **A `content::StoragePartition` per isolated Space**, the same primitive
  Chromium uses for `<webview>` guests and Isolated Web Apps, and the one
  Brave's Containers (`brave-core` `components/containers`, targeting 1.92)
  and Helium's container-tabs request (`imputnet/helium#199`) sit on.
  `SiteInstance::CreateForFixedStoragePartition` keeps the partition across
  navigations in that tab. Firefox Multi-Account Containers are the UX
  precedent (`userContextId`); Ghost Browser identities are the paid-browser
  precedent (persistent cookie jars, shared browser chrome).

## Decision

- An isolated Space is still one Profile. Its tabs are created with
  `SiteInstance::CreateForFixedStoragePartition` against
  `StoragePartitionConfig::Create(context, "spaces", profile_id, false)`.
- `RegistryEntry::profile_id` is that partition name. Empty means the Space
  has never been isolated. Non-empty is a random `base::Token` written the
  first time isolation is turned on and kept from then on; whether the Space
  is isolated right now is the `isolated` flag beside it, so turning it off
  and on again reattaches the same jar with its logins. A registry written
  before the flag existed (beta 7) reads a token as on. It is not a Chrome
  profile path and not the Space's runtime id.
- Isolation is **opt-in per Space**. Essentials stay on the default partition
  (they are in every Space, B6). Private windows have no Spaces. A Blank
  Window's in-memory registry can isolate; its partitions are in-memory too,
  so nothing is written to disk.
- New files under `chrome/browser/ui/spaces/` own the helper. The one
  upstream hunk is `CreateTargetContents` in `browser_navigator.cc`, which
  already chooses the `SiteInstance`. No `content/`, `blink/` or `net/`
  patch in this cut. `window.open` already inherits the opener's
  `SiteInstance`, so it keeps the jar without a content/ hook.
- Saved passwords, history, extensions and prefs stay on the Profile. The
  password manager can fill an isolated tab; `chrome.cookies` without a
  partition still sees the default jar.

## Consequences

- Two isolated Spaces can be signed into the same site at once. A shared
  Space still sees every other shared Space's cookies.
- Rebases pick up one helper directory and one navigator hunk. Brave's
  Containers also patch `content/browser/web_contents/web_contents_impl.cc`
  so every navigation inherits; we do not, until a test shows a leak this
  cut cannot close at chrome/.
- PRODUCT §2's "profile" wording is this ADR: a storage partition, not a
  Chromium profile. Binding two Spaces to one jar, or giving a Space its
  own extension set, is a later ADR.
- Deleting an isolated Space wipes its partition once its tabs have moved
  (sessions S17); Clear Independent Session on the chip menu wipes it in
  place (S13). Turning isolation off keeps the jar for the next time it is
  turned on, so the data on disk is bounded by the Spaces that exist.
