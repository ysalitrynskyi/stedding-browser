# Installing Stedding

Stedding ships as beta pre-releases on the
[Releases page](https://github.com/ysalitrynskyi/stedding-browser/releases). Each
release carries one file per platform and a SHA-256 checksum for each.

The builds are **not code-signed yet**. On macOS that means one Terminal command
before the first launch; on Windows, one SmartScreen prompt. Signing and notarisation are the
next step (`S-17` in [BACKLOG.md](../BACKLOG.md)); once they land, this page loses
those paragraphs.

## macOS (Apple silicon)

Requirements: a Mac with an M-series chip (M1 or later). Intel Macs are not supported
yet.

1. Download `Stedding-<version>-arm64.dmg` from the latest release and check its
   checksum ([below](#verifying-the-download)).
2. Open the DMG and drag **Stedding** into **Applications**.
3. Open Terminal and run, once:

   ```bash
   xattr -dr com.apple.quarantine /Applications/Stedding.app
   ```

   Then open Stedding as usual. Every later launch is a normal double-click.

Without step 3, macOS says Stedding "is damaged and can't be opened" and offers to
move it to the Trash. The app is not damaged: that is what macOS says about an
unsigned build of Chromium downloaded from the internet, and right-click → Open does
not get past it. The command removes the download mark from this one app, which is
why the checksum comes first. Do not turn Gatekeeper off system-wide for this.

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
Stedding's own folder and leaves the old one as it was; once you have checked that
your tabs and Spaces came across, and if you run no Chromium yourself, you can delete
the old folder. Sidebar snapshots are written into the
profile every hour (**Settings → Stedding → Restore sidebar…** lists them), and
**Export Space…** writes a Space to a file you can keep or move to another machine.

Saved passwords are encrypted with a key kept in the macOS keychain under the name
"Stedding Safe Storage".

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

1. Download `Stedding-<version>-win-x64.exe` from the latest release.
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

The profile is under `%LOCALAPPDATA%\Stedding\User Data`. Backups and export work as on
macOS.

### Updating and uninstalling

Run the new installer over the old version; the profile is kept. Uninstall from
**Settings → Apps**, as with any app.

### What the Windows preview does not have yet

The Windows build is a preview: the full interface, Arc's keyboard mapped to Ctrl and
Alt, the name and icon, and a per-user installer. Still open: little windows for links
from other apps, signing, and automatic updates (`S-56`).

## First start

The first window opens the welcome flow: choose a search engine, import from Arc (or
Chrome, Firefox, Safari), pick a Space colour, set Stedding as the default browser if
you want, and see the keyboard shortcuts. Everything on it can be changed later in
**Settings → Stedding**.

## Linux

Not yet. Linux follows the Windows port ([docs/ROADMAP.md](ROADMAP.md), M9).
