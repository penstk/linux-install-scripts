# Application name (used in logs / messages)
APP_NAME="bat"

# Package names in each distro's package manager.
# Set to "" if this package is not available on that distro.
# Keep "$APP_NAME" when the package name matches APP_NAME.
ARCH_PKG="$APP_NAME"
UBUNTU_PKG="$APP_NAME"
FEDORA_PKG="$APP_NAME"

# Load helper scripts
. "$ROOT_DIR/helpers/is_installed.sh"
. "$ROOT_DIR/helpers/pkg-helpers.sh"

is_installed() {
  is_installed_cmd "bat"
}

install_package() {
  install_via_pkgmgr "$APP_NAME" "$ARCH_PKG" "$UBUNTU_PKG" "$FEDORA_PKG" || return 1

  case "$DISTRO" in
  ubuntu)
    # Ubuntu/Debian install the binary as "batcat"
    # Create a "bat" symlink to prevent any issues that may come up because of this and to be consistent with other distributions.

    if command -v bat >/dev/null 2>&1; then
      echo "bat command already exists"
      return 0
    fi

    if ! command -v batcat >/dev/null 2>&1; then
      echo "ERROR: 'batcat' not found." >&2
      return 1
    fi

    local batcat_path="$(command -v batcat)"

    mkdir -p "$HOME/.local/bin"

    local bat_path="$HOME/.local/bin/bat"
    # Check if "bat" file or symlink already exists
    if [[ -e "$bat_path" || -L "$bat_path" ]]; then
      return 0
    fi

    # Create symlink
    ln -s "$batcat_path" "$bat_path"
    ;;
  esac
}
