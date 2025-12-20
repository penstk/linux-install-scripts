# Application name (used in logs / messages)
APP_NAME="webex"

# Command to check for in PATH.
# Use a different value if the binary name differs from APP_NAME.
CMD_NAME="$APP_NAME"

# Distro-specific dependencies:
DEPENDENCIES=()
case "$DISTRO" in
ubuntu | fedora)
  DEPENDENCIES+=(curl)
  ;;
esac

# Download URLs
DEB_URL="https://binaries.webex.com/WebexDesktop-Ubuntu-Official-Package/Webex.deb"
RPM_URL="https://binaries.webex.com/WebexDesktop-CentOS-Official-Package/Webex.rpm"

# Load helper scripts
. "$ROOT_DIR/helpers/is_installed.sh"
. "$ROOT_DIR/helpers/pkg-helpers.sh"

is_installed() {
  is_installed_cmd "$CMD_NAME"
}

install_package() {
  case "$DISTRO" in
  arch | cachyos)
    sudo paru -S --needed --noconfirm webex-bin || return 1
    ;;
  ubuntu)
    install_pkg_from_url "$DEB_URL" || return 1
    ;;

  fedora)
    install_pkg_from_url "$RPM_URL" || return 1
    ;;

  *)
    echo "$APP_NAME: Unsupported distro '$DISTRO'." >&2
    return 1
    ;;
  esac
}
