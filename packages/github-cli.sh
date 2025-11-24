# Application name (used to check if the application is already installed)
APP_NAME="github-cli"
CMD_NAME="gh"

# Load helper scripts
. "$ROOT_DIR/helpers/cmd_helper.sh"

is_installed() {
  cmd_is_installed "$CMD_NAME"
}

install_package() {
  case "$DISTRO" in
  arch | cachyos)
    sudo pacman -S --needed --noconfirm github-cli
    ;;
  ubuntu)
    # Only run apt-get update if it hasn’t been done in this session
    if [[ "${APT_UPDATED:-0}" != 1 ]]; then
      sudo apt-get update
      APT_UPDATED=1
    fi

    (type -p wget >/dev/null || (sudo apt update && sudo apt install wget -y)) &&
      sudo mkdir -p -m 755 /etc/apt/keyrings &&
      out=$(mktemp) && wget -nv -O$out https://cli.github.com/packages/githubcli-archive-keyring.gpg &&
      cat $out | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg >/dev/null &&
      sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg &&
      sudo mkdir -p -m 755 /etc/apt/sources.list.d &&
      echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null &&
      sudo apt update &&
      sudo apt install gh -y
    ;;
  fedora)
    sudo dnf install dnf5-plugins -y
    sudo dnf config-manager addrepo --from-repofile=https://cli.github.com/packages/rpm/gh-cli.repo
    sudo dnf install gh --repo gh-cli -y
    ;;
  *)
    echo "$APP_NAME: Unsupported distro '$DISTRO'." >&2
    return 1
    ;;
  esac
}
