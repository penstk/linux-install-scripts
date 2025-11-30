# Application name (used in logs / messages)
APP_NAME="paru"

# Command to check for in PATH.
# Use a different value if the binary name differs from APP_NAME.
CMD_NAME="$APP_NAME"

# Packages that should be installed before installing this package.
# Each entry must correspond to another package script in the packages directory (without .sh).
DEPENDENCIES=(
  git
  base-devel
)

# AUR repostitory with the sourcecode to built
REPO_URL="https://aur.archlinux.org/paru.git"

# Load helper scripts
. "$ROOT_DIR/helpers/is_installed.sh"
. "$ROOT_DIR/helpers/install.sh"

is_installed() {
  is_installed_deps "${DEPENDENCIES[@]}" && is_installed_cmd "$CMD_NAME"
}

install_package() {
  install_via_aur "$APP_NAME" "$REPO_URL"
}
