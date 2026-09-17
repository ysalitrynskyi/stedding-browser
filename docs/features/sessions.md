# Feature: Independent Space sessions

Status: **S1–S17 built and tested** (ADR 0019). Patch: 0046.
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
| S8 | An essentials (Chromium-pinned) tab always uses the default partition, including when the active Space is isolated. | `SpaceWindowTest.EssentialTabStaysOnTheDefaultPartition` | built |
| S9 | Moving a tab into or out of an isolated Space reloads it in the destination jar. | `SpaceWindowTest.MovingATabIntoAnIsolatedSpaceRebindsIt` | built |
| S10 | Isolation is a Space menu check item ("Independent session"), a toggle on each Space in chrome://settings/stedding, and an Independent Session row in the command bar. Off by default. | `CommandBarViewTest.ActionRowsListSpacesAndCaptures`; live: Space menu and the settings toggle | built |
| S11 | `window.open` / a link that opens a tab from an isolated tab inherits that tab's partition (the navigator reuses the opener's `SiteInstance`). | `SpaceWindowTest.WindowOpenFromIsolatedTabKeepsThePartition` | built |
| S12 | A restored tab in an isolated Space is created in that Space's partition, not the default. | `SpaceWindowTest.RestoredTabInIsolatedSpaceUsesItsPartition` | built |
| S13 | Clearing an isolated Space's session wipes that partition's site data and keeps the Space and its `profile_id`. Tabs in the Space reload in the empty jar. Shared Spaces have no wipe. | `SpaceWindowTest.WipeIsolatedSessionKeepsTheSpaceAndTheId`; `SpaceStoragePartitionTest.WipeSharedSpaceIsNoOp` | built |
| S14 | Copying a tab into an isolated Space inserts a new tab in the destination jar. The source tab, its URL and its partition are unchanged. Essentials are refused. | `SpaceWindowTest.CopyTabToIsolatedSpaceKeepsTheSourceJar` | built |
| S15 | Opening a URL signed-out is S14 into a new or existing isolated Space. The user clicks; there is no headless twin. | `SpaceWindowTest.CopyTabToIsolatedSpaceKeepsTheSourceJar` | built |
| S16 | Isolated chrome is a mark: `IsolationMarkForSpace` is "Independent session" iff the Space is isolated, empty otherwise. Shared Spaces show nothing. | `SpaceStoragePartitionTest.IsolationMarkFollowsProfileId` | built |
| S17 | Deleting an isolated Space wipes its partition after moving its tabs (S13's helper). | `SpaceStoragePartitionTest.WipeSharedSpaceIsNoOp` | built |

"built" means the test exists in the series and passes on the pinned tree. "gap"
is a behaviour we ship without a test — each one is a backlog follow-up.

## Out of scope here

A Chromium Profile per Space (separate extensions, history, prefs). Cookie-only
swapping. Binding two Spaces to one jar. Extension `chrome.cookies` seeing
isolated jars. Per-Space proxies or fingerprints. A persistent intern or model
that holds a Space's cookies (ADR 0020). Temporary in-memory jars are
`docs/features/throwaway.md`.

## Running the tests

```bash
tooling/dev test sessions
tooling/dev test spaces
tooling/dev test windows
```
