#!/usr/bin/env bash
# ~/.config/hypr/bin/workspace-wallpaper.sh

WORKSPACE=$1
DEFAULT_WALLPAPER="$HOME/utono/wallpapers/black.png"
WORKSPACE4_WALLPAPER="/usr/share/wallpapers/cachyos-wallpapers/Skyscraper.png"

case $WORKSPACE in
    # 7)
    #     hyprctl hyprpaper wallpaper ",$WORKSPACE4_WALLPAPER"
    #     ;;
    *)
        hyprctl hyprpaper wallpaper ",$DEFAULT_WALLPAPER"
        ;;
esac

hyprctl dispatch workspace $WORKSPACE
