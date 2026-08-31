# 0012 — Boosts and Easels are deferred, not dropped

Status: Accepted
Date: 2026-08-31

## Context

ADR 0011 set full functional parity with Arc as the product target. Working through the
inventory in `../PRODUCT.md`, two of Arc's features stand out as expensive and weakly
connected to browsing:

- **Boosts** — per-site restyling with colour and font controls, full custom CSS and
  JavaScript editors, and **Zap**, which hides a clicked page element permanently across
  that site.
- **Easels** — freeform whiteboards holding drawings, text and page captures, living as
  pinned tabs and archived to the Library.

Both are substantial. Easels is a drawing application inside a browser. Boosts is a
styling engine plus a script host, and a script host is a security surface: user
JavaScript injected per site needs a threat model, a permission story, and a way to
stop a shared Boost from being an attack.

Both also already have answers in the ecosystem we are required to support. Chrome
extension compatibility is a hard requirement of this project (`../../AGENTS.md`), and
Stylus covers per-site CSS, Violentmonkey covers per-site JavaScript, and uBlock
Origin's element picker covers Zap. A user who wants these can have them on day one
without us building or securing them.

## Decision

**Boosts and Easels are deferred past the first releases.** They are not cancelled and
not removed from `../PRODUCT.md`; they are marked as deferred with this ADR as the
reason.

Everything else in the parity inventory stands. Specifically kept: Spaces, Peek, the
command bar, Air Traffic Control, Split View, the archive model, and the whole
sidebar and tab model.

They return when either condition holds:

1. The features people actually stay in Arc for are shipped and meet the quality bar —
   Peek, Spaces, the command bar — and there is capacity to spend on this; or
2. Users tell us the extension answer is not good enough. That is evidence, not
   speculation, and it is the kind of thing a public issue tracker produces.

For Boosts specifically, the threat model comes **before** any implementation, not
alongside it.

## Consequences

- The near-term roadmap loses its two largest single items, which is most of the reason
  parity looked out of reach.
- Parity with Arc is, until this is revisited, **parity minus Boosts and Easels**, and
  the documents say exactly that rather than implying completeness.
- Users wanting per-site styling or scripting are pointed at extensions. That is a real
  answer, not a deflection, because extension support is a hard requirement we are
  keeping regardless.
- Deferring Boosts also defers the security work it implies. That is a saving now and a
  debt later; whoever picks it up inherits the threat-model requirement above rather
  than a blank sheet.
