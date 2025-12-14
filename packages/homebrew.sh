# Packages that should be installed before installing this package.
# Each entry must correspond to another package script in the packages directory (without .sh).
# shellcheck disable=SC2034 # used by install.sh dependency resolver
DEPENDENCIES=(
  curl
)

# Load helper scripts
. "$ROOT_DIR/helpers/is_installed.sh"
. "$ROOT_DIR/helpers/shell-helpers.sh"

is_installed() {
  is_installed_cmd "brew"
}

append_fish_asdf_block() {
  local file="$HOME/.config/fish/config.fish"
  local marker="# Homebrew configuration code"
  local block='
# Homebrew configuration code
if test -x $HOME/.linuxbrew/bin/brew
    eval ($HOME/.linuxbrew/bin/brew shellenv fish)
else if test -x /home/linuxbrew/.linuxbrew/bin/brew
    eval (/home/linuxbrew/.linuxbrew/bin/brew shellenv fish)
end
'
  append_block_if_missing "$file" "$marker" "$block"
}

configure_brew_shells() {
  # Get Brew install directory
  local brew_path=""
  if [[ -x "$HOME/.linuxbrew/bin/brew" ]]; then
    brew_path="$HOME/.linuxbrew/bin/brew"
  elif [[ -x "/home/linuxbrew/.linuxbrew/bin/brew" ]]; then
    brew_path="/home/linuxbrew/.linuxbrew/bin/brew"
  else
    echo "Homebrew installed, but brew not found in expected locations." >&2
    return 1
  fi

  # POSIX shells (bash, zsh, generic login shell)
  local shellenv_line='eval "$('"$brew_path"' shellenv)"'

  append_line_if_missing "$HOME/.bashrc" "$shellenv_line"
  append_line_if_missing "$HOME/.zshrc" "$shellenv_line"

  # Fish shell
  append_fish_asdf_block

  # Ensure brew is available in the current shell session, that runs the install.sh script
  eval "$("$brew_path" shellenv)"
}

install_package() {
  # Install homebrew
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || return 1

  # Configure PATH/env settings
  configure_brew_shells || return 1

  # Final sanity check: brew must be usable now
  command -v brew >/dev/null 2>&1 || return 1

  return 0
}
