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
  is_installed_cmd "uv"
}

install_package() {
  is_installed_cmd "brew" || return 1

  # Run `brew` in a pseudo-TTY to avoid Homebrew invalidating the sudo timestamp
  # (e.g. via `sudo -k`) and disrupting the installer’s sudo keepalive.
  run_in_pty brew install uv || return 1

  uv tool update-shell || return 1

  return 0 ## installation successful
}
