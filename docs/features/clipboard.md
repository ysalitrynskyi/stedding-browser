# Feature: Clipboard fence

Status: **Cf1–Cf2 withdrawn**; **Cf3 planned**; **Cf4 planned, written, not yet run** (`PLAN.md` WIN-5). Owner: sessions S16 follow-on. Patch: 0055.

Copy and paste are not tagged with a Space. The clipboard fence is not in the
product. The OS pasteboard is not fenced, which Cf3 still names.

## Behaviours

| Id | Behaviour | Test | State |
|---|---|---|---|
| Cf1 | Copy inside an isolated Space would tag the clipboard with that Space's jar. | none | withdrawn · cut in patch 0055 (owner decision, 2026-09-26) |
| Cf2 | Paste into a different isolated Space would confirm first. | none | withdrawn · with Cf1 |
| Cf3 | `navigator.clipboard` and paste into another app are not fenced until a `content/` ADR. The spec says so. | documented | planned |
| Cf4 | What Stedding itself puts on the clipboard from a private or Guest window stays out of the system's clipboard history and its cloud clipboard (Windows' Win+V), as the omnibox's own copies do: copy link and the Markdown link (⇧⌘C, ⌥⇧⌘C, the tab menu, a peek) and the three screenshots are written with `ui::ScopedClipboardWriter::MarkAsOffTheRecord`. Copy link decides from the pages being copied, so one off-the-record page marks the whole copy; a screenshot from the capture's window, fixed when it starts. | `CopyLinkTest.PrivatePagesAreCopiedOffTheRecord`; the screenshots: none yet (screenshot C8's browser test); live on Windows: a Markdown copy and a screenshot from a private window are not in Win+V | partial · passes on the Mac; the Windows clipboard history (Win+V) is live only |
