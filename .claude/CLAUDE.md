# Dotfiles

Personal dotfiles repository for configuring development environments across macOS and Linux machines.

## Repository Structure

```
Dotfiles/
├── setup-dependencies.sh      # Installs all tools, plugins, symlinks dotfiles, and optionally Claude Code
├── symlink-dotfiles.sh        # Symlinks config files from repo to their targets (called by setup-dependencies.sh)
├── atuin/                     # Atuin shell history config → ~/.config/atuin/
│   ├── .target                # Symlink destination: $HOME/.config/atuin
│   └── config.toml            # Local-only history, Enter edits instead of runs
├── claude/                    # Claude Code settings → ~/.claude/
│   ├── .target                # Symlink destination: $HOME/.claude
│   ├── CLAUDE.md              # Global user preferences/instructions
│   ├── settings.json          # Permissions + hooks config
│   └── policy-limits.json     # Restriction settings
├── claude-hooks/              # Claude Code hook scripts → ~/.claude/hooks/
│   ├── .target                # Symlink destination: $HOME/.claude/hooks
│   └── herdr-agent-state.sh   # herdr's Claude integration hook (session restore)
├── herdr/                     # Herdr multiplexer config → ~/.config/herdr/
│   ├── .target                # Symlink destination: $HOME/.config/herdr
│   └── config.toml            # Keybindings + UI, ported from .tmux.conf
├── vim/
│   └── .vimrc                 # Vim configuration → ~/
├── tmux/
│   └── .tmux.conf             # Tmux configuration → ~/
└── zsh/
    ├── .zshrc                 # Zsh / Oh My Zsh configuration → ~/
    └── .personal_aliases      # Custom shell aliases → ~/
```

## Branching Strategy

- **`main`** — Base dotfiles configuration, portable across machines.
- **`fauna-dotfiles`** — Extended configuration for Fauna work machines. Adds machine-specific settings (AWS credentials, ROS/middleware env vars, Docker builder alias, mise activation) on top of `main`.

When working on this repo, be aware of which branch you're on. Changes that are portable belong on `main`; machine-specific additions belong on `fauna-dotfiles`.

## Setup Flow

Single command — `setup-dependencies.sh` handles everything end-to-end:

```bash
bash setup-dependencies.sh            # Install dependencies + symlink dotfiles
bash setup-dependencies.sh --claude   # Same as above, also installs Claude Code
```

The script installs all dependencies, sets up Oh My Zsh (with `KEEP_ZSHRC=yes` to preserve existing configs), installs zsh plugins, then automatically runs `symlink-dotfiles.sh` to link dotfiles. `symlink-dotfiles.sh` can also be run independently if only symlinks need updating.

**Important:** Do not run with `sudo` — the script uses `sudo` internally only for commands that need it (apt). Running the whole script as root installs user-level tools (Oh My Zsh, fonts) to `/root/` instead of `$HOME`.

Post-setup reload commands:
- Zsh: restart terminal or `omz reload`
- Tmux: `tmux source-file $HOME/.tmux.conf`
- Herdr: `herdr server reload-config` (only if a herdr server is already running)
- Terminal font: set **JetBrainsMono Nerd Font Mono** in terminal preferences (required for eza icons)

## Dependencies

Installed via `setup-dependencies.sh`:

| Category | Tools |
|----------|-------|
| Core | curl, git, tmux, vim, fzf, zsh |
| Modern CLI | bat, eza, fd, ripgrep, delta, glow |
| Shell history | atuin |
| Fonts | JetBrainsMono Nerd Font |
| Zsh plugins | zsh-autosuggestions, zsh-syntax-highlighting |
| Multiplexer | herdr (via `herdr.dev/install.sh`) |
| AI | Claude Code (`--claude` flag required) |

Package names differ between macOS (Homebrew) and Linux (apt) for some tools — handled via `SHARED_DEPENDENCIES` and `OS_DEPENDENCIES` arrays in the setup script.

## Symlink System

The `symlink-dotfiles.sh` script uses a `.target` file convention:

- Each tool subdirectory can contain a `.target` file specifying where its files should be symlinked.
- If no `.target` file exists, files are symlinked to `$HOME` (the default).
- The `.target` file itself is never symlinked.
- The `*/` glob naturally excludes hidden directories (`.git/`, `.claude/`).
- The script resolves its own location via `dirname "$0"`, so it can be invoked from any directory.

Four `.target` files exist: `atuin/.target` (pointing to `$HOME/.config/atuin`), `claude/.target` (pointing to `$HOME/.claude`), `claude-hooks/.target` (pointing to `$HOME/.claude/hooks`), and `herdr/.target` (pointing to `$HOME/.config/herdr`). All other directories use the `$HOME` default.

The script only links top-level files (`find -maxdepth 1`), so a nested destination like `~/.claude/hooks/` needs its own top-level directory with a `.target` (hence `claude-hooks/` rather than `claude/hooks/`).

Because the script links files individually rather than the directory itself, `herdr/config.toml` can share `~/.config/herdr/` with herdr's runtime state (`herdr.sock`, `session.json`, `*.log`) without disturbing it.

## Configuration Details

### Zsh (`.zshrc`)

- **Framework:** Oh My Zsh
- **Theme:** `agnoster` (with cyan directory background for dark terminal readability)
- **Auto-update:** Weekly
- **Plugins:** `aliases`, `git`, `history`, `rsync`, `tmux`, `zsh-autosuggestions`, `zsh-syntax-highlighting`, `fzf`
- **FZF base:** OS-detected — `$HOMEBREW_PREFIX/opt/fzf` on macOS, `/usr/share/doc/fzf/examples` on Linux
- **History search:** atuin on `Ctrl-R` (initialized after oh-my-zsh so it overrides the fzf plugin's `Ctrl-R`; fzf keeps `Ctrl-T` and `Alt-C`). Falls back to fzf's `Ctrl-R` when atuin isn't installed
- Sources `~/.personal_aliases` if it exists

**fauna-dotfiles additions:** mise activation, `RMW_IMPLEMENTATION` export, AWS environment variables (profile, region, SSH key, security group).

### Tmux (`.tmux.conf`)

- **Prefix:** `Ctrl-A` (remapped from default `Ctrl-B`)
- **Default shell:** OS-detected — `/bin/zsh` on macOS, `/usr/bin/zsh` on Linux
- **Pane splits:** `Ctrl-A W` (horizontal), `Ctrl-A E` (vertical)
- **Pane switching:** `Alt + Arrow keys` (no prefix needed)
- **Config reload:** `Ctrl-A R`
- **Mouse mode:** Enabled
- **Status bar:** Bottom, shows `YYYY-MM-DD HH:MM`

### Herdr (`config.toml`)

Terminal workspace manager for AI coding agents. Hierarchy is `session → workspace → tab → pane`, where workspace is an extra layer above tmux's model (git branch/worktree aware, with per-pane agent detection).

The prefix is the only remapped default. The extra bindings (agent navigation, scratch shell) only fill actions herdr leaves unbound.

- **Prefix:** `Ctrl-A` (remapped from `Ctrl-B` to match tmux)
- **Pane splits:** `prefix V` (side by side), `prefix -` (stacked)
- **Pane switching:** `prefix H/J/K/L`, or `prefix G` for navigate mode
- **Pane swap:** `prefix Shift-H/J/K/L`
- **Copy mode:** `prefix [` (vi keys: `v` select, `y` yank, `/` and `?` search)
- **Agent navigation:** `prefix Alt-J`/`Alt-K` next/previous agent, `prefix Alt-1..9` jump to the Nth agent, `prefix O` jump to the agent behind the current notification. The sidebar is sorted by `priority` (blocked agents first), so next/previous visits agents needing input first
- **Scratch shell:** `prefix Alt-S` opens a floating `$SHELL` popup (80% × 80%) over the layout; exit the shell to close it
- **Worktrees:** `prefix Shift-G` creates a git worktree plus a workspace for it under `~/.herdr/worktrees/<repo>/<branch>`, so parallel agents can work on separate branches
- **Pane title:** `prefix Shift-P`
- **Config reload:** `prefix Shift-R`
- **Detach:** `prefix Q`
- **Workspace picker:** `prefix W`
- **Rename tab:** `prefix Shift-T`
- **Status bar:** bottom, shows `YYYY-MM-DD HH:MM`
- **Theme:** `dracula`, with automatic light/dark switching off
- **Agent status indicators:** `symbols` (distinct glyph per state instead of color-only dots)

Unchanged from tmux, so muscle memory already works: `prefix C` new tab, `prefix N`/`P` next/prev tab, `prefix 1..9` switch tab, `prefix X` close pane, `prefix Z` zoom.

Notes:

- Because no default besides the prefix is remapped, several tmux habits do something *different* rather than nothing: `prefix W` opens the workspace picker instead of splitting, `prefix E` edits scrollback, `prefix R` enters resize mode instead of reloading, and `prefix Shift-T` renames the **tab**, not the pane. `Alt + Arrow` is unbound.
- herdr names splits by divider orientation (like vim `:vsplit`), which is **inverted** from tmux's `-h`/`-v` flags. `split_vertical` = side by side; `split_horizontal` = stacked.
- herdr has **no send-prefix action**. With prefix `Ctrl-A`, a nested tmux session on the same prefix is unreachable. Use herdr as the outer multiplexer only.
- `default_shell` is deliberately left unset — it falls back to `$SHELL`, avoiding the `/bin/zsh` vs `/usr/bin/zsh` branch that `.tmux.conf` needs.
- Background notifications (`[ui.toast] delivery`) are off in herdr's defaults; this config sets `"system"` (OS notification service), so alerts show even when herdr isn't focused. `delivery` takes exactly one of `off`, `herdr`, `terminal`, `system` — in-app and system toasts can't be combined.
- A config parse error makes herdr silently fall back to all defaults, so always run `herdr config check` after editing.
- Installed by `setup-dependencies.sh` via the official `herdr.dev/install.sh` script to `~/.local/bin/herdr`. On reruns the script calls `herdr update` instead, which is a no-op when current. The update is skipped inside a herdr pane (detected via `HERDR_ENV`, where `herdr update` exits 1), and herdr itself declines to replace the binary while a server is running — detach/stop sessions, then run `herdr update`.
- Validate changes with `herdr config check`, then apply to a running server with `herdr server reload-config`.
- `Alt` bindings rely on iTerm2's Option key sending Esc+ (set by `setup-dependencies.sh`). Skip herdr 0.9.2: it broke Option+Left/Right and Option+Backspace in iTerm2, fixed in 0.9.3.

#### Claude Code integration (session restore)

With `session.resume_agents_on_restore` (on by default), herdr reopens agent panes into their native conversations after a server restart. For Claude, herdr learns each pane's session ID from a `SessionStart` hook:

```
claude starts / resumes in a herdr pane
   │
   └─▶ SessionStart hook (claude/settings.json)
          │
          └─▶ ~/.claude/hooks/herdr-agent-state.sh ──symlink──▶ claude-hooks/herdr-agent-state.sh
                 │
                 └─▶ pane.report_agent_session over $HERDR_SOCKET_PATH
```

- The hook command is portable (`$HOME`, not an absolute path) and guarded, so it's a silent no-op when the script is missing. The script itself exits immediately outside herdr (`HERDR_ENV` unset) and needs `python3`.
- Only sessions that start or resume *after* the hook is in place are known to herdr. A Claude session that predates it comes back as a plain shell; resume it by hand with `claude --resume`.
- **Do not let `setup-dependencies.sh` (or anyone) run `herdr integration install claude` blindly.** herdr only recognizes its own absolute-path hook entry, so it appends a second, machine-specific `bash '/Users/…/herdr-agent-state.sh' session` entry to `claude/settings.json` (through the symlink).
- **Upgrading the integration** (when `herdr integration status` reports claude as outdated after a herdr update): run `herdr integration install claude`, which rewrites `claude-hooks/herdr-agent-state.sh` through the symlink. Then delete the duplicate absolute-path entry it appended to `claude/settings.json`, and commit the updated script. The committed script is currently v10 (herdr 0.9.3).

### Atuin (`config.toml`)

Shell history in a local SQLite database, with each command's directory, exit code, duration, and host. Full-screen search on `Ctrl-R`.

- **Local only:** `auto_sync = false` and `update_check = false`, so nothing contacts `api.atuin.sh`. No account is set up. Secrets matching known token patterns (AWS, GitHub, Slack, Stripe) are filtered from history by default.
- **Enter edits, doesn't run:** `enter_accept = false`, so Enter (like Tab) places the selected command on the prompt, matching fzf's `Ctrl-R`. Running a fuzzy match immediately is risky on a robot.
- **Key bindings live in `.zshrc`**, not the config: `atuin init zsh --disable-up-arrow --disable-ai` binds only `Ctrl-R`. The up arrow stays plain history stepping, and `?` on an empty prompt does not open Atuin AI (a hosted service).
- **Install:** Homebrew on macOS. On Linux, the release binary from `atuin-installer.sh` with `ATUIN_INSTALL_DIR="$HOME/.local/bin"` (flat layout: the binary lands directly in that directory) and `ATUIN_NO_MODIFY_PATH=1`. The `setup.atuin.sh` wrapper is avoided because it appends to `~/.zshrc` and `~/.bashrc` and installs Claude Code hooks into the symlinked `~/.claude/settings.json`.
- **History import:** `setup-dependencies.sh` runs `atuin import zsh` once per machine, skipped once `~/.local/share/atuin/history.db` exists.
- Unlike herdr, atuin refuses to start on an invalid config ("could not load client settings") rather than silently using defaults.
- The Linux installer writes `atuin-receipt.json` next to the config; the symlink script links files individually, so it coexists with the linked `config.toml`.
- **Not enabled:** `atuin hook install claude-code` (records commands Claude runs into atuin history). It would edit the symlinked `settings.json`; decide on portability first, as with the herdr hook.

### Glow

Terminal markdown renderer (`glow README.md`, or `glow` alone to browse markdown files in the current directory). No config. Installed via Homebrew on macOS and Charm's apt repository on Linux.

### Vim (`.vimrc`)

Organized in folded sections (`{{{`/`}}}`):

- **File Type:** Detection, plugin loading, and indent support enabled
- **Display:** `showcmd`, `showmode`, `showmatch`
- **Formatting:** Syntax highlighting, line numbers + relative numbers, cursor line highlight, incremental search with highlight, smart case search, wildmenu completion, no line wrap
- **Spacing:** 4-space indentation, tabs expanded to spaces

### Claude Code (`claude/`)

Portable settings symlinked to `~/.claude/`:

- **CLAUDE.md** — Global preferences governing Claude Code behavior across all projects
- **settings.json** — Permission rules (silent read/write access to `.claude/` directories) and the herdr `SessionStart` hook
- **policy-limits.json** — Restriction settings (remote control disabled)

Hook scripts live in `claude-hooks/` and are symlinked to `~/.claude/hooks/` (see the Herdr section for the herdr integration).

Excluded from repo (machine-local): `.credentials.json`, `todo.md`, `sessions/`, `cache/`, `plugins/`.

### Aliases (`.personal_aliases`)

| Category | Alias | Command |
|----------|-------|---------|
| Config | `zshconfig` | Edit `.zshrc` + reload |
| Config | `aliases` | Edit `.personal_aliases` + reload |
| Git | `gs` | `git status` |
| Git | `ga` | `git add` |
| Git | `gc` | `git commit -m` |
| Git | `gca` | `git commit -am` |
| Git | `gp` | `git pull` |
| Git | `gf` | `git fetch` |
| Git | `grm` | `git rebase origin/main` |
| Git | `gpf` | `git push --force-with-lease` |
| Git | `gchm` | `git checkout main && git pull` |
| Git | `gbn` | `git checkout -b` |
| Modern CLI | `cat` | `bat --paging=never` |
| Modern CLI | `ls` | `eza --icons` |
| Modern CLI | `ll` | `eza --icons -la` |
| Modern CLI | `find` | `fd` |
| Modern CLI | `grep` | `rg` |
| Docker | `builder-x` | Set `BUILDX_BUILDER` (fauna-dotfiles only) |

## Conventions

- **Shell scripts** use `set -e` for strict error handling and `set +e` to restore at the end.
- **Idempotency** — setup scripts check for existing installations before running (e.g., `command -v` checks, directory existence checks).
- **Symlink strategy** — config files live in tool-specific subdirectories and are symlinked to their target directory. Use a `.target` file to override the default `$HOME` destination.
- **OS detection** — `uname` is used to branch between macOS (Homebrew) and Linux (apt). Package names that differ across OS are handled via separate dependency arrays.
- **No plugin managers** — Vim has no plugin manager; zsh plugins are git-cloned into Oh My Zsh's custom directory.

## Adding New Configurations

To add a new tool's config:

1. Create a subdirectory named after the tool (e.g., `git/`).
2. Place the config file(s) inside.
3. If the files should go somewhere other than `$HOME`, create a `.target` file containing the destination path (e.g., `$HOME/.config/tool`).
4. Run `bash symlink-dotfiles.sh` to create the symlinks (can be invoked from any directory).
5. If the tool needs installation, add it to the appropriate dependency array in `setup-dependencies.sh`.

## Sensitive Data

The `fauna-dotfiles` branch contains machine-specific values (AWS profile names, security group IDs, SSH key paths). These are environment-specific identifiers, not secrets, but be mindful when merging branches or sharing configurations.

The `claude/` directory excludes `.credentials.json` (OAuth tokens) and `todo.md` (working document) — these are machine-local and should never be committed.
