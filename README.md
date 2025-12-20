# Linux Install Scripts

This script install and configure multiple applications on Linux in a repeatable way.

The main entry point is `install.sh`, which:

- Installs packages based on either:
  - A config file, or
  - A list of package names passed on the command line
- Detects your Linux distribution (Arch, CachyOS, Ubuntu, Fedora)
- Updates the system using the appropriate package manager
- Asks once for sudo and keeps `sudo` authenticated while it runs

---

## Requirements

- Linux (currently only Arch, CachyOS, Ubuntu, or Fedora are supported)
- `bash`
- `sudo` access

---

## Usage

Install from config file

```bash

./install.sh -f|--file <packages.conf>

```

Install specific packages

```bash

./install.sh <pkg1> [pkg2 ...]

```

Examples:

```bash
# Install from a config file
./install.sh -f package.conf

# Install a custom list of packages
./install.sh zsh tmux neovim

# Show usage (no arguments)
./install.sh
```

---

## Config file format

A config file is a plain text file where each line starts with the package name.

Example:

```text
zsh        # shell
tmux       # terminal multiplexer
neovim
docker
```

Comments can be added with `#`.
Everything after the first word on a line is ignored.

---

## Package scripts

Each package is implemented as a script in `packages/`.

A package script must define the following methods:

- `is_installed` – returns 0 if the package is already installed
- `install_package` – performs the installation

Optionally, it can define:

- `DEPENDENCIES` – a Bash array of other package names this package depends on

Example skeleton:

```bash
# packages/example.sh

DEPENDENCIES=(curl git)

is_installed() {
  command -v example-app >/dev/null 2>&1
}

install_package() {
  sudo pacman -S --noconfirm example-app   # or apt/dnf depending on distro
}
```

Dependencies are resolved automatically before installation.

---

## Shell configuration (PATH/env vs interactive)

Some installers (notably `oh-my-bash` / `oh-my-zsh`) overwrite `~/.bashrc` / `~/.zshrc`, which can clobber PATH/env changes made earlier in the install. To make shell configuration repeatable and resilient to overwrites, this project writes shell config into dedicated files and only adds small “hook” snippets to your dotfiles.

**Files (Bash + Zsh)**

- `~/.config/shell/env`: PATH + environment only (POSIX sh). Sourced from login dotfiles so it applies to login shells and often your GUI session environment.
- `~/.config/shell/bash-interactive`: Bash interactive-only init (the equivalent of `~/.bashrc`). Sources `~/.config/shell/env` and optionally `~/.config/shell/env.bash` (if present).
- `~/.config/shell/zsh-interactive`: Zsh interactive-only init (the equivalent of `~/.zshrc`). Sources `~/.config/shell/env` and optionally `~/.config/shell/env.zsh` (if present).

**Hooks (where sourcing happens)**

- Login hook (sources `~/.config/shell/env`):
  - `~/.profile` (always ensured)
  - `~/.bash_profile` (only modified if it already exists)
  - `~/.zprofile` (ensured when Zsh is installed/available)
- Interactive hooks (source the per-shell interactive file):
  - Bash: `~/.bashrc` or, if `oh-my-bash` is installed, `~/.oh-my-bash/custom/source-bash-interactive.sh`
  - Zsh: `~/.zshrc` or, if `oh-my-zsh` is installed, `~/.oh-my-zsh/custom/source-zsh-interactive.zsh`

All of these files include a small guard at the top to avoid duplicate work if they get sourced multiple times in one session. You may add your own exports/evals below the header, but don’t modify/remove the header/guard lines.

**Fish**

Fish uses Fish-native config (Fish can’t reliably source POSIX sh files):

- `~/.config/fish/conf.d/shell-env.fish`: PATH + environment only
- `~/.config/fish/conf.d/shell-interactive.fish`: interactive-only init (only runs when interactive)

**What goes where**

- Put PATH exports and “environment for everything” in the env files (e.g. Homebrew/Rust/asdf PATH setup).
- Put interactive-only setup in the interactive files (e.g. `zoxide init`, completions, prompts, aliases).
