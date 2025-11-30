# Application name (used in logs / messages)
APP_NAME="spotify"

# Command to check for in PATH.
# Use a different value if the binary name differs from APP_NAME.
CMD_NAME="$APP_NAME"
CMD_NAME_ARCH="spotify-launcher"

# Distro-specific dependencies:
DEPENDENCIES=()
case "$DISTRO" in
ubuntu)
  DEPENDENCIES+=(snapd)
  ;;
esac

# Load helper scripts
. "$ROOT_DIR/helpers/is_installed.sh"

is_installed() {
  case "$DISTRO" in
  arch | cachyos)
    is_installed_cmd "$CMD_NAME_ARCH"
    ;;

  ubuntu)
    is_installed_deps "${DEPENDENCIES[@]}" && is_installed_cmd "$CMD_NAME"
    ;;

  fedora)
    is_installed_cmd "$CMD_NAME"
    ;;

  *)
    echo "$APP_NAME: Unsupported distro '$DISTRO'." >&2
    return 1
    ;;
  esac
}

install_package() {
  case "$DISTRO" in
  arch | cachyos)
    sudo pacman -S --needed --noconfirm spotify-launcher
    ;;

  ubuntu)
    sudo snap install spotify
    ;;

  fedora)
    # Enable rpmfusion repositories
    sudo dnf install -y https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
    sudo dnf install -y https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
    # Install
    sudo dnf install -y lpf-spotify-client
    lpf update
    ;;

  *)
    echo "$APP_NAME: Unsupported distro '$DISTRO'." >&2
    return 1
    ;;
  esac
}
