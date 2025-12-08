# Application name (used in logs / messages)
APP_NAME="protonmail-bridge"

# Command to check for in PATH.
CMD_NAME="$APP_NAME"

# Packages that should be installed before installing this package.
# Each entry must correspond to another package script in the packages directory (without .sh).
# shellcheck disable=SC2034 # used by install.sh dependency resolver
DEPENDENCIES=(
  jq
)

# Load helper scripts
. "$ROOT_DIR/helpers/is_installed.sh"
. "$ROOT_DIR/helpers/pkg-helpers.sh"

###############################################################################
# Check if already installed
###############################################################################
is_installed() {
  is_installed_cmd "$CMD_NAME"
}

###############################################################################
# Ensure we're on a supported architecture
# Proton's .deb/.rpm packages are currently only built for x86_64/amd64.
###############################################################################
is_supported_arch() {
  case "$(uname -m)" in
  x86_64 | amd64)
    return 0
    ;;
  *)
    echo "$APP_NAME: official Proton .deb/.rpm packages are only provided for x86_64/amd64 (got '$(uname -m)')." >&2
    return 1
    ;;
  esac
}

###############################################################################
# Install from Proton JSON for a given package field
#   $1 = field in JSON (DebFile | RpmFile)
#   $2 = human-readable distro label (e.g. "Ubuntu", "Fedora")
###############################################################################
install_from_proton() {
  local field="$1"

  is_supported_arch || return 1

  url="$(curl -fsSL "https://protonmail.com/download/current_version_linux.json" | jq -r ".${field}")"
  if [[ -z "$url" || "$url" == "null" ]]; then
    echo "$APP_NAME: failed to get latest ${field} URL from Proton." >&2
    return 1
  fi

  install_pkg_from_url "$url"
}

###############################################################################
# Main install entry point
###############################################################################
install_package() {
  case "$DISTRO" in
  arch | cachyos)
    # Official Arch package
    sudo pacman -S --needed --noconfirm protonmail-bridge
    ;;

  ubuntu)
    install_from_proton DebFile
    ;;

  fedora)
    install_from_proton RpmFile
    ;;

  *)
    echo "$APP_NAME: Unsupported distro '$DISTRO'." >&2
    return 1
    ;;
  esac
}
