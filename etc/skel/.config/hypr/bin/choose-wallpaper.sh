#!/usr/bin/env bash
#
# choose-wallpaper.sh — fzf-based swaybg wallpaper selector for Hyprland
#
# Prompts the user to select a wallpaper (including symlinks) from ~/utono/wallpapers
# using fzf, then restarts swaybg and records the selection to a log file.
#
# To check the current wallpaper:
#   cat "${XDG_STATE_HOME:-$HOME/.cache}/current-wallpaper.txt"

WALLPAPER_DIR="$HOME/utono/wallpapers"
LOG_FILE="${XDG_STATE_HOME:-$HOME/.cache}/current-wallpaper.txt"

# Verify the wallpaper directory exists
if [ ! -d "$WALLPAPER_DIR" ]; then
  echo "❌ Error: $WALLPAPER_DIR does not exist." >&2
  exit 1
fi

# Use fd to find image files and symlinks, pipe through fzf with kitty preview
SELECTED=$(fd --type f --type l --follow --extension png --extension jpg --extension jpeg . "$WALLPAPER_DIR" |
  fzf --preview 'kitty +kitten icat --clear --place=50x20@50x0 {}' \
      --height=40% --reverse --prompt="Choose wallpaper: ")

# Exit if nothing selected
if [ -z "$SELECTED" ]; then
  echo "No wallpaper selected."
  exit 0
fi

# Record selected wallpaper path to state file
echo "$SELECTED" > "$LOG_FILE"

# Restart swaybg with the selected wallpaper
pkill swaybg
swaybg -o "*" -i "$SELECTED" -m fill &

notify-send "Wallpaper Changed" "Now using: $(basename "$SELECTED")"
