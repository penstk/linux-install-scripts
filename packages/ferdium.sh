# Application name (used in logs / messages)
APP_NAME="ferdium"

# Distro-specific dependencies:
DEPENDENCIES=()
case "$DISTRO" in
arch | cachyos)
  DEPENDENCIES+=(paru)
  ;;
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
  fedora)
    is_installed_deps "${DEPENDENCIES[@]}" && flatpak info org.ferdium.Ferdium &>/dev/null
    ;;
  *)
    is_installed_deps "${DEPENDENCIES[@]}" && is_installed_cmd "ferdium"
    ;;
  esac
}

install_package() {
  case "$DISTRO" in
  arch | cachyos)
    paru -S --noconfirm --needed ferdium-bin
    ;;
  ubuntu)
    sudo snap install ferdium
    ;;
  fedora)
    sudo flatpak install -y flathub org.ferdium.Ferdium
    ;;
  *)
    echo "$APP_NAME: Unsupported distro '$DISTRO'." >&2
    return 1
    ;;
  esac
}
