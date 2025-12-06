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

  # Add .bashrc to .bash_profile
  local bash_profile="$HOME/.bash_profile"

  if [[ -f "$bash_profile" ]]; then
    if ! grep -Eq '(^|\s)(\.|source)\s+(\$HOME|~/)\.bashrc' "$bash_profile"; then
      {
        echo
        echo 'if [[ -f ~/.bashrc ]]; then'
        echo '  source ~/.bashrc'
        echo 'fi'
      } >>"$bash_profile"
      echo "==> Updated ~/.bash_profile to source ~/.bashrc for oh-my-bash"
    fi
  fi
}
