# Application name (used in logs / messages)
APP_NAME="appimagelauncher"

# Command to check for in PATH.
# Use a different value if the binary name differs from APP_NAME.
CMD_NAME="ail-cli"

# Load helper scripts
. "$ROOT_DIR/helpers/is_installed.sh"
. "$ROOT_DIR/helpers/github-helpers.sh"
. "$ROOT_DIR/helpers/pkg-helpers.sh"

# Check if already installed
is_installed() {
  is_installed_cmd "$CMD_NAME"
}

# Get system architecture to find the correct package
# $1 = deb|rpm
detect_arch() {
  local pkg_type="$1" machine_arch
  machine_arch="$(uname -m)"

  case "$pkg_type:$machine_arch" in
  deb:x86_64 | deb:amd64) echo "amd64" ;;
  deb:aarch64 | deb:arm64) echo "arm64" ;;
  deb:armv7l | deb:armhf) echo "armhf" ;;
  rpm:x86_64 | rpm:amd64) echo "x86_64" ;;
  rpm:aarch64 | rpm:arm64) echo "aarch64" ;;
  rpm:armv7l) echo "armv7hl" ;;
  *)
    echo "$APP_NAME: unsupported arch '$machine_arch' for $pkg_type package" >&2
    return 1
    ;;
  esac
}

# Install latest AppImageLauncher .deb/.rpm from GitHub using shared helpers
# $1 = deb|rpm
install_from_github_pkg() {
  local pkg_type="$1" arch pattern url
  local repo="TheAssassin/AppImageLauncher"

  arch="$(detect_arch "$pkg_type")" || return 1

  # Pattern is used by github_latest_asset_url (grep -E) on browser_download_url.
  pattern="AppImageLauncher.*${arch}.*\.${pkg_type}$"

  # Get URL of the latest matching asset
  url="$(github_latest_asset_url "$repo" "$pattern")" || true
  if [[ -z "$url" ]]; then
    echo "$APP_NAME: could not find .$pkg_type asset for arch '$arch' in latest release" >&2
    return 1
  fi

  echo "Installing $APP_NAME from GitHub release:"
  echo "  $url"

  # Use generic helper to download & install .deb/.rpm
  install_pkg_from_url "$url"
}

# Main package install
install_package() {
  case "$DISTRO" in
  arch | cachyos)
    paru -S --needed --noconfirm appimagelauncher
    ;;

  ubuntu)
    install_from_github_pkg deb
    ;;

  fedora)
    install_from_github_pkg rpm
    ;;

  *)
    echo "$APP_NAME: Unsupported distro '$DISTRO'." >&2
    return 1
    ;;
  esac
}
