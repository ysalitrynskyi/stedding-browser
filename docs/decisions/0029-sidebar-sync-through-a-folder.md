# 0029 — The sidebar syncs through a folder the user picks

Status: Built in patch 0101 and released in 0.3.0 beta 16. The owner’s acceptance of this record is still open (`BACKLOG.md` `S-282`). Current behaviour, row by row: `docs/features/sidebar-file.md` Sf7–Sf42. Amended by ADR 0032 (2026-11-06): WebDAV and S3 storage the user sets up are a second way to the same files. This record stays true of a folder. Amended by [ADR 0034](0034-spaces-that-share-a-named-session.md), proposed 2026-11-05: a named session syncs by its id.
Date: 2026-10-25

## Context

GitHub issue 20 (`S-282`) asked for the sidebar on several computers with no account and no Stedding server: Spaces, pins, folders and essentials written to a folder the user picks, and merged by each install. The owner took it up on 2026-10-23 (`PLAN.md` decision 18). The same idea had been sidebar-file Sf3–Sf5, withdrawn on 2026-09-26.

This is not a sync service. Stedding makes no network request for it. The user’s own sync tool, or a shared drive, moves the files. `docs/ROADMAP.md` keeps sync services off the path to 1.0.

Export and import stay add-only. **Export Space…**, **Export all Spaces…** and **Import sidebar…** live under Settings › Stedding › Sync and import (settings T13, patch 0109). They cannot carry a rename, a recolour, a move, a reorder or a deletion both ways.

## Decision

Sync through a folder is off by default and set per profile.

**The folder.** The user picks a folder that already exists. Stedding creates only `Stedding Sidebar` inside it, or uses the folder itself when it already is one or already holds sidebar files. Each install writes only `stedding-sidebar-<16 hex>.json`, atomically, in that directory. A folder inside Stedding’s own data, a folder it cannot write, and a folder the system will not open are refused, each with one sentence.

**The file.** Each file holds the whole merged sidebar, in the Export all Spaces shape, so **Import sidebar…** reads it on a computer that does not sync. A `stedding_sync` block adds the format number (1), the install id, the device name, a sequence number and a nonce, a stamp per field, tombstones, list order, aliases, and any keys from a newer version kept as they came. The synced fields are a Space’s name, icon, colours and whether it has its own session; a pin’s home (a web page only) and the user’s name for it; a folder’s title; and each item’s parent. A pin made an essential is a move. A file is at most 4 MiB and 5,000 records.

**What each install keeps,** in the profile, never in the folder: `Stedding Sidebar Sync/ledger.json`, local state (when each tombstone arrived, what was last read of each peer, held decisions, choices for this computer only), a journal of the last 10 applied batches within 30 days, and the last 5 backups, taken before the first join and before a held batch is applied.

**The merge.** A local edit is stamped with the later of now and the highest time seen plus one. The install id breaks a tie. Each field is its own register and the later stamp wins. Each list is one register: the newer list wins, and an item the other side added meanwhile stays beside its neighbour. The result does not depend on the order files are read in. At the first join, what is already here is older than any real edit, so the folder wins a tie.

**Pairing,** only after the user chooses Combine. Spaces pair by trimmed, case-folded name only when each side has exactly one of that name. Inside a paired Space, a pin pairs with one candidate of the same home and the same name, a folder with one of the same title, and an essential by home. The smaller id becomes the shared one, written as an alias. No local id changes. Anything ambiguous stays as two items.

**What applies by itself:** additions, renames, icons, colours, homes, pin names, reorders and moves. A new pin, folder or essential arrives unloaded, in its Space, in the registry window that holds the most pins of that Space, otherwise the last-active ordinary window. It never goes into a Blank Window, the little window or Peek, and never into two windows. Sync never activates a tab, a Space or a window.

**Deletions.** A tombstone is written only when the user removed the item in a live window (unpin, a real close, remove an essential, unpin or close a pinned folder, delete a Space) and, two seconds later, the item is in no window of the profile. A close that only puts a pin to sleep, a window closing, quitting, session restore, and a missing, short, unreadable or conflict-copy file delete nothing. An edit after a deletion keeps the item. Tombstones drop 180 days after they arrived here.

A pin or essential that sync put here and that was never opened here goes to Recently Closed when another computer removes it. Any other becomes an ordinary tab in its Space. A removed folder releases its tabs.

**What waits,** as a row in Settings, with no deadline: a Space deleted elsewhere; a change to an existing Space’s own session; a batch with 5 or more removals, a third or more of the synced pins, more than 50 additions, or any Space deletion; a move that would reload a loaded tab into another session; synced pins that are in no window here; a sync tool’s conflict copy. A computer whose clock runs more than 24 hours ahead is held whole. Its times never move this computer’s clock.

**Files are not trusted.** Peer files are parsed off the UI thread, within the caps. A cycle, a duplicate id or a bad value refuses the file. Only exact `stedding-sidebar-<16 hex>.json` names are read. A newer format is not applied. An older copy of this computer’s own file is ignored and overwritten. A copied profile takes a new install id and leaves the old file alone.

**Timing.** A change is written 2 seconds after the last edit to the synced sidebar, and at quit. A title, a load or a navigation inside a pin writes nothing. Another computer’s change applies about 2 seconds after its file changes (FSEvents on the Mac, ReadDirectoryChangesW on Windows). The folder is also checked when a Stedding window becomes active (at most every 5 seconds), every 10 seconds while one is in front, and on Sync now. Never in the background.

**What never travels:** open tabs below the Clear line and unpinned folders; a tab’s current address or title; child-tab nesting, splits, collapsed state, the active Space or tab, and which window holds what; history, Recently Closed, cookies, site data, passwords and payment data; extensions, bookmarks and downloads; routes, settings and permissions; a Space’s partition; the computer’s host name. The default device name is “Mac” or “Windows PC” plus 4 hex characters, and it is editable. A Blank Window, a private window, Guest, the little window and Peek do not take part.

Two simpler designs were set aside: one that never deletes without a question, and one where the newer whole record wins and an item missing from a live window is a deletion.

## Consequences

- The merge, the file reader and writer, the ledger, the per-window tracker, the applier and a profile service sit beside the importer. The importer stays add-only. The two share the id helpers and the unloaded-tab insert. Preferences are `stedding.sidebar_sync.folder`, `stedding.sidebar_sync.install_id` and `stedding.sidebar_sync.device_name`. Renaming those, or `Stedding Sidebar Sync`, needs a migration.
- Patch 0106 (Sf42) adds a note when the picked folder does not look like one a known sync tool keeps. Any folder still works.
- `docs/features/sidebar-file.md` is the behaviour. Sf11 is not in the series. Sf14, Sf20, Sf21, Sf24 and Sf31 are in patch 0101. Sf25 holds a move that would reload a loaded tab into another session; a change while a tab is dragged does not wait. Sf16 merges every list’s order but applies it to the Space list only, and a pin added elsewhere joins the end of its run (Sf17). Sf28 names a conflict copy in Settings and has no toast. Sf30 and Sf32 are not yet run on a signed build.
- A computer away for more than 180 days can bring removed items back as additions. The bulk guard holds a large batch. Pins in a closed window stay in the ledger and keep travelling, and come back only through Bring them here or by reopening the window, until windows G2 (`S-94`).
