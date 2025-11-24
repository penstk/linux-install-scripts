# Application name (used to check if the application is already installed)
APP_NAME="jetbrains-mono-nerd-font"

# Load helper scripts
. "$ROOT_DIR/helpers/repo_helper.sh"

is_installed() {
  cmd_is_installed "$CMD_NAME"
}

install_package() {
  case "$DISTRO" in
  arch | cachyos)
    sudo pacman -S --needed --noconfirm ttf-jetbrains-mono-nerd
    ;;
  ubuntu)
    echo "$APP_NAME: Ubuntu install not implemented." >&2
    return 1
    ;;
  fedora)
    echo "$APP_NAME: Fedora install not implemented." >&2
    return 1
    ;;
  *)
    echo "$APP_NAME: Unsupported distro '$DISTRO'." >&2
    return 1
    ;;
  esac
}
