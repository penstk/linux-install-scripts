# Application name (used in logs / messages)
APP_NAME="JetBrainsMono Nerd Font"

# Load helper scripts
. "$ROOT_DIR/helpers/pkg-helpers.sh"

is_installed() {
  case "$DISTRO" in
  arch | cachyos)
    if pacman -Qq ttf-jetbrains-mono-nerd >/dev/null 2>&1; then
      return 0
    fi
    ;;
  esac

  # Check fontconfig’s view of installed fonts
  local match pattern
  pattern='jetbrains.*nerd'
  match="$(fc-match -s 'JetBrainsMono Nerd Font' 2>/dev/null | head -n 1)"
  if echo "$match" | grep -Eiq "$pattern"; then
    return 0 # found
  fi

  return 1 # not found
}

install_package() {
  local tmpdir rc

  case "$DISTRO" in
  arch | cachyos)
    sudo pacman -S --needed --noconfirm ttf-jetbrains-mono-nerd || return 1
    ;;
  ubuntu | fedora)
    tmpdir="$(mktemp -d)" || return 1
    (
      curl -fLo "$tmpdir/JetBrainsMono.tar.xz" https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz || exit 1
      sudo mkdir -p /usr/local/share/fonts/nerd-fonts || exit 1
      sudo tar -xf "$tmpdir/JetBrainsMono.tar.xz" -C /usr/local/share/fonts/nerd-fonts || exit 1
      sudo fc-cache -f || exit 1
    )
    rc=$?
    rm -rf "$tmpdir"
    return "$rc"
    ;;
  *)
    echo "$APP_NAME: Unsupported distro '$DISTRO'." >&2
    return 1
    ;;
  esac
}
