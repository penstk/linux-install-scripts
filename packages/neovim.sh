# Command to check for in PATH.
# Use a different value if the binary name differs from APP_NAME.
CMD_NAME="nvim"

# Packages that should be installed before installing this package.
# Each entry must correspond to another package script in the packages directory (without .sh).
# shellcheck disable=SC2034 # used by install.sh dependency resolver
DEPENDENCIES=(
  neovim-pynvim
  neovim-npm_npm
)

# Load helper scripts
. "$ROOT_DIR/helpers/is_installed.sh"

is_installed() {
  # Check if all dependencies installed
  is_installed_deps "${DEPENDENCIES[@]}" || return 1

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
