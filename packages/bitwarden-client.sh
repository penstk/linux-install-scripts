# Application name (used in logs / messages)
APP_NAME="bitwarden-client"

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
    is_installed_cmd "bitwarden-desktop"
    ;;
  ubuntu)
    is_installed_cmd "bitwarden"
    ;;
  fedora)
    flatpak info com.bitwarden.desktop &>/dev/null
    ;;
  esac
}

install_package() {
  case "$DISTRO" in
  arch | cachyos)
    sudo pacman -S --needed --noconfirm bitwarden
    ;;

  ubuntu)
    sudo snap install bitwarden
    sudo snap connect bitwarden:password-manager-service
    ;;
  fedora)
    sudo flatpak install -y flathub com.bitwarden.desktop
    ;;
  *)
    echo "$APP_NAME: Unsupported distro '$DISTRO'." >&2
    return 1
    ;;
  esac
}
