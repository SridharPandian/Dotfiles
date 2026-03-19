#!/bin/bash
set -e

SOURCE_DIR="$(cd "$(dirname "$0")" && pwd)"
DEFAULT_TARGET="$HOME"

echo "Linking dotfiles from: $SOURCE_DIR"

for dir in "$SOURCE_DIR"/*/; do
    [ ! -d "$dir" ] && continue

    # Determine target directory from .target file or default to $HOME
    if [ -f "$dir/.target" ]; then
        TARGET_DIR=$(eval echo "$(cat "$dir/.target")")
    else
        TARGET_DIR="$DEFAULT_TARGET"
    fi

    mkdir -p "$TARGET_DIR"

    # Symlink all files in the subdirectory (excluding .target)
    find "$dir" -maxdepth 1 -type f ! -name ".target" | while read -r src; do
        filename="$(basename "$src")"
        [ -z "$filename" ] && continue

        dest="$TARGET_DIR/$filename"

        # Remove existing target if any
        if [ -e "$dest" ] || [ -L "$dest" ]; then
            echo "Removing existing: $dest"
            rm -f "$dest"
        fi

        # Create symlink
        ln -s "$src" "$dest"
        echo "Linked $dest → $src"
    done
done

echo "All symlinks created successfully."
