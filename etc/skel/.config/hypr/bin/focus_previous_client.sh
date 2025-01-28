#!/usr/bin/env bash
# focus_previous_client.sh
# This script switches focus to the previously active window on the current workspace.
# If no active window or previous client is available, the script exits silently.

# Get the ID of the currently active workspace
active_workspace="$(hyprctl activewindow -j | jq -r ".workspace.id")"

# Exit if there is no active workspace (e.g., no window is focused)
if [ "$active_workspace" = "null" ]; then exit; fi

# Find the address of the second most recently focused window (previous client) in the current workspace
previous_client="$(hyprctl clients -j | jq -r '[.[] | select(.workspace.id == '"$active_workspace"')] | sort_by(.focusHistoryID) | nth(1) | .address')"

# Exit if there is no previous client available
if [ "$previous_client" = "null" ]; then exit; fi

# Bring the previous client to the top of the z-order and focus on it
# TODO: Replace `bringactivetotop` with `alterzorder top` once the related Hyprland issue is resolved
hyprctl --batch "dispatch focuswindow address:$previous_client; dispatch bringactivetotop"
