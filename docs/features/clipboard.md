# Feature: Clipboard fence

Status: **Cf1–Cf2 model only**; **Cf3 planned**. Owner: sessions S16 follow-on. Patch: 0048.

In-browser paste does not silently cross isolated jars. The OS pasteboard is
named as a hole. No model. No content inspection of the clipboard.

The fence is two functions and their tests. No copy or paste path in the browser
calls them yet, so nothing is fenced today; where the hook goes is the `content/`
question Cf3 names.

## Behaviours

| Id | Behaviour | Test | State |
|---|---|---|---|
| Cf1 | Copy inside an isolated Space tags the chrome clipboard with that Space's `profile_id`. | `ClipboardFenceTest.CopyRecordsTheJar` | partial · model only |
| Cf2 | Paste into a different isolated Space, or isolated ↔ shared, confirms first. Default on only when the destination is isolated. | `ClipboardFenceTest.CrossJarPasteConfirms` | partial · model only |
| Cf3 | `navigator.clipboard` and paste into another app are not fenced until a `content/` ADR. The spec says so. | documented | planned |
