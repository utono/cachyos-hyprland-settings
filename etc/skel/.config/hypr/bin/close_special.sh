#!/bin/bash
#
# https://www.reddit.com/r/hyprland/comments/1b6bf39/comment/ktbgj1t/
#
# Script to close a special workspace on the focused monitor in Hyprland

# Fetch the name of the special workspace on the focused monitor
active=$(hyprctl -j monitors | jq --raw-output '.[] | select(.focused==true).specialWorkspace.name | split(":") | if length > 1 then .[1] else "" end')

# If a special workspace name exists, close it by dispatching a toggle
if [[ ${#active} -gt 0 ]]; then
    hyprctl dispatch togglespecialworkspace "$active"
fi

