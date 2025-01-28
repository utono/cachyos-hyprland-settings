#!/bin/sh

# Script to enable or disable the touchpad on Hyprland.
# Moves the cursor to the upper-left of the screen after enabling the touchpad.
# Usage: touchpad_hyprland.sh ven_04f3:00-04f3:32aa-touchpad
# https://www.reddit.com/r/hyprland/comments/1cx0lc5/enabling_and_disabling_the_touchpad/

HYPRLAND_DEVICE="$1"

if [ -z "$XDG_RUNTIME_DIR" ]; then
	export XDG_RUNTIME_DIR="/run/user/$(id -u)"
fi

export STATUS_FILE="$XDG_RUNTIME_DIR/touchpad.status"

move_cursor_to_upper_left() {
	# Move the cursor to the upper-left corner of the screen
	hyprctl dispatch movecursor "0 0"
}

restore_touchpad_click() {
	# Restore touchpad's tap-to-click behavior
	hyprctl keyword "device[$HYPRLAND_DEVICE]:tap-to-click" true
	hyprctl keyword "device[$HYPRLAND_DEVICE]:clickfinger_behavior" true
}

switch_to_dvorak() {
	sleep 0.5
	# Switch keyboard layout to real_prog_dvorak
	hyprctl switchxkblayout all 1
	notify-send -u low "Switched to real_prog_dvorak layout"
}

enable_touchpad() {
	printf "true" >"$STATUS_FILE"
	notify-send -u low "Enabling Touchpad"
	hyprctl keyword "device[$HYPRLAND_DEVICE]:enabled" true
	restore_touchpad_click
	move_cursor_to_upper_left
	switch_to_dvorak
}

disable_touchpad() {
	printf "false" >"$STATUS_FILE"
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
