# Application name (used in logs / messages)
APP_NAME="python3"

# Package names in each distro's package manager.
# Set to "" if this package is not available on that distro.
# Keep "$APP_NAME" when the package name matches APP_NAME.
ARCH_PKG="python"
UBUNTU_PKG="python3"
FEDORA_PKG="python3"

# Load helper scripts
. "$ROOT_DIR/helpers/pkg-helpers.sh"

is_installed() {
  # Check if python package is installed and has version 3.*
  is_installed_pkg "$ARCH_PKG" "$UBUNTU_PKG" "$FEDORA_PKG" "3" || return 1

  # Check if 'python' or 'python3' command is available
  is_installed_cmd python || is_installed_cmd python3 || return 1
}

install_package() {
  install_via_pkgmgr "$APP_NAME" "$ARCH_PKG" "$UBUNTU_PKG" "$FEDORA_PKG"
}
