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
