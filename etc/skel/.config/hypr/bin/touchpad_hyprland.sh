#!/bin/sh

# Script to enable or disable the touchpad on Hyprland.
# Moves the cursor to the lower-right of the screen before disabling the touchpad.
# Moves the cursor to the center of the screen after enabling the touchpad.
# Usage: touchpad_hyprland.sh ven_04f3:00-04f3:32aa-touchpad
# https://www.reddit.com/r/hyprland/comments/1cx0lc5/enabling_and_disabling_the_touchpad/
#
# hyprctl devices
#
# mice:
#
#         Mouse at 56a93a3459d0:
#                 ven_04f3:00-04f3:32aa-touchpad
#                         default speed: 0.00000

HYPRLAND_DEVICE="$1"

if [ -z "$XDG_RUNTIME_DIR" ]; then
	export XDG_RUNTIME_DIR="/run/user/$(id -u)"
fi

export STATUS_FILE="$XDG_RUNTIME_DIR/touchpad.status"

move_cursor_to_lower_left() {
	# Move the cursor to the lower-right corner of the screen
	hyprctl dispatch movecursor "1900 1200"
}

move_cursor_to_center() {
	# Move the cursor to the center of the screen (1920x1200 resolution)
	hyprctl dispatch movecursor "960 600"
}

restore_touchpad_click() {
	# Restore touchpad's tap-to-click behavior
	hyprctl keyword "device[$HYPRLAND_DEVICE]:tap-to-click" false
	hyprctl keyword "device[$HYPRLAND_DEVICE]:clickfinger_behavior" true
}

switch_to_dvorak() {
	sleep 0.25
	# Switch keyboard layout to real_prog_dvorak
	hyprctl switchxkblayout all 1
	# notify-send -u low "Switched to real_prog_dvorak layout"
}

enable_touchpad() {
	printf "true" > "$STATUS_FILE"
	notify-send -u low "Enabling Touchpad"
	hyprctl keyword "device[$HYPRLAND_DEVICE]:enabled" true
	restore_touchpad_click
	switch_to_dvorak
	move_cursor_to_center
}

disable_touchpad() {
	move_cursor_to_lower_left
	printf "false" > "$STATUS_FILE"
	notify-send -u low "Disabling Touchpad"
	hyprctl keyword "device[$HYPRLAND_DEVICE]:enabled" false
	switch_to_dvorak
}

if ! [ -f "$STATUS_FILE" ]; then
	enable_touchpad
else
	if [ "$(cat "$STATUS_FILE")" = "true" ]; then
		disable_touchpad
	elif [ "$(cat "$STATUS_FILE")" = "false" ]; then
		enable_touchpad
	fi
fi
