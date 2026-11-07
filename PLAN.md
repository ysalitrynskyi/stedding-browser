# Plan: the owner's decisions and the rules of done

The order of work is [BACKLOG.md](BACKLOG.md). This file holds what does not change from item
to item: the owner's standing decisions, and when an item counts as done. The audit of
2026-09-26, with every item it raised (TAB-1, SPC-4, WIN-29, ...), is
[docs/history/plan-2026-09-26.md](docs/history/plan-2026-09-26.md). An item from it that is
still open is a BACKLOG row that names its id.

## The owner's decisions (2026-09-26)

1. Horizontal tab mode stays. Do not remove or hide the toggle. Switching either way must not
   crash, Stedding's views are torn down and rebuilt with the strip, menu ids are
   range-checked, and Spaces, pins and folders keep working in horizontal mode
   (`docs/features/spaces.md` B34, `docs/features/menus.md` M9).
2. Peek is on by default (the owner, 2026-10-25; `S-93`). `stedding.peek.enabled` registers
   true (`patches/0106-feat-peek-explains-itself-and-sync-says-what-folder.patch`).
3. The Space sleep timer defaults to Never. `stedding.spaces.sleep_minutes` registers as 0.
   A tab sleeps only when `MaySleep` in `sleep_tabs.cc` allows it. A Space pin or an essential sent home by decision 11 is the exception: it is unloaded whatever it is doing (`docs/features/tabs.md` R6).
4. The cuts named in the message of
   `patches/0055-fix-cut-unwired-helpers-and-close-the-open-holes.patch` are approved,
   and that patch applied them (`S-61`). The sidebar folder stays withdrawn
   (`docs/features/sidebar-file.md` Sf3). Sync through a folder, decision 18, is what
   replaced it.
5. ⌘9 selects the last visible row (`docs/features/tabs.md` R10, R11).
6. Collapsing the folder that holds the active tab keeps that tab showing under the header.
   No tab switch (`docs/features/folders.md` F3).
7. Deleting a Space asks first. Deleting the active Space then shows its neighbour. Only the
   last Space cannot be deleted (`docs/features/spaces.md` B5).
8. Do not document an import from Chrome, Brave or Edge until that importer exists. The
   history file's WEB-15 records that it was dropped. Patch 0057 removed the reader patch
   0055 had added. Since 2026-11-01 it exists: Chrome, Edge, Brave and Vivaldi come in as
   Dia does (`docs/features/import.md` I43), and the docs may say so.
9. Little windows get no Space commands. "Open in Stedding" is the way into the main window
   (`docs/features/little.md` E2, E7).
10. Tests that pin a bug are decided from the spec row and Arc's behaviour. Ask the owner only
    where those two disagree.

## Later decisions

11. ⌘W, a middle click and the tab menu's Close unload a Space pin or an essential and send
    it back to its home, in its place, whatever it is doing, after the page's own "Leave
    site?" if it asks (2026-10-20; `docs/features/pins.md` H3, H16). The close button on a
    Space pin is a minus while the pin is awake, and that minus does the same. Once the pin
    is asleep at its home the button is an x that asks "Remove this pinned tab?" before it
    removes the pin (2026-10-28; pins H29, GitHub issue 50). With the setting off, ⌘W, the
    close button and a middle click close the pin (H9).
12. A top-level folder can join a Space's pinned run, and its tabs are then pins
    (2026-10-20; `docs/features/folders.md` F38). Essentials take no folder.
13. On Windows the extension chord is Ctrl+Alt+E (2026-10-20; `docs/features/toolbar.md` T39).
14. Essentials stay shared by every Space, as in Arc (2026-10-21). A Space with an
    Independent session has essentials of its own and shows those instead of the shared ones
    (2026-10-22, ADR 0028; `S-254`, GitHub issue 8). When every Space has its own session,
    the shared essentials show in each, so they can still be reached. There is no setting
    for them.
15. Spaces switch with a sideways scroll over the sidebar, as in Arc (2026-10-21, GitHub
    issue 10): a tilt wheel and Shift with the wheel, on Windows also a touchpad's sideways
    scroll and Ctrl with the wheel. No Control with the wheel on the Mac, and a vertical
    scroll never switches (`docs/features/spaces.md` B39).
16. An issue a user files on GitHub is a suggestion unless it reports a bug (2026-10-21).
    Bugs are fixed. A requested feature is built only once the owner has said yes. Nothing
    is said or closed on GitHub (`AGENTS.md`, red lines). Labels are kept to the owner's
    replies when the owner asks (2026-10-23; the set widened 2026-11-07). Each issue has a
    kind (`bug`, `enhancement`, `question`, with `crash` or `regression` beside a bug),
    an `area: …`, a `platform: …` where it is one platform's, and a status:
    `status: needs decision`, `status: planned`, `status: later` (in the backlog, not
    planned now), `status: in progress`, `status: fixed on main` (ships in the next
    release), `status: released`, and `status: verify` (released, waiting for the
    reporter). `upstream` is the pin's own workflow's.
17. The address does not jump when the field takes focus (2026-10-23, GitHub issue 14;
    `S-275`; `docs/features/toolbar.md` T18). The field is the whole row in every state
    (the owner, 2026-10-24; toolbar T34). Its width is a setting: full width, or a field
    centred on the page at 800, 640 or 480 DIP (the owner, 2026-10-28; toolbar T48). Wide
    and centred, 800, is the default (the owner, 2026-11-02).
18. Sync has no account and no Stedding server. It goes through a folder the user picks,
    and it is off by default (2026-10-23, GitHub issue 20; `S-282`; ADR 0029;
    `docs/features/sidebar-file.md` Sf7–Sf41). WebDAV or S3 storage the user sets up is an
    alternative to the folder, never a replacement, and nothing for it ships with the
    browser: no provider, key or sign-in client (the owner, 2026-11-06, GitHub issue 77;
    `S-426`; ADR 0032; Sf43–Sf57).
19. A peek shows over the page, inside the pinned tab's window, as Arc's does (the owner,
    2026-11-01, GitHub issue 62: "current behaviour must be possible to set up in settings
    too"). "Show a peek: In a small window" keeps the little window; over the page is the
    default (`stedding.peek.style`, `docs/features/peek.md` P20). Its card wears a frosted
    rim, so it shows on a page as dark as itself; a soft glow or none is a setting (the owner,
    2026-11-02, from four rendered styles; peek P21).
20. Privacy choices that cost the user something are theirs, asked in the welcome flow's
    privacy step (the owner, 2026-11-02; `docs/features/welcome.md` W19): Global Privacy
    Control stays on by default, ad and tracker blocking stays off until chosen, and link
    cleaning is off by default because it can strip the code a site credits a referral by.
    The blocker's step says how it works and that an extension can block more, without
    running Stedding down.

The operator's own request in chat comes before any of this and before BACKLOG's order.

## When an item is done

A green unit test does not close anything. An item is closed when all of these hold:

1. Its check passes on a real build: the shipping configuration of the current pin, launched
   as the app and used through its interface. The date, the commit and the result go into the
   item's row or `docs/PROJECT-LOG.md`.
2. A test that goes through the user's path, not a helper, was seen red before the fix and
   green after, and a `tooling/dev test` filter runs it. Input, focus, drag and restore need a
   browser test (`chrome/test/stedding/`, with `PRE_` steps for a restart). A unit test is fine
   for pure logic, but it never proves a spec row on its own. A capture proves pixels only.
3. The spec row cites that test, and the spec and the code's comments say what the code now
   does.
4. Suites that touch lifetimes ran clean with DCHECKs and the dangling-pointer detector on
   (`win-checks`, `mac-checks`), and under ASan before a release
   (`docs/ROADMAP.md#the-quality-bar`).

## How items are taken

- **One root cause is one change.** Items that share a cause are fixed together. Finish one
  change's check before starting the next. A fix goes into the patch that owns the code
  (`tooling/fold-fix`, `patches/README.md`).
- **Confirm before fixing.** A finding that was read in the code but not seen happening is
  reproduced first: a failing test, or the failure on a real build. If an honest attempt does
  not reproduce it, record the attempt and close it as not reproduced. Nothing is fixed blind.
- **Defects before features.** New features wait until the core-loop gate passes (`S-173`;
  its script and the record of each run are `docs/features/acceptance.md`), unless the
  operator asks for one in chat. A crash, data loss or a broken privacy promise is built at
  once.
