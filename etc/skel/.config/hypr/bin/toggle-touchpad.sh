#!/usr/bin/env bash

# ~/.local/bin/bin-mlj/toggle-touchpad.sh

# ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
# ┃     Toggle I2C Touchpad via Driver Unbind (Dell XPS 17)     ┃
# ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
#
# This script disables and re-enables the touchpad at the kernel
# level by unbinding it from its I2C driver (usually i2c_hid_acpi).
# It is compatible with devices like ELAN1200 / 04F3:32AA.
#
# Requires: root (via sudo)

# Replace with your actual ID if known
TOUCHPAD_I2C_ID="$(grep -i 04f3 /sys/bus/i2c/devices/*/name | cut -d/ -f6)"

if [[ -z "$TOUCHPAD_I2C_ID" ]]; then
  notify-send -u critical "Touchpad Error" "Touchpad I2C device not found."
  exit 1
fi

STATUS_FILE="$XDG_RUNTIME_DIR/touchpad.status"
DRIVER_PATH="/sys/bus/i2c/drivers/i2c_hid_acpi"

move_cursor_to_lower_right() {
  hyprctl dispatch movecursor "1900 1200"
}

move_cursor_to_center() {
  hyprctl dispatch movecursor "960 600"
}

maybe_switch_to_dvorak() {
  sleep 0.25
  hyprctl switchxkblayout all 1
}

unbind_touchpad() {
  echo "$TOUCHPAD_I2C_ID" | sudo tee "$DRIVER_PATH/unbind" >/dev/null
  notify-send -u low "Touchpad" "Disabled"
  move_cursor_to_lower_right
  maybe_switch_to_dvorak
  echo false > "$STATUS_FILE"
}

bind_touchpad() {
  echo "$TOUCHPAD_I2C_ID" | sudo tee "$DRIVER_PATH/bind" >/dev/null
  notify-send -u low "Touchpad" "Enabled"
  move_cursor_to_center
  maybe_switch_to_dvorak
  echo true > "$STATUS_FILE"
}

if [[ ! -f "$STATUS_FILE" ]]; then
  bind_touchpad
else
  case "$(cat "$STATUS_FILE")" in
    true) unbind_touchpad ;;
    false) bind_touchpad ;;
    *) bind_touchpad ;;
  esac
fi
