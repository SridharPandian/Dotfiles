#!/bin/bash
set -e

# OS specific dependency install
OS="$(uname)"
echo "Detected OS: $OS"

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

set +e