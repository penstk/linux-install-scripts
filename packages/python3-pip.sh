# Application name (used in logs / messages)
APP_NAME="python3-pip"

# Packages that should be installed before installing this package.
# Each entry must correspond to another package script in the packages directory (without .sh).
DEPENDENCIES=(
  python3
)

# Package names in each distro's package manager.
# Set to "" if this package is not available on that distro.
# Keep "$APP_NAME" when the package name matches APP_NAME.
ARCH_PKG="python-pip"
UBUNTU_PKG="python3-pip"
FEDORA_PKG="python3-pip"

# Load helper scripts
. "$ROOT_DIR/helpers/is_installed.sh"
. "$ROOT_DIR/helpers/pkg-helpers.sh"

is_installed() {
  # All dependencies installed AND we have either pip3 or pip
  is_installed_deps "${DEPENDENCIES[@]}" &&
    { is_installed_cmd pip3 || is_installed_cmd pip; }
}

install_package() {
  install_via_pkgmgr "$APP_NAME" "$ARCH_PKG" "$UBUNTU_PKG" "$FEDORA_PKG"
}
