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
    sudo apt update -y
    sudo apt install -y zsh zsh-common

    for pkg in "${SHARED_DEPENDENCIES[@]}" fd-find; do
        sudo apt install -y "$pkg"
    done

    # eza requires its own apt repository
    if ! command -v eza &> /dev/null; then
        echo "Installing eza..."
        sudo apt install -y gpg
        sudo mkdir -p /etc/apt/keyrings
        wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
        echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
        sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
        sudo apt update -y
        sudo apt install -y eza
    fi

    # delta requires downloading the .deb package directly
    if ! command -v delta &> /dev/null; then
        echo "Installing git-delta..."
        DELTA_VERSION=$(curl -fsSL https://api.github.com/repos/dandavison/delta/releases/latest | grep -oP '"tag_name": "\K[^"]+')
        DELTA_DEB="git-delta_${DELTA_VERSION}_$(dpkg --print-architecture).deb"
        curl -fsSL -o "/tmp/$DELTA_DEB" "https://github.com/dandavison/delta/releases/latest/download/$DELTA_DEB"
        sudo dpkg -i "/tmp/$DELTA_DEB"
        rm -f "/tmp/$DELTA_DEB"
    fi
else
    echo "Unsupported OS: $OS"
    exit 1
fi

# Set zsh as default shell (skip if already set)
CURRENT_SHELL=$(basename "$SHELL")
if [ "$CURRENT_SHELL" != "zsh" ]; then
    echo "Setting zsh as default shell..."
    chsh -s "$(which zsh)"
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
