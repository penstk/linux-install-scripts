# Application name (used in logs / messages)
APP_NAME="ferdium"

# Command to check for in PATH.
# Use a different value if the binary name differs from APP_NAME.
CMD_NAME="$APP_NAME"
CMD_NAME="flatpak run org.ferdium.Ferdium"

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
  is_installed_cmd "$CMD_NAME"
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
