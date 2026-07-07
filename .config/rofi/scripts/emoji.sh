#!/usr/bin/env bash
# rofi-picker.sh — Unified emoji and nerd icon picker

# 1. We combine 'emoji' and 'nerdy' engines into a single combi mode
# 2. We set 'combi' as the active view
# 3. We hide the default [emoji] or [nerdy] text prefix tags to keep the grid perfectly clean
selected=$(rofi \
  -modi "combi,emoji,nerdy" \
  -show combi \
  -combi-modi "emoji,nerdy" \
  -combi-hide-mode-prefix \
  -emoji-format '{emoji}' \
  -theme ~/.config/rofi/emoji.rasi)

# Exit if nothing was selected (Esc pressed)
[ -z "$selected" ] && exit 0

# Copy selection cleanly to your Wayland clipboard using uwsm environment rules
printf '%s' "$selected" | wl-copy

# Fire desktop notification
notify-send "Icon copied" "$selected" -t 1500
