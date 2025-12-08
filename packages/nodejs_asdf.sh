# Packages that should be installed before installing this package.
# Each entry must correspond to another package script in the packages directory (without .sh).
# shellcheck disable=SC2034 # used by install.sh dependency resolver
DEPENDENCIES=(
  asdf-vm
)

# Load helper scripts
. "$ROOT_DIR/helpers/asdf-helpers.sh"

is_installed() {
  is_installed_asdf "nodejs"
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

  install_via_asdf nodejs latest https://github.com/asdf-vm/asdf-nodejs.git
}
