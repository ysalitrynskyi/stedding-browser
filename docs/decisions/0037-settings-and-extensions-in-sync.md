# 0037 — Settings and the extension list travel with sync

Status: Accepted (the owner, 2026-11-15: "Settings and extensions"; BACKLOG S-479, GitHub issue 109). Amends ADR 0029 and ADR 0032, whose list of what never travels (`docs/features/sidebar-file.md` Sf36) loses settings, routes and the extension list once this is built. Not built.
Date: 2026-11-15

## Context

Sync carries the sidebar alone: Spaces, pins, pinned folders and essentials (Sf36). GitHub issue 109 reports what that leaves: a second computer gets the sidebar and nothing else, so every setting is chosen again and every extension found and installed again by hand.

Sync has no account and no Stedding server (`PLAN.md` decision 18, ADR 0029). Each computer writes a file of its own to a place the person picks, a folder, WebDAV or S3 storage (ADR 0032), and reads the others'. Each field keeps its later edit on a clock that never runs backwards (Sf15). Chromium's own sync, which carries settings and extensions in Chrome, needs Google's servers and cannot work here.

Three scopes were considered:

- **Stedding's settings only.** The smallest change. Extensions stay a manual job.
- **Stedding's settings and the extension list.** The person's own choices, plus which extensions to install. No extension's data.
- **Also Chromium's own settings** (search engine, site permissions, fonts, content settings). Many settings, some holding per-site data and some meaning different things on each platform.

## Decision

The second: Stedding's own settings and the extension list, each a part of sync with its own box.

**Settings.**

- What travels: the settings a person chooses in Settings › Stedding, kept by profile or browser-wide, and the sites routed to Spaces, each by the synced Space it names (a route to a Space that is not synced stays here).
- What stays: a setting that belongs to one computer. That covers a Mac-only or Windows-only setting, the computer's sync name and place, and the sidebar's width and anything else measured against this screen. The two lists are one table in the code, and a test fails when a Stedding setting is in neither list.
- Each setting keeps its later edit, as a sidebar field does (Sf15).
- The first time two computers that both have settings meet, the join sheet (Sf9) asks which computer's settings to start from. A fresh install, with nothing changed from the defaults, takes the other computer's without asking.
- Chromium's own settings do not travel. Each may come later, with a decision of its own.

**Extensions.**

- What travels: the list of extensions installed from the Chrome Web Store, each by its id and name. Unpacked extensions, ones installed by policy or by another program, Chromium's own components and extensions from other stores stay.
- What another computer does: it offers the extensions it lacks, in Settings and once in a notice. Each is installed only through Chromium's own Web Store confirmation (`WebstoreInstallWithPrompt`). An extension declined there is not offered again from that computer.
- What never happens: an extension removed or turned off on one computer is never removed or turned off on another. Nothing about an extension's data, settings, logins or state travels.

**The boxes.** Settings and Extensions are boxes in sync's settings and on the join sheet, each on for a new join. A computer that already syncs gets both parts only when it turns them on, so no setting changes under someone after an update.

## Consequences

- The per-computer file gains a settings part and an extension part. A computer on an older version ignores them, and its sidebar still syncs.
- Sf36 is amended when this ships, and new spec rows in `docs/features/sidebar-file.md` cover each rule above.
- `docs/PRIVACY.md` gains a line: the list of extension ids is written to the person's own sync place, and the only network requests it causes are the Web Store downloads the person confirms.
- WebDAV and S3 storage carry the same file, so nothing changes in ADR 0032's rules.
- Tests to come with it:
  - every Stedding setting is in the synced list or the staying list;
  - a setting changed on one computer arrives on the other, and a Mac-only one does not;
  - a route arrives on the paired Space, and one to an unsynced Space does not;
  - the first join with settings on both sides asks which to start from;
  - an extension is offered and installed only after the confirmation, and never removed elsewhere;
  - a declined extension is not offered again;
  - no extension data, cookie, password or token is in the file (`SidebarSyncFileTest.NoSecretTravels`, extended).
