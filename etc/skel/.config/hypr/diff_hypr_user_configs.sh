#!/usr/bin/env bash

CONFIG_DIR="$HOME/utono/cachyos-hyprland-settings/etc/skel/.config/hypr/config"
cd "$CONFIG_DIR" || exit 1

# Create a temp file for Vimscript commands
tmpfile="$(mktemp --suffix=.vim)"

found_pairs=0

# Set diff options: vertical layout, 3 lines of context, no fold column
echo "set diffopt+=context:3,foldcolumn:0" >> "$tmpfile"
echo "set diffopt+=context:3,internal,algorithm:histogram,indent-heuristic" >> "$tmpfile"

for user_file in user-*.conf; do
  base_file="${user_file#user-}"
  if [[ -f "$base_file" ]]; then
    echo "tabnew $base_file" >> "$tmpfile"
    echo "vsplit $user_file" >> "$tmpfile"
    echo "wincmd l" >> "$tmpfile"
    echo "diffthis" >> "$tmpfile"
    echo "wincmd h" >> "$tmpfile"
    echo "diffthis" >> "$tmpfile"
    found_pairs=1
  else
    echo "No base file for $user_file"
  fi
done

if [[ $found_pairs -eq 1 ]]; then
  nvim -S "$tmpfile"
else
  echo "No diffable pairs found."
  rm -f "$tmpfile"
fi
