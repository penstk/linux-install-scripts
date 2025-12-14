# Application name (used in logs / messages)
APP_NAME="freerdp"

# Load helper scripts
. "$ROOT_DIR/helpers/is_installed.sh"

is_installed() {
  case "$DISTRO" in
  arch | cachyos | ubuntu)
    is_installed_cmd "xfreerdp3" && is_installed_cmd "wlfreerdp3"
    ;;
  fedora)
    is_installed_cmd "xfreerdp" && is_installed_cmd "wlfreerdp"
    ;;
  esac
}

install_package() {
  case "$DISTRO" in
  arch | cachyos)
    sudo pacman -S --needed --noconfirm "freerdp" || return 1
    ;;
  ubuntu)
    sudo apt-get install -y "freerdp3-x11" "freerdp3-wayland" || return 1
    ;;
  fedora)
    sudo dnf install -y "freerdp" || return 1
    ;;
  *)
    echo "$APP_NAME: Unsupported distro '$DISTRO'." >&2
    return 1
    ;;
  esac
}
