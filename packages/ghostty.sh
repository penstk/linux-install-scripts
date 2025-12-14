# Application name (used in logs / messages)
APP_NAME="ghostty"

# Command to check for in PATH.
# Use a different value if the binary name differs from APP_NAME.
CMD_NAME="$APP_NAME"

# Load helper scripts
. "$ROOT_DIR/helpers/pkg-helpers.sh"

is_installed() {
  is_installed_cmd "$CMD_NAME"
}

install_package() {
  case "$DISTRO" in
  arch | cachyos)
    sudo pacman -S --needed --noconfirm ghostty || return 1
    ;;
  ubuntu)
    sudo snap install ghostty --classic || return 1
    ;;
  fedora)
    sudo dnf -y copr enable scottames/ghostty || return 1
    sudo dnf install -y ghostty || return 1
    ;;
  *)
    echo "$APP_NAME: Unsupported distro '$DISTRO'." >&2
    return 1
    ;;
  esac
}
