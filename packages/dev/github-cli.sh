# Application name (used to check if the application is already installed)
APP_NAME="github-cli"
CMD_NAME="gh"

# Package names for each distro family.
# Set to an empty string ("") if this package is not supported on that distro.
ARCH_PKG="github-cli"
DEBIAN_PKG=""
REDHAT_PKG=""

# Load helper scripts
. "$ROOT_DIR/helpers/cmd_helper.sh"
. "$ROOT_DIR/helpers/repo_helper.sh"

is_installed() {
  cmd_is_installed "$CMD_NAME"
}

install_package() {
  repo_install "$APP_NAME" "$ARCH_PKG" "$DEBIAN_PKG" "$REDHAT_PKG"
}
