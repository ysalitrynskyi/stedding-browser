# Feature: Independent Space sessions

Status: **S1–S13, S17–S19 built and tested; S14–S16 model only** (ADR 0019). Patches: 0046 (S1–S12), 0047 (S13–S17), the 2026-09-18 audit (S18–S19).
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
| S2 | Turning isolation on writes a non-empty `profile_id` (a random token) and sets the `isolated` flag; both survive the registry round trip. Turning it on again when a token is already set leaves that token, so the Space reattaches the jar it had. | `SpaceRegistryTest.IsolatedProfileIdRoundTrips` | built |
| S3 | Two isolated Spaces get different `profile_id`s. | `SpaceRegistryTest.TwoIsolatedSpacesGetDifferentIds` | built |
| S4 | A tab opened while an isolated Space is active is created in that Space's storage partition (`partition_domain` `spaces`, `partition_name` the `profile_id`, on disk). | `SpaceWindowTest.IsolatedSpaceTabUsesItsPartition` | built |
| S5 | A tab opened in a shared Space uses the default partition even when another Space in the same window is isolated. | `SpaceWindowTest.SharedSpaceStaysOnDefaultPartition` | built |
| S6 | Two tabs of the same http(s) site in two isolated Spaces have different storage partitions, so they do not share cookies. | `SpaceWindowTest.TwoIsolatedSpacesDoNotShareAPartition` | built |
| S7 | Turning isolation off clears the `isolated` flag and keeps `profile_id`: a tab opened after that uses the default partition, and turning it on again reattaches the same jar with its logins. The on-disk jar stays until Clear Independent Session (S13) or the Space's deletion (S17). | `SpaceWindowTest.TurningIsolationOffUsesTheDefaultPartition`; `SpaceWindowTest.TurningIsolationOffKeepsTheJarForNextTime` | built |
| S8 | An essentials (Chromium-pinned) tab always uses the default partition, including when the active Space is isolated. | `SpaceWindowTest.EssentialTabStaysOnTheDefaultPartition` | built |
| S9 | Moving a tab into or out of an isolated Space rebinds it to the destination jar: its history travels as session restore carries it (serialized entries, nothing of the old jar), a sleeping tab stays asleep and keeps its title, an awake one reloads, and the user's name for the tab comes along. | `SpaceWindowTest.MovingATabIntoAnIsolatedSpaceRebindsIt`; `SpaceWindowTest.RebindKeepsASleepingTabAsleepWithItsHistory` | built |
| S10 | Isolation is a Space menu check item ("Independent session"), a toggle on each Space in chrome://settings/stedding, and an Independent Session row in the command bar. Off by default. | `CommandBarViewTest.ActionRowsListSpacesAndCaptures`; live: Space menu and the settings toggle | built |
| S11 | `window.open` / a link that opens a tab from an isolated tab inherits that tab's partition (the navigator reuses the opener's `SiteInstance`). | `SpaceWindowTest.WindowOpenFromIsolatedTabKeepsThePartition` | built |
| S12 | A restored tab in an isolated Space is created in that Space's partition, not the default. | `SpaceWindowTest.RestoredTabInIsolatedSpaceUsesItsPartition` | built |
| S13 | **Clear Independent Session** on the Space chip menu (enabled only on an isolated Space) wipes that partition's site data and its HTTP cache and keeps the Space and its `profile_id`. Tabs in the Space reload in the empty jar. Shared Spaces have no wipe. | `SpaceWindowTest.WipeIsolatedSessionKeepsTheSpaceAndTheId`; `SpaceStoragePartitionTest.WipeSharedSpaceIsNoOp`; live: the chip menu | built |
| S14 | Copying a tab into an isolated Space inserts a new tab in the destination jar. The source tab, its URL and its partition are unchanged. Essentials are refused. | `SpaceWindowTest.CopyTabToIsolatedSpaceKeepsTheSourceJar` | partial · model only, `CopyTabToSpace` has its test and no menu row calls it |
| S15 | Opening a URL signed-out is S14 into a new or existing isolated Space. The user clicks; there is no headless twin. | `SpaceWindowTest.CopyTabToIsolatedSpaceKeepsTheSourceJar` | partial · model only, S14's verb |
| S16 | Isolated chrome is a mark: `IsolationMarkForSpace` is "Independent session" iff the Space is isolated, empty otherwise. Shared Spaces show nothing. | `SpaceStoragePartitionTest.IsolationMarkFollowsProfileId` | partial · model only, nothing paints the mark yet; the chip menu's check item is the one visible sign |
| S17 | Deleting an isolated Space wipes its partition after moving its tabs (S13's helper). | `SpaceWindowTest.DeletingAnIsolatedSpaceWipesItsPartition` | built |
| S18 | A Blank Window's registry is not written to prefs, and its isolated Spaces get in-memory partitions, so nothing of them reaches the disk (ADR 0019). | `SpaceWindowTest.UnpersistedRegistryIsolatesInMemory` | built |
| S19 | A registry written before the `isolated` flag existed (beta 7) reads a Space with a token as isolated, so an update loses nobody's jar. | `SpaceRegistryTest.OldRegistryTokenMeansIsolated` | built |

"built" means the test exists in the series and passes on the pinned tree. "gap"
is a behaviour we ship without a test — each one is a backlog follow-up. "partial
· model only" means the helper exists and its unit test is green, but no menu,
key or setting reaches it: the row is not shipped to a user until it says built
(`docs/HANDOFF.md`, trap 46).

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
