# Application name (used in logs / messages)
APP_NAME="zellij"

# Command to check for in PATH.
# Use a different value if the binary name differs from APP_NAME.
CMD_NAME="$APP_NAME"

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
  is_installed_cmd "$CMD_NAME"
}

install_package() {
  case "$DISTRO" in
  arch | cachyos)
    sudo pacman -S --needed --noconfirm zellij || return 1
    ;;

  ubuntu)
    sudo snap install zellij --classic || return 1
    ;;

  fedora)
    sudo dnf copr enable -y varlad/zellij || return 1
    sudo dnf install -y zellij || return 1
    ;;

  *)
    echo "$APP_NAME: Unsupported distro '$DISTRO'." >&2
    return 1
    ;;
  esac
}
