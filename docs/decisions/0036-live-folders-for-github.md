# 0036 — Live Folders: GitHub pull requests in the sidebar

Status: Accepted, option B (the owner, 2026-11-15: "Yes, option B"). Proposed 2026-11-13 (BACKLOG S-478, discussion 106). Built 2026-11-16 (`docs/features/live-folders.md` Lf1–Lf13) and released in 0.6.0 (2026-11-18).
Date: 2026-11-13

## Context

Arc kept a folder named "Pull Requests" in the sidebar, filled from github.com and kept up to date: the pull requests a person opened, is assigned to, is asked to review or is mentioned in, each as a tab, with merged and closed ones leaving on their own (TechCrunch, 2024-04-11). Someone who used it daily asked for it in discussion 106, and `docs/PRODUCT.md` lists Live Folders (GitHub) as deferred, not dropped.

Arc's folder read GitHub's web pages through the browser's signed-in session. When GitHub changed its pull-request view, the folder stopped with "failed to fetch", and the fix people shared was to switch GitHub back to its old view (r/ArcBrowser, "Github Live Folder not working, failed to fetch").

A live folder is the first thing in Stedding that would ask a site for data with no page open and no click. `docs/PRIVACY.md` holds that Stedding makes no request the person did not cause, so that rule has to name it.

## Decision

**B**, the owner's choice on 2026-11-15. Options considered:

- **A. Read github.com's pages with the Space's sign-in, as Arc did.** No setup, but it reads pages written for people, so any redesign of GitHub breaks it, as it broke Arc's, and nothing tells Stedding until people report it.
- **B. GitHub's API, with a token the person makes.** The folder asks `api.github.com` (GitHub's search API, `is:pr is:open`) for the pull requests the person opened, is assigned, is asked to review or is mentioned in, with a fine-grained, read-only token the person creates on github.com and pastes once. The API is documented and versioned. The token is kept in the profile, encrypted by the system's key store, and sent to `api.github.com` alone. Settings links to the page where the token is made.
- **C. B without a token, through the signed-in session.** GitHub's API does not take the web session's cookies, so this is A again.

Why B: it keeps working when GitHub changes its pages, it reaches nothing but `api.github.com`, and the person grants it and can revoke it on github.com.

## Consequences

- A live folder is made from the sidebar's menu (New Live Folder › GitHub Pull Requests) or from Settings; it is off until made, and no folder appears by itself.
- It refreshes when made, every 10 minutes while a window of the profile is open, and when a window comes to the front, never more than once a minute. A failed refresh keeps the last list and puts ⚠ after the folder's name, with the reason in its tooltip.
- Each pull request is a row asleep until chosen. A merged or closed one leaves at the next refresh; one open by hand stays as a normal tab.
- Deleting the folder turns it off and forgets the token.
- `docs/PRIVACY.md` says that a live folder, once made, asks `api.github.com` for its list on a timer, with the person's token, and nothing else.
- GitHub Enterprise on its own domain, and other sources such as an RSS or Atom feed, can come later, each with its own decision.
- The behaviour and its tests are live-folders Lf1–Lf13.
