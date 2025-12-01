# Application name (used in logs / messages)
APP_NAME="lazydocker"

# Command to check for in PATH.
CMD_NAME="$APP_NAME"

# Distro-specific dependencies
DEPENDENCIES=()
case "$DISTRO" in
arch | cachyos)
  DEPENDENCIES+=(paru)
  ;;
ubuntu | fedora)
  DEPENDENCIES+=(curl)
  ;;
esac

# Load helper scripts
. "$ROOT_DIR/helpers/is_installed.sh"

is_installed() {
  is_installed_deps "${DEPENDENCIES[@]}" && is_installed_cmd "$CMD_NAME"
}

install_package() {
  case "$DISTRO" in
  arch | cachyos)
    paru -S --needed --noconfirm lazydocker
    ;;

  ubuntu | fedora)
    # Use official install script, but installed to /usr/local/bin for all users
    local url="https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh"
    curl -fsSL "$url" | sudo DIR=/usr/local/bin bash
    ;;

  *)
    echo "$APP_NAME: Unsupported distro '$DISTRO'." >&2
    return 1
    ;;
  esac
}
