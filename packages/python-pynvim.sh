# Application name (used to check if the application is already installed)
APP_NAME="pynvim"

# Package names for each distro.
# Set to an empty string ("") if this package is not supported on that distro.
ARCH_PKG="python-pynvim"
UBUNTU_PKG="python3-pynvim"
FEDORA_PKG="python3-pynvim"

# Load helper scripts
. "$ROOT_DIR/helpers/repo_helper.sh"

is_installed() {
  PYTHON_CANDIDATES=("python3" "python")

  for PYTHON_BIN in "${PYTHON_CANDIDATES[@]}"; do
    if command -v "$PYTHON_BIN" >/dev/null 2>&1; then
      if "$PYTHON_BIN" -c "import pynvim" >/dev/null 2>&1; then
        return 0
      fi
    fi
  done

  return 1
}

install_package() {
  repo_install "$APP_NAME" "$ARCH_PKG" "$UBUNTU_PKG" "$FEDORA_PKG"
}
