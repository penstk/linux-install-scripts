# Application name (used in logs / messages)
APP_NAME="snapd"

# Command to check for in PATH.
CMD_NAME="snap"

# Distro-specific dependencies:
DEPENDENCIES=()
case "$DISTRO" in
arch | cachyos)
  DEPENDENCIES+=(paru)
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
    paru -S --needed --noconfirm snapd
    ;;

  ubuntu)
    sudo apt-get install -y snapd
    ;;

  fedora)
    sudo dnf install -y snapd
    ;;

  *)
    echo "$APP_NAME: Unsupported distro '$DISTRO'." >&2
    return 1
    ;;
  esac
}
