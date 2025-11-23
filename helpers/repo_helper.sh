# Generic install via distro repos
#   $1 = app name
#   $2 = arch package name
#   $3 = debian/ubuntu package name
#   $4 = redhat/fedora package name
repo_install() {
  local app_name=$1
  local arch_pkg=$2
  local deb_pkg=$3
  local rh_pkg=$4

  case "$DISTRO_FAMILY" in
  arch)
    if [[ -z "$arch_pkg" ]]; then
      echo "$app_name: Arch/CachyOS install not implemented." >&2
      return 1
    fi
    sudo pacman -S --needed --noconfirm "$arch_pkg"
    ;;
  debian)
    if [[ -z "$deb_pkg" ]]; then
      echo "$app_name: Debian/Ubuntu install not implemented." >&2
      return 1
    fi
    # Only run apt-get update if it hasn’t been done in this session
    if [[ "${APT_UPDATED:-0}" != 1 ]]; then
      sudo apt-get update
      APT_UPDATED=1
    fi
    sudo apt-get install -y "$deb_pkg"
    ;;
  redhat)
    if [[ -z "$rh_pkg" ]]; then
      echo "$app_name: RedHat/Fedora install not implemented." >&2
      return 1
    fi
    sudo dnf install -y "$rh_pkg"
    echo "$app_name: RedHat/Fedora install placeholder (pkg: $rh_pkg)" >&2
    ;;
  *)
    echo "$app_name: Unsupported distro family '$DISTRO_FAMILY'." >&2
    return 1
    ;;
  esac
}
