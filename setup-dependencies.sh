#!/bin/bash
set -e

# Parse flags
INSTALL_CLAUDE=false
for arg in "$@"; do
    case "$arg" in
        --claude) INSTALL_CLAUDE=true ;;
        *) echo "Unknown option: $arg"; exit 1 ;;
    esac
done

# OS specific dependency install
OS="$(uname)"
echo "Detected OS: $OS"

SHARED_DEPENDENCIES=(curl git tmux vim fzf bat ripgrep)

if [ "$OS" = "Darwin" ]; then
    # zsh is the default shell in MAC
    OS_DEPENDENCIES=(eza fd git-delta)
    for pkg in "${SHARED_DEPENDENCIES[@]}" "${OS_DEPENDENCIES[@]}"; do
        brew install "$pkg"
    done

    # Install JetBrainsMono Nerd Font (required for eza icons)
    if ! brew list --cask font-jetbrains-mono-nerd-font &> /dev/null; then
        echo "Installing JetBrainsMono Nerd Font..."
        brew install --cask font-jetbrains-mono-nerd-font
    fi
elif [ "$OS" = "Linux" ]; then
    sudo apt update -y
    sudo apt install -y zsh zsh-common

    for pkg in "${SHARED_DEPENDENCIES[@]}" fd-find unzip; do
        sudo apt install -y "$pkg"
    done

    # bat and fd install as batcat and fdfind on Ubuntu — create compatibility symlinks
    if command -v batcat &> /dev/null && ! command -v bat &> /dev/null; then
        sudo ln -s "$(which batcat)" /usr/local/bin/bat
    fi
    if command -v fdfind &> /dev/null && ! command -v fd &> /dev/null; then
        sudo ln -s "$(which fdfind)" /usr/local/bin/fd
    fi

    # eza requires its own apt repository
    if ! command -v eza &> /dev/null; then
        echo "Installing eza..."
        sudo apt install -y gpg
        sudo mkdir -p /etc/apt/keyrings
        curl -fsSL https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
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

    # Install JetBrainsMono Nerd Font (required for eza icons)
    if [ ! -d "$HOME/.local/share/fonts/JetBrainsMono" ]; then
        echo "Installing JetBrainsMono Nerd Font..."
        mkdir -p "$HOME/.local/share/fonts"
        curl -fsSL -o /tmp/JetBrainsMono.zip https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip
        unzip -o /tmp/JetBrainsMono.zip -d "$HOME/.local/share/fonts/JetBrainsMono"
        fc-cache -fv
        rm -f /tmp/JetBrainsMono.zip
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
    KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
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

# Install Claude Code (only with --claude flag)
if [ "$INSTALL_CLAUDE" = true ]; then
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
fi

# Symlink dotfiles from repo to their target locations
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
bash "$SCRIPT_DIR/symlink-dotfiles.sh"

echo ""
echo "Setup complete! To load all changes:"
echo "  - Zsh: restart your terminal or run 'omz reload'"
echo "  - Tmux: run 'tmux source-file ~/.tmux.conf'"
echo "  - Terminal font: set 'JetBrainsMono Nerd Font Mono' in your terminal preferences"
set +e
