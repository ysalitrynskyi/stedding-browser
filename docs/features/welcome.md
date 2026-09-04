# Feature: Welcome flow

Status: **W1–W6 built**; W7 is a gap.
Owner docs: `docs/PRODUCT.md` (first run, import), `docs/PRIVACY.md` (the chooser).
Patch: `0015`.

The first window of a profile opens a welcome dialog floating over it, hosting
`chrome://stedding-welcome` (a `views::DialogDelegate` around a `WebView`, a child
window of the browser window, opened one loop turn after `BrowserView::Show`; the
search-engine chooser's own trigger routes here too). It is deliberately not a
window-modal sheet: Chromium refuses to quit while the active window has a sheet
attached (`AppController`'s `keyWindowIsModal`), and not a `WebDialogView`, whose
first close request is answered "not yet" while it runs `beforeunload`. Closing the
window or quitting with the flow open works, and the flow returns on the next window.
The flow has five steps with dots, Back, Next, and Skip. Step one is the
search-engine chooser Stedding already required (`docs/PRIVACY.md`); the others are the
things a switcher does in their first minute. Every step is skippable; nothing here
leaves the machine.

## Behaviours

| Id | Behaviour | Test | State |
|---|---|---|---|
| W1 | The dialog shows once per profile: on the first normal window of a regular profile, never again after Finish or Skip (`stedding.welcome.shown`). `--no-first-run` suppresses it (the capture harness passes that switch); `--stedding-welcome` forces it for a manual check. | `SteddingPrefsTest.*`; live: `tooling/drive <fresh> <steps> --stedding-welcome` | built |
| W2 | Step 1 lists the same engines as the chooser, in the same random order, and choosing one sets the default search engine through the choice service. | live: engine chosen → `chrome://settings/search` shows it | built |
| W3 | Step 2 lists the browsers Chromium's importer finds on this Mac; Import copies bookmarks, history and passwords (each optional) through `ImportDataHandler`. | live: Import from Chrome shows "Imported" | built |
| W4 | Step 3 sets the colour scheme (system, light, dark) through the theme service, at once. | live | built |
| W5 | Step 4 shows whether Stedding is the default browser and asks macOS to make it so. | live | built |
| W6 | Step 5 lists the five shortcuts (⌘T, ⌘S, ⌘O, ⇧⌘L, ⇧⌘2) and the Space swipe; Finish closes the dialog. | live | built |
| W7 | A Space-colour picker on step 3 (the first Space's tint). | none yet | gap |
