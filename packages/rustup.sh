# Application name (used in logs / messages)
APP_NAME="rustup"

# Command to check for in PATH.
# Use a different value if the binary name differs from APP_NAME.
CMD_NAME="$APP_NAME"

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

append_fish_cargo_block() {
  local marker="# Cargo configuration code"
  local block='
# Cargo configuration code
set _cargo_bin "$HOME/.cargo/bin"

if not contains $_cargo_bin $PATH
    set -gx --prepend PATH $_cargo_bin
end
set --erase _cargo_bin
'
  append_fish_env_block_if_missing "$marker" "$block"
}

configure_cargo_shells() {
  append_shell_env_line_if_missing 'export PATH="${CARGO_HOME:-$HOME/.cargo}/bin:$PATH"'

  append_fish_cargo_block

  # Make sure cargo are available in the current shell session, that runs the install.sh script
  ensure_path_contains "${CARGO_HOME:-$HOME/.cargo}/bin"
}

is_installed() {
  is_installed_cmd "$CMD_NAME" && is_installed_cmd cargo
}

install_package() {
  install_via_pkgmgr "$APP_NAME" "$ARCH_PKG" "$UBUNTU_PKG" "$FEDORA_PKG" || return 1

  case "$DISTRO" in
  arch | cachyos | ubuntu)
    rustup default stable
    ;;
  fedora)
    rustup-init -y --no-modify-path
    ;;
  *)
    echo "$APP_NAME: Unsupported distro '$DISTRO'." >&2
    return 1
    ;;
  esac

  configure_cargo_shells || return 1
}
