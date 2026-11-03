# The README's animation: storyboard

Since 0.4.0 beta 7, `demo.gif` and the clips under the README's Highlights are cut from that release's window recordings by `tooling/readme/make-gifs.sh`, and `demo.mp4` is gone. What follows is the storyboard `record-demo.sh` takes its own animation from.

One animated GIF under the README's header, `docs/images/readme/demo.gif`, and `demo.mp4` of the same take. It shows what Stedding is in under 40 seconds, at a pace a person can follow, and loops without a seam. `tooling/readme/record-demo.sh` makes it from the steps in [tooling/readme/steps/](../../../tooling/readme/steps/). How to run it is [tooling/readme/README.md](../../../tooling/readme/README.md).

`timeline.txt` is a take's own length. `media.py` notes when that length is outside 25 to 40 seconds.

## The picture

| | |
|---|---|
| Window | 1400 × 880 points, the size `tooling/drive` opens, at the top left of the main display |
| Colours | Light by default. `--scheme dark` records the other one. Page colours read best against light pages, and a night gradient bands in a 256-colour GIF |
| Frame | The window, with its own rounded corners, on the brand's slate (#2F4858): a 28 px margin, then 12 px, then the caption lane, at 1400 px wide |
| Captions | A 64 px lane. The keys are #99F6E4, the words #F1F5F9, one caption per scene, with a short blank between two when the scene is long enough |
| Pointer | Visible. It glides on one eased `move` (0.3 to 0.6 s in the steps; 0.5 s when a glide gives no time) and does not jump. Clicks draw no ring. `--show-clicks` adds one only for the `screencapture` recorder |
| GIF | 15 fps at 1200 px wide, then 12 fps at 1200, 1120 and 1040 px, until the file is within 8 MB |
| MP4 | The same composed picture, 1400 px wide, 30 fps, H.264 (CRF 18, faststart) |

The pace the steps are written to:

- One idea per scene. Each scene opens on a still frame, the scene's marker.
- One thing moves at a time: the pointer, or the window.
- Typing comes in two short bursts.
- Dark pages stays on for two seconds, then goes off.

## What is in the window

The fixture is built before the recording, and none of that building is recorded. The pages are `common.sh`'s `DEMO_URLS`. `pin_tabs/4/folder_tabs/6` makes the essentials and the folder about a second after the window opens: the first four pages are pinned, and the next two are a folder whose last tab is nested. `steps/setup.steps` does the rest with keys: it files four tabs into the other Spaces, pins Django and PyPI, and names the folders with a double click on each name (folders F4).

| Space | Colour, icon | Its tabs |
|---|---|---|
| Essentials | shared | GitHub trending, Swift, this week; MDN; DuckDuckGo; Hacker News. Shown in Work and Reading. Personal's own session shows none of them (spaces B6) |
| Work | Moss, 💼 | Pinned: Django, PyPI. A folder Docs holding MDN's CSS reference and a nested folder Python with the Python tutorial. The sample app on localhost:5173. The project's repository |
| Personal | Plum, 🏠, its own session | OpenStreetMap, Lobsters |
| Reading | Clay, 📚 | NASA, Apollo 11 (Wikipedia) |

The first frame and the last are Work on the Swift trending essential, the pointer at rest (150, 720). The project's repository is a tab in the list, not the page on screen.

## Pages

Real sites that stay still, need no sign-in and show no banner, plus a local page of this repository. A page that moves on its own can take the place of the command bar when the captions are synced. A page in a split is half the window wide, so its top edge has to keep its colour at that width too. If a header has changed colour, pick another page whose top edge is one strong colour, put it in `common.sh` and in the steps, and check it in a rehearsal.

| Page | Address | Where it is | Check at rehearsal |
|---|---|---|---|
| Swift trending | github.com/trending/swift?since=weekly | The first and last frame, the first essential | The page is still, and the address row has taken its colour |
| Django | www.djangoproject.com | Work's first pin. The row turns green | The row is green |
| PyPI | pypi.org | Work's second pin. The row turns blue. Preroll clicks the top edge in case a notice is there | The row is blue, and no notice bar |
| OpenStreetMap | www.openstreetmap.org | Personal's page in the command-bar scene. Preroll closes its welcome and any promotion in the side panel | The tiles have loaded. The side panel shows only the search |
| NASA | www.nasa.gov | Reading. The split's left half, dark along the top | The row's left part is dark |
| Apollo 11 | en.wikipedia.org/wiki/Apollo_11 | Reading's page on screen. The split's right half, white | The page is white |
| Sample app | localhost:5173 (`tooling/readme/pages/sample-app/`) | A Work tab, teal across its top (#14B8A6). Its row shows the host and port at the default Comfortable density | The outline, and host:port, once the window is up |
| Sample API | localhost:8797 (`tooling/readme/pages/sample-api/`) | The `local-tabs` still only | |

## Scenes

Coordinates are window points in the steps. Read them again from a layout run's `shots/setup-*.png` and a rehearsal's `marks/` when a build moves the rows. Each scene runs from its marker to the next.

| # | Scene (`steps/`) | What the steps do | On screen | Caption |
|---|---|---|---|---|
| | `setup`, `preroll` | Cut. The fixture is built, quit and reopened. Every page a scene shows is loaded once. Back to Work and the trending essential, the pointer at rest | | |
| 1 | `hero` | Nothing. The window at rest | Work: essentials, pins, the folder, the tabs. The trending page on its card, the address row in the page's colour | Stedding: an open-source, Arc-style browser built on Chromium |
| 2 | `colour` | Glide to Django's row, click. Glide to PyPI's row, click. Back to the rest point | The page changes, and the address row with it: green, then blue | The address row takes each page's own colour |
| 3 | `bar` | ⌘T. Type "open", a beat, "street". ↓. Return | The bar lists the OpenStreetMap tab and its Space. Return slides the sidebar to Personal, its plum tint, the map, and the mark of its own session | **⌘T** Search, open a site, or jump to any tab in any Space |
| 4 | `spaces` | A beat on Personal. Glide to the third chip, click | Reading slides in, clay, its Apollo 11 page | **⌃1–⌃9** Spaces, each in its own colour, with its own cookies if you like |
| 5 | `split` | Glide to NASA's row, the one not on screen. Press, drag it level out of the sidebar onto the page's left half, hold, let go. Back to the rest point | Apollo 11 stays on screen through the drag (tabs R61, splits J10). Over the page its left half lights in clay with "Create split view". The drop puts NASA on the left and Apollo 11 on the right. The address row is dark over one and white over the other, with the window's ground over the gap (toolbar T41). The sidebar's row becomes the split's two halves | Drag a tab onto the page for split view, the address row in each page's colour |
| 6 | `dark` | ⌥⇧⌘D, two seconds, ⌥⇧⌘D | Both pages of the split go dark at once, the row with them, and come back | **⌥⇧⌘D** Every website dark at once, with no white flash |
| 7 | `end` | Glide to the first chip, click. Glide to the first essential, click. Glide to the rest point. Hold | Work slides back on the PyPI page scene 2 left there, then the first frame again. The split stays in Reading, out of sight | stedding.dev · free and open source · macOS and Windows |

The split is made in Reading, so the last frame is still the first. A split in Work would change Work's list, and the loop would show it. The dragged row is the one not on screen: a page dropped on itself makes no split (splits J13). Confirm NASA's row from `marks/split.png` before a take. The mark of a Space with its own session is on screen in scenes 3 and 4.

`rail` and `local` are written and left out of the default take, so the take stays under 40 seconds. `rail` folds the sidebar to icons and opens it again (⌘S). `local` clicks the sample app, whose row already shows its host and port in the other frames. `--scenes` puts either back. `local` belongs right after `colour`.

The recorded scenes switch Spaces with the chips, and the fixture comes back with ⌥⌘←. macOS takes ⌃1–⌃9 once a second desktop exists. The caption still names those keys.

## Left out of the animation

These are a still, a clip, or a line of the README. Folders and a wandered pin up close are too small at GIF size. The rail, the archive, little windows, apps made from pages, the Arc import, the welcome flow and private windows are the same: each would be a scene of its own past 40 seconds, and a still or a clip already shows it.

## The clips

Four short clips in the README, under Highlights. Each is one idea, made as one `tooling/drive` run on a fresh copy of the demo fixture (`steps/setup.steps`). A cut preroll loads the pages. The command bar opens and closes once to sync the recording's clock, as the demo's `bar` scene does. The clip runs from a still frame to a hold on the result.

The frame is the demo's, 1200 px wide, with no caption lane. The two sidebar clips show the window's top left 760 × 478 points at 1.5 times the size, so the rows can be read.

| File | What happens |
|---|---|
| `clip-pinned-folder.gif` | Work. The Docs folder, its nested Python folder closed, dragged by its header from under the line to between the Django and PyPI pins. The bar shows the place. The folder settles there |
| `clip-space-scroll.gif` | Work on Django. A sideways wheel notch over the sidebar four times: Personal, Reading, Personal, Work. Work comes back to its own last tab, not an essential, so the clip starts on Django and loops without a seam. Reading is on Apollo 11 |
| `clip-little-window.gif` | Reading on Apollo 11. `open -a <app> https://docs.djangoproject.com/en/stable/` from outside opens the little window, its row Django's green. A click on Open in Stedding moves it into Reading |
| `clip-pin-close.gif` | Work. Django's pin has wandered (the slash). ⌘W: the pin sleeps at home, in place, and PyPI shows. A click wakes Django on its home page |

Two things a take needs. The pointer comes to a row over no tab row it would slow on: a glide that eases out over a tab row opens that row's hover card, and the card stays up through a drag that starts next. The little window is a launch without `--window-size` and `--window-position`. `tooling/drive` passes both, and the window sizer gives them to every window, the little one included ([docs/HANDOFF.md](../../HANDOFF.md) trap 26). The session brings the main window back to the fixture's place without them.

## Real input only where nothing else shows it

Every still is taken with no input (`tooling/readme/capture-stills.sh`, through `tooling/capture-state`). So is everything in the fixture that a seed or a param can make. Motion cannot be seeded: typing in the bar, a Space sliding in, a tab dragged onto the page. Those take one driven run with the real pointer and keys. It starts only after nobody has touched the Mac for a while, and it stops if anyone does.

When the Mac cannot be left alone, `record-demo.sh slideshow` makes the GIF and the MP4 from the stills, crossfaded, with the same captions. It has no pointer and no motion. It is the fallback.

## Recording and conversion

- **Recorder.** `tooling/record-window` when `swiftc` is available: the browser's window alone, with the pointer (trap 133). `--recorder screencapture` records the window's rectangle of the screen. `--recorder ffmpeg` records the whole display, and convert cuts the window out. `record-demo.sh probe` says which of those two screen recorders produced frames. Both need the terminal's Screen Recording permission.
- **Clock.** Each scene opens with a capture of the window (`shot`). The files' times are the scene boundaries. The command bar opening in scene 3 is the largest change on screen around its marker, which gives the recorder's delay. The bar opens about 0.15 s after the marker is written. `--offset` overrides the delay. A page that moves on its own under the bar can take that place.
- **Composition.** The first marker is the window captured by its id, with transparent corners. Its alpha cuts the corners out of every frame. The window goes on the slate ground, the caption lane under it. A window recorded alone carries the system's capture badge where the traffic lights are. Convert paints the lights of an active window over it.
- **GIF.** Two passes: `palettegen` (256 colours, from every frame), then `paletteuse` with ordered (Bayer) dithering at scale 4, and only the changed rectangle of each frame redrawn. Ordered dithering puts the same pattern on the same pixels in every frame, so flat interface colour does not shimmer. `mpdecimate` drops a frame that repeats the one before, so a held state costs one frame.
- **MP4.** From the same composed take: H.264, CRF 18, faststart.

## Before a take

- The operator's yes for real input, then nobody at the Mac.
- Their own Stedding quit. The scripts refuse to start beside it. Arc and any clipboard manager quit too: each takes a chord from every app while it runs.
- With a screen recorder, Do Not Disturb on, so no notification lands on the rectangle. The window recorder does not take other windows or the desktop.
- One desktop in Mission Control is the safest. The steps avoid ⌃1–⌃9 anyway.
- The display shows at least 1400 × 880 points under the menu bar.

## Checks on the result

- `layout`: the coordinates in `steps/` match the fixture's pictures.
- `rehearse`: each frame in `marks/` is the state its scene starts from. `marks/dark.png` is the split as the drop left it.
- `demo.mp4`, watched once through: captions on their scenes, the pointer never jumps, no white flash, no banner, no link address in the corner from a resting pointer, the first and last frames the same.
- `timeline.txt`: 25 to 40 seconds. `demo.gif`: 8 MB or less.
