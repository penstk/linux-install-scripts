# Application name (used in logs / messages)
APP_NAME="rustup"

# Command to check for in PATH.
# Use a different value if the binary name differs from APP_NAME.
CMD_NAME="$APP_NAME"

# Package names in each distro's package manager.
# Set to "" if this package is not available on that distro.
# Keep "$APP_NAME" when the package name matches APP_NAME.
ARCH_PKG="$APP_NAME"
UBUNTU_PKG="$APP_NAME"
FEDORA_PKG="$APP_NAME"

# Load helper scripts
. "$ROOT_DIR/helpers/is_installed.sh"
. "$ROOT_DIR/helpers/install.sh"

append_line_if_missing() {
  local file="$1" line="$2"

  mkdir -p "$(dirname "$file")"
  [[ -f "$file" ]] || touch "$file"

  if ! grep -qxF "$line" "$file" 2>/dev/null; then
    printf '%s\n' "$line" >>"$file"
  fi
}

append_fish_cargo_block() {
  local file="$HOME/.config/fish/config.fish"
  local marker="# Cargo configuration code"
  local block='
# Cargo configuration code
set _cargo_bin "$HOME/.cargo/bin"

if not contains $_cargo_bin $PATH
    set -gx --prepend PATH $_cargo_bin
end
set --erase _cargo_bin
'

  mkdir -p "$(dirname "$file")"
  [[ -f "$file" ]] || touch "$file"

  if ! grep -q "$marker" "$file" 2>/dev/null; then
    printf '%s\n' "$block" >>"$file"
  fi
}

configure_cargo_shells() {
  local cargo_line='export PATH="${CARGO_HOME:-$HOME/.cargo}/bin:$PATH"'

  append_line_if_missing "$HOME/.bash_profile" "$cargo_line"
  append_line_if_missing "$HOME/.zshrc" "$cargo_line"
  append_line_if_missing "$HOME/.profile" "$cargo_line"

  append_fish_cargo_block

  # Make Cargo-installed binaries available during this install run
  export PATH="${CARGO_HOME:-$HOME/.cargo}/bin:$PATH"
}

is_installed() {
  is_installed_cmd "$CMD_NAME" && is_installed_cmd cargo
}

install_package() {
  if ! install_via_pkgmgr "$APP_NAME" "$ARCH_PKG" "$UBUNTU_PKG" "$FEDORA_PKG"; then
    return 1
  fi

  case "$DISTRO" in
  arch | cachyos | ubuntu)
    rustup default stable
    ;;
  fedora)
    rustup-init -y
    ;;
  *)
    echo "$APP_NAME: Unsupported distro '$DISTRO'." >&2
    return 1
    ;;
  esac

  configure_cargo_shells

  cargo install cargo-binstall
}
