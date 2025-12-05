# Application name (used in logs / messages)
APP_NAME="lazygit"

# Command to check for in PATH.
# Use a different value if the binary name differs from APP_NAME.
CMD_NAME="$APP_NAME"

# Load helper scripts
. "$ROOT_DIR/helpers/is_installed.sh"
. "$ROOT_DIR/helpers/install.sh"

is_installed() {
  is_installed_cmd "$CMD_NAME"
}

install_package() {
  case "$DISTRO" in
  arch | cachyos)
    sudo pacman -S --needed --noconfirm lazygit
    ;;
  ubuntu)
    # Check Ubuntu Version
    if [[ -r /etc/os-release ]]; then
      . /etc/os-release
    fi

    ver="${VERSION_ID:-0}"
    major=${ver%%.*}
    minor=${ver##*.}

    if ((major > 25 || (major == 25 && minor >= 10))); then
      # Ubuntu 25.10+ → lazygit is in the repo
      sudo apt-get install -y lazygit
    else
      # Ubuntu 25.04 and earlier → install from GitHub
      tmpdir="$(mktemp -d)"
      ( # Run the manual install in a subshell
        cd "$tmpdir" || exit 1
        LAZYGIT_VERSION=$(
          curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" |
            grep -Po '"tag_name": *"v\K[^"]*'
        )
        curl -Lo lazygit.tar.gz \
          "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
        tar xf lazygit.tar.gz lazygit
        sudo install lazygit -D -t /usr/local/bin/
      )
      rc=$? # Save exit code of the subshell
      rm -rf "$tmpdir"
      return "$rc"
    fi
    ;;
  fedora)
    sudo dnf copr enable dejan/lazygit
    sudo dnf install -y lazygit
    ;;
  *)
    echo "$APP_NAME: Unsupported distro '$DISTRO'." >&2
    return 1
    ;;
  esac
}
