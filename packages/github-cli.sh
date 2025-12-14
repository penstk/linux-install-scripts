# Application name (used in logs / messages)
APP_NAME="github-cli"

# Command to check for in PATH.
# Use a different value if the binary name differs from APP_NAME.
CMD_NAME="gh"

# Packages that should be installed before installing this package.
# Each entry must correspond to another package script in the packages directory (without .sh).
# shellcheck disable=SC2034 # used by install.sh dependency resolver
DEPENDENCIES=(
  git
)

# Load helper scripts
. "$ROOT_DIR/helpers/is_installed.sh"

is_installed() {
  is_installed_cmd "$CMD_NAME"
}

install_package() {
  case "$DISTRO" in
  arch | cachyos)
    sudo pacman -S --needed --noconfirm github-cli || return 1
    ;;
  ubuntu)
    # Only run apt-get update if it hasn’t been done in this session
    if [[ "${APT_UPDATED:-0}" != 1 ]]; then
      sudo apt-get update
      APT_UPDATED=1
    fi

    (type -p wget >/dev/null || (sudo apt-get update && sudo apt-get install wget -y)) &&
      sudo mkdir -p -m 755 /etc/apt/keyrings &&
      out=$(mktemp) && wget -nv -O$out https://cli.github.com/packages/githubcli-archive-keyring.gpg &&
      cat $out | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg >/dev/null &&
      sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg &&
      sudo mkdir -p -m 755 /etc/apt/sources.list.d &&
      echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null &&
      sudo apt-get update &&
      sudo apt-get install gh -y || return 1
    ;;
  fedora)
    sudo dnf install dnf5-plugins -y || return 1
    sudo dnf config-manager addrepo --from-repofile=https://cli.github.com/packages/rpm/gh-cli.repo || return 1
    sudo dnf install gh --repo gh-cli -y || return 1
    ;;
  *)
    echo "$APP_NAME: Unsupported distro '$DISTRO'." >&2
    return 1
    ;;
  esac
}
