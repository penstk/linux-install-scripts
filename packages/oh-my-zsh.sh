# Packages that should be installed before installing this package.
# Each entry must correspond to another package script in the packages directory (without .sh).
# shellcheck disable=SC2034 # used by install.sh dependency resolver
DEPENDENCIES=(
  zsh
  curl
  git
)

is_installed() {
  [[ -d "$HOME/.oh-my-zsh" ]]
}

install_package() {
  # On some distros (e.g. Arch), ZSH may be exported as /usr/share/oh-my-zsh.
  # Override it so the installer uses the per-user directory.
  export ZSH="$HOME/.oh-my-zsh"

  # Install oh-my-zsh
  curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh | sh
}
