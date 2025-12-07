# Application name (used in logs / messages)
APP_NAME="7-Zip"

# Command to check for in PATH.
# Use a different value if the binary name differs from APP_NAME.
CMD_NAME="7z"

# Package names in each distro's package manager.
# Set to "" if this package is not available on that distro.
# Keep "$APP_NAME" when the package name matches APP_NAME.
ARCH_PKG="7zip"
UBUNTU_PKG="p7zip-full"
FEDORA_PKG="p7zip p7zip-plugins"

# Load helper scripts
. "$ROOT_DIR/helpers/is_installed.sh"
. "$ROOT_DIR/helpers/install.sh"

is_installed() {
  is_installed_cmd "$CMD_NAME"
}

install_package() {
  install_via_pkgmgr "$APP_NAME" "$ARCH_PKG" "$UBUNTU_PKG" "$FEDORA_PKG"
}
