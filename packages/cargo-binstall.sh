# Packages that should be installed before installing this package.
# Each entry must correspond to another package script in the packages directory (without .sh).
# shellcheck disable=SC2034 # used by install.sh dependency resolver
DEPENDENCIES=(
  curl
)

# Load helper scripts
. "$ROOT_DIR/helpers/is_installed.sh"

is_installed() {
  is_installed_cmd "cargo-binstall"
}

install_package() {
  curl -L --proto '=https' --tlsv1.2 -sSf https://raw.githubusercontent.com/cargo-bins/cargo-binstall/main/install-from-binstall-release.sh | bash
}
