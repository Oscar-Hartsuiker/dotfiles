#!/bin/bash
# rofi-wifi.sh

# Rescan first
nmcli device wifi rescan >/dev/null 2>&1
sleep 1

# Get current connection (if any)
current_ssid=$(nmcli -t -f active,ssid device wifi list | awk -F: '$1=="yes"{print $2}')

# Build list: signal icon + SSID + lock icon if secured, mark active connection
wifi_list=$(nmcli -t -f SSID,SIGNAL,SECURITY device wifi list | sort -t: -k2 -rn | awk -F: '
{
    ssid=$1; signal=$2; security=$3
    if (ssid == "") next
    icon = (signal > 75) ? "" : (signal > 50) ? "" : (signal > 25) ? "" : ""
    lock = (security != "" && security != "--") ? "" : ""
    print icon " " ssid " " lock " (" signal "%)"
}')

# Mark currently connected network
if [ -n "$current_ssid" ]; then
  wifi_list=$(echo "$wifi_list" | sed "s/ $current_ssid / $current_ssid  ✓/")
fi

chosen=$(echo "$wifi_list" | rofi -dmenu -i -p "WiFi" -theme-str 'window {width: 30%;}')
[ -z "$chosen" ] && exit 0

# Extract SSID (strip icons/signal/lock)
ssid=$(echo "$chosen" | sed -E 's/^[^ ]+ //; s/ [^ ]* \([0-9]+%\)( ✓)?$//')

# Already connected to this one? just exit
[ "$ssid" == "$current_ssid" ] && exit 0

# Check if a saved connection profile exists
if nmcli -t -f NAME connection show | grep -qx "$ssid"; then
  nmcli connection up "$ssid"
else
  security=$(nmcli -t -f SSID,SECURITY device wifi list | grep "^$ssid:" | cut -d: -f2)
  if [ "$security" != "" ] && [ "$security" != "--" ]; then
    password=$(rofi -dmenu -password -p "Password for $ssid")
    [ -z "$password" ] && exit 0
    nmcli device wifi connect "$ssid" password "$password"
  else
    nmcli device wifi connect "$ssid"
  fi
fi

# Notify result
if [ $? -eq 0 ]; then
  notify-send "WiFi" "Connected to $ssid"
else
  notify-send "WiFi" "Failed to connect to $ssid" -u critical
fi
