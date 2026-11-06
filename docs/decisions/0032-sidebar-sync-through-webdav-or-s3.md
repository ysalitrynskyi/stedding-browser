# 0032 — The sidebar can also sync through WebDAV or S3 storage the user sets up

Status: Accepted (the owner, 2026-11-06). Amends ADR 0029, which stays true of a folder. Built (`BACKLOG.md` S-426).
Date: 2026-11-06

## Context

Sync goes through a folder, so it needs a sync app or a shared drive to carry that folder (ADR 0029). GitHub issue 77 asks for sync with no extra app, through storage the user already has.

One-click sign-in to Google Drive, Dropbox or OneDrive needs an app registered with each company and shipped in the browser, and each company's approval. Google also issues a client secret, which it says a desktop app cannot keep confidential. The owner will not ship any of that. WebDAV and S3 need none of it: the user types an address and their own credentials.

## Decision

**Two more places, beside the folder.** A profile can sync through a folder, a WebDAV folder or an S3 bucket. The folder stays as it is and comes first. All three are off by default.

**Nothing ships with the browser.** No provider, preset, address, key or sign-in client. Every value is the user's.

**One place at a time.** A profile uses one place. Changing it means **Stop syncing** and a new join. The service refuses a join while sync is on, so no screen can get around the rule.

**The same files.** The directory, the file names, the format, the merge, the caps and the deletion rules are ADR 0029's. Each install still writes only its own file. A computer on WebDAV and a computer whose sync app keeps the same directory sync with each other.

**No setup without a passing test.** The form leads only to a test, and only a passing test leads to the join sheet. The test signs in, proves the address is a WebDAV folder or an S3 bucket, and writes, reads back, lists and deletes a probe file. A failure names the step in one sentence. A place anyone can read with no sign-in is refused, because the files hold Space names and pinned addresses. So is an address that would send credentials unencrypted to anything but a private network. Stedding never creates a bucket or the folders above `Stedding Sidebar`.

**Credentials stay on the computer.** They are encrypted with the system's key store and go only to the address the user typed. They are never in a sync file, a backup, an export or a log.

**Reads are slower than a folder's, and still never in the background.** A network place has no watch, and each request can cost the user money, so a list runs at most every 30 seconds on activation and every 60 seconds while a window is in front. Quitting does not wait for the network.

Left out: sign-in to Google Drive, Dropbox or OneDrive, which would ship something; sync while no window is in front; and encrypting the files. They are plain text on the user's own storage, as they are in a folder, and the join sheet says so.

`docs/features/sidebar-file.md` Sf43–Sf57 is the behaviour.

## Consequences

- Stedding makes network requests for sync when, and only when, the user has set up one of these places. "No network request" stays true of a folder and of sync that is off. `docs/PRIVACY.md`, `docs/PRODUCT.md`, `docs/VISION.md`, `docs/FAQ.md` and `README.md` change when this ships.
- The first design to try is a bridge that keeps a mirror of the place in the profile, which the service reads as its folder. The merge, the file code and the ledger then do not change, and the one-folder rule holds by construction. The bridge is new code beside patch 0101.
- There is no new dependency. S3's signature uses Chromium's crypto, requests use its network stack, and a server's XML goes through its sandboxed data decoder.
- Google Drive has no WebDAV, so the case issue 77 names first stays a folder its own app keeps. Someone with no WebDAV or S3 account has to open one.
- Setup takes more typing than one click. Steps for common services belong in `docs/FAQ.md`, not in the browser.
