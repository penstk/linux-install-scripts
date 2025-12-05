# Packages that should be installed before installing this package.
# Each entry must correspond to another package script in the packages directory (without .sh).
# shellcheck disable=SC2034 # used by install.sh dependency resolver
DEPENDENCIES=(
  git
)

is_installed() {
  [[ -d "$HOME/.bash_it" ]]
}

install_package() {
  git clone --depth=1 https://github.com/Bash-it/bash-it.git "$HOME/.bash_it"
  bash "$HOME/.bash_it/install.sh"
}
