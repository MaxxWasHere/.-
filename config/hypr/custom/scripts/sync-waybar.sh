#!/usr/bin/env bash
# Start or stop Waybar based on ~/.config/illogical-impulse/config.json bar.useWaybar
set -euo pipefail
cfg="${XDG_CONFIG_HOME:-$HOME/.config}/illogical-impulse/config.json"
use_raw="false"
if [[ -f "$cfg" ]]; then
  if command -v jq >/dev/null 2>&1; then
    use_raw="$(jq -r '.bar.useWaybar // false' "$cfg")"
  elif command -v python3 >/dev/null 2>&1; then
    use_raw="$(python3 -c 'import json,sys; p=sys.argv[1]; d=json.load(open(p)); print(d.get("bar",{}).get("useWaybar", False))' "$cfg")"
  fi
fi
if [[ "$use_raw" == "true" || "$use_raw" == "True" ]]; then
  pkill -x waybar 2>/dev/null || true
  sleep 0.15
  if command -v waybar >/dev/null 2>&1; then
    nohup waybar </dev/null >>"${XDG_CACHE_HOME:-$HOME/.cache}/waybar.log" 2>&1 &
  fi
else
  pkill -x waybar 2>/dev/null || true
fi
