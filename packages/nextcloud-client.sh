# Application name (used in logs / messages)
APP_NAME="nextcloud-client"

# Command to check for in PATH.
# Use a different value if the binary name differs from APP_NAME.
CMD_NAME="nextcloud"

# Package names in each distro's package manager.
# Set to "" if this package is not available on that distro.
# Keep "$APP_NAME" when the package name matches APP_NAME.
ARCH_PKG="nextcloud-client"
UBUNTU_PKG="nextcloud-desktop"
FEDORA_PKG="nextcloud-client"

# Load helper scripts
. "$ROOT_DIR/helpers/is_installed.sh"
. "$ROOT_DIR/helpers/install.sh"

is_installed() {
  is_installed_cmd "$CMD_NAME"
}

install_package() {
  install_via_pkgmgr "$APP_NAME" "$ARCH_PKG" "$UBUNTU_PKG" "$FEDORA_PKG"
}
