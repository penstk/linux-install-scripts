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
