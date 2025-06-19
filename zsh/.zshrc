# If you come from bash you might have to change your $PATH.
export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Theme
ZSH_THEME="jonathan"

# Enable command auto-correction.
ENABLE_CORRECTION="true"

# Plugins
plugins=(git)

# Sourcing the main zsh file
source $ZSH/oh-my-zsh.sh

# Configuring all the other aliases
alias zshconfig="vim ~/.zshrc && source ~/.zshrc"