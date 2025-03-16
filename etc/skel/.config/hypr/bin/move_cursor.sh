#!/usr/bin/env bash

# Enable debugging
set -x

# Log file for debugging
LOG_FILE="$HOME/.config/hypr/move_cursor_debug.log"
echo "Starting move_cursor.sh" > "$LOG_FILE"

# Ensure script runs with correct user environment
export DISPLAY=$DISPLAY
export WAYLAND_DISPLAY=$WAYLAND_DISPLAY
export HYPRLAND_INSTANCE_SIGNATURE=$HYPRLAND_INSTANCE_SIGNATURE

echo "WAYLAND_DISPLAY: $WAYLAND_DISPLAY" >> "$LOG_FILE"
echo "HYPRLAND_INSTANCE_SIGNATURE: $HYPRLAND_INSTANCE_SIGNATURE" >> "$LOG_FILE"

# Get the touchpad event device
TOUCHPAD_DEVICE=$(libinput list-devices | awk '/Touchpad/,/^$/' | awk '/Kernel:/ {print $2}')
echo "Detected Touchpad Device: $TOUCHPAD_DEVICE" >> "$LOG_FILE"

# If no touchpad is found, exit
if [ -z "$TOUCHPAD_DEVICE" ]; then
    echo "Error: No touchpad detected" >> "$LOG_FILE"
    exit 1
fi

# Initial timestamp
last_event=$(date +%s)
echo "Initial timestamp: $last_event" >> "$LOG_FILE"

# Monitor touchpad activity
stdbuf -oL libinput debug-events --device "$TOUCHPAD_DEVICE" | while read -r line; do
    echo "Event detected: $line" >> "$LOG_FILE"

    if echo "$line" | grep -iq "touchpad"; then
        last_event=$(date +%s)
        echo "Touchpad activity detected at $last_event" >> "$LOG_FILE"
    fi

    # Check inactivity duration
    current_time=$(date +%s)
    idle_time=$((current_time - last_event))
    echo "Idle time: $idle_time seconds" >> "$LOG_FILE"

    if [ "$idle_time" -ge 5 ]; then
        # Move cursor to lower-left using Hyprland dispatcher
        echo "Moving cursor to 0, 1200" >> "$LOG_FILE"
        hyprctl dispatch movecursor "0 1200"
        last_event=$current_time
    fi

    # Avoid excessive CPU usage
    sleep 1
done
