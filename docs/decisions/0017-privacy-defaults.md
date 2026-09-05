# 0017 — Privacy defaults are preference defaults, in one block

Status: accepted
Date: 2026-09-05

## Context

`docs/PRIVACY.md` promises defaults Chromium does not ship with: third-party cookies
blocked, HTTPS-First on, no web service asked about navigation errors, Global Privacy
Control sent, quiet permission prompts, the Privacy Sandbox off, search suggestions
off. Until now these were a to-do table. Round 6 (`docs/ROUND6-PLAN.md` R6-26) ships
them.

Two ways to ship a default: flip the value where Chromium registers the preference,
or leave Chromium's registration alone and write the value into every new profile.
Writing the value makes the preference "user-set", which changes what Chromium's own
UI shows (a user-set value shows no "default" state, and some rows show a managed or
changed badge), and it needs a migration for profiles that exist. Flipping the
registered default changes nothing for a user who chose otherwise and needs no
migration.

Third-party cookies are the one flip with a breakage cost: some sign-in flows and
embedded widgets need a third-party cookie.

## Decision

- Each promised default is made by changing the registered default of Chromium's own
  preference, in the patch that owns the feature (`docs/features/privacy.md`). Global
  Privacy Control, which has no Chromium preference, gets one Stedding preference,
  `stedding.privacy.gpc`, on by default.
- Every default is one row in a Privacy block of chrome://settings/stedding, bound to
  exactly one preference, the protective side on. The rows that bind Chromium
  preferences are exempt from the Stedding section's rule that a `stedding.*` toggle
  starts on: they are not Stedding preferences, and their wording makes the protective
  side the default.
- Third-party cookies are blocked in normal windows. The site-breakage answer is
  Chromium's: the eye icon in the address row when a site's cookies were blocked, and a
  per-site allowance from it or from chrome://settings/cookies. The block's row says
  so.
- Search suggestions off is the `docs/PRIVACY.md` line-209 to-do, closed here.

## Consequences

- A profile created by Stedding gets the protective defaults with no migration; a
  profile that already set any of these preferences keeps its choice.
- `docs/PRIVACY.md`'s table of defaults stays the reference; `docs/features/privacy.md`
  carries the test per row. Rebases re-apply seven one-line default changes; the ADR is
  the record of why each exists.
- Some sites break under blocked third-party cookies; the answer is per-site, in
  Chromium's UI, never a global flip back.
