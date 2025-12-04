# Application name (used in logs / messages)
APP_NAME="JetBrainsMono Nerd Font"

# Load helper scripts
. "$ROOT_DIR/helpers/install.sh"

is_installed() {
  case "$DISTRO" in
  arch | cachyos)
    if pacman -Qq ttf-jetbrains-mono-nerd >/dev/null 2>&1; then
      return 0 # found
    fi
    ;;
  esac

  local pattern="JetBrains.*(Nerd[[:space:]]*Font|NerdFont| NF| NFM| NFP)"
  if fc-list : family 2>/dev/null | grep -Eiq "$pattern"; then
    return 0 # found
  fi

  return 1 # not found

}

install_package() {
  case "$DISTRO" in
  arch | cachyos)
    sudo pacman -S --needed --noconfirm ttf-jetbrains-mono-nerd
    ;;
  ubuntu | fedora)
    curl -OL https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz
    sudo mkdir -p /usr/local/share/fonts/nerd-fonts
    sudo tar -xvf JetBrainsMono.tar.xz -C /usr/local/share/fonts/nerd-fonts
    rm JetBrainsMono.tar.xz
    sudo fc-cache
    ;;
  *)
    echo "$APP_NAME: Unsupported distro '$DISTRO'." >&2
    return 1
    ;;
  esac
}
