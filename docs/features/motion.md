# Feature: Motion

Status: **O1–O8 built.** `MotionFramesTest` is a browser test. A Windows run of it is not recorded.
Owner: `docs/ROADMAP.md` ("The quality bar"). The gate is `stedding::ShouldAnimate` (patch 0017).

`stedding::ShouldAnimate()` is false when the system asks for reduced motion, when `stedding.ui.animate` is off, or when a capture sets `reduce_motion`. Every Stedding animation asks it.

## Behaviours

| Id | Behaviour | Test | State |
|---|---|---|---|
| O1 | `stedding::ShouldAnimate()` is false when `gfx::Animation::PrefersReducedMotion()` is set or `stedding.ui.animate` is off. A null prefs pointer follows the system only. The toast, the sidebar's width and hover, and the recent-tabs strip are gated by it, and so is each later Stedding animation whose row says so. The hover card follows the system and the capture parameter only (O2). | `MotionTest.PreferenceOffStillsIt`, `MotionTest.SystemReduceMotionStillsIt` | built |
| O2 | In the Stedding window, upstream's expand-on-hover and the strip collapse take this gate. The hover-card fade follows the system and the capture parameter. The capture parameter `reduce_motion` forces the still path. | `MotionTest.CaptureParameterStillsIt` | built |
| O3 | The preference off stills Stedding's motion whatever the system says. On, it follows the system: Reduce Motion on the Mac, animation effects off on Windows. The default is on. The settings row is "Animate the sidebar and overlays". | `MotionTest.PreferenceOffStillsIt`, `MotionTest.SystemReduceMotionStillsIt`, `SteddingPrefsTest.EveryPreferenceRegistersWithItsDefault` | built |
| O4 | Stedding's animations can be measured frame by frame in a real window: for each frame the compositor makes, how many views the UI thread laid out and painted, how long layout, paint and the main frame took, and how many frames were begun and presented. The command bar, the update pill and the split drop highlight draw at once. | browser: `MotionFramesTest.SidebarCollapseAndExpand`, `MotionFramesTest.CommandBarOpens` | built |
| O5 | A width animation lays out the views it moves and not the ones it hides. A row's rename field and its badges are left out of the row's layout list. The Space title row's rename field keeps no bounds while hidden. Of the hidden text fields, at most the switcher's is laid out, once a frame: its fill layout sizes that field with its chips. | browser: `MotionFramesTest.SidebarCollapseAndExpand`, `MotionFramesTest.RailHoverOverlay` | built |
| O6 | In the Stedding window the sidebar's collapse and expand, and the rail's hover overlay, ease out (`gfx::Tween::EASE_OUT`) over Chromium's times: 350 ms to collapse and 400 ms to expand on the Mac, 250 ms to open the hover overlay and 200 ms to close it. Nothing moves when `ShouldAnimate()` is false (O2). | browser: `MotionFramesTest.SidebarMotionsEaseOut` | built |
| O7 | A Space switch keeps the Space being left (spaces B32) as a recording of what its rows painted. The compositor rasters that recording with its other layers. The switch does not draw a bitmap of the list on the UI thread. | browser: `MotionFramesTest.TheSpaceLeftIsARecordingOfItsRows`, `MotionFramesTest.SpaceSlide` | built |
| O8 | The omnibox's hidden popups (the results dropdown and the AI mode popup) follow a moving location bar once its bounds have stayed put for 200 ms, not at every frame. A sidebar collapse, a window resize or a full-screen change no longer moves those hidden windows and lays out their hidden pages on every frame. A popup opened before that update is placed and sized from the location bar as it is then, so it opens at the field. Each hidden popup takes a new place, its origin and its width, at most once per collapse or expand; its height follows its page's answer to a layout, which can land at any time (S-366). | browser: `MotionFramesTest.HiddenOmniboxPopupsFollowTheSidebarOnceAMotion`, `MotionFramesTest.TheOmniboxDropdownOpensAtTheFieldAfterTheWindowChanges` | built |

## Running the tests

```bash
tooling/dev test motion
tooling/dev test browser 'MotionFramesTest.*'
```
