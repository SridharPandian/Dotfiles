# Sridhar's Dotfiles
This repo is used to setup custom configurations on machines I use.

The following tools can be setup using this repo:
- [ohmyzsh](https://ohmyz.sh/)
- tmux
- vim
- [Claude Code](https://docs.anthropic.com/en/docs/claude-code)

## Dependencies installed
The setup script installs these tools automatically:
- **Core:** curl, tmux, vim, fzf, zsh
- **Modern CLI:** bat, eza, fd, ripgrep, delta
- **Zsh plugins:** zsh-autosuggestions, zsh-syntax-highlighting

## Setup

To install all the tools and dependencies:
```
bash setup-dependencies.sh
```

To setup the symlinks to all the configuration dotfiles:
```
cd <project-directory>
bash symlink-dotfiles.sh
```

## Adding new tool configurations

1. Create a subdirectory named after the tool (e.g., `git/`).
2. Place the config file(s) inside.
3. If the files should go somewhere other than `$HOME`, create a `.target` file containing the destination path (e.g., `$HOME/.claude`).
4. Run `bash symlink-dotfiles.sh` from the repo root.
5. If the tool needs installation, add it to the dependency arrays in `setup-dependencies.sh`.

## Post-setup

To source the zshrc changes:
```
omz reload
```

To load the tmux changes:
```
tmux source-file $HOME/.tmux.conf
```
