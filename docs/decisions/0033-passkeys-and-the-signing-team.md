# 0033 — Passkeys on the Mac, and the team they stay with

Status: Accepted (the owner made the App ID and the profile, and asked Apple, on 2026-11-06). Touch ID is `BACKLOG.md` S-239. Apple Passwords waits for Apple's answer.
Date: 2026-11-06

## Context

Chromium keeps passkeys on the Mac in two places: its own store in the keychain, behind Touch ID or the login password, and iCloud Keychain through Apple's AuthenticationServices. Stedding's builds used neither. The first needs a keychain access group of the signing team, and the second a browser entitlement Apple grants on request. Both need a provisioning profile embedded in the app.

Chrome, Firefox, Brave, Vivaldi and Arc all ship this way, read from their bundles on 2026-11-06: a Developer ID signature, an `embedded.provisionprofile` for all devices, and the team's keychain groups. Each profile runs for about eighteen years.

## Decision

**The team is YS Progress Inc. (`3A672M9PRY`), the App ID `dev.stedding.Stedding`.** That team has signed every release. A passkey made with Touch ID lives under the team's access group, so a change of team would lose it. This is the part that is hard to undo.

**Three keychain groups, none of Google's.** `<team>.<bundle id>.webauthn`, `.secure-payment-confirmation` and `.unexportable-keys`. Chrome's list has more, for its enclave, its trusted vault and enterprise device trust, none of which a build without Google's services can use.

**The profile stays out of the repository.** `tooling/sign-release` takes its path from `STEDDING_PROVISION_PROFILE`, like the signing identity, and a release cannot be signed without it. The team id is in `branding/BRANDING`: it is public in every signed app.

**No profile, no entitlements.** macOS will not start an app that claims these without a profile that grants them. The signer leaves them out when it embeds none, so `--development` signing and the test copies keep working.

**Apple Passwords comes after Apple's answer.** The request for `com.apple.developer.web-browser.public-key-credential` went in on 2026-11-06. Once granted, the capability is enabled on the App ID, the profile is made again, and the entitlement joins the three groups. Apple asks in return that a granted browser offers iCloud Keychain passkeys, for signing in and for saving, and Chromium's code does.

## Consequences

- A new Developer ID certificate means a new profile too, since a profile names its certificate (`BACKLOG.md` S-444).
- A Touch ID passkey belongs to one Mac and one Stedding profile. It does not sync. Passkeys in a password manager's extension are not touched by any of this.
- `tooling/sign-release` starts the signed app once, because no other check sees an app macOS refuses to run.
- Windows is not changed. Windows Hello is the system's own and needs none of this.
