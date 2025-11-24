# Application name (used to check if the application is already installed)
APP_NAME="kitty"

# Package names for each distro.
# Set to an empty string ("") if this package is not supported on that distro.
ARCH_PKG="kitty"
UBUNTU_PKG="kitty"
FEDORA_PKG="kitty"

# Load helper scripts
. "$ROOT_DIR/helpers/cmd_helper.sh"
. "$ROOT_DIR/helpers/repo_helper.sh"

is_installed() {
  cmd_is_installed "$APP_NAME"
}

install_package() {
  repo_install "$APP_NAME" "$ARCH_PKG" "$UBUNTU_PKG" "$FEDORA_PKG"
}
