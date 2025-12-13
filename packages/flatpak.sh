# Application name (used in logs / messages)
APP_NAME="flatpak"

# Command to check for in PATH.
# Use a different value if the binary name differs from APP_NAME.
CMD_NAME="$APP_NAME"

# Load helper scripts
. "$ROOT_DIR/helpers/is_installed.sh"

is_installed() {
  is_installed_cmd "$CMD_NAME" || return 1

  # Treat Flatpak as "installed" only when Flathub is present.
  flatpak remotes --system --columns=name 2>/dev/null | grep -qx "flathub"
}

install_package() {
  case "$DISTRO" in
  arch | cachyos)
    sudo pacman -S --needed --noconfirm flatpak
    sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    sudo flatpak remote-modify --system --enable flathub
    ;;

  ubuntu)
    sudo apt-get install -y flatpak
    sudo apt-get install -y gnome-software-plugin-flatpak
    sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    sudo flatpak remote-modify --system --enable flathub
    ;;

  fedora)
    sudo dnf install -y flatpak
    sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    sudo flatpak remote-modify --system --enable flathub
    ;;

  *)
    echo "$APP_NAME: Unsupported distro '$DISTRO'." >&2
    return 1
    ;;
  esac
}
