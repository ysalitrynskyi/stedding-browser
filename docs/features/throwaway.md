# Feature: Throwaway Space

Status: **T1–T4 planned**. Owner: ADR 0019 follow-on (in-memory jars). Patch: none yet.

A Space whose partition is in-memory. Close wipes it. Not a persistent intern.
No model (ADR 0020).

## Behaviours

| Id | Behaviour | Test | State |
|---|---|---|---|
| T1 | "Open in Throwaway" creates an isolated Space with `StoragePartitionConfig` `in_memory=true`. | `SpaceWindowTest.ThrowawayTabUsesAnInMemoryPartition` | planned |
| T2 | Closing the last throwaway tab, or quitting, forgets the Space and its jar. It is not session-restored. | `SpaceWindowTest.ThrowawayIsNotRestored` | planned |
| T3 | Peek and little windows that are not routed load in a throwaway jar; promote rebinds into the destination Space. | `PeekViewTest.GuestPeekUsesInMemoryPartition` | planned |
| T4 | Password autofill does not fill in a throwaway, peek guest, or little guest jar. | `SpaceWindowTest.ThrowawayDoesNotAutofill` | planned |
