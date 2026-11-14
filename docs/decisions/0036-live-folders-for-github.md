# 0036 — Live Folders: GitHub pull requests in the sidebar

Status: Proposed, for the owner's decision (BACKLOG S-478, discussion 106). Nothing is built until the owner chooses.
Date: 2026-11-13

## Context

Arc kept a folder named "Pull Requests" in the sidebar, filled from github.com and kept up to date: the pull requests a person opened, is assigned to, is asked to review or is mentioned in, each as a tab, with merged and closed ones leaving on their own. It appeared the first time a pull request was opened on github.com, or by hand from the sidebar's menu (TechCrunch, 2024-04-11; Arc's announcement video). Someone who used it daily asked for it in discussion 106, and `docs/PRODUCT.md` lists Live Folders (GitHub) as deferred, not dropped.

Arc's folder read GitHub's own web pages through the browser's signed-in session. When GitHub changed its pull-request view, the folder stopped with "failed to fetch", and the fix people shared was to switch GitHub back to its old view (r/ArcBrowser, "Github Live Folder not working, failed to fetch").

A live folder is the first thing in Stedding that would ask a site for data with no page open and no click. `docs/PRIVACY.md` holds that Stedding makes no request the person did not cause; a live folder needs that rule to name it.

## Decision

Proposed: **B**, below, once the owner agrees. The ways considered:

**A. Read github.com's pages with the Space's sign-in, as Arc did.** No setup: whoever is signed in to github.com in that Space gets their pull requests. It reads pages written for people, so any redesign of GitHub breaks it, as it broke Arc's, and nothing tells Stedding until people report it.

**B. GitHub's API, with a token the person makes.** The folder asks `api.github.com` for the pull requests the person opened, is assigned, is asked to review or is mentioned in (GitHub's search API, `is:pr is:open`), with a fine-grained, read-only token the person creates on github.com and pastes once. The API is documented and versioned, so a page redesign does not break it. The token is kept in the profile, encrypted by the system's keychain (as passwords are), and sent to `api.github.com` alone. Setup is one minute, and the folder's empty state links to the page where the token is made.

**C. B, without a token, through the signed-in session.** GitHub's API does not take the web session's cookies, so this is A again under another name. Not possible as B.

Why B: it keeps working when GitHub changes its pages, it reaches nothing but `api.github.com`, and it is honest about what it does: the person grants it, and can revoke it on github.com.

## Consequences

If B is chosen:

- A live folder is made from the sidebar's menu (New Live Folder › GitHub Pull Requests) and from Settings; it is off until made. No folder appears by itself.
- It refreshes when made, every 10 minutes while a window of the profile is open, and when the window comes to the front, never more than once a minute. A failed refresh keeps the last list and marks the folder's row; the reason (token expired, no network, GitHub's rate limit) is in its tooltip.
- Each pull request is a row asleep until chosen, titled with the repository and the title. A merged or closed one leaves the folder at the next refresh; one opened by hand and still open stays a normal tab when it leaves.
- Deleting the folder turns it off and forgets the token.
- `docs/PRIVACY.md` gains a line: a live folder, once made, asks `api.github.com` for its list on a timer, with the person's token, and nothing else.
- GitHub Enterprise on its own domain can come later with a field for its address; it is not in the first slice.
- Other sources (an RSS or Atom feed of any site) fit the same folder and come later, each with its own decision.
- Tests to come with it: the folder lists what a recorded API answer holds; a merged pull request leaves at the next refresh; a refresh never runs more than once a minute; a bad token keeps the last list and says why; no request leaves before the folder is made, or after it is deleted; the token never reaches a page or an extension.
