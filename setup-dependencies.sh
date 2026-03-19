#!/bin/bash
set -e

# OS specific dependency install
OS="$(uname)"
echo "Detected OS: $OS"

DEPENDENCIES=(curl tmux vim fzf)

if [ "$OS" = "Darwin" ]; then
    # zsh is the default shell in MAC
    for pkg in "${DEPENDENCIES[@]}"; do
        brew install "$pkg"
    done
elif [ "$OS" = "Linux" ]; then
    sudo apt update -y
    sudo apt install -y zsh zsh-common

    for pkg in "${DEPENDENCIES[@]}"; do
        sudo apt install -y "$pkg"
    done
else
    echo "Unsupported OS: $OS"
    exit 1
fi

# Setup ohmyzsh (skip if already installed)
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL https://install.ohmyz.sh)"
fi

# Install zsh plugins
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

# zsh-autosuggestions
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    echo "Installing zsh-autosuggestions..."
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
fi

# zsh-syntax-highlighting
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
    echo "Installing zsh-syntax-highlighting..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
fi

echo "Setup complete!"
set +e
