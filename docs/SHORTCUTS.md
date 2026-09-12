# Keyboard shortcuts

Every shortcut Stedding adds or changes, on both platforms. The same list is inside
the browser at **Settings → Stedding → Shortcuts**, generated from the keyboard tables
the browser itself uses, so that page is always exact for the version you run.

Keys: ⌘ Command, ⌥ Option, ⇧ Shift, ⌃ Control, ⇥ Tab.

## Sidebar and Spaces

| Action | macOS | Windows |
|---|---|---|
| Collapse the sidebar to icons, or bring it back | ⌘S | Ctrl+S |
| Show or hide the address row on its own | ⇧⌘D | Ctrl+Shift+D |
| Jump to Space 1 to 9 | ⌃1 – ⌃9 | Alt+1 – Alt+9 |
| Next Space / previous Space | ⌥⌘→ / ⌥⌘← | Ctrl+Alt+→ / Ctrl+Alt+← |
| Move the tab to the next / previous Space | ⌥⇧⌘→ / ⌥⇧⌘← | Ctrl+Alt+Shift+→ / ← |
| Pin the tab in its Space, or unpin it | ⌘D | Ctrl+D |
| Clear: close the Space's unpinned tabs | ⇧⌘K | Ctrl+Shift+K |
| New Blank Window: a window with Spaces of its own | ⌥⇧⌘N | Ctrl+Alt+Shift+N |
| In a little window: send the page into a split of your window | ⇧⌘O | — |
| In a little window: close it | Esc | — |

## Tabs and the bar

| Action | macOS | Windows |
|---|---|---|
| Open the bar: search, a URL, or any open tab | ⌘T | Ctrl+T |
| Open the bar in actions mode (⇥ in an empty bar does the same) | ⇧⌘P | Ctrl+Shift+P |
| Select the address with the URL selected | ⌘L | Ctrl+L |
| Jump to one of the first nine rows you can see (hold ⌘ / Ctrl a moment to see the numbers) | ⌘1 – ⌘9 | Ctrl+1 – Ctrl+9 |
| Next tab / previous tab | ⇧⌘] / ⇧⌘[ | Ctrl+PgDn / Ctrl+PgUp |
| Next tab down the sidebar / previous tab up the sidebar | ⌥⌘↓ / ⌥⌘↑ | Ctrl+Alt+↓ / Ctrl+Alt+↑ |
| Most recent tab of the Space (hold ⌃ / Ctrl to see the five most recent) | ⌃⇥ | Ctrl+Tab |
| Most recent tabs, the other way round | ⌃⇧⇥ | Ctrl+Shift+Tab |
| Move the row down / up (a folder beside it is one row) | ⌥⇧⌘↓ / ⌥⇧⌘↑ | Ctrl+Alt+Shift+↓ / ↑ |
| Split the current tab with a new one | ⌥⌘N | Alt+Shift+N |
| Put a pinned tab to sleep (instead of closing it) | ⌘W | Ctrl+W |
| Turn a peek into a tab / into a split | ⌘O / ⇧⌘O | — |

## Page

| Action | macOS | Windows |
|---|---|---|
| Copy the link, without its tracking parameters | ⇧⌘C | Ctrl+Shift+C |
| Copy the link as Markdown | ⌥⇧⌘C | Ctrl+Alt+Shift+C |
| Screenshot the page as shown | ⇧⌘2 | Ctrl+Shift+2 |
| Screenshot a region you drag out | ⌥⇧⌘2 | Ctrl+Alt+Shift+2 |
| Screenshot the whole document | ⇧⌘1 | Ctrl+Shift+1 |

Screenshots go to Downloads as PNG and to the clipboard.

## Where Stedding differs from Chromium

Stedding takes a few chords Chromium uses for other commands. The old command keeps
its menu item; only the key moves.

| Chord | Stedding | Chromium had |
|---|---|---|
| ⌘S / Ctrl+S | Collapse or expand the sidebar | Save Page As… (now ⇧⌘S / Ctrl+Shift+S) |
| ⌘D / Ctrl+D | Pin the tab in its Space | Bookmark This Tab… (keeps its menu row) |
| ⇧⌘D / Ctrl+Shift+D | Show or hide the address row | Bookmark All Tabs… (keeps its menu row) |
| ⇧⌘C | Copy the link | Inspect Elements, as a second chord (⌥⌘C stays) |
| Ctrl+Shift+C | Copy the link | Inspect (F12 and Ctrl+Shift+I stay) |
| Ctrl+Shift+P | Open the bar in actions mode | Print using the system dialog (now Ctrl+Alt+P) |
| ⌃⇥ / Ctrl+Tab | Most recent tab of the Space | Next tab, in strip order |
| ⌥⌘→ / ⌥⌘← | Next / previous Space | Next / previous tab |
| ⌥⌘↓ / ⌥⌘↑ | Next / previous tab in the sidebar | Focus the next / previous pane (now F6 / ⇧F6) |
| ⇧⌘K / Ctrl+Shift+K | Clear the Space | unbound |

## Notes

- **macOS:** ⌃1–⌃9 are also Mission Control's "Switch to Desktop N" once a second
  desktop exists, and macOS takes them first. The Spaces menu in the menu bar keeps
  the commands reachable.
- **macOS:** a clipboard manager that owns ⇧⌘C system-wide (Maccy does by default)
  takes it before the browser does; the File menu row always works.
- **Windows:** a tap of Alt on its own still focuses the app menu, as in Chromium; the
  digit goes with the key held.
- **Windows:** Ctrl+Alt with an arrow is also the display-rotation hotkey some Intel
  graphics drivers install; turn that off in the driver if the two collide. A keyboard
  whose AltGr types a character with one of the Ctrl+Alt chords may see the character
  instead inside a text field.
- Remapping shortcuts yourself is not available yet (planned for 1.0).
