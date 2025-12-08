# Application name (used in logs / messages)
APP_NAME="pynvim"

# Packages that should be installed before installing this package.
# Each entry must correspond to another package script in the packages directory (without .sh).
DEPENDENCIES=(
  python3
  neovim
)

# Package names in each distro's package manager.
# Set to "" if this package is not available on that distro.
# Keep "$APP_NAME" when the package name matches APP_NAME.
ARCH_PKG="python-pynvim"
UBUNTU_PKG="python3-neovim"
FEDORA_PKG="python3-pynvim"

# Load helper scripts
. "$ROOT_DIR/helpers/pkg-helpers.sh"

# Helper function to check if pynvim is installed
# _python_has_pynvim() {
#   local PYTHON_CANDIDATES=("python3" "python")
#   local PYTHON_BIN
#
#   for PYTHON_BIN in "${PYTHON_CANDIDATES[@]}"; do
#     if command -v "$PYTHON_BIN" >/dev/null 2>&1 &&
#       "$PYTHON_BIN" -c "import pynvim" >/dev/null 2>&1; then
#       return 0
#     fi
#   done
#
#   return 1
# }

is_installed() {
  # Check if all dependencies installed
  is_installed_deps "${DEPENDENCIES[@]}" || return 1

  # Check if pynvim package is installed via package manager
  is_installed_pkg "$ARCH_PKG" "$UBUNTU_PKG" "$FEDORA_PKG" || return 1
}

install_package() {
  install_via_pkgmgr "$APP_NAME" "$ARCH_PKG" "$UBUNTU_PKG" "$FEDORA_PKG"
}
