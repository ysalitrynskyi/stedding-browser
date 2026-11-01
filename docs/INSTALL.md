# Installing Stedding

Stedding is in beta. Download it from the
[Releases page](https://github.com/ysalitrynskyi/stedding-browser/releases).
Each release carries a file for each platform it was built for, and the release
notes give a SHA-256 checksum for each file. Not every release has both: take
the newest one with a file for your platform.

The app in the Mac download is signed with the project's Developer ID and
notarized by Apple, so it opens like any other app. The Windows installer is
not code-signed yet, so SmartScreen warns (`S-56` in
[BACKLOG.md](../BACKLOG.md)).

Stedding is offered as is under its [BSD-3-Clause licence](../LICENSE). Keep a
copy of anything important before it becomes your everyday browser.

## macOS (Apple silicon)

A Mac with an M-series chip (M1 or later) and macOS 13 or later. There is no
Intel build.

1. Download `Stedding-<version>-arm64.dmg` from the latest release and check
   its checksum ([below](#verifying-the-mac-download)).
2. Open the disk image and drag **Stedding** into **Applications**.
3. Open Stedding.

Or with Homebrew, from the project's tap
([homebrew-stedding](https://github.com/ysalitrynskyi/homebrew-stedding)), which
follows each release:

```bash
brew install --cask ysalitrynskyi/stedding/stedding
```

Stedding then updates itself ([below](#updating)). `brew upgrade` is not
required for a new version.

### Verifying the Mac download

The release notes list a SHA-256 for each file. In Terminal:

```bash
shasum -a 256 ~/Downloads/Stedding-<version>-arm64.dmg
```

The number must match the one in the notes.

### Where your data is

Your profile — tabs, Spaces, history, passwords, extensions — is in
`~/Library/Application Support/Stedding`. Saved passwords are encrypted with a
key in the macOS keychain, under the name "Stedding Safe Storage".

**Export Space…** writes the active Space to a file, and **Export all Spaces…**
writes every Space. Both are in Settings › Stedding › Sync and import. The file
can be kept or moved to another computer.

An early Mac build kept the profile in
`~/Library/Application Support/Chromium` and the key in "Chromium Safe
Storage". The first launch that finds no Stedding profile copies that profile
across, when it is Stedding's, and leaves the old folder as it was. If another
browser is using the old folder, Stedding asks you to **Quit** and close it, or
to **Start a New Profile**. It copies the key once. macOS may ask for access to the Chromium item, and asks again on the next launch if you refuse. Keep the old folder until you have checked that
your tabs and Spaces came across.

### Uninstalling

Move Stedding from Applications to the Trash. To remove your data as well,
delete `~/Library/Application Support/Stedding` and the "Stedding Safe Storage"
item in Keychain Access.

## Windows (x64)

Windows 10 or 11, 64-bit.

1. Download `Stedding-<version>-win-x64.exe` from the latest release and check
   its checksum ([below](#verifying-the-windows-download)).
2. Run it. If SmartScreen shows "Windows protected your PC", click **More
   info**, then **Run anyway**.
3. Stedding installs for the current user, into
   `%LOCALAPPDATA%\Stedding\Application`, with no administrator prompt.

A sideways scroll on a touchpad moves one Space. The list does not follow your
fingers, as it does on the Mac. Ctrl with the wheel over the sidebar moves one
Space too (`TAB-31` in
[history/plan-2026-09-26.md](history/plan-2026-09-26.md)).

### Verifying the Windows download

```
certutil -hashfile Stedding-<version>-win-x64.exe SHA256
```

The number must match the one in the release notes.

### Where your data is

The profile is `%LOCALAPPDATA%\Stedding\User Data`. **Export Space…** and
**Export all Spaces…** are in Settings › Stedding › Sync and import, as on the
Mac.

### Uninstalling

Uninstall from **Settings › Apps**. That removes the program and keeps the
profile. To remove your data as well, delete
`%LOCALAPPDATA%\Stedding\User Data`.

## Updating

From 0.2.0 beta 16 on the Mac, and from 0.2.0 beta 19 on Windows, Stedding
updates itself. It looks for a new version on GitHub when you open it, if the
last check was more than an hour ago, and every six hours while it runs. A new
version downloads in the background. **New Stedding Version Available** shows
at the foot of the sidebar, above the Spaces. Click it to restart into the new
version. If you quit instead, the Mac installs the new version as it quits. On
Windows the next start is the new version. Before it runs that installer,
Windows checks it against the signed update feed.

On the Mac, **Stedding › Check for Updates…** looks at once. On both platforms,
**Check for Updates** in the command bar does the same. **Update Stedding
automatically**, in Settings › Stedding › Updates, turns the scheduled checks
off. Stedding then makes no update request until you ask. On the Mac, a version
already downloaded still installs when you quit.

After you finish or skip the welcome flow, Stedding opens one thank-you page on
stedding.dev. The first window of a later version opens another. **Show a
thank-you page after an update**, in the same settings, turns that second page
off ([features/updates.md](features/updates.md), [PRIVACY.md](PRIVACY.md)).

A copy from before those versions has no updater. Install the latest by hand
once.

By hand on the Mac, download the new disk image and drag Stedding onto the copy
in Applications. The profile stays. On Windows, run the new installer. A newer
version can install while Stedding is open. The installer of the version
already installed is a repair, and Stedding has to be closed first.

## First start

The first window opens a welcome screen, with **Get started** and **Skip
setup**, then six steps. Each step can be skipped. The names along the top are
Search, Import, Appearance, Behaviour, Default browser and Keys.

1. Choose a search engine. If you skip that step, or finish without picking
   one, a fresh profile keeps DuckDuckGo and records it as the choice.
2. Import. From Arc, on the Mac or on Windows: its sidebar, history and
   passwords. On the Mac, macOS asks once whether Stedding may read Arc's
   keychain item. From Chrome, Edge, Brave, Vivaldi and Dia, each when it is
   installed: bookmarks, history and passwords, with the profile to take them
   from (on Windows, passwords Chrome seals with its own key are counted and
   left out). From a file Safari exported, on either platform: bookmarks and
   history, and passwords only if you tick them, because the file holds them as
   plain text. Through Chromium's importer: Safari's bookmarks, or Firefox's
   bookmarks and history, on the Mac; Firefox, with passwords, Internet
   Explorer or the old Edge, on Windows, each with only what it can bring; and a
   bookmarks HTML file on either platform. Opera is not offered. Settings →
   Stedding → Sync and import → **Import from another browser** opens this step
   again.
3. The colour scheme (system, light or dark), a Space colour, and the sidebar
   text size. A fresh profile uses 14 until you pick another.
4. How Stedding behaves. Idle tabs stay until you choose a time to archive
   them. The closed sidebar shrinks to icons, or hides. A Space stays awake
   after you leave it until you choose a time. A link from a pinned tab to another site opens in a peek on a click until you choose otherwise.
5. Set Stedding as the default browser, if you want.
6. The keys worth knowing.

Each choice can be changed later in Settings.

## Linux

There is no Linux build. Linux is M9 in [the roadmap](ROADMAP.md), after the
Windows port.
