# Application name (used in logs / messages)
APP_NAME="fd"

# Command to check for in PATH.
# Use a different value if the binary name differs from APP_NAME.
CMD_NAME="$APP_NAME"

# Package names in each distro's package manager.
# Set to "" if this package is not available on that distro.
# Keep "$APP_NAME" when the package name matches APP_NAME.
ARCH_PKG="fd"
UBUNTU_PKG="fd-find"
FEDORA_PKG="fd-find"

# Load helper scripts
. "$ROOT_DIR/helpers/is_installed.sh"
. "$ROOT_DIR/helpers/install.sh"

is_installed() {
  is_installed_cmd "$CMD_NAME"
}

install_package() {
  install_via_pkgmgr "$APP_NAME" "$ARCH_PKG" "$UBUNTU_PKG" "$FEDORA_PKG"
  case "$DISTRO" in
  ubuntu)
    # Global symlink so users can use fd with "fd" instead of "fdfind"
    sudo ln -sf "$(command -v fdfind)" /usr/local/bin/fd
    ;;
  esac
}
