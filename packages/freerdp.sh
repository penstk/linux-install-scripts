# Application name (used in logs / messages)
APP_NAME="freerdp"

# Load helper scripts
. "$ROOT_DIR/helpers/is_installed.sh"

is_installed() {
  is_installed_cmd "xfreerdp3" && is_installed_cmd "wlfreerdp3"
}

install_package() {
  case "$DISTRO" in
  arch | cachyos)
    sudo pacman -S --needed --noconfirm "freerdp"
    ;;
  ubuntu)
    sudo apt-get install -y "freerdp2-x11" "freerdp2-wayland"
    ;;
  fedora)
    sudo dnf install -y "freerdp"
    ;;
  *)
    echo "$APP_NAME: Unsupported distro '$DISTRO'." >&2
    return 1
    ;;
  esac
}
