#!/usr/bin/env bash
#
# choose-wallpaper.sh — fzf-based swaybg wallpaper selector
#
# Prompts the user to select a wallpaper from ~/utono/wallpapers using fzf,
# then restarts swaybg with the selected image.

WALLPAPER_DIR="$HOME/utono/wallpapers"

# Ensure directory exists
if [ ! -d "$WALLPAPER_DIR" ]; then
  echo "❌ Error: Directory $WALLPAPER_DIR does not exist." >&2
  exit 1
fi

# Select a wallpaper using fzf
SELECTED=$(fd . "$WALLPAPER_DIR" --type f --extension png --extension jpg --extension jpeg |
  fzf --preview 'kitty +kitten icat --clear --place=50x20@50x0 {}' --height=40% --reverse --prompt="Choose wallpaper: ")

# Exit if nothing selected
[ -z "$SELECTED" ] && echo "No wallpaper selected." && exit 0

# Kill existing swaybg and apply new wallpaper
pkill swaybg
swaybg -o "*" -i "$SELECTED" -m fill &
echo "✅ Wallpaper set to: $SELECTED"
