# 0029 — The sidebar syncs through a folder the user picks

Status: Built in patch 0101 and released in 0.3.0 beta 16. The owner’s acceptance of this record is still open (`BACKLOG.md` `S-282`). Current behaviour, row by row: `docs/features/sidebar-file.md`. Amended by ADR 0032 (2026-11-06): WebDAV and S3 storage the user sets up are a second way to the same files; this record stays true of a folder. Amended by [ADR 0034](0034-spaces-that-share-a-named-session.md), accepted 2026-11-10: a named session syncs by its id. Amended by [ADR 0037](0037-settings-and-extensions-in-sync.md), 2026-11-15: Stedding's settings, the routes and the extension list can travel too.
Date: 2026-10-25

## Context

GitHub issue 20 (`S-282`) asked for the sidebar on several computers with no account and no Stedding server: Spaces, pins, folders and essentials written to a folder the user picks, and merged by each install. The owner took it up on 2026-10-23 (`PLAN.md` decision 18). The same idea had been sidebar-file Sf3–Sf5, withdrawn on 2026-09-26.

This is not a sync service. Stedding makes no network request for it; the user’s own sync tool, or a shared drive, moves the files. Export and import (Settings › Stedding › Sync and import) stay add-only: they cannot carry a rename, a recolour, a move, a reorder or a deletion both ways.

## Decision

Sync through a folder is off by default and set per profile.

**The folder.** The user picks a folder that already exists. Stedding creates only `Stedding Sidebar` inside it, or uses the folder itself when it already is one. Each install writes only its own `stedding-sidebar-<16 hex>.json`, atomically. A folder inside Stedding’s own data, one it cannot write, and one the system will not open are refused, each with one sentence.

**The file** holds the whole merged sidebar in the Export all Spaces shape, so **Import sidebar…** reads it on a computer that does not sync, plus a `stedding_sync` block: format number, install id, device name, sequence number, nonce, a stamp per field, tombstones, list order, aliases, and any keys from a newer version kept as they came. Synced fields: a Space’s name, icon, colours and whether it has its own session; a pin’s home (a web page only) and its name; a folder’s title; each item’s parent. A file is at most 4 MiB and 5,000 records.

**What each install keeps,** in the profile, never in the folder: a ledger, a journal of the last 10 applied batches within 30 days, and the last 5 backups, taken before the first join and before a held batch is applied.

**The merge.** A local edit is stamped with the later of now and the highest time seen plus one; the install id breaks a tie. Each field is its own register and the later stamp wins. Each list is one register: the newer list wins, and an item the other side added meanwhile stays beside its neighbour. The result does not depend on the order files are read in. At the first join the folder wins a tie.

**Pairing,** only after the user chooses Combine. Spaces pair by trimmed, case-folded name only when each side has exactly one of that name; inside a paired Space, pins, folders and essentials pair only when exactly one candidate matches. The smaller id becomes the shared one, written as an alias. Anything ambiguous stays as two items.

**What applies by itself:** additions, renames, icons, colours, homes, pin names, reorders and moves. A new item arrives unloaded, in its Space, in one ordinary window, never a Blank Window, the little window or Peek. Sync never activates a tab, a Space or a window.

**Deletions.** A tombstone is written only when the user removed the item in a live window and, two seconds later, it is in no window of the profile. A sleep, a window closing, quitting, session restore, and a missing, short, unreadable or conflict-copy file delete nothing. An edit after a deletion keeps the item. Tombstones drop after 180 days. A removed pin that was never opened here goes to Recently Closed; any other becomes an ordinary tab in its Space.

**What waits** as a row in Settings, with no deadline: a Space deleted elsewhere; a change to a Space’s own session; a bulk batch (5 or more removals, a third of the synced pins, more than 50 additions, or any Space deletion); a move that would reload a loaded tab into another session; synced pins in no window here; a conflict copy. A computer whose clock runs more than 24 hours ahead is held whole.

**Files are not trusted.** Peer files are parsed off the UI thread, within the caps. A cycle, a duplicate id or a bad value refuses the file. A newer format is not applied. A copied profile takes a new install id.

**Timing.** A change is written 2 seconds after the last edit, and at quit. Another computer’s change applies about 2 seconds after its file changes (FSEvents on the Mac, ReadDirectoryChangesW on Windows). The folder is also checked when a window becomes active, every 10 seconds while one is in front, and on Sync now. Never in the background.

**What never travels:** open tabs below the Clear line, a tab’s current address or title, nesting, splits, collapsed state, the active Space or tab, which window holds what, history, cookies, site data, passwords, payment data, extensions, bookmarks, downloads, routes, settings, permissions, a Space’s partition and the host name. (ADR 0037 later let settings, routes and the extension list travel, each behind a box.) A Blank Window, a private window, Guest, the little window and Peek do not take part.

Options set aside: one design that never deletes without a question, and one where the newer whole record wins and an item missing from a live window is a deletion.

## Consequences

- The merge, the file code, the ledger, the per-window tracker, the applier and a profile service sit beside the importer, which stays add-only. Renaming the `stedding.sidebar_sync.*` preferences or `Stedding Sidebar Sync` needs a migration.
- Patch 0106 (Sf42) adds a note when the picked folder does not look like one a known sync tool keeps. Any folder still works.
- A computer away for more than 180 days can bring removed items back as additions; the bulk guard holds a large batch.
- Pins in a closed window stayed in the ledger and kept travelling until windows G2. Amended 2026-11-18: since 0.6.0 pins and essentials are the profile's ([ADR 0035](0035-pins-in-every-window.md)).
