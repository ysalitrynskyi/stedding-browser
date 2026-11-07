# Feature: Passkeys on the Mac

Status: **Ps1–Ps4 built. Ps5 planned.** BACKLOG S-239, ADR 0033. Making a passkey for real, with a finger on Touch ID, is still owed.

Chromium keeps passkeys on the Mac in its own store in the keychain. That store needs a keychain group of the signing team, and so a provisioning profile in the app. Released builds before 0.4.0 beta 13 had neither, so sites saw no authenticator on the Mac. Passkeys in a password manager's extension have never depended on this.

## Behaviours

| Id | Behaviour | Test | State |
|---|---|---|---|
| Ps1 | A signed Mac build reports a platform authenticator to a page (`PublicKeyCredential.isUserVerifyingPlatformAuthenticatorAvailable()`), and a site's request to make a passkey opens Chromium's dialog: "Create a passkey for <site>", "This passkey will only be saved on this device". Touch ID, or the login password, then guards it. It stays on that Mac, in that Stedding profile, and does not sync. | acceptance: `ps_available`, `ps_dialog` | built |
| Ps2 | Those dialogs name Stedding. "Save another way" lists "Your Stedding profile", and the Bluetooth question says Stedding needs permission. | acceptance: `ps_dialog` | built |
| Ps3 | `tooling/sign-release` will not sign a release without the App ID's Developer ID profile, embeds it as `embedded.provisionprofile`, and starts the signed app once, since macOS refuses to run an app whose entitlements its profile does not grant. | acceptance: `ps_signed` | built |
| Ps4 | With no profile the signer leaves out the entitlements that need one, so a `--development` signature still starts. An unsigned test copy has neither, and reports no authenticator. | acceptance: `ps_signed` | built |
| Ps5 | Passkeys saved in Apple Passwords, offered once Apple grants the browser entitlement requested on 2026-11-06. | — | planned · S-239 |

## Decisions

- The team, the groups and the profile: ADR 0033.
- Windows is not changed: Windows Hello is the system's own.
