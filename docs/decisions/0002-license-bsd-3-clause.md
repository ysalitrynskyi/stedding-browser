# 0002 — License: BSD-3-Clause

Status: Accepted
Date: 2026-08-30

## Context

The license had to be chosen before the first public commit, because relicensing
later requires the consent of every contributor. Requirements: fully open-source
core; compatibility with Chromium's own BSD-3-Clause license and the mixed licenses
of its third-party components; freedom to build closed-source or paid add-ons later
(see ADR 0005) without a copyleft obligation contaminating them; and some protection
of the project name against implied endorsement.

Copyleft licenses (GPL family) were rejected: they complicate shipping alongside
Chromium's permissively licensed code and would restrict the open-core option.
MIT was the closest alternative.

## Decision

The project is licensed under **BSD-3-Clause**, the same license as Chromium itself.

Chosen over MIT for clause 3: neither the project name nor the names of contributors
may be used to endorse or promote derived products without permission. That is a
small but real lever protecting the "Stedding" name against forks marketing
themselves as us.

## Consequences

- Anyone may use, modify, redistribute, and sell the code, including in proprietary
  products. We accept that; it is the price of a permissive core.
- Future closed or paid add-ons are legally straightforward: they can link against
  and ship with the BSD core (boundaries defined in ADR 0005).
- License matches Chromium's, so patches, vendored code, and derived files carry no
  license friction in either direction.
- Clause 3 gives limited name protection; real brand protection still depends on
  trademark practice (`../BRAND.md`).
- Relicensing later is effectively impossible once outside contributions arrive —
  this decision is permanent in practice.
