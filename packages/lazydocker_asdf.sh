# Packages that should be installed before installing this package.
# Each entry must correspond to another package script in the packages directory (without .sh).
# shellcheck disable=SC2034 # used by install.sh dependency resolver
DEPENDENCIES=(
  asdf-vm
)

# Load helper scripts
. "$ROOT_DIR/helpers/is_installed.sh"
. "$ROOT_DIR/helpers/asdf-helpers.sh"

is_installed() {
  is_installed_cmd "lazydocker" && is_installed_asdf "lazydocker"
}

install_package() {
  install_via_asdf lazydocker latest https://github.com/comdotlinux/asdf-lazydocker.git
}
