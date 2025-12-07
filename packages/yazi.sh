# Application name (used in logs / messages)
APP_NAME="yazi"

# Command to check for in PATH.
# Use a different value if the binary name differs from APP_NAME.
CMD_NAME="$APP_NAME"

# Packages that should be installed before installing this package.
# Each entry must correspond to another package script in the packages directory (without .sh).
# shellcheck disable=SC2034 # used by install.sh dependency resolver
DEPENDENCIES=(
  nerdfonts-jetbrains-mono
  ffmpeg
  7zip
  jq
  poppler-utils
  fd
  ripgrep
  fzf
  zoxide
  imagemagick
  wl-clipboard
  xclip
)

# Load helper scripts
. "$ROOT_DIR/helpers/is_installed.sh"
. "$ROOT_DIR/helpers/install.sh"

is_installed() {
  is_installed_cmd "$CMD_NAME"
}

install_package() {
  case "$DISTRO" in
  arch | cachyos)
    sudo pacman -S --needed --noconfirm yazi resvg
    ;;

  ubuntu)
    sudo apt-get install -y resvg
    sudo snap install yazi --classic
    ;;

  fedora)
    sudo dnf copr enable lihaohong/yazi
    sudo dnf install -y yazi
    ;;

  *)
    echo "$APP_NAME: Unsupported distro '$DISTRO'." >&2
    return 1
    ;;
  esac
}
