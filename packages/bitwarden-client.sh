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
    sudo pacman -S --needed --noconfirm bitwarden || return 1
    ;;

  ubuntu)
    sudo snap install bitwarden || return 1
    sudo snap connect bitwarden:password-manager-service || return 1
    ;;
  fedora)
    sudo flatpak install -y flathub com.bitwarden.desktop || return 1
    ;;
  *)
    echo "$APP_NAME: Unsupported distro '$DISTRO'." >&2
    return 1
    ;;
  esac
}
