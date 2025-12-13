# Packages that should be installed before installing this package.
# Each entry must correspond to another package script in the packages directory (without .sh).
# shellcheck disable=SC2034 # used by install.sh dependency resolver
DEPENDENCIES=(
  python3_asdf
)

# Load helper scripts
. "$ROOT_DIR/helpers/is_installed.sh"

is_installed() {
  python3 -m pip show pynvim >/dev/null 2>&1
}

install_package() {
  python3 -m pip install pynvim
}
