# Generic install via distro repos
#   $1 = app name
#   $2 = arch package name
#   $3 = ubuntu package name
#   $4 = fedora package name
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
    sudo pacman -S --needed --noconfirm "$arch_pkg"
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

install_via_aur() {
  local app_name=$1
  local repo_url=$2

  case "$DISTRO" in
  arch | cachyos)
    TMPDIR="$(mktemp -d -t "${app_name}-build-XXXXXXXXXX")"
    echo "Using temp dir: $TMPDIR"
    trap 'rm -rf "$TMPDIR"' RETURN

    cd "$TMPDIR" || return 1

    echo "Cloning $repo_url ..."
    if ! git clone "$repo_url" "$app_name"; then
      echo "Error: failed to clone $repo_url" >&2
      return 1
    fi

    cd "$app_name" || return 1

    if ! makepkg --noconfirm; then
      echo "Error: makepkg failed for $app_name" >&2
      return 1
    fi

    if ! sudo pacman -U --noconfirm "${app_name}"-*.pkg.tar.zst; then
      echo "Error: pacman -U failed for $app_name" >&2
      return 1
    fi

    echo "==> Verifying installation..."
    if command -v "$app_name" >/dev/null 2>&1; then
      echo "$app_name installed successfully. Version:"
      "$app_name" --version
    else
      echo "Error: $app_name command not found after installation." >&2
      return 1
    fi
    ;;

  ubuntu)
    echo "$app_name is not implemented for Ubuntu" >&2
    return 1
    ;;

  fedora)
    echo "$app_name is not implemented for Fedora" >&2
    return 1
    ;;

  *)
    echo "$app_name: Unsupported distro '$DISTRO'." >&2
    return 1
    ;;
  esac
}
