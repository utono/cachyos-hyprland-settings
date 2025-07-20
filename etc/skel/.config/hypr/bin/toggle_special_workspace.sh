#!/bin/bash
# $HOME/utono/cachyos-hyprland-settings/etc/skel/.config/hypr/bin/toggle_special_workspace.sh
#
# Script to toggle between special workspace and previous workspace
#
# Usage: This script checks if a special workspace is currently active.
# If it is, it toggles away from the special workspace.
# If it's not, it switches to the previous workspace.

# Check if a special workspace is active on the focused monitor
# This is based on the logic from close_special.sh
active_special=$(hyprctl -j monitors | jq -r '.[] | select(.focused==true).specialWorkspace.name')

# Check if we have an active special workspace
if [[ -n "$active_special" && "$active_special" != "null" ]]; then
    # We have an active special workspace, so toggle it off
    # Extract the special workspace name (everything after "special:")
    if [[ "$active_special" == special:* ]]; then
        special_name="${active_special#special:}"
        # If there's a name after "special:", use it; otherwise toggle default
        if [[ -n "$special_name" ]]; then
            hyprctl dispatch togglespecialworkspace "$special_name"
        else
            hyprctl dispatch togglespecialworkspace
        fi
    else
        # Handle case where the name doesn't have "special:" prefix
        hyprctl dispatch togglespecialworkspace "$active_special"
    fi
else
    # No special workspace is active, so switch to previous workspace
    hyprctl dispatch workspace previous
fi
