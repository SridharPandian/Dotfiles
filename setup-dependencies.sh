#!/bin/bash
set -e

# OS specific dependency install
OS="$(uname)"
echo "Detected OS: $OS"

SHARED_DEPENDENCIES=(curl tmux vim fzf bat ripgrep)

if [ "$OS" = "Darwin" ]; then
    # zsh is the default shell in MAC
    OS_DEPENDENCIES=(eza fd git-delta)
    for pkg in "${SHARED_DEPENDENCIES[@]}" "${OS_DEPENDENCIES[@]}"; do
        brew install "$pkg"
    done
elif [ "$OS" = "Linux" ]; then
    OS_DEPENDENCIES=(eza fd-find git-delta)
    sudo apt update -y
    sudo apt install -y zsh zsh-common

    for pkg in "${SHARED_DEPENDENCIES[@]}" "${OS_DEPENDENCIES[@]}"; do
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

# Install Claude Code (skip if already installed)
if ! command -v claude &> /dev/null; then
    echo "Installing Claude Code..."
    curl -fsSL https://claude.ai/install.sh | bash
else
    echo "Claude Code already installed: $(claude --version)"
fi

# Create Claude Code config directory (skip if already exists)
if [ ! -d "$HOME/.claude" ]; then
    echo "Creating Claude Code config directory..."
    mkdir -p "$HOME/.claude"
fi

echo "Setup complete!"
set +e
