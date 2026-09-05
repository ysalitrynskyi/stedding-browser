# Feature: Copy link

Status: **L1–L6 planned** (round 6, `docs/ROUND6-PLAN.md` R6-04).
Owner docs: `docs/PRIVACY.md` (the tracking strip), `docs/PRODUCT.md`. Patch: TBD.

⇧⌘C copies the page's URL, ⌥⇧⌘C a Markdown link with a rich-text twin, both with
tracking parameters removed when the setting is on. Inside a peek the copy is the peek's
page (it is the page the user is looking at). The Markdown title is the page title, or
the host when the title is empty. Until the selection rule (R6-20, wave 2) lands, both
act on the active tab only.

## Behaviours

| Id | Behaviour | Test | State |
|---|---|---|---|
| L1 | ⇧⌘C copies the page URL; ⌥⌘C keeps Inspect Element (both chords mapped to `IDC_DEV_TOOLS_INSPECT` before), recorded in the shortcut reference (Z2). | `ShortcutReferenceTest.EverySteddingCommandWithAnAcceleratorIsListed` (⇧⌘C resolves to `IDC_COPY_URL` through the accelerator tables) | built |
| L2 | Tracking parameters are removed before the copy when the setting is on: `utm_*`, `fbclid`, `gclid`, `dclid`, `msclkid`, `mc_eid`, `mc_cid`, `igshid`, `_hsenc`, `_hsmi`, `mkt_tok`, `yclid`, `twclid`, `ref_src`, and `si` on youtube.com; the table lives in one file. Never applied to navigation. | `CleanLinkTest.StripsEachFamily`, `CleanLinkTest.KeepsUnknownParameters` | built |
| L3 | ⌥⇧⌘C (`IDC_STEDDING_COPY_MARKDOWN_LINK`) writes `[title](clean url)` as text and an anchor as HTML on the same pasteboard, so Slack, Notion and Docs paste a live link. | `CopyLinkTest.PlainMarkdownAndHtmlFlavours` reads the clipboard | built |
| L4 | Both appear in the tab context menu (`CommandCopyURL` exists; a Markdown sibling joins it) and the app menu; the command bar's actions mode (R6-11) lists them when it lands. | live: capture of the tab context menu and the File menu | built |
| L5 | Chromium's `ToastId::kLinkCopied` confirms; it reads "Link copied, tracking removed" when something was stripped. | live capture through `tooling/drive` | built |
| L6 | Setting off copies the URL verbatim. | `CopyLinkTest.SettingOffCopiesVerbatim` | built |

## Running the tests

```bash
tooling/dev test copy-link
```
