# Application name (used in logs / messages)
APP_NAME="brave"

# Command to check for in PATH.
CMD_NAME="brave-browser"
CMD_NAME_ARCH="brave"

# Distro-specific dependencies:
DEPENDENCIES=()
case "$DISTRO" in
arch | cachyos)
  DEPENDENCIES+=(paru)
  ;;

ubuntu)
  DEPENDENCIES+=(curl)
  ;;
esac

# Load helper scripts
. "$ROOT_DIR/helpers/is_installed.sh"
. "$ROOT_DIR/helpers/pkg-helpers.sh"

is_installed() {
  case "$DISTRO" in
  arch | cachyos)
    is_installed_cmd "$CMD_NAME_ARCH"
    ;;

  ubuntu | fedora)
    is_installed_cmd "$CMD_NAME"
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
    paru -S --needed --noconfirm brave-bin || return 1
    ;;

  ubuntu)
    sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg || return 1
    sudo curl -fsSLo /etc/apt/sources.list.d/brave-browser-release.sources https://brave-browser-apt-release.s3.brave.com/brave-browser.sources || return 1
    sudo apt-get update || return 1
    sudo apt-get install -y brave-browser || return 1
    ;;

  fedora)
    sudo dnf install -y dnf-plugins-core || return 1
    sudo dnf config-manager addrepo --from-repofile=https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo || return 1
    sudo dnf install -y brave-browser || return 1
    ;;

  *)
    echo "$APP_NAME: Unsupported distro '$DISTRO'." >&2
    return 1
    ;;
  esac
}
