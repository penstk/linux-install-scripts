# Packages that should be installed before installing this package.
# Each entry must correspond to another package script in the packages directory (without .sh).
# shellcheck disable=SC2034 # used by install.sh dependency resolver
DEPENDENCIES=(
  curl
  git
)

is_installed() {
  if [[ -d "$HOME/.oh-my-bash" ]]; then
    return 0
  fi

  if [[ -d "$HOME/.bash_it" ]]; then
    echo "==> Skipping oh-my-bash: bash-it already installed"
    return 0
  fi

  return 1
}

install_package() {
  curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh | bash
}
