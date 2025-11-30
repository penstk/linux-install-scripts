# Application name (used in logs / messages)
APP_NAME="python3"

# Package names in each distro's package manager.
# Set to "" if this package is not available on that distro.
# Keep "$APP_NAME" when the package name matches APP_NAME.
ARCH_PKG="python"
UBUNTU_PKG="python3"
FEDORA_PKG="python3"

# Load helper scripts
. "$ROOT_DIR/helpers/install.sh"

# Helper: check if given command exists and is Python 3.x
_python_cmd_is_v3() {
  local cmd=$1

  # Command must exist
  if ! command -v "$cmd" >/dev/null 2>&1; then
    return 1
  fi

  # Capture version string safely - do not tregger set -e aborts
  local out
  if ! out=$("$cmd" --version 2>&1); then
    return 1
  fi

  # Expected format: "Python 3.x.y"
  # Strip leading "Python " if present
  out=${out#Python }

  # Extract major part before first dot
  local major=${out%%.*}

  [[ "$major" == "3" ]]
}

# Check if either "python" or "python3" exists and is version 3.x
is_installed() {
  if _python_cmd_is_v3 python; then
    return 0
  fi

  if _python_cmd_is_v3 python3; then
    return 0
  fi

  return 1
}

install_package() {
  install_via_pkgmgr "$APP_NAME" "$ARCH_PKG" "$UBUNTU_PKG" "$FEDORA_PKG"
}
