# Feature: Motion

Status: **O1–O3 planned** (round 6, `docs/ROUND6-PLAN.md` R6-08).
Owner docs: `docs/QUALITY.md`. Patch: TBD.

One helper decides whether Stedding animates: `stedding::ShouldAnimate()` is false when
macOS Reduce Motion is on or the preference `stedding.ui.animate` is off. Every Stedding
animation is gated by it, and its spec row says so.

## Behaviours

| Id | Behaviour | Test | State |
|---|---|---|---|
| O1 | `stedding::ShouldAnimate()` is false when `gfx::Animation::PrefersReducedMotion()` or the preference is off; every Stedding animation (the toast, the sidebar's expand-on-hover, later the ⌃⇥ strip fade and the ⌘-badge fade) is gated by it. | `MotionTest.*` on the helper under both inputs | built |
| O2 | Upstream's expand-on-hover animation, hover-card fade and strip collapse take the same gate in the Stedding window. | a capture parameter `SteddingArcStyleWindow:reduce_motion/true` proves the still path (two shots 80 ms apart identical) | partial · the collapse and the toast show no intermediate frame at 50–130 ms sampling in either mode, so the two-shot capture cannot tell the gate; the gate itself is `MotionTest.*` and the call sites in `browser_animation_controller.cc`, `tab_hover_card_controller.cc`, `toast_view.cc` |
| O3 | Setting off stills the browser regardless of macOS; on follows macOS Reduce Motion. | `SteddingPrefsTest` default; live toggle | built |

## Running the tests

```bash
tooling/dev test motion
```
