# Application name (used in logs / messages)
APP_NAME="vscode"

# Command to check for in PATH.
CMD_NAME="code"

# Distro-specific dependencies:
DEPENDENCIES=()
case "$DISTRO" in
arch | cachyos)
  DEPENDENCIES+=(paru)
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
    paru -S --needed --noconfirm code || return 1
    ;;

  ubuntu)
    sudo snap install --classic code || return 1
    ;;

  fedora)
    sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc || return 1
    echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\nautorefresh=1\ntype=rpm-md\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" | sudo tee /etc/yum.repos.d/vscode.repo >/dev/null
    dnf check-update || return 1
    sudo dnf install -y code || return 1
    ;;

  *)
    echo "$APP_NAME: Unsupported distro '$DISTRO'." >&2
    return 1
    ;;
  esac
}
