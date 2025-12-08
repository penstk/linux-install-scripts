# Application name (used in logs / messages)
APP_NAME="winboat"

# Packages that should be installed before installing this package.
# Each entry must correspond to another package script in the packages directory (without .sh).
# shellcheck disable=SC2034 # used by install.sh dependency resolver
DEPENDENCIES=(
  docker
  freerdp
)
# Load helper scripts
. "$ROOT_DIR/helpers/github.sh"
. "$ROOT_DIR/helpers/pkg-helpers.sh"

# Check if already installed
is_installed() {
  case "$DISTRO" in
  arch | cachyos)
    if pacman -Q winboat >/dev/null 2>&1 ||
      pacman -Q winboat-bin >/dev/null 2>&1 ||
      pacman -Q winboat-electron >/dev/null 2>&1; then
      return 0
    fi
    return 1
    ;;

  ubuntu)
    if dpkg -s winboat >/dev/null 2>&1; then
      return 0
    fi
    return 1
    ;;

  fedora)
    if dnf -q list installed winboat >/dev/null 2>&1; then
      return 0
    fi
    return 1
    ;;
  esac
}

# Get system architecture to find the correct package
# $1 = deb|rpm
detect_arch() {
  local pkg_type="$1" machine_arch
  machine_arch="$(uname -m)"

  case "$pkg_type:$machine_arch" in
  deb:x86_64 | deb:amd64) echo "amd64" ;;
  rpm:x86_64 | rpm:amd64) echo "x86_64" ;;
  *)
    echo "$APP_NAME: unsupported arch '$machine_arch' for $pkg_type package" >&2
    return 1
    ;;
  esac
}

# Install latest WinBoat .deb/.rpm from GitHub
# $1 = deb|rpm
install_from_github_pkg() {
  local pkg_type="$1" arch pattern url
  local repo="TibixDev/winboat"

  arch="$(detect_arch "$pkg_type")" || return 1

  # Pattern is used by github_latest_asset_url (grep -E) on browser_download_url.
  pattern="winboat.*${arch}.*\.${pkg_type}$"

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
    paru -S --needed --noconfirm winboat-bin
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
