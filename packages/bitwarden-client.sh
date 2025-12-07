# Application name (used in logs / messages)
APP_NAME="bitwarden-client"

# Distro-specific dependencies:
DEPENDENCIES=()
case "$DISTRO" in
arch | cachyos | fedora)
  DEPENDENCIES+=(flatpak)
  ;;
ubuntu)
  DEPENDENCIES+=(snapd)
  ;;
esac

# Load helper scripts
. "$ROOT_DIR/helpers/is_installed.sh"

is_installed() {
  case "$DISTRO" in
  arch | cachyos | fedora)
    flatpak info com.bitwarden.desktop &>/dev/null
    ;;
  *)
    is_installed_cmd "bitwarden"
    ;;
  esac
}

install_package() {
  case "$DISTRO" in
  arch | cachyos | fedora)
    sudo flatpak install -y flathub com.bitwarden.desktop
    ;;

  ubuntu)
    sudo snap install bitwarden
    sudo snap connect bitwarden:password-manager-service
    ;;

  *)
    echo "$APP_NAME: Unsupported distro '$DISTRO'." >&2
    return 1
    ;;
  esac
}
