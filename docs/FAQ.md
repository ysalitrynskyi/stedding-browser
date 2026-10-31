# Frequently asked questions

## About the project

**What is Stedding?**
An open-source desktop browser with Arc’s way of working: a sidebar of vertical tabs,
Spaces, pinned tabs and folders, and a command bar. It is Chromium plus a documented
series of patches. See the [README](../README.md).

**What does it have that Arc did not, and the other way round?**
It is open source and needs no account. A Space can keep its own sign-ins inside one
profile, so one site can be signed in as work in one Space and as you in another. One
switch turns every website dark. A web page can become an app with a window of its own.
**Clear Site Cookies and Reload** clears the cookies of the site in front of you, in
that tab’s sign-in, and reloads it; other sites are left alone. Arc still has Boosts,
Easels, the sidebar’s mini player, the Library panel and Live Folders, shared Spaces,
and AI. Both lists are in the README: [What Arc never had](../README.md#what-arc-never-had)
and [what Arc has that Stedding does not](../README.md#what-arc-has-that-stedding-does-not).

**Is it a fork of Arc?**
No. Arc is closed source, so nothing of it can be reused. Stedding is written on
Chromium’s open-source code.

**Why does it exist when Arc still runs?**
Arc runs until 22 December 2026, when The Browser Company said it will stop. Since May
2025 it has had only security and Chromium updates, and in September 2025 Atlassian
announced it was acquiring Arc’s maker. Stedding’s core is BSD-licensed and forkable,
so no pivot or acquisition can take it away
([the comparison](VISION.md#competitors)).

**Does it have AI?**
No bundled model, and no chat in the command bar
([ADR 0020](decisions/0020-no-bundled-model.md)). An extension can add one.

**What does “Stedding” mean?**
A haven. It is shaped on “steading”, a farmstead, from “stead”, an old word for a place
([how it was chosen](VISION.md#the-name)).

**Who makes it?**
One maintainer, in the open. Bug reports go to GitHub.

**Is there a warranty?**
No. Stedding comes as is under its [BSD-3-Clause license](../LICENSE), which says its
authors and contributors are not liable for what comes of using it. Bug reports are
welcome and are fixed as time allows. As with any beta, keep a copy of anything
important.

## Installing and updating

**Is the build signed, and is it safe?**
Stedding is built in the open on Chromium stable, follows its security releases, and
is tested in daily use. The macOS image is signed with the project’s Developer ID and
notarized by Apple. The Windows installer is not signed yet, so SmartScreen asks once
([INSTALL.md](INSTALL.md)). Every release is built from this repository’s patch series,
and its SHA-256 checksum is published beside the file. There is no warranty (the
question above).

**Will it update itself?**
Yes. A Mac copy from 0.2.0 beta 16 on, and a Windows copy from 0.2.0 beta 19 on, looks
for a new version when you open it, unless it looked in the past hour, and every six
hours while it runs. It downloads in the background and shows **New Stedding Version
Available** above the Spaces. A click restarts into it. The download is checked against
the project’s key before it installs, and the check sends nothing that identifies you
([PRIVACY.md](PRIVACY.md)). Settings → Stedding → Updates → **Update Stedding
automatically** turns it off. A Windows copy older than 0.2.0 beta 19 needs one newer
release installed by hand.

**Intel Mac? Linux?**
No. The downloads are macOS on Apple silicon and Windows x64. Intel Macs are not
supported yet. Linux is not available ([ROADMAP.md](ROADMAP.md)).

**Can it be my default browser?**
Yes. The welcome flow asks, and so does Settings → Default browser.

## Using it

**How do I move from Arc?**
The welcome flow’s **Move everything from Arc** brings over Spaces, essentials, pinned
tabs, folders, tabs, history and passwords from Arc’s files on your disk. On a Mac,
passwords need one keychain prompt. On Windows, none. Run it again from Settings →
Stedding → Sync and import → **Import from Arc**. A second run adds only what Arc
gained.

**Can the sidebar get out of the way completely?**
Yes. Settings → Stedding → Sidebar → **When the sidebar closes: Hide it completely**.
⌘S (Ctrl+S) then gives the page the whole window. Rest the pointer on the window’s
edge on the sidebar’s side and the sidebar slides back. The same section sets row
height, text size, width and **Page flush against the window**. **Sidebar on the
right** moves the sidebar, and that edge, to the right.

**What does closing a pinned tab do?**
⌘W (Ctrl+W), a middle click on its sidebar row, or **Close** on its menu unloads it
and puts it back on the page you pinned, in its place, so it costs nothing until you
open it again. A page that asks “Leave site?” asks first. On a Space pin’s row the
button is a minus while the pin is awake (“Close, keep pinned”). Once the pin is
asleep on its pinned page the button is an ✕: it asks *Remove this pinned tab?*,
Cancel is the default, and **Remove** unpins and closes it. ⇧⌘T (Ctrl+Shift+T) brings
it back. **Unpin from This Space** or **Remove from Essentials** removes one too. An
essentials card has no close button; ⌘W and a middle click still follow the same rule.
Turn off **⌘W on a pinned tab puts it to sleep** (**Ctrl+W on a pinned tab puts it to sleep** on Windows) in Settings → Stedding → Tabs, and
⌘W, the close button and a middle click close the pin, with no question.

**Can I pin a tab by dragging it?**
Yes, as in Arc. Drag a tab up over the line and it is pinned where you drop it. Drag
a pinned tab down under the line and it is unpinned where you drop it.

**Can I make a tab an essential by dragging it?**
Yes, as in Arc. Drag a tab up over the essentials: it becomes a card under the
pointer, the cards part to make a place, and dropping it there makes it an essential.
Drag an essential down into the list and it stops being one: under the line it is a
tab again, above it a pinned tab of the Space. **Add to Essentials** and **Remove
from Essentials** on a tab’s menu do the same.

**Can a folder hold pinned tabs?**
Yes. Drag a folder over the line into the pinned tabs, or choose **Pin Folder** on
its menu. Every tab in it, including tabs in a folder inside it, becomes a pinned tab,
and the folder stays a folder. **Unpin Folder**, or a drag back under the line,
unpins it. Essentials take no folders.

**Can essentials belong to one Space?**
In a Space with an **Independent session**, yes. A tab you add to the essentials there
is that Space’s own, stays signed in with the Space, and shows in that Space alone.
That Space shows its own essentials and not the shared ones, unless every Space has
its own session, in which case the shared essentials show in each. In a Space that
shares the session, essentials are shared, as in Arc. For a tab that belongs to one
Space, you can also pin it there (⌘D, Ctrl+D): pinned tabs are each Space’s own.
Turning the Space’s session off makes its essentials its pinned tabs.

**Where did the bookmark bar go?**
Pinned tabs play its part. Imported bookmarks stay bookmarks, and ⇧⌘B (Ctrl+Shift+B)
still shows the bar. The command bar’s **Turn Bookmarks into Pinned Tabs** makes them
pins and folders, then hides the bar and the star, because the sidebar holds them.
Above 50 bookmarks it asks first. Settings → Stedding → Tabs → **Show the bookmark
bar and the star** brings both back.

**A link opened in a little window over the page. What is that?**
A peek. A link from a pinned tab or an essential to another site opens over the
window, so the pinned tab stays where it was. Escape, ⌘W, or a click on the window
behind it closes the peek. **Open as Tab** (⌘O) keeps the page as a tab. Settings →
Stedding → Peek and little windows → **Open a peek with** can require a press held
for 0.3 or 0.5 seconds, so a plain click follows the link in the tab. **Open links
from pinned tabs in a peek**, the switch above that, turns Peek off.

**Can I divide the sidebar with lines?**
Yes. Right-click a tab or a pinned tab in a Space’s list and choose **Add Separator
Above**. A faint line goes above that row and stays after a restart. **Remove
Separator** on the same menu takes it away. Essentials, folders and a split’s panes
have no separator.

**What happens to tabs I do not close?**
Nothing, until you choose a time in Settings → Stedding → Tabs → **Archive tabs
nobody has looked at for** (6 hours, 12 hours, 1 day, 3 days or 7 days; Never until
you choose). Idle tabs then leave the sidebar. **Archived**, on the line above the Spaces, opens them grouped by day. **Restore** on a row brings that tab back. Pinned tabs and tabs in a folder never
archive.

**Why do most tabs look dimmed after a restart?**
They are asleep. A launch loads only the tab you were on, both sides when it is a
split, so a long sidebar costs nothing until you open a tab. Settings → Stedding →
Tabs → **On startup, load** can also load the essentials, or the whole Space on
screen. The choices are **The selected tab only**, **The selected tab and the
essentials**, and **The whole active Space**.

**Can tabs I am not using free their memory?**
Yes. Settings → Stedding → Tabs → **Put tabs to sleep after** offers Never (the
default), 5 minutes, 30 minutes or 4 hours. A tab you have not looked at for that
long sleeps: its row stays, and it reloads when you open it. Essentials stay awake,
and so does a tab playing sound, on a call, showing picture in picture, or holding
text you typed. The command bar’s **Sleep Other Tabs** does it at once in every Space, in every normal window, except each window’s tab on screen, the essentials, and a tab playing sound, on a call, showing picture in picture, holding text you typed, or otherwise in use. When memory runs
short, the tab you saw longest ago sleeps first, unless those rules keep it awake.

**I closed a tab by mistake.**
⇧⌘T (Ctrl+Shift+T) reopens closed tabs one at a time, each in its Space and folder.
For a toast with **Undo** after a close, which puts that whole close back at once,
turn on Settings → Stedding → Tabs → **Offer Undo after closing tabs**. It is off
by default.

**How do I leave full screen?**
⌃⌘F, the green button, or hold Esc. On Windows, F11, or hold Esc. Stedding does not
show Chromium’s note about it unless Settings → Stedding → Pages and menus → **Show
how to leave full screen** is on. A page that fills the screen by itself, such as a
video, always shows its own note.

**Can a tab sit indented under the page it came from?**
Yes, if you want it. A link you open in a new tab (a middle click, or ⌘-click (Ctrl+click on Windows)) opens just below its page. Settings → Stedding → Tabs → **Show tabs
under the tab that opened them** draws it a level to the right, and a link opened
from it a level further. Close the page and its tabs move up a level. Essentials and
pinned tabs take no children, so their links stay at the left. The indent is off
until you turn it on.

**Which tab do I see after I close one?**
The tab you used before it in the same Space, the one a quick ⌃⇥ (Ctrl+Tab) would
show, while its row is in view, so the list does not jump. If that row is scrolled
out of view, or you have not used another tab there since the browser started, you get the tab below it, or the one above when nothing is below. Putting a tab to sleep, and ⌘W on a
pinned tab, land on that same tab. When a Space’s last tab closes, it shows the
essential you used there last, or the first essential if you have not used one. With
no essential, it opens a new tab.

**Can I be signed into the same site twice?**
Yes. Right-click a Space chip and turn on **Independent session**. That Space keeps
its own cookies and site data, so another Space can use a different account. The
essentials you add there are its own and use its session. Extensions, history and
passwords stay shared. **Clear Independent Session** on the same menu signs that
Space out of everything. Settings → Stedding → Spaces → **Give every new Space its
own session** does it for every Space you add, and asks whether to turn it on for
the Spaces you already have.

**Is there sync? Can I sync without an account?**
There is no account. Settings → Stedding → Sync and import → **Sync through a
folder** keeps your Spaces, pins, pinned folders and essentials the same on your
computers, through a folder you choose: one your own sync app keeps (iCloud,
Dropbox, Syncthing and the like) or a shared drive. A folder in your home that no
known sync app keeps gets a note that nothing seems to sync it. The file still
works there; your tool has to move it. Stedding has no server and sends nothing.
Open tabs, history, passwords and sign-ins are not in the file. You can also export
a Space (**Export Space…**) and import that file on the other computer.

**Do my extensions work?**
Yes. It is Chromium. Extensions install from the Chrome Web Store. ⌘E (Ctrl+Alt+E
on Windows) runs one from the keyboard: hold the keys and press E again to choose,
then let go to run it. The command bar’s actions mode lists them too, including when
the address row is hidden.

**Does uBlock Origin work?**
uBlock Origin Lite does; it installs from the Chrome Web Store. The full uBlock
Origin is a Manifest V2 extension, and Chromium turns those off. Stedding leaves
that as Chromium has it: turning them back on would be one more patch that any
Chromium update could break. Stedding also has a blocker of its own, off until you
turn it on in Settings › Stedding › Privacy. It blocks the requests EasyList and
EasyPrivacy name.

**Does Netflix play?**
Not yet. Netflix, Disney+, Prime Video and Spotify’s web player need Widevine.
Stedding does not have that licence yet (`S-270` in [BACKLOG.md](../BACKLOG.md)).
Video that is not DRM-protected, such as YouTube, plays.

**Can I switch Spaces with the mouse?**
Yes. Over the sidebar or its icons, scroll sideways: a two-finger swipe on a
touchpad, a mouse’s tilting wheel, or Shift with the wheel. On Windows, Ctrl with
the wheel over the sidebar does it too. Scrolling up and down still scrolls the
tabs ([SHORTCUTS.md](SHORTCUTS.md)).

**Can I change a keyboard shortcut?**
Yes. Settings → Stedding → Shortcuts. Press Add on a command’s row and press the
keys. If another command has them, the row says which, and Replace moves them. A
switch turns a command’s keys off, and Reset puts its own keys back. Your shortcuts
apply to every profile and window on the computer, including private windows. A page
you installed as an app on the Mac keeps the original keys.

**Why does ⌃1 switch desktops instead of Spaces?**
With a second desktop, macOS Mission Control takes ⌃1–⌃9 before the browser sees
them. Settings → Stedding → Shortcuts → **Number keys for the rows and the Spaces**
can put the Spaces on ⌘1–⌘9 instead. The Spaces menu keeps every command reachable
([SHORTCUTS.md](SHORTCUTS.md)).

**How do I put two pages side by side?**
Drag a tab, from the sidebar or the tab strip, onto the page you are looking at.
The left or right half lights in the Space’s colour. Let go, and the two pages share
the window, the one you dragged on that half. ⌃⌘N (Alt+Shift+N) splits the current
tab with a new one. A tab’s right-click menu has **New Split View with Current Tab**.

**A link from another app opened in a small window. How do I keep it?**
When Stedding is your default browser, a link from another app opens in a little
window, to read and close. **Open in Stedding**, ⌘O (Ctrl+O on Windows), or the
page’s right-click menu moves the page into a tab of your window, without reloading
it. ⇧⌘O (Ctrl+Shift+O) puts it in a split with the tab on screen, or in a tab of its own when that tab is already split, pinned, or outside the active Space. Settings → Stedding → Peek and
little windows turns little windows off. On Windows the little window keeps Windows’
own title bar.

**Why does ⌥⌘N open Arc?**
While Arc runs it takes ⌥⌘N from every app for Little Arc. ⌥⌘N still splits in
Stedding when Arc is not running. ⌃⌘N splits either way, and so does the tab menu’s
**New Split View with Current Tab**.

**How do I get Chromium’s full tab menu back?**
Settings → Stedding → Pages and menus → turn off **Short context menus**.

## Privacy

**Does it send anything to Google, or to you?**
No telemetry, crash reports, experiments or identifiers, and no Google sign-in.
Chromium itself still contacts Google for component updates, Safe Browsing lists and
network time. The Safe Browsing requests carry no API key and are refused, so Safe
Browsing’s warning pages are not active yet (`S-75`). The Web Store is contacted
only when you install or update an extension. Every connection is listed in
[PRIVACY.md](PRIVACY.md). Anything else is a bug.

**What is on by default?**
Third-party cookies blocked, HTTPS-First, Global Privacy Control, quiet permission
prompts, Chromium’s ad-measurement APIs off, search suggestions off, and DuckDuckGo
until you choose an engine. Most are switches in Settings → Stedding → Privacy.

**Where is my data?**
On your own computer: `~/Library/Application Support/Stedding` on macOS, and
`%LOCALAPPDATA%\Stedding\User Data` on Windows. The project runs no server that
keeps a copy, so back it up as you would any other files.

**Does the hover card keep pictures of my tabs?**
Only in memory. Hovering a tab that is not on screen shows a picture of its page as
you last saw it. The picture is not written to disk or sent, and it goes when the
tab closes or the browser quits. Settings → Appearance → **Show tab preview images**
turns the pictures off.

## Contributing

**How can I help?**
Use a beta for a day and open an issue for each thing that is worse than what you
use now. See [CONTRIBUTING.md](../CONTRIBUTING.md).

**I found a security problem.**
Use private vulnerability reporting on the repository’s Security tab
([SECURITY.md](../SECURITY.md)), not a public issue. Reports are handled as a best
effort.

**Where does a new contributor start?**
[AGENTS.md](../AGENTS.md), then [HANDOFF.md](HANDOFF.md).
