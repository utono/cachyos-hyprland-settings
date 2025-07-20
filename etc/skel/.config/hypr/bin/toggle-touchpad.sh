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

# Wait for device to be properly initialized
wait_for_device_ready() {
  local max_attempts=10
  local attempt=0
  
  while [[ $attempt -lt $max_attempts ]]; do
    if [[ -e "/dev/input/by-path/pci-0000:00:15.0-platform-i2c_designware.0-event-mouse" ]] || \
       [[ $(xinput list | grep -i touchpad) ]]; then
      return 0
    fi
    sleep 0.5
    ((attempt++))
  done
  return 1
}

# Reset touchpad driver state
reset_touchpad_driver() {
  # Force reload of the i2c_hid_acpi module
  sudo modprobe -r i2c_hid_acpi 2>/dev/null || true
  sleep 0.5
  sudo modprobe i2c_hid_acpi
  sleep 1
}

unbind_touchpad() {
  echo "$TOUCHPAD_I2C_ID" | sudo tee "$DRIVER_PATH/unbind" >/dev/null
  notify-send -u low "Touchpad" "Disabled"
  move_cursor_to_lower_right
  maybe_switch_to_dvorak
}

bind_touchpad() {
  # First attempt normal bind
  echo "$TOUCHPAD_I2C_ID" | sudo tee "$DRIVER_PATH/bind" >/dev/null
  
  # Wait a moment for device initialization
  sleep 1
  
  # Check if device is properly initialized
  if ! wait_for_device_ready; then
    notify-send -u normal "Touchpad" "Reinitializing driver..."
    
    # If device not ready, try driver reset
    reset_touchpad_driver
    
    # Wait for device again
    if wait_for_device_ready; then
      notify-send -u low "Touchpad" "Enabled (reinitialized)"
    else
      notify-send -u critical "Touchpad" "Failed to initialize properly"
    fi
  else
    notify-send -u low "Touchpad" "Enabled"
  fi
  
  # Additional delay before moving cursor to ensure touchpad is responsive
  sleep 0.5
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
