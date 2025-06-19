#!/bin/bash
set -e 

SOURCE_DIR="$(pwd)"
TARGET_DIR="$HOME"

echo "Linking dotfiles from: $SOURCE_DIR"

# Find all files starting with '.' inside immediate subdirectories
find "$SOURCE_DIR" -mindepth 2 -type f -name ".*" | while read -r src; do
    filename="$(basename "$src")"
    dest="$TARGET_DIR/$filename"

    # Skip if source or filename is empty
    [ -z "$filename" ] && continue

    # Remove existing target if any
    if [ -e "$dest" ] || [ -L "$dest" ]; then
        echo "Removing existing: $dest"
        rm -f "$dest"
    fi

    # Create symlink
    ln -s "$src" "$dest"
    echo "Linked $dest → $src"
done

echo "All symlinks created successfully."

echo "Loading OhMyZsh changes..."
source ~/.zshrc

echo "Loading tmux config changes..."
tmux source-file $HOME/.tmux.conf