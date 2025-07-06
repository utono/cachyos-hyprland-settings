#!/usr/bin/env bash

# ~/.local/bin/bin-mlj/toggle-touchpad.sh

# ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
# ┃     Toggle I2C Touchpad via Driver Unbind (Dell XPS 17)     ┃
# ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

TOUCHPAD_I2C_ID="$(grep -i 04f3 /sys/bus/i2c/devices/*/name | cut -d/ -f6)"

if [[ -z "$TOUCHPAD_I2C_ID" ]]; then
  notify-send -u critical "Touchpad Error" "Touchpad I2C device not found."
  exit 1
fi

DRIVER_PATH="/sys/bus/i2c/drivers/i2c_hid_acpi"
DEVICE_PATH="/sys/bus/i2c/devices/$TOUCHPAD_I2C_ID"

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
}

bind_touchpad() {
  echo "$TOUCHPAD_I2C_ID" | sudo tee "$DRIVER_PATH/bind" >/dev/null
  notify-send -u low "Touchpad" "Enabled"
  move_cursor_to_center
  maybe_switch_to_dvorak
}

# ────────────────────────────────────────────────────────────────
# Determine whether the device is currently bound
# ────────────────────────────────────────────────────────────────
if [[ -L "$DEVICE_PATH/driver" ]]; then
  unbind_touchpad
else
  bind_touchpad
fi
