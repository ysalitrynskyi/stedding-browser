# Feature: Clipboard fence

Status: **Cf1–Cf2 built**; **Cf3 planned**. Owner: sessions S16 follow-on. Patch: 0048.

In-browser paste does not silently cross isolated jars. The OS pasteboard is
named as a hole. No model. No content inspection of the clipboard.

## Behaviours

| Id | Behaviour | Test | State |
|---|---|---|---|
| Cf1 | Copy inside an isolated Space tags the chrome clipboard with that Space's `profile_id`. | `ClipboardFenceTest.CopyRecordsTheJar` | built |
| Cf2 | Paste into a different isolated Space, or isolated ↔ shared, confirms first. Default on only when the destination is isolated. | `ClipboardFenceTest.CrossJarPasteConfirms` | built |
| Cf3 | `navigator.clipboard` and paste into another app are not fenced until a `content/` ADR. The spec says so. | documented | planned |
