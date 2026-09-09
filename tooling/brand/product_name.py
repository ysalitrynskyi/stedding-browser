"""Rewrite the product name in Chromium's branded string tables.

Chromium's user-facing strings say "Chromium" in some seven hundred places --
"Chromium is being controlled", "Chromium PDF Document", the shortcut name,
the uninstall entry -- and they come from grit tables that a build reads as
files, never from the BRANDING file. The name reaches every one of them by
rewriting the tables in the checkout before the build, the way
tooling/apply-branding copies the icons over: a build-time transform, not a
patch, so it never conflicts on a rebase.

What is rewritten: the word "Chromium" inside message bodies of the branded
tables (chrome/app/chromium_strings.grd and its .grdp siblings, components'
and extensions' branded tables) and inside every locale's translations of
them (the .xtb files), since the name is a proper noun in every language.
What is not: the `desc=` attributes translators read, "ChromiumOS" and
"ChromiumUpdater" (different products), and anything lowercase such as
chromium.org. "The Chromium Authors" becomes "The Stedding Authors", as the
BRANDING file's copyright line already says and as the earlier one-liner did.

Usage:
  python3 tooling/brand/product_name.py <chromium-src> [--check] [--name Stedding]
"""
import argparse
import pathlib
import re
import sys

TABLES = [
    "chrome/app/chromium_strings.grd",
    "chrome/app/settings_chromium_strings.grdp",
    "components/components_chromium_strings.grd",
    "extensions/strings/extensions_chromium_strings.grdp",
]
TRANSLATION_GLOBS = [
    "chrome/app/resources/chromium_strings_*.xtb",
    "components/strings/components_chromium_strings_*.xtb",
]
KEEP = ("ChromiumOS", "ChromiumUpdater")
WORD = re.compile(r"\bChromium\b")


def rewrite_line(line: str, name: str) -> str:
    # Tag lines carry descriptions and ids; the name only lives in text lines.
    # A message's opening tag (its desc= is for translators); a translation
    # keeps its text on the tag's own line and is rewritten.
    if line.lstrip().startswith("<message"):
        return line
    out = []
    pos = 0
    for m in WORD.finditer(line):
        start = m.start()
        if any(line.startswith(k, start) for k in KEEP):
            continue
        # The About page's license line links the Chromium project by name:
        # "<name> is made possible by the Chromium open source project". The
        # subject is ours, the project is theirs; the placeholder that closes
        # the link marks it, in the English table and in every translation.
        if line.startswith('<ph name="END_LINK_CHROMIUM"', m.end()):
            continue
        out.append(line[pos:start])
        out.append(name)
        pos = m.end()
    out.append(line[pos:])
    return "".join(out)


def rewrite(text: str, name: str) -> str:
    return "".join(rewrite_line(l, name) for l in text.splitlines(keepends=True))


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("src")
    ap.add_argument("--name", default="Stedding")
    ap.add_argument("--check", action="store_true", help="report; write nothing")
    args = ap.parse_args()
    root = pathlib.Path(args.src)
    files = [root / t for t in TABLES]
    for g in TRANSLATION_GLOBS:
        files += sorted(root.glob(g))
    changed = 0
    replaced = 0
    for f in files:
        if not f.exists():
            print(f"  missing: {f.relative_to(root)}", file=sys.stderr)
            continue
        before = f.read_text(encoding="utf-8")
        after = rewrite(before, args.name)
        if after != before:
            changed += 1
            replaced += len(WORD.findall(before)) - len(WORD.findall(after))
            if not args.check:
                f.write_text(after, encoding="utf-8", newline="\n")
    verb = "would rewrite" if args.check else "rewrote"
    print(f"product name: {verb} {replaced} occurrences in {changed} of {len(files)} files")
    return 0


if __name__ == "__main__":
    sys.exit(main())
