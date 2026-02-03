#!/usr/bin/env bash

dracula_battery="$HOME/.tmux/plugins/tmux/scripts/battery.sh"
raw="$($dracula_battery 2>/dev/null)"

# Pull percent digits
pct="$(printf '%s' "$raw" | tr -dc '0-9')"

# Charging detection (best-effort)
charging=0
printf '%s' "$raw" | grep -qiE 'AC|Charging' && charging=1

# Fallback if parsing fails
if [ -z "$pct" ]; then
  printf '%s' "$raw"
  exit 0
fi

# Choose icon by percentage (your emoji scheme)
if [ "$pct" -ge 90 ]; then
  icon="🔋"
elif [ "$pct" -ge 65 ]; then
  icon="🔋"
elif [ "$pct" -ge 40 ]; then
  icon="🔌"
elif [ "$pct" -ge 15 ]; then
  icon="🪫"
else
  icon="🪫"
fi

# Charging overrides
if [ "$charging" -eq 1 ]; then
  icon=""
fi

# Print a *clean* percent (no hearts or other symbols)
printf '%s %s%%' "$icon" "$pct"
