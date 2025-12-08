################################################################################
# Install a package from the distro repos with the default package manager
################################################################################
#
#   $1 = app name
#   $2 = arch package name
#   $3 = ubuntu package name
#   $4 = fedora package name
#
################################################################################
install_via_pkgmgr() {
  local app_name=$1
  local arch_pkg=$2
  local ubuntu_pkg=$3
  local fedora_pkg=$4

  case "$DISTRO" in
  arch | cachyos)
    if [[ -z "$arch_pkg" ]]; then
      echo "$app_name: Arch/CachyOS install not implemented." >&2
      return 1
    fi
    if command -v paru >/dev/null 2>&1; then
      paru -S --needed --noconfirm "$arch_pkg"
    else
      # Fall back to pacman if paru is not installed
      sudo pacman -S --needed --noconfirm "$arch_pkg"
    fi
    ;;
  ubuntu)
    if [[ -z "$ubuntu_pkg" ]]; then
      echo "$app_name: Ubuntu install not implemented." >&2
      return 1
    fi
    # Only run apt-get update if it hasn’t been done in this session
    if [[ "${APT_UPDATED:-0}" != 1 ]]; then
      sudo apt-get update
      APT_UPDATED=1
    fi
    sudo apt-get install -y "$ubuntu_pkg"
    ;;
  fedora)
    if [[ -z "$fedora_pkg" ]]; then
      echo "$app_name: Fedora install not implemented." >&2
      return 1
    fi
    sudo dnf install -y "$fedora_pkg"
    ;;
  *)
    echo "$app_name: Unsupported distro '$DISTRO'." >&2
    return 1
    ;;
  esac
}

################################################################################
# Install a local package file
################################################################################
#
# $1 = path to package file (.deb or .rpm)
#
################################################################################
install_pkg_from_file() {
  local pkg="$1"

  case "$pkg" in
  *.deb)
    sudo apt-get install -y "$pkg"
    ;;
  *.rpm)
    sudo dnf install -y "$pkg"
    ;;
  *)
    echo "install_pkg_file: unsupported package type '$pkg'" >&2
    return 1
    ;;
  esac
}

################################################################################
# Download a .deb or .rpm package from URL and install it.
################################################################################
#
# The URL must point to a .deb or .rpm file (its extension is used to detect
# which installer to use).
#
# $1 = URL to package (.deb or .rpm)
#
################################################################################
install_pkg_from_url() {
  local url="$1"
  local tmpdir pkg rc

  tmpdir="$(mktemp -d)"

  (
    cd "$tmpdir" || exit 1

    if ! curl -fLO "$url"; then
      exit 1
    fi

    pkg=("$tmpdir"/*)
    install_pkg_from_file "${pkg[0]}"
  )
  rc=$?

  rm -rf "$tmpdir"
  return "$rc"
}

################################################################################
# Check if a package is installed via the distro's native package manager
################################################################################
#
#   $1 = arch package name
#   $2 = ubuntu package name
#   $3 = fedora package name
#   $4 = version string to match (optional, substring match, like is_installed_asdf)
#
################################################################################
is_installed_pkg() {
  local arch_pkg=$1
  local ubuntu_pkg=$2
  local fedora_pkg=$3
  local version=${4:-}

  case "$DISTRO" in
  arch | cachyos)
    [[ -z "$arch_pkg" ]] && return 1 # if package name is empty, treat it as not installed

    if [[ -z "$version" ]]; then
      # No version given -> Check if app is installed"
      if ! pacman -Q "$arch_pkg" >/dev/null 2>&1; then
        return 1
      fi
    else
      # Version given -> Check if app is installed and has correct version
      if ! pacman -Q "$arch_pkg" 2>/dev/null | grep -q -- "$version"; then
        return 1
      fi
    fi
    return 0
    ;;

  ubuntu)
    [[ -z "$ubuntu_pkg" ]] && return 1 # if package name is empty, treat it as not installed

    if [[ -z "$version" ]]; then
      # No version given -> Check if app is installed"
      if ! dpkg -s "$ubuntu_pkg" >/dev/null 2>&1; then
        return 1
      fi
    else
      # Version given -> Check if app is installed and has correct version
      if ! dpkg-query -W -f='${Version}\n' "$ubuntu_pkg" 2>/dev/null | grep -q -- "$version"; then
        return 1
      fi
    fi
    return 0
    ;;

  fedora)
    [[ -z "$fedora_pkg" ]] && return 1 # if package name is empty, treat it as not installed

    if [[ -z "$version" ]]; then
      # No version given -> Check if app is installed"
      if ! rpm -q "$fedora_pkg" >/dev/null 2>&1; then
        return 1
      fi
    else
      # Version given -> Check if app is installed and has correct version
      if ! rpm -q "$fedora_pkg" 2>/dev/null | grep -q -- "$version"; then
        return 1
      fi
    fi
    return 0
    ;;

  *)
    echo "Unsupported distro '$DISTRO'." >&2
    return 1
    ;;
  esac
}
