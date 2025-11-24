APP_NAME="unzip"

# Package names for each distro.
# Set to an empty string ("") if this package is not supported on that distro.
ARCH_PKG="unzip"
UBUNTU_PKG="unzip"
FEDORA_PKG="unzip"

# Load helper scripts
. "$ROOT_DIR/helpers/cmd_helper.sh"
. "$ROOT_DIR/helpers/repo_helper.sh"

is_installed() {
  cmd_is_installed "$APP_NAME"
}

install_package() {
  repo_install "$APP_NAME" "$ARCH_PKG" "$UBUNTU_PKG" "$FEDORA_PKG"
}
