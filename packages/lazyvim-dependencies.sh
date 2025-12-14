# Installs all dependencies for Lazygit
# Does not install the Lazygit dotfiles

DEPENDENCIES=(
  neovim
  python3
  git                      # for partial clones support
  nerdfonts-jetbrains-mono # needed to display some icons
  lazygit
  curl # for nvim-treesitter
  gcc  # for nvim-treesitter
  # tree-sitter-cli # for nvim-treesitter
  fzf           # for fzf-lua
  ripgrep       # for fzf-lua
  fd            # for fzf-lua
  unzip         # for mason.nvim
  neovim-pynvim # Should run last because it has brew dependencies which invalidate sudo keepalive
)

# Load helper scripts
. "$ROOT_DIR/helpers/is_installed.sh"

is_installed() {
  # Consider installed if all dependencies are installed
  is_installed_deps "${DEPENDENCIES[@]}"
}

install_package() {
  # No package to install -> dependencies are handled by the main resolver
  :
}
