# Packages that should be installed before installing this package.
# Each entry must correspond to another package script in the packages directory (without .sh).
# shellcheck disable=SC2034 # used by install.sh dependency resolver
DEPENDENCIES=(
  asdf-vm
)

# Load helper scripts
. "$ROOT_DIR/helpers/asdf-helpers.sh"

is_installed() {
  is_installed_asdf "python" "3"
}

install_package() {
  install_via_asdf python latest https://github.com/danhper/asdf-python.git
}
