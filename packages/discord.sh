# Application name (used in logs / messages)
APP_NAME="discord"

# Command to check for in PATH.
# Use a different value if the binary name differs from APP_NAME.
CMD_NAME="$APP_NAME"
CMD_NAME_FEDORA="Discord"

# Distro-specific dependencies:
DEPENDENCIES=()
case "$DISTRO" in
ubuntu)
  DEPENDENCIES+=(snapd)
  ;;
esac

# Load helper scripts
. "$ROOT_DIR/helpers/is_installed.sh"

is_installed() {
  case "$DISTRO" in
  arch | cachyos)
    is_installed_cmd "$CMD_NAME"
    ;;

  ubuntu)
    is_installed_cmd "$CMD_NAME"
    ;;

  fedora)
    is_installed_cmd "$CMD_NAME_FEDORA"
    ;;

  *)
    echo "$APP_NAME: Unsupported distro '$DISTRO'." >&2
    return 1
    ;;
  esac
}

install_package() {
  case "$DISTRO" in
  arch | cachyos)
    sudo pacman -S --needed --noconfirm discord || return 1
    ;;
  ubuntu)
    sudo snap install discord || return 1
    ;;

  fedora)
    sudo dnf install -y "https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm" || return 1
    sudo dnf install -y discord || return 1
    ;;

  *)
    echo "$APP_NAME: Unsupported distro '$DISTRO'." >&2
    return 1
    ;;
  esac
}
