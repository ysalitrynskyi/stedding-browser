# Feature: Throwaway Space

Status: **T1 model only**; **T2–T4 planned**. Owner: ADR 0019 follow-on (in-memory jars). Patch: 0048.

A Space whose partition is in-memory. Close wipes it. Not a persistent intern.
No model (ADR 0020).

Nothing in the browser opens a throwaway Space yet. The command-bar row that did
was withdrawn on 2026-09-18: a Space it made was written to the registry and came
back after a restart with a fresh, empty jar (T2 is not built), and its tabs would
have been session-restored into the shared jar. The row returns with T2.

## Behaviours

| Id | Behaviour | Test | State |
|---|---|---|---|
| T1 | `AddThrowawaySpace` creates an isolated Space with `StoragePartitionConfig` `in_memory=true`. | `SpaceWindowTest.ThrowawayTabUsesAnInMemoryPartition`; `SpaceRegistryTest.ThrowawayIsInMemoryAndIsolated` | partial · model only, no row calls it until T2 |
| T2 | Closing the last throwaway tab, or quitting, forgets the Space and its jar. It is not session-restored. | `SpaceWindowTest.ThrowawayIsNotRestored` | planned |
| T3 | Peek and little windows that are not routed load in a throwaway jar; promote rebinds into the destination Space. | `PeekViewTest.GuestPeekUsesInMemoryPartition` | planned |
| T4 | Password autofill does not fill in a throwaway, peek guest, or little guest jar. | `SpaceWindowTest.ThrowawayDoesNotAutofill` | planned |
