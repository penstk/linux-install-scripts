# Application name (used in logs / messages)
APP_NAME="zoxide"

# Command to check for in PATH.
# Use a different value if the binary name differs from APP_NAME.
CMD_NAME="zoxide"

# Package names in each distro's package manager.
# Set to "" if this package is not available on that distro.
# Keep "$APP_NAME" when the package name matches APP_NAME.
ARCH_PKG="$APP_NAME"
UBUNTU_PKG="$APP_NAME"
FEDORA_PKG="$APP_NAME"

# Load helper scripts
. "$ROOT_DIR/helpers/is_installed.sh"
. "$ROOT_DIR/helpers/install.sh"

append_line_if_missing() {
  local file="$1" line="$2"

  mkdir -p "$(dirname "$file")"
  [[ -f "$file" ]] || touch "$file"

  # Add the line only if it is not already present verbatim
  if ! grep -qxF "$line" "$file" 2>/dev/null; then
    printf '%s\n' "$line" >>"$file"
  fi
}

append_fish_config() {
  local file="$HOME/.config/fish/config.fish"
  local marker="# Zoxide configuration code"
  local block='
# Zoxide configuration code
zoxide init fish | source
'

  mkdir -p "$(dirname "$file")"
  [[ -f "$file" ]] || touch "$file"

  # Only append once, using the marker as an anchor
  if ! grep -q "$marker" "$file" 2>/dev/null; then
    printf '%s\n' "$block" >>"$file"
  fi
}

configure_shells() {
  # POSIX shells (bash, zsh, generic login shell)
  append_line_if_missing "$HOME/.bashrc" 'eval "$(zoxide init bash)"'
  append_line_if_missing "$HOME/.zshrc" 'eval "$(zoxide init zsh)"'

  # Fish shell
  append_fish_config
}

is_installed() {
  is_installed_cmd "$CMD_NAME"
}

install_package() {
  install_via_pkgmgr "$APP_NAME" "$ARCH_PKG" "$UBUNTU_PKG" "$FEDORA_PKG"
  configure_shells
  eval "$(zoxide init bash)"
}
