# Application name (used in logs / messages)
APP_NAME="spotify"

# Command to check for in PATH.
# Use a different value if the binary name differs from APP_NAME.
CMD_NAME="spotify-launcher"

# Load helper scripts
. "$ROOT_DIR/helpers/is_installed.sh"

is_installed() {
  is_installed_cmd "$CMD_NAME"
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
    # Enable rpmfusion repositories
    sudo dnf install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
    sudo dnf install https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
    # Install
    sudo dnf install lpf-spotify-client
    lpf update
    ;;

  *)
    echo "$APP_NAME: Unsupported distro '$DISTRO'." >&2
    return 1
    ;;
  esac
}
