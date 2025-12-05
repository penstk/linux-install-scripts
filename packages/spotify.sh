# Application name (used in logs / messages)
APP_NAME="spotify"

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
    is_installed_cmd "spotify-launcher"
    ;;

  ubuntu)
    is_installed_cmd "spotify"
    ;;

  fedora)
    flatpak info com.spotify.Client &>/dev/null
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
