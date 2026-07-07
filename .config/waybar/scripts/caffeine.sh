#!/usr/bin/env zsh

if systemctl --user is-active --quiet hypridle.service; then
  echo '{"text":" 󰛊 ","class":"idle"}'
else
  echo '{"text":"  ","class":"caffeine"}'
fi
