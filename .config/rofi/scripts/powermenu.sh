#!/usr/bin/env bash
# ~/.config/rofi/scripts/powermenu.sh

uptime_str=$(uptime -p | sed 's/up //')

options="⏻  Shutdown\n󰜉  Reboot\n󰌾  Lock\n󰍃  Logout\n⏾  Suspend"

selected=$(echo -e "$options" | rofi -dmenu -i -p "Uptime: $uptime_str" \
  -theme ~/.config/rofi/catppuccin-mocha.rasi)

case "$selected" in
*Shutdown*)
  systemctl poweroff
  ;;
*Reboot*)
  systemctl reboot
  ;;
*Lock*)
  hyprlock
  ;;
*Logout*)
  loginctl terminate-user $USER
  ;;
*Suspend*)
  systemctl suspend
  ;;
esac
