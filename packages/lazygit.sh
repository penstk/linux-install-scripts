# Application name (used to check if the application is already installed)
APP_NAME="lazygit"
CMD_NAME="lazygit"

# Load helper scripts
. "$ROOT_DIR/helpers/cmd_helper.sh"
. "$ROOT_DIR/helpers/repo_helper.sh"

is_installed() {
  cmd_is_installed "$CMD_NAME"
}

install_package() {
  case "$DISTRO" in
  arch | cachyos)
    sudo pacman -S --needed --noconfirm lazygit
    ;;
  ubuntu)
    sudo apt install lazygit
    ;;
  fedora)
    sudo dnf copr enable dejan/lazygit
    sudo dnf install lazygit
    ;;
  *)
    echo "$APP_NAME: Unsupported distro '$DISTRO'." >&2
    return 1
    ;;
  esac
}
