# Feature: One sidebar for every window

Status: **G0, G1, G3–G5 built, G2 a gap** (round 6, `docs/ROUND6-PLAN.md` R6-31; ADR 0016).
Owner docs: `docs/decisions/0016-space-registry.md`, `docs/PRODUCT.md` §10. Patch: 0036.

A second window shows the same Spaces, essentials and pins as the first. The Space list
lives in a profile-level registry; each window keeps only its active Space and which of
its tabs is in which Space. A pinned tab is a real tab in one window at a time and a
ghost row everywhere else.

## Behaviours

| Id | Behaviour | Test | State |
|---|---|---|---|
| G0 | ADR 0016 beside 0015: the Space list, order, metadata, essentials and per-Space pinned entries move to a profile-level `SpaceRegistry` (KeyedService); `SpaceModel` stays per window with only the active Space and tab membership, observing the registry. Written and accepted before code. | `docs/decisions/0016-space-registry.md` | built |
| N1 | The series compiles for Windows: every `base::FilePath` built from a narrow string uses `FILE_PATH_LITERAL`, `FromUTF8Unsafe`, `AppendASCII` or `AsUTF8Unsafe`, because `FilePath` is `std::wstring` there. Nine errors in four files on the first build, 2026-09-07. | none; a Windows build (patch 0039) | partial · no Windows CI (S-49) |
| N2 | The Windows build runs with the Stedding window: sidebar, Spaces, folders, the command bar, archive and routing; without branding, the macOS keyboard map, the Cocoa menus and the keychain naming, which live in `is_mac` sources. Not a port -- M8 -- but the first evidence for one. | none; live: `docs/images/win-wide.png` (the open sidebar) and `docs/images/win-rail.png` (the rail), Windows, 2026-09-08 | partial · M8, `S-56` |
| N3 | Windows knows the browser as Stedding: the product name and company from `branding/BRANDING`; the install and profile directory `%LOCALAPPDATA%\Stedding`; the app name, app id and window class `Stedding`; the ProgIDs `SteddingHTM` and `SteddingPDF`; the `stedding:` launch scheme; and fresh GUIDs for Active Setup, the toast activator, the elevator and the tracing service, plus a fresh sandbox SID prefix, so an install lives beside a Chromium install and never on top of it (`chrome/install_static/chromium_install_modes.h`, patch 0041; ADR 0018). | none; live: `chrome.exe`'s version resource reads Stedding, the profile lands under `%LOCALAPPDATA%\Stedding` (Windows, 2026-09-09) | partial · no unit test yet (S-49) |
| N4 | The Windows icons come from the mark -- `branding/win/app.ico`, `doc.ico`, `pdf.ico` and the two tiles, written by `tooling/brand/win_icons.py` from the generated 256 px logo -- and `tooling/apply-branding`, which now runs under Git for Windows too, copies them over `chrome/app/theme/chromium/win/`. The product-name rewrite (`tooling/brand/product_name.py`) reaches every locale's translations, not only the English tables. | none; live: the taskbar and the About page (Windows, 2026-09-09) | partial · no unit test yet (S-49) |
| N5 | chrome://settings/stedding opens on Windows. The shortcut reference on that page is the Mac's keyboard map and its handler is Mac-only, and the page asked for it on every platform: a WebUI message nobody handles is a `NOTREACHED` in the browser process, so opening the Stedding settings killed the Windows browser until 2026-09-09. The page asks only where the reference exists (`steddingHasShortcutReference`), and the Shortcuts block is absent elsewhere until the Windows map lands (S-56). | none; live: `w9_settings` (Windows, 2026-09-09) | partial · no unit test yet (S-49) |
| G1 | ⌘N (and a tab dragged out) opens a window showing the same Spaces, essentials and pinned rows. | `SpaceWindowTest.SecondWindowSeesTheSameSpaces`; live: `w4_windows` (⌘N shows the same Spaces) | built |
| G2 | A pinned tab is a real tab in one window at a time; other windows show its row as a ghost (muted favicon, "in another window" on hover); a click moves the WebContents here (detach, then insert, no reload), ⌥-click focuses the window that has it. | none yet | gap · the next pass: a pinned tab is still a tab of one window with no ghost row elsewhere |
| G3 | The registry serialises to profile prefs (`stedding.spaces.registry`); per-window extra data keeps the active Space and memberships so the B9 rebuild path is unchanged; the settings page reads the registry. | `SpaceRegistryTest.RoundTrip`; the session's per-window data is unchanged (`SessionRebuildTest.*` still green) | built |
| G4 | "New Blank Window" (⌥⇧⌘N, the app menu) opens a window that opts out of the registry: Arc's Blank Window. | `SpaceWindowTest.BlankWindowHasItsOwnSpaces`; live: `w4_blank_window` | built |
| G5 | The registry's Space carries a profile id, empty in round 6, so per-Space profiles need no second migration (critic #9). | `SpaceRegistryTest.RoundTrip` (the empty profile id survives the round trip) | built |

## Notes

- Order of work, from the ADR: the registry and its round trip first (G3, G5), then the
  model observing it (G1), then the ghost rows and the move (G2), then the Blank Window
  (G4). Every step keeps every existing `SpaceWindowTest` green, since the model's
  surface does not change.
- Routing (R6-23) and the little window (R6-30) ask "which window": the last-active
  normal window that shares the registry; a Blank Window is never the answer.
- This cut shares the Space list, its order and metadata (G1, G3) and keeps a
  window's tabs, pins and essentials per window: a pinned tab is a real tab of the
  window it was pinned in, with no ghost row elsewhere yet (G2). The registry seeds
  itself from the first window's session and merges later windows' Spaces by id,
  so an upgrade loses nothing. The backup scheduler stays per window for now.
