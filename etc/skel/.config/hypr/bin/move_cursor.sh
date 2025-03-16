#!/usr/bin/env bash

# Get the touchpad event device
TOUCHPAD_DEVICE=$(libinput list-devices | awk '/Touchpad/,/^$/' | awk '/Kernel:/ {print $2}')

# If no touchpad is found, exit
[ -z "$TOUCHPAD_DEVICE" ] && exit 1

# Initial timestamp
last_event=$(date +%s)

# Monitor touchpad activity
stdbuf -oL libinput debug-events --device "$TOUCHPAD_DEVICE" | while read -r line; do
    if echo "$line" | grep -iq "touchpad"; then
        last_event=$(date +%s)
    fi

    # Check inactivity duration
    current_time=$(date +%s)
    idle_time=$((current_time - last_event))

    if [ "$idle_time" -ge 5 ]; then
        # Move cursor to lower-left using Hyprland dispatcher
        hyprctl dispatch movecursor "0 1200"
        last_event=$current_time
    fi

    # Avoid excessive CPU usage
    sleep 1
done
