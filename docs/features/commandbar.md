# Feature: Command bar

Status: **K1–K7 built and tested**.
Owner docs: `docs/PRODUCT.md` ("Command bar"). Patch: `0005`.

⌘T opens a bar over the page. It lists open tabs from every Space, then the omnibox's own
suggestions; typing a URL opens it, anything else searches with the default engine.

## Behaviours

| Id | Behaviour | Test | State |
|---|---|---|---|
| K1 | ⌘T opens the bar; Escape or a click outside closes it. | `CommandBarViewTest.*`; live | built |
| K2 | Tabs from every Space are listed, with the Space named when it is not the active one; choosing one switches Space and activates it (spaces B13). | `CommandBarViewTest.ChoosingATabInAnotherSpaceSwitchesToIt` | built |
| K3 | Typed text is classified the way the address bar classifies it: "example.com" opens, "dfsfsfsdfdsfcvv3233" searches. | `CommandBarViewTest.TypedTextWithoutAClassifierBecomesASearch` (fallback); live on the classifier | built |
| K4 | Below the tabs, the omnibox providers' suggestions (history, bookmarks, search suggestions) appear as they arrive, labelled Search / History / Bookmark / Open. | live | built |
| K5 | ↑/↓ move the chosen row; Enter takes it (or the typed text when it is the chosen row). | live | built |
| K6 | The bar takes the theme's dialog colours with a quiet text-tinted highlight. | capture | built |
| K7 | The "Open"/"Search" row always shows what Enter does with the typed text. | live | built |
