# 0004 — Canonical domain: stedding.dev

Status: Accepted
Date: 2026-08-30

## Context

The project needs one canonical domain for the site, downloads, and update
endpoints. Candidates at decision time:

- **stedding.dev** — available, registered by us; DNS on Cloudflare.
- **steddingbrowser.com** — available; exact-match phrase, but exact-match-domain
  SEO is mostly obsolete — ranking depends on content and links, not the string.
- **stedding.top** — available and cheap, but the .top TLD carries a spam
  association that hurts trust exactly where we can least afford it: the page where
  users download a browser binary.
- **stedding.com / stedding.app / stedding.co** — already registered by unrelated
  parties; not for sale at a price a pre-code project should pay.

## Decision

**stedding.dev** is the canonical domain. Short brand domain, TLD that fits a
technical audience, and the entire .dev zone is HSTS-preloaded, so every page —
including downloads — is HTTPS-only by construction. That is the right default
signal for a privacy-focused product.

## Consequences

- All public URLs (site, docs, downloads, update checks) live under stedding.dev;
  other domains we may register only redirect there.
- HSTS preload means plain-HTTP serving is impossible on this domain — a feature,
  but hosting must always present valid TLS.
- We do not own stedding.com; some type-in traffic goes to a stranger. Accepted
  risk; revisit acquisition only if the project's scale ever justifies it.
- The domain is a single point of failure for updates; registrar and DNS accounts
  must be locked down accordingly (2FA, transfer lock).
