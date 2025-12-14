# Command to check for in PATH.
# Use a different value if the binary name differs from APP_NAME.
CMD_NAME="nvim"

# Load helper scripts
. "$ROOT_DIR/helpers/is_installed.sh"

is_installed() {
  # Check if neovim is installed
  is_installed_cmd "$CMD_NAME" || return 1
}

install_package() {
  case "$DISTRO" in
  arch | cachyos)
    sudo pacman -S --needed --noconfirm neovim
    ;;

  ubuntu)
    sudo snap install nvim --classic
    ;;

  fedora)
    sudo dnf install -y neovim
    ;;

  *)
    echo "Unsupported distro '$DISTRO'." >&2
    return 1
    ;;
  esac
}
