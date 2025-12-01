# Application name (used in logs / messages)
APP_NAME="zellij"

# Command to check for in PATH.
# Use a different value if the binary name differs from APP_NAME.
CMD_NAME="$APP_NAME"

# Distro-specific dependencies:
DEPENDENCIES=()
case "$DISTRO" in
ubuntu)
  DEPENDENCIES+=(rustup)
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
    sudo pacman -S --needed --noconfirm zellij
    ;;

  ubuntu)
    BINSTALL_DISABLE_TELEMETRY=true \
      cargo binstall --no-confirm zellij
    ;;

  fedora)
    sudo dnf copr enable varlad/zellij
    sudo dnf install -y zellij
    ;;

  *)
    echo "$APP_NAME: Unsupported distro '$DISTRO'." >&2
    return 1
    ;;
  esac
}
