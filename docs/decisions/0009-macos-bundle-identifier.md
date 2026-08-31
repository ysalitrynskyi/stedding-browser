# 0009 — macOS bundle identifier and product strings

Status: Accepted
Date: 2026-08-30

## Context

Branding replaces `chrome/app/theme/chromium/BRANDING`, whose `MAC_BUNDLE_ID` drives
the app's `CFBundleIdentifier` and, through it, the helper bundles, keychain access
groups, Mach service names, LaunchServices registration and the profile directory
under `~/Library/Application Support`.

That makes it hard to reverse in a specific, user-visible way. macOS keys a great deal
off the bundle identifier: change it after release and the browser no longer finds its
own profile, its saved passwords in the keychain, or its registration as a default
browser. Users would appear to lose their data. So the identifier is chosen once,
before anything ships, rather than discovered later.

Chromium's default is `org.chromium.Chromium`. We own `stedding.dev`
(ADR 0004), and Apple's convention is reverse-DNS of a domain the developer controls.

## Decision

- **Bundle identifier: `dev.stedding.Stedding`.** Reverse-DNS of the domain we own,
  with the product name as the final component, which is the Apple convention and what
  a signing certificate will expect.
- **`PRODUCT_FULLNAME` and `PRODUCT_SHORTNAME`: `Stedding`.** One word, no suffix. The
  app is `Stedding.app`.
- **`COMPANY_FULLNAME` / `COMPANY_SHORTNAME`: `The Stedding Authors`**, mirroring
  Chromium's own phrasing. There is no company; inventing one would be a lie in a
  string users can read.
- The identifier is **not** changed for pre-release channels. Shipping a beta under a
  different identifier means beta users cannot upgrade into the stable app without
  losing their profile, which is the exact failure this ADR exists to avoid.
- Three upstream files hardcode `org.chromium.Chromium` and do not derive from
  `MAC_BUNDLE_ID`; they are patched as part of the branding series and are enumerated
  in `../ARCHITECTURE.md` under Branding.

## Consequences

- The profile path becomes `~/Library/Application Support/Stedding`. There is no
  migration story from a Chromium profile and none is promised — importing from other
  browsers is a separate feature (M6), not a rename.
- A Developer ID certificate at M7 must be issued for this identifier. Changing it
  afterwards would orphan every installed copy, so M7 signing is a downstream
  consumer of this decision rather than an opportunity to revisit it.
- Interoperability identifiers stay as they are: `org.chromium.extension`,
  `org.chromium.shortcut` and the clipboard pasteboard types are shared with other
  Chromium browsers and are not branding. Renaming them would break interchange.
- If the domain in ADR 0004 ever changes, this identifier does not follow it. The
  cost of moving is borne by users, and a domain change is not worth that.
