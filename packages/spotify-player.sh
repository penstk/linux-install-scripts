# Command to check for in PATH.
# Use a different value if the binary name differs from APP_NAME.
CMD_NAME="spotify_player"

# Distro-specific dependencies:
DEPENDENCIES=()
case "$DISTRO" in
ubuntu | fedora)
  DEPENDENCIES+=(rustup)
  DEPENDENCIES+=(cargo-binstall)
  ;;
esac

# Load helper scripts
. "$ROOT_DIR/helpers/is_installed.sh"

is_installed() {
  is_installed_cmd "$CMD_NAME"
}

install_package() {
  case "$DISTRO" in
  arch | cachyos)
    sudo pacman -S --needed --noconfirm spotify-player
    ;;

  ubuntu)
    sudo apt-get install -y libssl-dev libasound2-dev libdbus-1-dev
    cargo binstall spotify_player --no-confirm --disable-telemetry --pkg-url="{ repo }/releases/download/v{ version }/{ name }-{ target }{ archive-suffix }"
    ;;

  fedora)
    sudo dnf install -y openssl-devel alsa-lib-devel dbus-devel
    cargo binstall spotify_player --no-confirm --disable-telemetry --pkg-url="{ repo }/releases/download/v{ version }/{ name }-{ target }{ archive-suffix }"
    ;;
  *)
    echo "Unsupported distro '$DISTRO'." >&2
    return 1
    ;;
  esac
}
