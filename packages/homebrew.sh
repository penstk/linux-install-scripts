# Packages that should be installed before installing this package.
# Each entry must correspond to another package script in the packages directory (without .sh).
# shellcheck disable=SC2034 # used by install.sh dependency resolver
DEPENDENCIES=(
  curl
)

# Load helper scripts
. "$ROOT_DIR/helpers/is_installed.sh"
. "$ROOT_DIR/helpers/shell-helpers.sh"
. "$ROOT_DIR/helpers/run_in_pty.sh"

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
  local url="https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh"
  local tmp

  tmp="$(mktemp -t homebrew-install.XXXXXX)"
  curl -fsSL "$url" -o "$tmp"
  chmod +x "$tmp"

  # Run installer in a pseudo-TTY to avoid the Homebrew installer invalidating the sudo timestamp
  # (e.g. via `sudo -k`) and disrupting the installer’s sudo keepalive.
  run_in_pty env NONINTERACTIVE=1 /bin/bash "$tmp"

  rm -f "$tmp"

  # Configure PATH/env settings
  configure_brew_shells
}
