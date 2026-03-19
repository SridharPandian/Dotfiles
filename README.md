# Sridhar's Dotfiles
This repo is used to setup custom configurations on machines I use.

The following tools can be setup using this repo:
- [ohmyzsh](https://ohmyz.sh/)
- tmux
- vim
- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) (optional)

## Dependencies installed
The setup script installs these tools automatically:
- **Core:** curl, git, tmux, vim, fzf, zsh
- **Modern CLI:** bat, eza, fd, ripgrep, delta
- **Fonts:** JetBrainsMono Nerd Font (required for eza icons)
- **Zsh plugins:** zsh-autosuggestions, zsh-syntax-highlighting
- **AI:** Claude Code (only with `--claude` flag)

## Setup

Single command to install all dependencies and symlink dotfiles:
```
bash setup-dependencies.sh
```

To also install Claude Code:
```
bash setup-dependencies.sh --claude
```

> **Note:** Do not run with `sudo`. The script uses `sudo` internally only for commands that need it (apt).

## Adding new tool configurations

1. Create a subdirectory named after the tool (e.g., `git/`).
2. Place the config file(s) inside.
3. If the files should go somewhere other than `$HOME`, create a `.target` file containing the destination path (e.g., `$HOME/.claude`).
4. Run `bash symlink-dotfiles.sh` to create the symlinks.
5. If the tool needs installation, add it to the dependency arrays in `setup-dependencies.sh`.

## Post-setup

Restart your terminal, or reload manually:
```
omz reload                              # Zsh
tmux source-file $HOME/.tmux.conf       # Tmux
```

Set **JetBrainsMono Nerd Font Mono** as your terminal font for eza icons to render correctly.
