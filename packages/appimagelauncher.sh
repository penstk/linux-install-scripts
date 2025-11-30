# Application name (used in logs / messages)
APP_NAME="appimagelauncher"

# Command to check for in PATH.
# Use a different value if the binary name differs from APP_NAME.
CMD_NAME="$APP_NAME"

# Load helper scripts
. "$ROOT_DIR/helpers/is_installed.sh"
. "$ROOT_DIR/helpers/install.sh"

is_installed() {
  is_installed_cmd "$CMD_NAME"
}

install_package() {
  case "$DISTRO" in
  arch | cachyos)
    sudo paru -S --needed --noconfirm appimagelauncher
    ;;
  ubuntu)
    sudo add-apt-repository -y ppa:appimagelauncher-team/stable
    sudo apt update
    sudo apt install -y appimagelauncher
    ;;
  fedora)
    sudo dnf -y copr enable langdon/appimagelauncher
    sudo dnf install -y appimagelauncher
    ;;
  *)
    echo "$APP_NAME: Unsupported distro '$DISTRO'." >&2
    return 1
    ;;
  esac
}
