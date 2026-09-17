# 0020 — No bundled model

Status: Accepted
Date: 2026-09-16

## Context

PRODUCT §8 listed Arc Max as [needs decision]: hover previews, tidy titles, tidy
downloads, tidy tabs, Ask on Page, Instant Links, and ChatGPT in the command bar.
ADR 0011's full Arc parity collides with ROADMAP (built-in AI is not on the path
to 1.0) and with VISION: no AI gimmicks bolted on; nothing sends page content or
browsing data to a model without an explicit user action; Dia exists for people
who want an AI browser.

A persistent agent that holds a Space's cookies was proposed as "the intern in
every Space". Cookies are the user's identity on the site. ADR 0019's partitions
exist so credentials do not leak across Spaces; handing the jar to an agent is
the leak, to a model. Persistence means it acts without a click.

## Decision

**Stedding ships no bundled model.** Not in the app, not as a default key, not as
a Stedding-operated API. Chrome's own AI surfaces stay hidden.

- **Tidy downloads** stay [1.0], no model.
- **Hover preview** is a screenshot of the tab. No model. Hover is not a click.
- **Tidy titles** may ship later as an optional local heuristic. No model.
- **Ask on Page**, command-bar chat, Instant Links "Folder of …", and a
  persistent intern with or without Space cookies are **never**.
- Extensions remain the answer for people who want a chatbot.

## Consequences

- PRODUCT §8 is no longer [needs decision].
- A later ADR is required before any opt-in local or BYOK feature that sends
  page content, and cookies / other Spaces / the storage partition never leave.
- Reopening any Never row requires superseding this ADR in public.
