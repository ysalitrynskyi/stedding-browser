#!/usr/bin/env bash
# The README's animation, made from the site's tour video.
#
# Usage: tooling/readme/make-animation.sh <tour-video> <out>
#
# <tour-video> holds the tour cut, 1920 x 1080 at 30 fps, in the site's two looks:
# stedding-tour-<date>-<n>.mp4 (dark) and stedding-tour-<date>-<n>-light.mp4, every shot of
# the browser at the cut's own pace, the words beside the window (the stedding-marketing
# repository's video/TOUR.md has how it is made). <out> gets demo.webp from the light one and
# demo-dark.webp from the dark one, the README's <picture> in each look.
#
# Animated WebP, not GIF (the owner, 2026-11-03): the cut's camera moves change nearly every
# pixel of every frame, and the 51 s tour was 23 MB as a GIF at 1200 px and still 11 MB at
# 900 px and 8 fps; as WebP it is under 8 MB at 1200 px and 15 fps. GitHub shows it as it
# shows a GIF. Each file is at most 8 MB, which promote-readme.py checks: too big, it is
# made again at a lower quality, then smaller. Copy them into docs/images/readme/ once they
# pass a look.
#
# The animation starts 0.35 s in, on the first shot: the cut's own first frame is its empty
# ground, and the first frame is the picture shown before it plays.
#
# Needs ffmpeg and img2webp (brew install ffmpeg webp). Both run at the lowest priority, so
# the Mac stays usable meanwhile.

set -euo pipefail

FFMPEG="${FFMPEG:-ffmpeg}"
FFPROBE="${FFPROBE:-ffprobe}"
IMG2WEBP="${IMG2WEBP:-img2webp}"
[ $# -eq 2 ] || { echo "usage: $0 <tour-video> <out>" >&2; exit 2; }
VIDEO="$1"
OUT="$2"
mkdir -p "$OUT"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

# <name> <budget MB> <file> <start>: the file from <start> to its end, as one animation.
animate() {
  local name="$1" mb="$2" file="$3" start="$4" step fps width quality size
  for step in 15:1200:70 15:1200:60 12:1100:60; do
    IFS=: read -r fps width quality <<<"$step"
    rm -rf "$WORK/frames"
    mkdir -p "$WORK/frames"
    nice -n 19 "$FFMPEG" -nostdin -y -hide_banner -v error -ss "$start" -i "$file" \
      -vf "fps=$fps,scale=$width:-2:flags=lanczos" "$WORK/frames/f%05d.png"
    (cd "$WORK/frames" &&
      nice -n 19 "$IMG2WEBP" -loop 0 -lossy -q "$quality" -m 4 -d $((1000 / fps)) \
        f*.png -o "$OUT/$name.webp" >/dev/null 2>&1)
    size="$(stat -f %z "$OUT/$name.webp")"
    echo "$name.webp: $fps fps, $width px, quality $quality, $((size / 1024)) KB"
    [ "$size" -gt $((mb * 1024 * 1024)) ] || return 0
  done
  echo "warning: $name.webp is over $mb MB even at $fps fps, $width px and quality $quality" >&2
}

dark="$(find "$VIDEO" -maxdepth 1 -name 'stedding-tour-*.mp4' ! -name '*-light*' ! -name '*-vertical*' | sort | tail -1)"
light="${dark%.mp4}-light.mp4"
[ -f "$dark" ] && [ -f "$light" ] || { echo "no tour cut and its light look in $VIDEO" >&2; exit 1; }
echo "from $(basename "$dark"), $("$FFPROBE" -v error -show_entries format=duration -of csv=p=0 "$dark") s"
animate demo 8 "$light" 0.35
animate demo-dark 8 "$dark" 0.35
