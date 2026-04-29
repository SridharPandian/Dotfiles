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

# fzf base directory (for oh-my-zsh fzf plugin)
export FZF_BASE=/usr/share/doc/fzf/examples

# Plugins (zsh-autosuggestions and zsh-syntax-highlighting require installation via setup-dependencies.sh)
plugins=(aliases git history rsync tmux zsh-autosuggestions zsh-syntax-highlighting fzf)

# Sourcing the main zsh file
source $ZSH/oh-my-zsh.sh

# Sourcing custom aliases
[ -f ~/.personal_aliases ] && source ~/.personal_aliases

# Custom machine specific
eval "$(mise activate)"
export RMW_IMPLEMENTATION=rmw_zenoh_cpp

# AWS
export AWS_PROFILE=sridhar-imitation-learning
export AWS_DEFAULT_REGION=us-east-1
export AWS_SSH_KEY_NAME="sridhar-key"
export AWS_SSH_KEY_PATH=~/.ssh/sridhar-key.pem
export AWS_SECURITY_GROUP="sg-06f32cd57f5eebf23"

# BEGIN Ansible - mise
eval "$(mise activate)"
# END Ansible - mise

export PATH="$HOME/.toolbox/bin:$PATH"

# BEGIN ANSIBLE MANAGED: Claude Code Bedrock
export CLAUDE_CODE_USE_BEDROCK=1
export AWS_REGION=us-east-1
export AWS_PROFILE=prod
export ANTHROPIC_DEFAULT_SONNET_MODEL=us.anthropic.claude-sonnet-4-6
export ANTHROPIC_DEFAULT_OPUS_MODEL=us.anthropic.claude-opus-4-7
export ANTHROPIC_DEFAULT_HAIKU_MODEL=us.anthropic.claude-haiku-4-5-20251001-v1:0
# END ANSIBLE MANAGED: Claude Code Bedrock
