# Command to check for in PATH.
# Use a different value if the binary name differs from APP_NAME.
CMD_NAME="codex"

# Packages that should be installed before installing this package.
# Each entry must correspond to another package script in the packages directory (without .sh).
# shellcheck disable=SC2034 # used by install.sh dependency resolver
DEPENDENCIES=(
  homebrew
)

# Load helper scripts
. "$ROOT_DIR/helpers/is_installed.sh"
. "$ROOT_DIR/helpers/run_in_pty.sh"

is_installed() {
  is_installed_cmd "$CMD_NAME"
}

install_package() {
  # Run `brew` in a pseudo-TTY to avoid Homebrew invalidating the sudo timestamp
  # (e.g. via `sudo -k`) and disrupting the installer’s sudo keepalive.
  run_in_pty brew install codex
}
