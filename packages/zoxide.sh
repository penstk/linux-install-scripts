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
. "$ROOT_DIR/helpers/pkg-helpers.sh"
. "$ROOT_DIR/helpers/shell-helpers.sh"

configure_shells() {
  # Add to PATH in interactive shells
  append_shell_bash_line_if_missing 'eval "$(zoxide init bash)"'
  append_shell_zsh_line_if_missing 'eval "$(zoxide init zsh)"'
  append_fish_interactive_line_if_missing 'zoxide init fish | source'
}

is_installed() {
  is_installed_cmd "$CMD_NAME"
}

install_package() {
  install_via_pkgmgr "$APP_NAME" "$ARCH_PKG" "$UBUNTU_PKG" "$FEDORA_PKG" || return 1
  configure_shells || return 1
  eval "$(zoxide init bash)" || return 1
}
