#!/usr/bin/env python3
"""Turn docs/readme-draft.md into README.md.

    tooling/readme/promote-readme.py            check only: says what blocks it
    tooling/readme/promote-readme.py --write    writes README.md when nothing does

The draft sits in docs/, so its links are written from there and
tooling/check-repo checks them where they stand. This rewrites every relative
target -- Markdown links and images, and the src, srcset and href of HTML tags
-- from docs/ to the repository root, drops the draft's notes (the HTML comment
that opens with "draft notes"), and refuses while

  - a line still carries a confirm-when-built marker: a feature of the round
    not yet confirmed built on the release the README will describe;
  - a target does not exist, pictures included: the media come from
    tooling/readme/capture-stills.sh and record-demo.sh and are copied into
    docs/images/readme/ by hand, after a look at each;
  - the README's animation (docs/images/readme/demo.gif, or demo.webp and
    demo-dark.webp, which tooling/readme/make-animation.sh makes) is over
    8 MB.

Code blocks and inline code are left as they are.
"""

from __future__ import annotations

import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
DRAFT = os.path.join(ROOT, "docs", "readme-draft.md")
README = os.path.join(ROOT, "README.md")
GIF_BUDGET = 8 * 1024 * 1024

CODE = re.compile(r"```.*?```|`[^`\n]*`", re.DOTALL)
NOTES = re.compile(r"<!--\s*draft notes.*?-->\n*", re.DOTALL)
MARKER = re.compile(r"<!--\s*confirm-when-built\b[^>]*-->")
MD_TARGET = re.compile(r"(\]\()([^)\s]+)(\))")
HTML_TARGET = re.compile(r"\b(src|srcset|href)=\"([^\"]+)\"")
EXTERNAL = ("http://", "https://", "mailto:", "#")


def rewrite(target: str, missing: list[str]) -> str:
    if target.startswith(EXTERNAL):
        return target
    path, hashmark, fragment = target.partition("#")
    moved = os.path.normpath(os.path.join("docs", path)).replace(os.sep, "/")
    if path.endswith("/"):
        moved += "/"
    if not os.path.exists(os.path.join(ROOT, moved)):
        missing.append(moved)
    return moved + hashmark + fragment


def rewrite_srcset(value: str, missing: list[str]) -> str:
    parts = []
    for candidate in value.split(","):
        words = candidate.split()
        if words:
            words[0] = rewrite(words[0], missing)
        parts.append(" ".join(words))
    return ", ".join(parts)


def promote(text: str, missing: list[str]) -> str:
    def prose(chunk: str) -> str:
        chunk = MD_TARGET.sub(lambda m: m.group(1) + rewrite(m.group(2), missing) + m.group(3), chunk)

        def html(m: re.Match) -> str:
            if m.group(1) == "srcset":
                return '%s="%s"' % (m.group(1), rewrite_srcset(m.group(2), missing))
            return '%s="%s"' % (m.group(1), rewrite(m.group(2), missing))
        return HTML_TARGET.sub(html, chunk)

    out, last = [], 0
    for m in CODE.finditer(text):
        out.append(prose(text[last:m.start()]))
        out.append(m.group(0))
        last = m.end()
    out.append(prose(text[last:]))
    return "".join(out)


def main(argv: list[str]) -> int:
    write = argv[1:] == ["--write"]
    if argv[1:] not in ([], ["--write"]):
        print(__doc__.strip(), file=sys.stderr)
        return 2
    with open(DRAFT, encoding="utf-8") as handle:
        draft = handle.read()
    blocks = []
    for number, line in enumerate(draft.splitlines(), 1):
        if MARKER.search(line):
            blocks.append("docs/readme-draft.md:%d: not yet confirmed: %s"
                          % (number, MARKER.search(line).group(0)))
    missing: list[str] = []
    readme = promote(NOTES.sub("", draft, count=1), missing)
    for target in sorted(set(missing)):
        blocks.append("missing: %s" % target)
    for name in ("demo.gif", "demo.webp", "demo-dark.webp"):
        animation = os.path.join(ROOT, "docs", "images", "readme", name)
        if (os.path.exists(animation) and
                os.path.getsize(animation) > GIF_BUDGET):
            blocks.append("docs/images/readme/%s is %.1f MB, over 8 MB"
                          % (name, os.path.getsize(animation) / 1048576))
    if blocks:
        print("\n".join(blocks))
        print("README.md not written: %d thing(s) above block it" % len(blocks))
        return 1
    if not write:
        print("nothing blocks the promotion; run with --write to replace README.md")
        return 0
    with open(README, "w", encoding="utf-8") as handle:
        handle.write(readme)
    print("README.md written from docs/readme-draft.md; check it with tooling/check-repo links,"
          " then delete the draft")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
