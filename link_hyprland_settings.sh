#!/usr/bin/env bash

# This script creates symbolic links (symlinks) in the target directory (~/.config)
# that point to the contents of a source directory. If any existing files or directories
# in the target directory conflict with the symlink creation, they are moved to a backup
# directory at ~/backups/.config.

# Usage:
# 1. Ensure the SOURCE variable points to the directory containing the original configuration files.
#    Example: "$HOME/utono/cachyos-hyprland-settings/etc/skel/.config"
# 2. Ensure the TARGET variable points to the directory where the symlinks should be created.
#    Example: "$HOME/.config"
# 3. Run the script: ./link_config.sh
#    - Existing conflicting files or directories in the target directory will be moved to ~/backups/.config.
#    - Symlinks will then be created in the target directory for all items in the source directory.

# Example Output:
# Moved existing /home/user/.config/alacritty to /home/user/backups/.config/alacritty_20250101123456
# Created symlink: /home/user/.config/alacritty -> /home/user/utono/cachyos-hyprland-settings/etc/skel/.config/alacritty

# Define source and target directories
SOURCE="$HOME/utono/cachyos-hyprland-settings/etc/skel/.config"
TARGET="$HOME/.config"
BACKUP_DIR="$HOME/backups/.config"

# Create target and backup directories if they don't exist
mkdir -p "$TARGET"
mkdir -p "$BACKUP_DIR"

# Loop through the contents of the source directory
for item in "$SOURCE"/*; do
    # Get the base name of the item (e.g., "alacritty")
    base=$(basename "$item")
    target_item="$TARGET/$base"
    backup_item="$BACKUP_DIR/${base}_$(date +%Y%m%d%H%M%S)"

    # Check if a conflicting directory or file exists in the target
    if [ -e "$target_item" ] || [ -L "$target_item" ]; then
        # Move the existing directory or file to the backup directory
        mv "$target_item" "$backup_item"
        echo "Moved existing $target_item to $backup_item"
    fi

    # Create a symlink in the target directory
    ln -s "$item" "$target_item"
    echo "Created symlink: $target_item -> $item"
done

echo "Symlinks created in $TARGET pointing to $SOURCE, with backups stored in $BACKUP_DIR"
