# Application name (used in logs / messages)
APP_NAME="jetbrains-mono-nerd-font"

# Load helper scripts
. "$ROOT_DIR/helpers/install.sh"

is_installed() {
  case "$DISTRO" in
  arch | cachyos)
    # Check if the package is installed via pacman
    if pacman -Q ttf-jetbrains-mono-nerd &>/dev/null; then
      return 0 # installed
    else
      return 1 # not installed
    fi
    ;;
  ubuntu)
    echo "$APP_NAME: Ubuntu is_installed check not implemented." >&2
    return 1
    ;;
  fedora)
    echo "$APP_NAME: Fedora is_installed check not implemented." >&2
    return 1
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
