aur_install() {
  local app_name=$1
  local repo_url=$2
  shift 2
  local required_pkgs=("$@")

  case "$DISTRO" in
  arch | cachyos)
    sudo pacman -S --noconfirm --needed "${required_pkgs[@]}"

    TMPDIR="$(mktemp -d -t "${app_name}-build-XXXXXXXXXX")"
    echo "Using temp dir: $TMPDIR"
    trap 'rm -rf "$TMPDIR"' RETURN

    cd "$TMPDIR" || return 1

    echo "Cloning $repo_url ..."
    git clone "$repo_url" "$app_name" || {
      echo "Error: failed to clone $repo_url" >&2
      return 1
    }

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
