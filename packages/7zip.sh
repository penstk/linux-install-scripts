# Application name (used in logs / messages)
APP_NAME="7-Zip"

# Command to check for in PATH.
# Use a different value if the binary name differs from APP_NAME.
CMD_NAME="7z"

# Load helper scripts
. "$ROOT_DIR/helpers/is_installed.sh"

is_installed() {
  is_installed_cmd "$CMD_NAME"
}

install_package() {
  case "$DISTRO" in
  arch | cachyos)
    sudo pacman -S --needed --noconfirm "7zip"
    ;;
  ubuntu)
    sudo apt-get install -y "p7zip-full"
    ;;
  fedora)
    sudo dnf install -y "p7zip" "p7zip-plugins"
    ;;
  *)
    echo "$APP_NAME: Unsupported distro '$DISTRO'." >&2
    return 1
    ;;
  esac
}
