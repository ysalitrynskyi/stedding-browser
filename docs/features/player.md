# Feature: Mini player

Status: **Mp1–Mp4 planned**. Owner docs: `docs/PRODUCT.md` §9. Patch: none yet.

Picture-in-picture is a child of the page card, not Chromium's always-on-top
overlay window. No model.

## Behaviours

| Id | Behaviour | Test | State |
|---|---|---|---|
| Mp1 | PiP is `MiniPlayerView`, clipped to the card. Chromium's `VideoOverlayWindowViews` is not created in a Stedding window. | `MiniPlayerTest.UsesTheCardHostNotTheOverlayWindow` | planned |
| Mp2 | Leaving a tab that is playing unmuted video enters Mp1. A muted tab does not auto-pop. | `MiniPlayerTest.LeavingAPlayingVideoPopsOut` | planned |
| Mp3 | A non-active unmuted audio tab shows a 44 DIP strip when no video player is up. | `MiniPlayerTest.BackgroundAudioShowsTheStrip` | planned |
| Mp4 | Close hides the player. Back-to-tab activates the source tab and its Space. Drag stays inside the card. One player per window. | `MiniPlayerTest.ReturnActivatesTheSourceTab` | planned |
