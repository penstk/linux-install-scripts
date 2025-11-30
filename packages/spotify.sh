# Application name (used in logs / messages)
APP_NAME="spotify"

# Command to check for in PATH.
# Use a different value if the binary name differs from APP_NAME.
CMD_NAME_ARCH="spotify-launcher"
CMD_NAME_UBUNTU="spotify"
CMD_NAME_FEDORA="flatpak run com.spotify.Client"

# Distro-specific dependencies:
DEPENDENCIES=()
case "$DISTRO" in
ubuntu)
  DEPENDENCIES+=(snapd)
  ;;
fedora)
  DEPENDENCIES+=(flatpak)
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
    is_installed_deps "${DEPENDENCIES[@]}" && is_installed_cmd "$CMD_NAME_UBUNTU"
    ;;

  fedora)
    is_installed_deps "${DEPENDENCIES[@]}" && is_installed_cmd "$CMD_NAME_FEDORA"
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
    sudo flatpak install -y flathub com.spotify.Client
    ;;

  *)
    echo "$APP_NAME: Unsupported distro '$DISTRO'." >&2
    return 1
    ;;
  esac
}
