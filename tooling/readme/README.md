# tooling/readme/

The README's pictures and its animation, made on a Mac from a build, the same way every time. What the animation shows is [docs/images/readme/STORYBOARD.md](../../docs/images/readme/STORYBOARD.md). The page that shows the pictures is [README.md](../../README.md). `promote-readme.py` turns `docs/readme-draft.md` into that page once nothing blocks it.

| File | What it does |
|---|---|
| `capture-stills.sh` | **(macOS)** Every still. Each one is `tooling/capture-state`: no pointer, no keys, no focus change, so it can run while someone works at the Mac. One function per picture. |
| `record-demo.sh` | **(macOS)** The animation. The fixture and the scenes go through `tooling/drive` with real input, the window is recorded, then the GIF and the MP4 are made. Also `check` (no launch), `layout`, `rehearse`, `convert`, `slideshow` and `probe`. |
| `steps/` | One steps file per scene, plus `setup` (the fixture) and `preroll` (the pages loaded before the first scene). `tooling/drive`'s language, plus `glide`, which `media.py render` turns into one eased `move`. |
| `captions.tsv` | One caption per scene and per still: the keys, then the words. |
| `arc-demo-sidebar.py` | A made-up Arc sidebar for the `welcome-import` still, written under a scratch home folder. |
| `media.py` | A seeded profile, the rendered steps, the caption strips, the window's rectangle, and the timeline that cuts the recording. |
| `common.sh` | What both scripts share: the pages, the local servers, the checks before a launch. |
| `pages/` | Two local pages, served on localhost:5173 and localhost:8797 while the scripts run. |
| `promote-readme.py` | Checks `docs/readme-draft.md` and, with `--write`, replaces `README.md`. |
| `win-stills.ps1` | **(Windows)** The Windows pictures, `win-wide` and `win-rail`, light and dark, through `tooling/win/capture.ps1`. |
| `round-corners.py` | Clears a Windows capture's corners the way Windows 11 rounds the window on screen. |

## What it needs

- macOS. The terminal needs **Screen Recording** (the window capture and the recorder) and **Accessibility** (`tooling/drive`'s input), under System Settings → Privacy and Security.
- A build in `out/release` (`tooling/dev build`), or an installed copy with `--app`. The capture params (`pin_tabs`, `folder_tabs`, `space_pin_tabs`, `drift_tabs`, `open_command_bar`) are compiled into that build. An official build leaves them out, and the pictures come out without the essentials, folders, pins or open command bar those params add.
- A `python3` with PyObjC, as `tooling/drive` and `tooling/capture-state` need.
- `ffmpeg` and `ffprobe` for the animation (`brew install ffmpeg`, or set `FFMPEG` and `FFPROBE`).
- Your own Stedding quit, or a copy of the build with its own identity passed as `--app`. Every launching mode refuses to start beside another app with the same bundle id. To run beside the owner's Stedding, copy `out/release/Stedding.app` (`ditto`), give the copy's `Info.plist` its own `CFBundleIdentifier`, `CrProductDirName` and `SUDefaultsDomain`, point `SUFeedURL` at nothing, and sign it again ad hoc (`codesign --force --deep --sign -`).
- Ports 5173 and 8797 free.

## Order of work

```bash
# 1. The stills. No input. <out> is any folder outside the repository.
tooling/readme/capture-stills.sh ~/Desktop/readme-media/stills
tooling/readme/capture-stills.sh ~/Desktop/readme-media/stills --with-new

# 2. The animation. Real input: only with the operator's yes, then hands off.
tooling/readme/record-demo.sh check    ~/Desktop/readme-media/demo
tooling/readme/record-demo.sh probe    ~/Desktop/readme-media/demo
tooling/readme/record-demo.sh layout   ~/Desktop/readme-media/demo
tooling/readme/record-demo.sh rehearse ~/Desktop/readme-media/demo
tooling/readme/record-demo.sh record   ~/Desktop/readme-media/demo
tooling/readme/record-demo.sh convert  ~/Desktop/readme-media/demo --offset -0.3

# 3. Look at every file, copy the chosen ones into docs/images/readme/, then:
tooling/readme/promote-readme.py
tooling/readme/promote-readme.py --write
```

`--with-new` on the stills also takes `dark-pages`, `local-tabs`, `isolated-space` and `web-app`. On `slideshow` it adds `isolated-space`, `local-tabs` and `dark-pages` to the crossfade (not `web-app`).

Each script writes only under the folder it is given, and refuses one inside the repository's `docs/` or `tooling/`. Pictures go into `docs/images/readme/` by hand, after a look ("Looking at a still" below). Running a step again replaces what it wrote. Do not edit these scripts, or `common.sh`, while a run is going: bash reads a running script from where it left off, and an edit shifts the text under it (a run ended in `-z: command not found`).

The site keeps its own copies of most stills, the Windows picture and the press kit's files. Its repository's README ("Screenshots and their close-ups") says which file goes where, and its close-ups are cut again after a change.

## The stills

`capture-stills.sh <out> [still ...]`. `--list` names them. `--build` chooses the output directory under `out/` (default `release`). `--scheme light` or `dark` sets the scheme for every still except `hero-dark`, which is always dark. `--keep-profiles` leaves the seeded profiles in place. `--settle S` waits S seconds for the pages before each capture (18 by default); a tab whose page is slow keeps the plain globe until its icon arrives, so look at the icons and take such a still again with a longer wait. Before each launch `capture-state` parks the pointer off the window's area once nobody has used the Mac for ten seconds, and refuses to capture while the pointer is over the window: a resting pointer leaves its hover in the picture (`docs/HANDOFF.md`, trap 136).

Each still is `<out>/<still>.png` at 1800 px wide, the size `docs/images/readme/` keeps. A window already narrower than that (a web app's) is copied as captured. The capture as taken is `<out>/raw/`, and a second window is `raw/<still>-2.png`. `<out>/captures.tsv` names the still, the file, the app version, the time, the fixture and the arguments.

| Still | The state |
|---|---|
| `hero`, `hero-dark` | The demo fixture: four essentials and a folder holding a nested one (`pin_tabs/4/folder_tabs/6`), three Spaces, light and dark |
| `spaces` | Five Spaces with their colours and icons (the `spaces` fixture, `pin_tabs/2`) |
| `command-bar` | The bar open over the page (`open_command_bar/true`) |
| `folders` | Two essentials and a nested folder (`pin_tabs/2/folder_tabs/5`) |
| `pins` | Three pinned tabs, the first wandered off to the next one's page (`space_pin_tabs/3/drift_tabs/1`) |
| `rail` | The sidebar closed to the rail (the seed's `collapsed`) |
| `private` | A private window (`--incognito`) |
| `welcome-<step>` | The welcome flow on `search`, `import`, `appearance`, `behaviour`, `default` or `keys` (`--stedding-welcome=<step>`). The dialog can be the second window |
| `dark-pages` | Dark pages on. The seed sets Chromium's `force_dark_mode_enabled`. The page is Hacker News, which has no dark theme of its own |
| `local-tabs` | The sample app and the sample API, the app's page the one the still is for |
| `isolated-space` | The `isolated` fixture: Personal, with its own session, on screen |
| `web-app` | A page in a window of its own (`--app=`). Chromium's app window stands in for an app made with the feature |

`media.py seed` writes a fresh profile: the Spaces (names, colours, icons, and a Space with its own session), the colour scheme, the rail, dark pages, the welcome flow marked as shown, and the version that last ran. The profile is passed as a second `--user-data-dir` after the one `capture-state` passes. Chromium keeps the last value of a repeated switch, so the browser runs on the seeded profile and `capture-state`'s empty one is deleted unused. Essentials, folders and pins are not in that profile. The testing params apply them about a second after the tabs exist.

`welcome-import` runs with a scratch home folder that holds the made-up Arc sidebar (`arc-demo-sidebar.py`: four Spaces, pinned tabs and folders, four essentials, on example sites). That home is handed to the browser alone through `STEDDING_LAUNCH_ENV` (`tooling/lib.sh`), so the step reads that sidebar and the dialog sits on GitHub's home page.

### Looking at a still

A capture can pass every check and still be wrong. Look at each one before it goes in:

- **No hover.** No bar along the sidebar's edge and no row lit as if the pointer were on
  it. Both come from a pointer resting over the window (trap 136).
- **Every tab's icon.** A plain globe, or a globe with a spinner or a dot, is a page still
  loading. It happens on a slow page and on a busy Mac (trap 137). Take that still again
  with `--settle 60` once the machine is quiet.
- **The corners** are transparent, not the desktop and not a solid colour.
- **The page.** No advert, banner, pop-up, cookie notice, political headline or AI
  product. Live pages change between runs: on 2026-10-28 Wikipedia showed a fundraising
  banner, MDN an advert, GitHub's home page an AI coding advert around the import dialog,
  example.com a dark theme, and Hacker News' front page politics. Hence the map, GitHub's
  trending page, the Python tutorial and one day's Hacker News front page
  (`URL_HN_DAY` in `common.sh`) in the stills.

## The Windows pictures

`docs/images/win-wide.png` (the open sidebar) and `win-rail.png` (the rail) come from the
PC's `win-release` build, which is not an official one, so the capture params work. They
show the stills' demo fixture: four essentials, a folder holding a nested one, three Spaces,
GitHub's trending page on screen, the sample app left out.

1. On the Mac, seed four profiles: `media.py seed <dir>/wide-light --fixture demo
   --version-file VERSION --scheme light`, the same for `wide-dark` with `--scheme dark`,
   and `rail-light` and `rail-dark` with `--collapsed` added. Copy them to the PC.
2. Run `win-stills.ps1 -Exe <src>\out\win-release\chrome.exe -Profiles <dir> -Out <folder>`
   in the signed-in session. Over SSH, register a one-off task with an interactive token
   (`New-ScheduledTaskPrincipal -LogonType Interactive`, `-Priority 4` in its settings),
   start it, read `<folder>\run.log` until it says `end`, and unregister the task (trap 67).
3. Clear the corners: `round-corners.py <in> <out>`. PrintWindow gives the window's full
   rectangle, and Windows 11 rounds its corners on screen with an 8 px radius, so a capture
   kept as it is shows square corners the window never has. A capture of the screen instead
   shows the desktop in them.
4. Look at each as "Looking at a still" says: no hover on a row, every icon, the corners.

A Windows page shows its scrollbar while it can scroll, as Chrome does there; the
sidebar's does not.

## The animation

`record-demo.sh <mode> <out>`. The modes, in the order you use them:

- `check` renders the steps of the chosen scenes into `<out>/steps/` and checks every line with `tooling/drive-window.py --check`, and that every scene has a caption. It launches nothing.
- `probe` records two seconds of a corner of the screen with `screencapture` and with ffmpeg, and says which produced frames. It does not start the browser, and it does not try the window recorder.
- `layout` seeds a profile, starts the local pages, waits until nobody has touched the Mac for `--idle` seconds (15 by default, at most ten minutes), and builds the fixture with `steps/setup.steps`. The pictures in `<out>/shots/` are what the coordinates in `steps/` are read from. The log calls them GUESS. Fix the numbers in the steps before a take.
- `rehearse` does the same and then runs the scenes without recording. The window at the start of each scene is in `<out>/marks/`.
- `record` does the same, recording the window from the moment it appears, then converts.
- `convert` makes the GIF and the MP4 again from the kept recording (`raw.mov`, `recording.env`, `marks/`). `--offset` shifts the cut and the captions when they run early or late. With no offset, the cut is synced on the command bar opening.
- `slideshow --stills <capture-stills out>` makes a GIF and an MP4 from the stills, each held and crossfaded, with the same captions. No browser and no input. It is the fallback when the Mac cannot be left alone.

The default scenes are `hero colour bar spaces split dark end`. `--scenes` picks others, and `end` stays last. `rail` and `local` are left out of the default so the take stays under 40 seconds. `rail` goes anywhere before `end`. `local` goes right after `colour`, where Work is on screen. `--scheme dark` records the dark scheme. `--max-mb` is the GIF's budget (default 8). `--show-clicks` draws a ring at each click, and only for the `screencapture` recorder. `--keep-profile` leaves the demo profile.

A take uses `tooling/record-window` when `swiftc` is available: the browser's window alone, never the screen ([docs/HANDOFF.md](../../docs/HANDOFF.md) trap 133). `--recorder screencapture` or `--recorder ffmpeg` records the screen instead. ffmpeg records the whole display, and convert cuts the window out. The option parser accepts `auto`, `screencapture` and `ffmpeg`.

Between the fixture and the scenes the script checks again that nobody used the Mac, as `tooling/acceptance/mac/run-mac.sh` does, and stops if someone did. Ctrl-C lets go of every key and button, quits the launched browser, and stops the recorder and the local pages. `check`, `convert` and `slideshow` start no browser and record nothing, so they also run beside your own Stedding.

The first scene's marker is a capture of the window by its id. Its transparent corners become the mask that cuts the desktop out of every frame. When the recorder is the window one, convert paints the traffic lights over the system's capture badge and keeps that picture as `raw-clean.mov`.

Outputs under `<out>`: `demo.gif` and `demo.mp4`, `timeline.txt` (each scene's start and length, the offset and how it was found), `raw.mov` (kept for `convert`; delete it when done, and `raw-clean.mov` with it), `steps/`, `marks/`, `shots/`, `logs/` and `work/` (the profile, the captions, the palette).

What to check by hand, from `layout` and `rehearse`: the coordinates in `steps/` against `shots/` and `marks/`. That is the essentials card, the two pinned rows, the folder headers, the sample app's row, the rest point, and Reading's rows (`marks/split.png`). The chips and the sidebar toggles are the acceptance runs' coordinates. The storyboard says what each scene must show.

## Promoting the README

`promote-readme.py` reads `docs/readme-draft.md`. The draft's links are written from `docs/`, so `tooling/check-repo` checks them where the draft stands, and the script rewrites them for the repository root. It drops the draft's notes (the HTML comment that opens with "draft notes"). It refuses while a line carries a `confirm-when-built` marker, while a linked file or picture is missing, or while `docs/images/readme/demo.gif` is over 8 MB. `--write` replaces `README.md`. Then run `tooling/check-repo links` and delete the draft.
