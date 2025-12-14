# Packages that should be installed before installing this package.
# Each entry must correspond to another package script in the packages directory (without .sh).
# shellcheck disable=SC2034 # used by install.sh dependency resolver
DEPENDENCIES=(
  curl
)

# Load helper scripts
. "$ROOT_DIR/helpers/is_installed.sh"
. "$ROOT_DIR/helpers/shell-helpers.sh"

is_installed() {
  is_installed_cmd "brew"
}

append_fish_asdf_block() {
  local file="$HOME/.config/fish/config.fish"
  local marker="# Homebrew configuration code"
  local block='
# Homebrew configuration code
if test -x $HOME/.linuxbrew/bin/brew
    eval ($HOME/.linuxbrew/bin/brew shellenv fish)
else if test -x /home/linuxbrew/.linuxbrew/bin/brew
    eval (/home/linuxbrew/.linuxbrew/bin/brew shellenv fish)
end
'
  append_block_if_missing "$file" "$marker" "$block"
}

configure_brew_shells() {
  # Get Brew install directory
  local brew_path=""
  if [[ -x "$HOME/.linuxbrew/bin/brew" ]]; then
    brew_path="$HOME/.linuxbrew/bin/brew"
  elif [[ -x "/home/linuxbrew/.linuxbrew/bin/brew" ]]; then
    brew_path="/home/linuxbrew/.linuxbrew/bin/brew"
  else
    echo "Homebrew installed, but brew not found in expected locations." >&2
    return 1
  fi

  # POSIX shells (bash, zsh, generic login shell)
  local shellenv_line='eval "$('"$brew_path"' shellenv)"'

  append_line_if_missing "$HOME/.bashrc" "$shellenv_line"
  append_line_if_missing "$HOME/.zshrc" "$shellenv_line"

  # Fish shell
  append_fish_asdf_block

  # Ensure brew is available in the current shell session, that runs the install.sh script
  eval "$("$brew_path" shellenv)"
}

install_package() {
  local had_keepalive=0
  local installer_rc=0

  # If install.sh keepalive is running, stop it before running Homebrew.
  if declare -F stop_sudo_keepalive >/dev/null 2>&1; then
    if [[ -n "${SUDO_KEEPALIVE_PID:-}" ]] && kill -0 "$SUDO_KEEPALIVE_PID" 2>/dev/null; then
      had_keepalive=1
      echo "==> Stopping sudo keepalive before Homebrew installer..."
      stop_sudo_keepalive
    fi
  fi

  # Ensure we have sudo cached before running the installer (important with NONINTERACTIVE=1).
  sudo -v

  # Run the official installer unmodified
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  installer_rc=$?

  # Homebrew may invalidate sudo at exit (sudo -k). Re-establish sudo + keepalive for the rest of the run.
  if ((had_keepalive)); then
    echo "==> Re-establishing sudo session after Homebrew installer..."
    sudo -v
    start_sudo_keepalive
  fi

  # If installer failed, propagate failure (install.sh will record it and continue to next packages).
  if ((installer_rc != 0)); then
    return "$installer_rc"
  fi

  # Configure PATH/env settings
  configure_brew_shells
}
