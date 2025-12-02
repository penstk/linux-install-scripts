APP_NAME="nodejs"

# Command to check for in PATH.
# Use a different value if the binary name differs from APP_NAME.
CMD_NAME="node"

# Load helper scripts
. "$ROOT_DIR/helpers/is_installed.sh"

# Packages that should be installed before installing this package.
# Each entry must correspond to another package script in the packages directory (without .sh).
DEPENDENCIES=(
  asdf-vm
)

is_installed() {
  is_installed_cmd "$CMD_NAME"
}

install_package() {
  # Install dependencies for the asdf-nodejs plugin
  case "$DISTRO" in
  ubuntu)
    sudo apt-get install -y dirmngr gpg curl gawk
    ;;
  fedora)
    sudo dnf install -y gnupg2 curl gawk
    ;;
  esac

  # Install asdf-nodejs plugin
  asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git

  # Install nodejs
  asdf install nodejs latest

  # Set a version
  asdf set -u nodejs latest

  # Ensure shims are regenerated
  asdf reshim nodejs || true
}
