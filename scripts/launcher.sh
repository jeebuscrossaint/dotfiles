#!/usr/bin/env bash

if [[ $XDG_SESSION_TYPE == "wayland" ]]; then
    fuzzel
elif [[ $XDG_SESSION_TYPE == "x11" ]]; then
    rofi -show drun
else
    echo "Unknown session type: $XDG_SESSION_TYPE"
fi
