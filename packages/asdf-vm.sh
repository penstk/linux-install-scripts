# Application name (used in logs / messages)
APP_NAME="asdf-vm"

# Command to check for in PATH.
CMD_NAME="asdf"

# Distro-specific dependencies:
DEPENDENCIES=()
case "$DISTRO" in
ubuntu | fedora)
  DEPENDENCIES+=(git)
  ;;
esac

# Load helper scripts
. "$ROOT_DIR/helpers/is_installed.sh"
. "$ROOT_DIR/helpers/github.sh"
. "$ROOT_DIR/helpers/install.sh"

# Check if already installed
is_installed() {
  is_installed_cmd "$CMD_NAME"
}

# Detect asdf binary archive suffix for this machine
detect_asdf_arch() {
  local machine_arch
  machine_arch="$(uname -m)"

  case "$machine_arch" in
  x86_64 | amd64)
    echo "linux-amd64"
    ;;
  aarch64 | arm64)
    echo "linux-arm64"
    ;;
  i386 | i686)
    echo "linux-386"
    ;;
  *)
    echo "$APP_NAME: unsupported architecture '$machine_arch'" >&2
    return 1
    ;;
  esac
}

# Install latest asdf binary from GitHub (system-wide)
install_asdf_from_github() {
  local asdf_arch archive_pattern url
  local repo="asdf-vm/asdf"

  asdf_arch="$(detect_asdf_arch)" || return 1

  # Match assets like: asdf-v0.18.0-linux-amd64.tar.gz
  archive_pattern="asdf-v[0-9.]+-${asdf_arch}\\.tar\\.gz$"

  url="$(github_latest_asset_url "$repo" "$archive_pattern")" || true
  if [[ -z "$url" ]]; then
    echo "$APP_NAME: could not find archive matching '$archive_pattern' in latest release" >&2
    return 1
  fi

  echo "Installing $APP_NAME from GitHub release:"
  echo "  $url"

  # Extract the "asdf" binary into /usr/local/bin (must be on PATH)
  install_binary_from_url "$url" "asdf" "/usr/local/bin"
}

append_line_if_missing() {
  local file="$1" line="$2"

  mkdir -p "$(dirname "$file")"
  [[ -f "$file" ]] || touch "$file"

  # Add the line only if it is not already present verbatim
  if ! grep -qxF "$line" "$file" 2>/dev/null; then
    printf '%s\n' "$line" >>"$file"
  fi
}

append_fish_asdf_block() {
  local file="$HOME/.config/fish/config.fish"
  local marker="# ASDF configuration code"
  local block='
# ASDF configuration code
if test -z $ASDF_DATA_DIR
    set _asdf_shims "$HOME/.asdf/shims"
else
    set _asdf_shims "$ASDF_DATA_DIR/shims"
end

# Do not use fish_add_path (added in Fish 3.2) because it
# potentially changes the order of items in PATH
if not contains $_asdf_shims $PATH
    set -gx --prepend PATH $_asdf_shims
end
set --erase _asdf_shims
'

  mkdir -p "$(dirname "$file")"
  [[ -f "$file" ]] || touch "$file"

  # Only append once, using the marker as an anchor
  if ! grep -q "$marker" "$file" 2>/dev/null; then
    printf '%s\n' "$block" >>"$file"
  fi
}

configure_asdf_shells() {
  # POSIX shells (bash, zsh, generic login shell)
  local shim_line='export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"'

  append_line_if_missing "$HOME/.bash_profile" "$shim_line"
  append_line_if_missing "$HOME/.zshrc" "$shim_line"
  append_line_if_missing "$HOME/.profile" "$shim_line"

  # Fish shell
  append_fish_asdf_block
}

# Configure completions for Bash, Zsh, Fish
configure_asdf_completions() {
  # Bash completions (simple eval line)
  local bash_line='. <(asdf completion bash)'
  append_line_if_missing "$HOME/.bashrc" "$bash_line"

  # Zsh completions
  mkdir -p "${ASDF_DATA_DIR:-$HOME/.asdf}/completions"
  asdf completion zsh >"${ASDF_DATA_DIR:-$HOME/.asdf}/completions/_asdf"

  local zsh_fpath_line='fpath=(${ASDF_DATA_DIR:-$HOME/.asdf}/completions $fpath)'
  local zsh_compinit_line='autoload -Uz compinit && compinit'
  append_line_if_missing "$HOME/.zshrc" "$zsh_fpath_line"
  append_line_if_missing "$HOME/.zshrc" "$zsh_compinit_line"

  # Fish completions
  local fish_comp_dir="$HOME/.config/fish/completions"
  mkdir -p "$fish_comp_dir"
  asdf completion fish >"$fish_comp_dir/asdf.fish" 2>/dev/null || true
}

# Main package install
install_package() {
  case "$DISTRO" in
  arch | cachyos)
    paru -S --needed --noconfirm asdf-vm
    ;;

  ubuntu | fedora)
    install_asdf_from_github
    ;;

  *)
    echo "$APP_NAME: Unsupported distro '$DISTRO'." >&2
    return 1
    ;;
  esac

  configure_asdf_shells
  configure_asdf_completions
}
