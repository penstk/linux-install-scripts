# Packages that should be installed before installing this package.
# Each entry must correspond to another package script in the packages directory (without .sh).
# shellcheck disable=SC2034 # used by install.sh dependency resolver
DEPENDENCIES=(
  zsh
  curl
  git
)

zshrc_path() {
  echo "${ZDOTDIR:-$HOME}/.zshrc"
}

is_installed() {
  [[ -d "${ZDOTDIR:-$HOME}/.oh-my-zsh" ]]
}

install_package() {
  curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh | sh
}
