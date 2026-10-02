# Installing Stedding

Stedding ships as beta pre-releases on the
[Releases page](https://github.com/ysalitrynskyi/stedding-browser/releases). Each
release carries a file for each platform it was built for, and a SHA-256 checksum for
each. When the newest release has no file for your platform, take it from the one before:
beta 11 and beta 12 are the macOS image only, and the Windows preview is beta 10's installer.

The macOS image is signed with the project's Developer ID and notarized by Apple from
beta 10 on, so it opens like any other app. The Windows installer is **not code-signed
yet**, which means one SmartScreen prompt (`S-56` in [BACKLOG.md](../BACKLOG.md)). There are
no automatic updates yet on either platform (`S-74`).

## macOS (Apple silicon)

Requirements: a Mac with an M-series chip (M1 or later) and macOS 13 or later. Intel
Macs are not supported yet.

1. Download `Stedding-<version>-arm64.dmg` from the latest release and check its
   checksum ([below](#verifying-the-download)).
2. Open the DMG and drag **Stedding** into **Applications**.
3. Open Stedding. macOS checks Apple's notarization once and opens it.

Betas up to beta 8 were not signed and needed a Terminal command
(`xattr -dr com.apple.quarantine /Applications/Stedding.app`) before the first launch;
from beta 10 on that step is gone.

### Verifying the download

The release notes list a SHA-256 for each file. In Terminal:

```bash
shasum -a 256 ~/Downloads/Stedding-<version>-arm64.dmg
```

The number must match the one in the notes exactly.

### Where your data is

Your profile — tabs, Spaces, history, passwords, extensions — lives in
`~/Library/Application Support/Stedding`. Mac builds up to beta 8 kept it in
`~/Library/Application Support/Chromium` by mistake, a folder any Chromium on the
same Mac also uses. The first launch of a later build copies that profile into
Stedding's own folder, if that folder holds no profile yet, and leaves the old one as
it was. If another browser is using the old folder at that moment, Stedding asks
first: **Quit**, close the other browser and open Stedding again to bring the profile
across, or **Start a New Profile** and leave the old one where it is. Keep the old folder until that build has been released and you have checked
that your tabs and Spaces came across. **Export Space…** in Settings → Stedding writes a
Space to a file you can keep or move to another machine.

Saved passwords are encrypted with a key kept in the macOS keychain under the name
"Stedding Safe Storage". Builds up to beta 8 used the item "Chromium Safe Storage"; a
later build copies that key under Stedding's name once, so macOS may ask one time for
access to the Chromium item.

### Updating

Download the new DMG and drag Stedding over the old one in Applications, then run
the command in step 3 again: each download carries the mark anew. Your profile is
untouched. In-app updates arrive with signing (`S-17`).

### Uninstalling

Move Stedding from Applications to the Trash. To remove your data as well, delete
`~/Library/Application Support/Stedding` and the "Stedding Safe Storage" item in
Keychain Access.

## Windows (x64)

Requirements: Windows 10 or 11, 64-bit.

1. Download `Stedding-<version>-win-x64.exe` from the newest release that has one
   (beta 10's, while the betas after it are the macOS image only).
2. Run it. If SmartScreen shows "Windows protected your PC", click **More info**, then
   **Run anyway**. This is needed once.
3. Stedding installs for the current user only, into `%LOCALAPPDATA%\Stedding`, with no
   administrator prompt, over an earlier version if there is one.

### Verifying the download

```
certutil -hashfile Stedding-<version>-win-x64.exe SHA256
```

The number must match the one in the release notes.

### Where your data is

The profile is under `%LOCALAPPDATA%\Stedding\User Data`. Export works as on macOS.

### Updating and uninstalling

Close Stedding, then run the new installer over the old version; the profile is kept. When
the new release is on the same Chromium number as the one installed (beta 9 and beta 10 are
both 155.0.8059.12) the installer repairs in place and cannot replace the files of a running
Stedding, so it has to be closed (a release on a different Chromium number is added beside the
old version, which is how beta 6 became beta 9). Uninstall from **Settings → Apps**, as with any
app.

### What the Windows preview does not have yet

The Windows build is a preview: the full interface, Arc's keyboard mapped to Ctrl and
Alt, the name and icon, and a per-user installer. Still open: little windows for links
from other apps, signing, and automatic updates (`S-56`).

## First start

The first window opens the welcome flow: choose a search engine; import from Arc, or
through Chromium's importer from Safari (bookmarks) or Firefox (bookmarks and history)
on macOS, and from Firefox, Internet Explorer or the old Edge on Windows; pick a Space
colour; set Stedding as the default browser if you want; and see the keyboard
shortcuts. Chrome, Brave and the new Edge cannot be imported yet. Each choice can be
changed later in Settings.

## Linux

Not yet. Linux follows the Windows port ([docs/ROADMAP.md](ROADMAP.md), M9).
