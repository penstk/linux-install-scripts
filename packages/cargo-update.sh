# Command to check for in PATH.
# Use a different value if the binary name differs from APP_NAME.
CMD_NAME="cargo-install-update"

# Packages that should be installed before installing this package.
# Each entry must correspond to another package script in the packages directory (without .sh).
# shellcheck disable=SC2034 # used by install.sh dependency resolver
DEPENDENCIES=(
  rustup
  cargo-binstall
)

# Load helper scripts
. "$ROOT_DIR/helpers/is_installed.sh"

is_installed() {
  is_installed_cmd "$CMD_NAME"
}

install_package() {
  cargo binstall cargo-update --no-confirm --disable-telemetry || return 1
}
