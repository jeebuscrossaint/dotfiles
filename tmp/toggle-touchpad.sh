#!/bin/sh
device=$(xinput list | grep -i touchpad | grep -oP 'id=\K\d+')
if [ -n "$device" ]; then
  state=$(xinput list-props "$device" | grep "Device Enabled" | grep -oP ':\s*\K\d+')
  if [ "$state" = "1" ]; then
    xinput disable "$device"
    notify-send "Touchpad" "Disabled" -t 1000
  else
    xinput enable "$device"
    notify-send "Touchpad" "Enabled" -t 1000
  fi
fi

