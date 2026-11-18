# 0020 — No bundled model

Status: Accepted
Date: 2026-09-16

## Context

[PRODUCT.md](../PRODUCT.md) §8 listed Arc Max as needing a decision: hover previews, tidy titles, tidy downloads, tidy tabs, Ask on Page, Instant Links, and chat in the command bar. Built-in AI is not on the path to 1.0 ([ROADMAP.md](../ROADMAP.md)). Stedding sends no page content or browsing data to a model. A later feature that does needs an ADR of its own, and is opt-in, clearly labelled and off by default ([VISION.md](../VISION.md)). An agent that held a Space's cookies would undo [ADR 0019](0019-space-sessions-are-storage-partitions.md): those partitions exist so credentials stay in the Space.

## Decision

Stedding ships no bundled model. Not in the app, not as a default key, and not as an API Stedding operates. Chrome's Lens, Gemini and AI Mode rows stay hidden (patches 0024 and 0061).

Tidy downloads use no model. The hover preview is a picture of the tab, with no model (pins H19). Tidy titles, if they ship, are an optional local heuristic, with no model. Amended 2026-11-18: they shipped that way in 0.4.0 beta 8, local rules off by default (tabs R65, S-398).

Ask on Page, command-bar chat, Instant Links' "Folder of …", and a persistent agent, with or without a Space's cookies, are never. A chatbot is an extension.

## Consequences

An opt-in local model, or a feature that sends page content with a key the user supplies, needs a later ADR. Cookies, other Spaces and the storage partition stay on the machine.

Reopening any of those never rows means superseding this ADR.
