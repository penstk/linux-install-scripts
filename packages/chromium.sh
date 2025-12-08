# Application name (used in logs / messages)
APP_NAME="chromium"

# Command to check for in PATH.
# Use a different value if the binary name differs from APP_NAME.
CMD_NAME="chromium-browser"
CMD_NAME_ARCH="chromium"

# Package names in each distro's package manager.
# Set to "" if this package is not available on that distro.
# Keep "$APP_NAME" when the package name matches APP_NAME.
ARCH_PKG="$APP_NAME"
UBUNTU_PKG="chromium-browser"
FEDORA_PKG="$APP_NAME"

# Load helper scripts
. "$ROOT_DIR/helpers/is_installed.sh"
. "$ROOT_DIR/helpers/pkg-helpers.sh"

is_installed() {
  case "$DISTRO" in
  arch | cachyos)
    is_installed_cmd "$CMD_NAME_ARCH"
    ;;

  ubuntu | fedora)
    is_installed_cmd "$CMD_NAME"
    ;;

  *)
    echo "$APP_NAME: Unsupported distro '$DISTRO'." >&2
    return 1
    ;;
  esac
}

install_package() {
  install_via_pkgmgr "$APP_NAME" "$ARCH_PKG" "$UBUNTU_PKG" "$FEDORA_PKG"
}
