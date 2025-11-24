APP_NAME="zsh"

# Package names for each distro.
# Set to an empty string ("") if this package is not supported on that distro.
ARCH_PKG="zsh"
UBUNTU_PKG="zsh"
FEDORA_PKG="zsh"

# Load helper scripts
. "$ROOT_DIR/helpers/cmd_helper.sh"
. "$ROOT_DIR/helpers/repo_helper.sh"

is_installed() {
  cmd_is_installed "$APP_NAME"
}

install_package() {
  repo_install "$APP_NAME" "$ARCH_PKG" "$UBUNTU_PKG" "$FEDORA_PKG"
}
