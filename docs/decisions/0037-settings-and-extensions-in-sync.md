# 0037 — Settings and the extension list travel with sync

Status: Accepted (the owner, 2026-11-15: "Settings and extensions"; BACKLOG S-479, GitHub issue 109). Amends ADR 0029 and ADR 0032, whose list of what never travels (`docs/features/sidebar-file.md` Sf36) loses settings, routes and the extension list. Built 2026-11-16 (sidebar-file Sf58–Sf69) and released in 0.6.0 (2026-11-18).
Date: 2026-11-15

## Context

Sync carried the sidebar alone: Spaces, pins, pinned folders and essentials (Sf36). GitHub issue 109 reports what that leaves: a second computer gets the sidebar, and every setting is chosen again and every extension found and installed again by hand.

Sync has no account and no Stedding server (`PLAN.md` decision 18, ADR 0029): each computer writes its own file to a folder, WebDAV or S3 storage (ADR 0032), and each field keeps its later edit (Sf15). Chromium's own sync, which carries settings and extensions in Chrome, needs Google's servers and cannot work here.

Options considered:

- **Stedding's settings only.** The smallest change; extensions stay a manual job.
- **Stedding's settings and the extension list.** The person's own choices, plus which extensions to install; no extension's data.
- **Also Chromium's own settings** (search engine, site permissions, fonts, content settings). Many settings, some holding per-site data, some meaning different things on each platform.

## Decision

The second: Stedding's own settings and the extension list, each a part of sync with its own box.

**Settings.**

- What travels: the settings a person chooses in Settings › Stedding, and the sites routed to Spaces, each by the synced Space it names (a route to an unsynced Space stays here).
- What stays: a setting that belongs to one computer, such as a Mac-only or Windows-only setting, the computer's sync name and place, and the sidebar's width and anything else measured against this screen. The two lists are one table in the code, and a test fails when a Stedding setting is in neither.
- Each setting keeps its later edit (Sf15). The first time two computers that both have settings meet, the join sheet (Sf9) asks whose to start from; a fresh install with only defaults takes the other's without asking.
- Chromium's own settings do not travel. Each may come later, with a decision of its own.

**Extensions.**

- What travels: the extensions installed from the Chrome Web Store, each by id and name. Unpacked extensions, ones installed by policy or another program, Chromium's components and other stores' extensions stay.
- Another computer offers the ones it lacks, in Settings and once in a notice, and installs each only through Chromium's own Web Store confirmation (`WebstoreInstallWithPrompt`). One declined there, or uninstalled on a computer, is not offered again on that computer.
- Nothing is ever removed or turned off because of another computer, and no extension's data, settings, logins or state travel.

**The boxes.** Settings and Extensions are boxes in sync's settings and on the join sheet, each on for a new join. A computer that already syncs gets them only when it turns them on, so no setting changes under someone after an update.

## Consequences

- The per-computer file gains a settings part and an extension part. An older version ignores them and keeps syncing the sidebar.
- `docs/PRIVACY.md` says the list of extension ids is written to the person's own sync place, and that the only requests it causes are the Chrome Web Store's, after the person clicks Install….
- WebDAV and S3 storage carry the same file, so nothing changes in ADR 0032's rules.
- The behaviour and its tests are sidebar-file Sf36 and Sf58–Sf69.
