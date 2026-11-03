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
# ground, and the first frame is the picture shown before it plays. It ends on the end card
# as one still frame, lossless, held for END_HOLD_MS: the cut dissolves into the card, draws
# its mark over a moving glow and fades out, and lossy WebP turned all three into blocks and
# bands (the owner, 2026-11-03). The card is a whole frame that replaces the picture, not
# one blended over it: img2webp writes each frame as what changed, over the frame before,
# and the earlier shots' lossy leftovers showed through the card's dark ground. So the
# shots are made with img2webp and the file is assembled again with webpmux, the card added
# with blending off. The still is taken from the cut's CRF 16 master
# (tour-ReelWide-master.mp4, tour-ReelWideLight-master.mp4) when it is there. The times are
# the 2026-11-03 cut's: the night shot is clean to NIGHT_END, the card still at END_FRAME.
#
# Needs ffmpeg, img2webp, cwebp and webpmux (brew install ffmpeg webp). Both run at the lowest priority, so
# the Mac stays usable meanwhile.

set -euo pipefail

FFMPEG="${FFMPEG:-ffmpeg}"
FFPROBE="${FFPROBE:-ffprobe}"
IMG2WEBP="${IMG2WEBP:-img2webp}"
CWEBP="${CWEBP:-cwebp}"
WEBPMUX="${WEBPMUX:-webpmux}"
NIGHT_END="${NIGHT_END:-47.73}"
END_FRAME="${END_FRAME:-50.0}"
END_HOLD_MS="${END_HOLD_MS:-3000}"
[ $# -eq 2 ] || { echo "usage: $0 <tour-video> <out>" >&2; exit 2; }
VIDEO="$1"
OUT="$2"
mkdir -p "$OUT"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

# <shots> <card> <out>: <shots>' frames as they are, each with its own offset, duration and
# blending, then <card> for END_HOLD_MS over the whole canvas, not blended.
with_card() {
  local shots="$1" card="$2" out="$3" number x y duration dispose blend rest
  local args=() i=0 mode
  rm -rf "$WORK/split"
  mkdir -p "$WORK/split"
  # webpmux -info's rows: number, width, height, alpha, x, y, duration, dispose, blend, ...
  while read -r number _ _ _ x y duration dispose blend rest; do
    case "$number" in [0-9]*:) ;; *) continue ;; esac
    i=$((i + 1))
    "$WEBPMUX" -get frame "$i" "$shots" -o "$WORK/split/$i.webp" >/dev/null 2>&1
    mode="+b"
    [ "$blend" = yes ] || mode="-b"
    [ "$dispose" = none ] || mode="+1$mode"
    [ "$dispose" != none ] || mode="+0$mode"
    args+=(-frame "$WORK/split/$i.webp" "+$duration+$x+$y$mode")
  done < <("$WEBPMUX" -info "$shots")
  args+=(-frame "$card" "+$END_HOLD_MS+0+0+0-b")
  nice -n 19 "$WEBPMUX" "${args[@]}" -loop 0 -o "$out" >/dev/null 2>&1
}

# <name> <budget MB> <file> <master> <start>: the file from <start> to NIGHT_END, then the
# end card from <master> held still, as one animation.
animate() {
  local name="$1" mb="$2" file="$3" master="$4" start="$5" step fps width quality size
  for step in 15:1200:70 15:1200:60 12:1100:60; do
    IFS=: read -r fps width quality <<<"$step"
    rm -rf "$WORK/frames"
    mkdir -p "$WORK/frames"
    nice -n 19 "$FFMPEG" -nostdin -y -hide_banner -v error -ss "$start" -to "$NIGHT_END" \
      -i "$file" -vf "fps=$fps,scale=$width:-2:flags=lanczos" "$WORK/frames/f%05d.png"
    nice -n 19 "$FFMPEG" -nostdin -y -hide_banner -v error -ss "$END_FRAME" -i "$master" \
      -frames:v 1 -vf "scale=$width:-2:flags=lanczos" "$WORK/frames/z-end.png"
    (cd "$WORK/frames" &&
      nice -n 19 "$IMG2WEBP" -loop 0 -lossy -q "$quality" -m 4 -d $((1000 / fps)) \
        f*.png -o "$WORK/shots.webp" >/dev/null 2>&1)
    nice -n 19 "$CWEBP" -quiet -lossless -exact "$WORK/frames/z-end.png" -o "$WORK/end.webp"
    with_card "$WORK/shots.webp" "$WORK/end.webp" "$OUT/$name.webp"
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
master() {
  local wanted="$VIDEO/$1"
  if [ -f "$wanted" ]; then echo "$wanted"; else echo "$2"; fi
}
animate demo 8 "$light" "$(master tour-ReelWideLight-master.mp4 "$light")" 0.35
animate demo-dark 8 "$dark" "$(master tour-ReelWide-master.mp4 "$dark")" 0.35
