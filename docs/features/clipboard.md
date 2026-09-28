# Feature: Clipboard fence

Status: **Cf1–Cf2 withdrawn**; **Cf3 planned**. Owner: sessions S16 follow-on. Patch: 0055.

Copy and paste are not tagged with a Space. The clipboard fence is not in the
product. The OS pasteboard is not fenced, which Cf3 still names.

## Behaviours

| Id | Behaviour | Test | State |
|---|---|---|---|
| Cf1 | Copy inside an isolated Space would tag the clipboard with that Space's jar. | `SpaceWindowTest.BlankWindowIsolationIsOnDisk` | planned · withdrawn, the clipboard fence is not in the product |
| Cf2 | Paste into a different isolated Space would confirm first. | `SpaceWindowTest.BlankWindowIsolationIsOnDisk` | planned · withdrawn with Cf1 |
| Cf3 | `navigator.clipboard` and paste into another app are not fenced until a `content/` ADR. The spec says so. | documented | planned |
