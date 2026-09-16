# Feature: Independent Space sessions

Status: **S1–S7 built and tested** (ADR 0019). Patch: next in series after 0045.
Owner docs: `docs/decisions/0019-space-sessions-are-storage-partitions.md`,
`docs/PRODUCT.md` §2, `docs/features/spaces.md`, `docs/features/windows.md` G5.

A Space can keep its own cookies, HTTP cache and site storage so the same site
can be signed into with different credentials in different Spaces of one window.
Off by default. Extensions, settings, history and saved passwords stay on the
profile.

This file is the definition of done. A behaviour is shipped when its test id is
green.

## What isolation is

Chromium already shards cookies, cache, localStorage, IndexedDB and service
workers by `StoragePartition`. An isolated Space's tabs are created in a
non-default partition named by that Space's `profile_id`. A Space with an empty
`profile_id` uses the profile's default partition, which is what every Space
does today.

Isolation is a property of the Space at tab creation. `window.open` inherits
the opener's partition. Essentials are in every Space (spaces B6) and stay on
the default partition.

## Behaviours

| Id | Behaviour | Test | State |
|---|---|---|---|
| S1 | A new Space has an empty `profile_id`. Its tabs use the default storage partition. | `SpaceRegistryTest.RoundTrip` (empty `profile_id`, G5); `SpaceWindowTest.SharedSpaceStaysOnDefaultPartition` | built |
| S2 | Turning isolation on writes a non-empty `profile_id` (a random token) that survives the registry round trip. Turning it on again when one is already set leaves that id. | `SpaceRegistryTest.IsolatedProfileIdRoundTrips` | built |
| S3 | Two isolated Spaces get different `profile_id`s. | `SpaceRegistryTest.TwoIsolatedSpacesGetDifferentIds` | built |
| S4 | A tab opened while an isolated Space is active is created in that Space's storage partition (`partition_domain` `spaces`, `partition_name` the `profile_id`, on disk). | `SpaceWindowTest.IsolatedSpaceTabUsesItsPartition` | built |
| S5 | A tab opened in a shared Space uses the default partition even when another Space in the same window is isolated. | `SpaceWindowTest.SharedSpaceStaysOnDefaultPartition` | built |
| S6 | Two tabs of the same http(s) site in two isolated Spaces have different storage partitions, so they do not share cookies. | `SpaceWindowTest.TwoIsolatedSpacesDoNotShareAPartition` | built |
| S7 | Turning isolation off clears `profile_id` for the purpose of new tabs: a tab opened after that uses the default partition. The on-disk jar stays until a later clear-session row. | `SpaceWindowTest.TurningIsolationOffUsesTheDefaultPartition` | built |
| S8 | An essentials (Chromium-pinned) tab always uses the default partition, including when the active Space is isolated. | none yet | gap |
| S9 | Moving a tab into or out of an isolated Space reloads it in the destination jar. | none yet | gap |
| S10 | Isolation is a Space menu check item ("Independent session") and a row on the Spaces list in chrome://settings/stedding. Off by default. | none yet | partial · the Space menu check item is in; settings row not yet |
| S11 | `window.open` / a link that opens a tab from an isolated tab inherits that tab's partition (the navigator already reuses the opener's `SiteInstance`). | none yet | gap · covered by the opener path; no extra test in this cut |
| S12 | A restored tab in an isolated Space is created in that Space's partition, not the default. | none yet | gap · restore currently `WebContents::Create(profile)` |

"built" means the test exists in the series and passes on the pinned tree. "gap"
is a behaviour we ship without a test — each one is a backlog follow-up.

## Out of scope here

A Chromium Profile per Space (separate extensions, history, prefs). Cookie-only
swapping. Temporary in-memory jars (Ghost's Temporary Identities). Binding two
Spaces to one jar. Wiping a deleted Space's partition. Extension `chrome.cookies`
seeing isolated jars. Per-Space proxies or fingerprints.

## Running the tests

```bash
tooling/dev test spaces
tooling/dev test windows
```
