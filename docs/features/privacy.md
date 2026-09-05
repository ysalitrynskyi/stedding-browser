# Feature: Tracker-free defaults, one Privacy block

Status: **Q0–Q8 built** (round 6, `docs/ROUND6-PLAN.md` R6-26).
Owner docs: `docs/PRIVACY.md`, `docs/decisions/0017-privacy-defaults.md`. Patch: 0030.

`docs/PRIVACY.md` promises defaults Chromium does not ship with. This feature makes
each promise a preference default, and puts every one of them in one Privacy block of
chrome://settings/stedding, one toggle per row, the protective side the default. The
rows bind to Chromium's own preferences where Chromium has one, so Chromium's other
UI (the eye icon in the address row, per-site cookie allowances, the permission
prompts) keeps working; only Global Privacy Control needs a preference of its own.

## Behaviours

| Id | Behaviour | Test | State |
|---|---|---|---|
| Q0 | `docs/decisions/0017-privacy-defaults.md` records the default flips this feature makes and the site-breakage answer: third-party cookies are blocked above all, and when a site breaks, Chromium's eye icon in the address row and the per-site allowance are the way out. | `docs/decisions/0017-privacy-defaults.md` | built |
| Q1 | Third-party cookies are blocked in normal windows: `profile.cookie_controls_mode` defaults to Block third-party (Chromium: in Incognito only). | `PrivacyDefaultsWindowTest.EveryDefaultIsTheProtectiveOne`; live: `w3_privacy_block` (the row reads Block) | built |
| Q2 | HTTPS-First balanced mode is on: `https_first_balanced_mode` defaults to true (Chromium: false). | `PrivacyDefaultsWindowTest.EveryDefaultIsTheProtectiveOne` | built |
| Q3 | "Ask a web service about navigation errors" is off: `alternate_error_pages.enabled` defaults to false (Chromium: true). | `PrivacyDefaultsWindowTest.EveryDefaultIsTheProtectiveOne` | built |
| Q4 | Global Privacy Control is sent: `stedding.privacy.gpc` (on) adds `Sec-GPC: 1` to every request through a URL loader throttle and turns on Blink's `GlobalPrivacyControl` runtime feature for the profile's renderers, so `navigator.globalPrivacyControl` is true. Off removes both; renderers already running keep their setting until they restart. | `PrivacyDefaultsTest.GpcSwitchFollowsTheLocalState`; live: `w3_privacy_gpc` (a local page that echoes request headers shows `Sec-GPC: 1` and `navigator.globalPrivacyControl` true) | built |
| Q5 | Quiet permission prompts for notifications and geolocation are on: `profile.quiet_notification_permission_ui_enabled` and its geolocation twin default to true (Chromium: false). | `PrivacyDefaultsWindowTest.EveryDefaultIsTheProtectiveOne` | built |
| Q6 | Topics, Protected Audience and Attribution stay off: their preferences already default to false in Chromium; the Ad privacy page is hidden from chrome://settings and its link row from the Privacy page. | `PrivacyDefaultsWindowTest.EveryDefaultIsTheProtectiveOne`; this Chromium has no Ad privacy settings page to hide | built |
| Q7 | Search suggestions are off by default: `search.suggest_enabled` defaults to false (Chromium: true); the row reads "Send what you type to the search engine for suggestions". | `PrivacyDefaultsWindowTest.EveryDefaultIsTheProtectiveOne` | built |
| Q8 | Each of Q1–Q7 is one row in the Privacy block, bound to exactly one preference, with the protective side on. | settings capture `w3_privacy_block` | built |

## Notes

- The flips are made where Chromium registers the preferences, by changing the
  registered default, so every reader of the preference (network context, HTTPS-first
  interstitials, the permission UI) sees the same value and no migration runs.
- `search.suggest_enabled` is a syncable Chromium preference; the block's row toggles
  the same preference the Chromium search-engine page toggles.
- Global Privacy Control: Chromium carries the Blink side (`navigator.globalPrivacyControl`
  and `Sec-GPC` on fetches from documents and workers) behind a runtime feature with no
  browser-side switch; Stedding turns the feature on for renderers whose profile has the
  preference on, and adds the header to navigations from the browser process with a
  throttle, since Blink never sees those.
- Out of scope here (each keeps a line in `docs/PRIVACY.md`'s to-do table): translate,
  preloading, network time, the component-updater endpoint, dummy API keys.
