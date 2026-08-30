# 0003 — Base: Chromium stable, minimal patch-set fork

Status: Accepted
Date: 2026-08-30

## Context

The browser needs an engine and a fork strategy. Hard requirements: full Chrome
extension compatibility, native desktop performance, and a maintenance load one
small team can carry across Chromium's release cadence. Options considered:

- **Electron/CEF wrapper** — rejected. No real Chrome extension support, an extra
  process/runtime layer, worse performance and memory behavior. Good for apps, not
  for a browser competing with browsers.
- **Firefox base** — rejected. Different extension ecosystem (WebExtensions subset,
  no Chrome Web Store), and Zen Browser already owns the "Arc-like on Firefox" lane.
- **Hard fork of Chromium** — rejected. Diverging from upstream means owning
  security backports forever; that is how forks die.
- **Minimal patch-set fork of Chromium stable** — the Brave/Helium model: vanilla
  upstream checkout plus an ordered, documented series of patches applied on top.

## Decision

Stedding is a **minimal patch-set fork of Chromium, stable channel**. UI work lives
as high in the stack as possible (views, WebUI, top chrome) so patches stay small
and rebases stay cheap. The patch series is maintained as ordered, individually
documented patches; tracking each upstream stable release is a recurring scheduled
task, not an emergency. Details: `../ARCHITECTURE.md`.

## Consequences

- Full Chrome extension compatibility comes for free and stays free.
- Security updates are inherited from upstream at stable cadence; our job is
  rebasing the patch series, not maintaining an engine.
- Every patch is a permanent tax on every rebase — feature work must justify its
  patch-weight, and deep engine-level features are effectively out of scope.
- Chromium's build cost (checkout size, build time, toolchain) is the entry fee;
  M0 on the roadmap is reproducing a vanilla build to pay it down first.
