#!/usr/bin/env bash

# https://www.reddit.com/r/hyprland/comments/1cx0lc5/enabling_and_disabling_the_touchpad/
# hyprctl devices

# ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
# ┃           Toggle Touchpad in Hyprland (Auto-Detecting)      ┃
# ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
#
# This script toggles the touchpad state using `hyprctl`.
# - It automatically detects the touchpad device name.
# - It moves the cursor before/after toggling to prevent issues.
# - It restores tap/click behavior when re-enabling the touchpad.
# - It forces a switch to the Dvorak layout (index 1) if defined.
#
# Your Hyprland input config uses:
#     kb_layout = us,real_prog_dvorak
#     kb_options = grp:alt_space_toggle
#
# That means:
# - Layout index 0 is "us"
# - Layout index 1 is "real_prog_dvorak"
# - You can toggle layouts manually with Alt+Space
#
# This script assumes you want to force layout 1 (Dvorak) when toggling.

# Ensure $XDG_RUNTIME_DIR is set for hyprctl socket communication
if [ -z "$XDG_RUNTIME_DIR" ]; then
  export XDG_RUNTIME_DIR="/run/user/$(id -u)"
fi

# File to store current touchpad state (true/false)
STATUS_FILE="$XDG_RUNTIME_DIR/touchpad.status"

# ────────────────────────────────────────────────────────────────
# Detect the touchpad name by looking for any device name that
# contains "-touchpad" under the "mice" section of hyprctl output.
# ────────────────────────────────────────────────────────────────
detect_touchpad() {
  hyprctl devices | awk '
    in_mice && /-touchpad/ { print $1; exit }
    /^mice:/ { in_mice=1; next }
    /^Keyboards:/ { in_mice=0 }
  '
}

HYPRLAND_DEVICE="$(detect_touchpad)"

# Abort if no touchpad device was found
if [[ -z "$HYPRLAND_DEVICE" ]]; then
  notify-send -u critical "Touchpad Error" "No touchpad device found!"
  exit 1
fi

# ────────────────────────────────────────────────────────────────
# Move the cursor to the lower-right of the screen
# Prevents accidental focus or click after disabling touchpad.
# Adjust coordinates if your screen resolution differs.
# ────────────────────────────────────────────────────────────────
move_cursor_to_lower_right() {
  hyprctl dispatch movecursor "1900 1200"
}

# ────────────────────────────────────────────────────────────────
# Move the cursor to the center of the screen
# Useful after re-enabling touchpad so pointer is easy to locate.
# ────────────────────────────────────────────────────────────────
move_cursor_to_center() {
  hyprctl dispatch movecursor "960 600"
}

# ────────────────────────────────────────────────────────────────
# Restore Hyprland touchpad options after enabling
# Ensures tap-to-click is disabled and clickfinger is enabled.
# ────────────────────────────────────────────────────────────────
restore_touchpad_click() {
  hyprctl keyword "device[$HYPRLAND_DEVICE]:tap-to-click" false
  hyprctl keyword "device[$HYPRLAND_DEVICE]:clickfinger_behavior" true
}

# ────────────────────────────────────────────────────────────────
# Force switch to real_prog_dvorak layout (index 1)
# Your config sets: kb_layout = us,real_prog_dvorak
# This enforces layout index 1 (Dvorak) for all keyboards.
# ────────────────────────────────────────────────────────────────
maybe_switch_to_dvorak() {
  if command -v hyprctl &>/dev/null; then
    sleep 0.25
    hyprctl switchxkblayout all 1
  fi
}

# ────────────────────────────────────────────────────────────────
# Enable the touchpad
# - Repositions cursor
# - Restores click behavior
# - Switches to Dvorak
# - Sends a notification
# ────────────────────────────────────────────────────────────────
enable_touchpad() {
  echo true > "$STATUS_FILE"
  notify-send -u low "Touchpad" "Enabling"
  hyprctl keyword "device[$HYPRLAND_DEVICE]:enabled" true
  restore_touchpad_click
  maybe_switch_to_dvorak
  move_cursor_to_center
}

# ────────────────────────────────────────────────────────────────
# Disable the touchpad
# - Moves cursor off-screen
# - Switches to Dvorak
# - Sends a notification
# ────────────────────────────────────────────────────────────────
disable_touchpad() {
  move_cursor_to_lower_right
  echo false > "$STATUS_FILE"
  notify-send -u low "Touchpad" "Disabling"
  hyprctl keyword "device[$HYPRLAND_DEVICE]:enabled" false
  maybe_switch_to_dvorak
}

# ────────────────────────────────────────────────────────────────
# Toggle behavior:
# - Enable if status file is missing or contains "false"
# - Disable if status file contains "true"
# ────────────────────────────────────────────────────────────────
if [[ ! -f "$STATUS_FILE" ]]; then
  enable_touchpad
else
  case "$(cat "$STATUS_FILE")" in
    true) disable_touchpad ;;
    false) enable_touchpad ;;
    *) enable_touchpad ;;  # fallback if file is corrupted
  esac
fi
