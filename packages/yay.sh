# Application name (used to check if the application is already installed)
APP_NAME="yay"

# AUR repostitory with the sourcecode to built
REPO_URL="https://aur.archlinux.org/yay.git"

# List of packages required to build the application
REQUIRED_PKGS=("base-devel" "git" "go")

# Load helper scripts
. "$ROOT_DIR/helpers/cmd_helper.sh"
. "$ROOT_DIR/helpers/aur_helper.sh"

is_installed() {
  cmd_is_installed "$APP_NAME"
}

install_package() {
  aur_install "$APP_NAME" "$REPO_URL" "${REQUIRED_PKGS[@]}"
}
