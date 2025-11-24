# Application name (used to check if the application is already installed)
APP_NAME="pip"

# Package names for each distro.
# Set to an empty string ("") if this package is not supported on that distro.
ARCH_PKG="python-pip"
UBUNTU_PKG="python3-pip"
FEDORA_PKG="python3-pip"

# Load helper scripts
. "$ROOT_DIR/helpers/repo_helper.sh"
. "$ROOT_DIR/helpers/repo_helper.sh"

# Check if either "pip" or "pip3" exists
is_installed() {
  if cmd_is_installed pip3 || cmd_is_installed pip; then
    return 0
  fi
  return 1
}

install_package() {
  repo_install "$APP_NAME" "$ARCH_PKG" "$UBUNTU_PKG" "$FEDORA_PKG"
}
