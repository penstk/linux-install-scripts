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
    sudo dpkg -i "$pkg" || sudo apt-get install -f -y
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
# Install a binary from a local file into a destination directory.
################################################################################
#
# The source file can be a .tar.gz/.tgz/.tar archive, or a standalone binary file.
#
# $1 = path to the binary
# $2 = name of the binary after installation
# $3 = destination directory (must be in $PATH, e.g. "/usr/local/bin")
#
################################################################################
install_binary_from_file() {
  local src_path="$1" bin_name="$2" dest_dir="$3"
  local sudo_prefix=""

  # Use sudo if dest_dir is not writable for the current user
  if [[ ! -w "$dest_dir" ]]; then
    sudo_prefix="sudo"
  fi

  $sudo_prefix mkdir -p "$dest_dir"

  case "$src_path" in
  *.tar.gz | *.tgz)
    # gzip-compressed tar
    if ! $sudo_prefix tar -xzf "$src_path" -C "$dest_dir" "$bin_name"; then
      return 1
    fi
    ;;
  *.tar)
    # uncompressed tar
    if ! $sudo_prefix tar -xf "$src_path" -C "$dest_dir" "$bin_name"; then
      return 1
    fi
    ;;
  *)
    # plain binary: just copy it to the desired name
    if ! $sudo_prefix cp "$src_path" "$dest_dir/$bin_name"; then
      return 1
    fi
    ;;
  esac

  $sudo_prefix chmod +x "$dest_dir/$bin_name" 2>/dev/null || true
  return 0
}

################################################################################
# Download a binary and install it
################################################################################
#
# The source file can be a .tar.gz/.tgz/.tar archive, or a standalone binary file.
#
# $1 = URL to the binary
# $2 = name of the binary after installation
# $3 = destination directory (must be in $PATH, e.g. "/usr/local/bin")
#
################################################################################
install_binary_from_url() {
  local url="$1" bin_name="$2" dest_dir="$3"
  local tmpdir src rc

  tmpdir="$(mktemp -d)"

  (
    cd "$tmpdir" || exit 1

    if ! curl -fLO "$url"; then
      exit 1
    fi

    src=("$tmpdir"/*)
    install_binary_from_file "${src[0]}" "$bin_name" "$dest_dir"
  )
  rc=$?

  rm -rf "$tmpdir"
  return "$rc"
}

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
    if ! pacman -T "$(pacman -Sgq base-devel)" >/dev/null 2>&1; then
      echo "==> Installing base-devel (required for AUR builds)..."
      sudo pacman -S --needed --noconfirm base-devel
    fi

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

  *)
    echo "$app_name: AUR install is not supporteted for '$DISTRO'." >&2
    return 1
    ;;
  esac
}
