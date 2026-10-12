#!/usr/bin/env bash

while true; do
  active_addr=$(hyprctl activewindow -j | jq -r '.address')
  data=$(hyprctl clients -j | jq -c --arg addr "$active_addr" '
    ([.[] | select(.address == $addr) | .grouped[]]) as $addrs
    | [.[] | select(.address as $a | $addrs | index($a)) | {title: .title, address: .address}]
  ')

  count=$(echo "$data" | jq 'length')
  if [ "$count" -le 1 ]; then
    exit 0
  fi

  selection=$(echo "$data" | jq -r '.[].title' | rofi -dmenu -i -p "Group windows " -format 'i' -kb-custom-1 "Alt+Return")
  retval=$?

  if [ -z "$selection" ]; then
    exit 0
  fi

  target=$(echo "$data" | jq -r ".[$selection].address")

  if [ "$retval" -eq 10 ]; then
    hyprctl dispatch "hl.dsp.window.close({ window = \"address:$target\" })"
    sleep 0.1
    continue
  else
    hyprctl dispatch "hl.dsp.focus({ window = \"address:$target\" })"
    exit 0
  fi
done
