# Distro-specific dependencies:
DEPENDENCIES=()
case "$DISTRO" in
ubuntu)
  DEPENDENCIES+=(curl)
  ;;
esac

# Load helper scripts
. "$ROOT_DIR/helpers/is_installed.sh"
. "$ROOT_DIR/helpers/shell-helpers.sh"

is_installed() {
  is_installed_cmd "mise"
}

configure_shells() {
  append_shell_bash_line_if_missing 'eval "$(mise activate bash)"'
  append_shell_zsh_line_if_missing 'eval "$(mise activate zsh)"'
  append_fish_interactive_line_if_missing 'mise activate fish | source'
}

install_package() {
  case "$DISTRO" in
  arch | cachyos)
    sudo pacman -S --needed --noconfirm mise || return 1
    ;;

  ubuntu)
    # Detect arch via dpkg
    local arch="$(dpkg --print-architecture 2>/dev/null || true)"

    # Fallback if dpkg did not work
    if [[ -z "$arch" ]]; then
      case "$(uname -m)" in
      x86_64 | amd64)
        arch="amd64"
        ;;
      aarch64 | arm64)
        arch="arm64"
        ;;
      *)
        echo "Unsupported Ubuntu architecture '$(uname -m)'." >&2
        return 1
        ;;
      esac
    fi

    case "$arch" in
    amd64 | arm64) ;;
    *)
      echo "Unsupported Ubuntu architecture '$arch'." >&2
      return 1
      ;;
    esac

    # Only run apt-get update if it hasn’t been done in this session
    if [[ "${APT_UPDATED:-0}" != 1 ]]; then
      sudo apt-get update
      APT_UPDATED=1
    fi

    sudo install -dm 755 /etc/apt/keyrings
    curl -fSs https://mise.jdx.dev/gpg-key.pub | sudo tee /etc/apt/keyrings/mise-archive-keyring.pub 1>/dev/null
    echo "deb [signed-by=/etc/apt/keyrings/mise-archive-keyring.pub arch=$arch] https://mise.jdx.dev/deb stable main" | sudo tee /etc/apt/sources.list.d/mise.list
    sudo apt update
    sudo apt install -y mise
    ;;

  fedora)
    sudo dnf copr enable -y jdxcode/mise || return 1
    sudo dnf install -y mise || return 1
    ;;

  *)
    echo " Unsupported distro '$DISTRO'." >&2
    return 1
    ;;
  esac

  configure_shells || return 1
}
