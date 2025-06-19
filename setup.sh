#!/bin/bash

set -e

# OS specific dependency install
OS_TYPE="$(uname)"
echo "Detected OS: $OS_TYPE"

DEPENDENCIES=(curl tmux vim)

if [ "$OS" = "Darwin" ]; then
    for pkg in "${PKGS[@]}"; do
        brew install $pkg
    done
elif [ "$OS" = "Linux" ]; then
    sudo apt update -y

    for pkg in "${PKGS[@]}"; do
        sudo apt install -y $pkg
    done
else
    echo "Unsupported OS: $OS"
    exit 1
fi

# Setup ohmyzsh
sh -c "$(curl -fsSL https://install.ohmyz.sh)"

# Copy the zsh config to the user home folder
cp zsh/.zshrc $HOME/.zshrc

# Copying the tmux config and activating the changes
cp tmux/.tmux.conf $HOME/.tmux.conf
tmux source-file ~/.tmux.conf

set +e