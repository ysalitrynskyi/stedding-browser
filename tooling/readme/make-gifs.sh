#!/usr/bin/env bash
# The README's animations, cut from a release's window recordings.
#
# Usage: tooling/readme/make-gifs.sh <takes> <out>
#
# <takes> holds the recordings of 2026-11-03 (0.4.0 beta 7): take-day-2x.mp4 and
# take-night-2x.mp4, 2800 x 1760 at 30 fps, each with a .timeline.txt naming its scenes'
# times. The cuts below are seconds in those files. <out> gets demo.gif and the clips, each
# at most the size the README keeps (8 MB for demo.gif, which promote-readme.py checks; 3 MB
# for a clip): too big at 12 fps and 1200 px, it is made again smaller, as
# record-demo.sh does. Copy the ones that pass a look into docs/images/readme/.
#
# ffmpeg runs at the lowest priority, so the Mac stays usable meanwhile. Every frame is
# kept at a steady rate: dropping the repeated ones (record-demo.sh's mpdecimate) left a
# scene that holds still, the site panel's, two frames and 0.7 s long.

set -euo pipefail

FFMPEG="${FFMPEG:-ffmpeg}"
[ $# -eq 2 ] || { echo "usage: $0 <takes> <out>" >&2; exit 2; }
TAKES="$1"
OUT="$2"
mkdir -p "$OUT"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

# <name> <budget MB> <take> <start> <end> [<start> <end> ...]: the scenes in order, cut
# where they join, as one GIF.
gif() {
  local name="$1" mb="$2" take="$TAKES/$3" step fps width size
  shift 3
  local parts="" labels="" n=0
  while [ $# -gt 0 ]; do
    parts="${parts}[0:v]trim=$1:$2,setpts=PTS-STARTPTS[s${n}];"
    labels="${labels}[s${n}]"
    n=$((n + 1))
    shift 2
  done
  for step in 12:1200 10:1100 8:1000; do
    fps="${step%%:*}"
    width="${step#*:}"
    nice -n 19 "$FFMPEG" -nostdin -y -hide_banner -v error -i "$take" \
      -filter_complex "${parts}${labels}concat=n=$n:v=1:a=0,fps=$fps,scale=$width:-2:flags=lanczos,palettegen=max_colors=256:stats_mode=full" \
      -frames:v 1 -update 1 "$WORK/palette.png"
    nice -n 19 "$FFMPEG" -nostdin -y -hide_banner -v error -i "$take" -i "$WORK/palette.png" \
      -filter_complex "${parts}${labels}concat=n=$n:v=1:a=0,fps=$fps,scale=$width:-2:flags=lanczos[x];[x][1:v]paletteuse=dither=bayer:bayer_scale=4:diff_mode=rectangle" \
      -loop 0 "$OUT/$name.gif"
    size="$(stat -f %z "$OUT/$name.gif")"
    echo "$name.gif: $fps fps, $width px, $((size / 1024)) KB"
    [ "$size" -gt $((mb * 1024 * 1024)) ] || return 0
  done
  echo "warning: $name.gif is over $mb MB even at $fps fps and $width px" >&2
}

# The top of the README: the window on the Linux kernel's GitHub page (its first frame, the
# GIF's still: not Django's green, the owner, 2026-11-03), the address row taking each
# page's colour, the command bar reaching a map in another Space, and a tab dragged onto
# the page making a split, cut before the next scene's command bar opens.
gif demo 8 take-day-2x.mp4 0.30 11.40 19.49 26.66 32.01 38.90
# The address in the sidebar, with the traffic lights, and the row back.
gif clip-address-sidebar 3 take-day-2x.mp4 107.5 117.0
# The site panel, from the button at the field's start.
gif clip-site-panel 3 take-day-2x.mp4 120.9 125.8
# Peek: the pinned mail page's order link opens on a card over the page.
gif clip-peek 3 take-day-2x.mp4 92.4 98.0
# The night look, then dark pages turning the page itself dark.
gif clip-night 3 take-night-2x.mp4 8.42 15.83
