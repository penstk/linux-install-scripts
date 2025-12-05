# Application name (used in logs / messages)
APP_NAME="spotify-player"

# Command to check for in PATH.
# Use a different value if the binary name differs from APP_NAME.
CMD_NAME="spotify_player"

# Distro-specific dependencies:
DEPENDENCIES=()
case "$DISTRO" in
ubuntu | fedora)
  DEPENDENCIES+=(rustup)
  ;;
esac

# Package names in each distro's package manager.
# Set to "" if this package is not available on that distro.
# Keep "$APP_NAME" when the package name matches APP_NAME.
ARCH_PKG="$APP_NAME"
UBUNTU_PKG=""
FEDORA_PKG=""

# Load helper scripts
. "$ROOT_DIR/helpers/is_installed.sh"
. "$ROOT_DIR/helpers/install.sh"

is_installed() {
  is_installed_cmd "$CMD_NAME"
}

install_package() {
  install_via_pkgmgr "$APP_NAME" "$ARCH_PKG" "$UBUNTU_PKG" "$FEDORA_PKG"
  case "$DISTRO" in
  arch | cachyos)
    sudo pacman -S --needed --noconfirm spotify-player
    ;;

  ubuntu | fedora)
    cargo install spotify_player --locked
    ;;

  *)
    echo "$APP_NAME: Unsupported distro '$DISTRO'." >&2
    return 1
    ;;
  esac
}
