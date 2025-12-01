# Application name (used in logs / messages)
APP_NAME="asdf-vm"

# Command to check for in PATH.
CMD_NAME="asdf"

# Distro-specific dependencies:
DEPENDENCIES=()
case "$DISTRO" in
ubuntu | fedora)
  DEPENDENCIES+=(git)
  ;;
esac

# Load helper scripts
. "$ROOT_DIR/helpers/is_installed.sh"
. "$ROOT_DIR/helpers/github.sh"
. "$ROOT_DIR/helpers/install.sh"

# Check if already installed
is_installed() {
  is_installed_cmd "$CMD_NAME"
}

# Detect asdf binary archive suffix for this machine
detect_asdf_arch() {
  local machine_arch
  machine_arch="$(uname -m)"

  case "$machine_arch" in
  x86_64 | amd64)
    echo "linux-amd64"
    ;;
  aarch64 | arm64)
    echo "linux-arm64"
    ;;
  i386 | i686)
    echo "linux-386"
    ;;
  *)
    echo "$APP_NAME: unsupported architecture '$machine_arch'" >&2
    return 1
    ;;
  esac
}

# Install latest asdf binary from GitHub (system-wide)
install_asdf_from_github() {
  local asdf_arch archive_pattern url
  local repo="asdf-vm/asdf"

  asdf_arch="$(detect_asdf_arch)" || return 1

  # Match assets like: asdf-v0.18.0-linux-amd64.tar.gz
  archive_pattern="asdf-v[0-9.]+-${asdf_arch}\\.tar\\.gz$"

  url="$(github_latest_asset_url "$repo" "$archive_pattern")" || true
  if [[ -z "$url" ]]; then
    echo "$APP_NAME: could not find archive matching '$archive_pattern' in latest release" >&2
    return 1
  fi

  echo "Installing $APP_NAME from GitHub release:"
  echo "  $url"

  # Extract the "asdf" binary into /usr/local/bin (must be on PATH)
  install_binary_from_url "$url" "asdf" "/usr/local/bin"
}

# Main package install
install_package() {
  case "$DISTRO" in
  arch | cachyos)
    paru -S --needed --noconfirm asdf-vm
    ;;

  ubuntu | fedora)
    install_asdf_from_github
    ;;

  *)
    echo "$APP_NAME: Unsupported distro '$DISTRO'." >&2
    return 1
    ;;
  esac
}
