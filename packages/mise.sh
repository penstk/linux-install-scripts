# Load helper scripts
. "$ROOT_DIR/helpers/is_installed.sh"
. "$ROOT_DIR/helpers/shell-helpers.sh"

is_installed() {
  is_installed_cmd "mise"
}

configure_shims() {
  append_shell_env_block_if_missing "# mise shims integration" "$(
    cat <<'EOF'
# mise shims integration

case $- in
  *i*) : ;;  # interactive: full activation lives in .bashrc/.zshrc
  *)
    command -v mise >/dev/null 2>&1 && {
      [ -n "${ZSH_VERSION-}" ] && eval "$(mise activate zsh --shims)"
      [ -n "${BASH_VERSION-}" ] && eval "$(mise activate bash --shims)"
    }
    ;;
esac
EOF
  )"

  append_fish_env_line_if_missing 'mise activate fish --shims | source'
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
    sudo snap install mise --beta --classic
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
  configure_shims || return 1
}
