# If you come from bash you might have to change your $PATH.
export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Update OMZ every week
zstyle ':omz:update' mode auto
zstyle ':omz:update' frequency 7

# Theme
ZSH_THEME="agnoster"
AGNOSTER_DIR_BG=cyan
AGNOSTER_DIR_FG=black

# Disable auto-setting terminal title.
DISABLE_AUTO_TITLE="true"

# Hyphen-insensitive completion
HYPHEN_INSENSITIVE="true"

# fzf base directory (for oh-my-zsh fzf plugin) — Homebrew prefix on macOS, apt path on Linux
if [[ "$OSTYPE" == darwin* ]]; then
    # Prefix is /opt/homebrew on Apple Silicon, /usr/local on Intel. Prefer
    # $HOMEBREW_PREFIX (exported by `brew shellenv`) to avoid forking `brew`
    # on every shell start; fall back to querying it only if unset.
    if [[ -z "$HOMEBREW_PREFIX" ]] && (( $+commands[brew] )); then
        HOMEBREW_PREFIX="$(brew --prefix)"
    fi
    [[ -n "$HOMEBREW_PREFIX" ]] && export FZF_BASE="$HOMEBREW_PREFIX/opt/fzf"
else
    export FZF_BASE=/usr/share/doc/fzf/examples
fi

# Plugins (zsh-autosuggestions and zsh-syntax-highlighting require installation via setup-dependencies.sh)
plugins=(aliases git history rsync tmux zsh-autosuggestions zsh-syntax-highlighting fzf)

# Sourcing the main zsh file
source $ZSH/oh-my-zsh.sh

# Sourcing custom aliases
[ -f ~/.personal_aliases ] && source ~/.personal_aliases
