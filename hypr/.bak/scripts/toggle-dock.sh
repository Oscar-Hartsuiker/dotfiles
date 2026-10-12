#!/bin/bash
if pgrep -f "nwg-dock-hyprland -x" >/dev/null; then
  pkill -f "nwg-dock-hyprland -x"
else
  uwsm app -- nwg-dock-hyprland -x -i 30 -mb 4 -c 'nwg-drawer' &
fi
