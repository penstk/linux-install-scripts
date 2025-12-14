################################################################################
# Install an application from the AUR
################################################################################
#
# $1 = Name of the AUR package
# $2 = Url of the AUR package
#
################################################################################
install_via_aur() {
  local app_name=$1
  local repo_url=$2

  case "$DISTRO" in
  arch | cachyos)
    echo "==> Ensure base-devel is installed..."
    sudo pacman -S --needed --noconfirm base-devel

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

    if ! makepkg -si --noconfirm --needed; then
      echo "Error: makepkg failed for $app_name" >&2
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

  *)
    echo "$app_name: AUR install is not supporteted for '$DISTRO'." >&2
    return 1
    ;;
  esac
}
