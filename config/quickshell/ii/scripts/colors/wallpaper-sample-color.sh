#!/usr/bin/env bash
# Samples dominant color for wallpaper sorting (largest bin after resize + quantize).
# Falls back to 1×1 mean if histogram parsing fails. Outputs: "<mtime_sec> <r> <g> <b>" (0-255).
set -euo pipefail
f="${1:-}"
[[ -n "$f" && -f "$f" ]] || exit 1

mtime=$(stat -c %Y "$f" 2>/dev/null || stat -f %m "$f" 2>/dev/null || echo 0)

mean_rgb_from_hex() {
  local hex_raw h
  hex_raw=$(magick "$f" +profile '*' -alpha off -colorspace sRGB -scale '1x1!' -depth 8 -format '%[hex:p{0,0}]' info: 2>/dev/null) || return 1
  [[ -n "$hex_raw" ]] || return 1
  h="${hex_raw#\#}"
  if ((${#h} >= 8)); then
    h="${h:0:6}"
  elif ((${#h} > 6)); then
    h="${h:0:6}"
  fi
  [[ ${#h} -eq 6 ]] || return 1
  r=$((16#${h:0:2}))
  g=$((16#${h:2:2}))
  b=$((16#${h:4:2}))
  echo "$r $g $b"
}

# Dominant = max-count color after modest resize + palette reduction (main color, not muddy average).
dominant_rgb() {
  local hist max cnt rr gg bb line
  hist=$(magick "$f" +profile '*' -alpha off -colorspace sRGB -resize '192x192>' \
    -colors 16 +dither -depth 8 -format "%c" histogram:info: 2>/dev/null) || return 1
  [[ -n "$hist" ]] || return 1
  max=0
  rr=0
  gg=0
  bb=0
  while IFS= read -r line || [[ -n "$line" ]]; do
    [[ -z "$line" ]] && continue
    if [[ "$line" =~ ^[[:space:]]*([0-9]+):[[:space:]]*\(([0-9.]+),([0-9.]+),([0-9.]+)\) ]]; then
      cnt="${BASH_REMATCH[1]}"
      if ((cnt > max)); then
        max=$cnt
        rr=$(printf '%.0f' "${BASH_REMATCH[2]}")
        gg=$(printf '%.0f' "${BASH_REMATCH[3]}")
        bb=$(printf '%.0f' "${BASH_REMATCH[4]}")
        ((rr > 255)) && rr=255
        ((gg > 255)) && gg=255
        ((bb > 255)) && bb=255
        ((rr < 0)) && rr=0
        ((gg < 0)) && gg=0
        ((bb < 0)) && bb=0
      fi
    fi
  done <<< "$hist"
  ((max > 0)) || return 1
  echo "$rr $gg $bb"
}

read -r r g b <<< "$(dominant_rgb || mean_rgb_from_hex)" || exit 1
[[ "$r" =~ ^[0-9]+$ && "$g" =~ ^[0-9]+$ && "$b" =~ ^[0-9]+$ ]] || exit 1
echo "$mtime $r $g $b"
