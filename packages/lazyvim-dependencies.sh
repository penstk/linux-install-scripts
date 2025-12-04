# Installs all dependencies for Lazygit
# Does not install the Lazygit dotfiles

DEPENDENCIES=(
  neovim
  git                      # for partial clones support
  nerdfonts-jetbrains-mono # needed to display some icons
  lazygit
  curl # for nvim-treesitter
  gcc  # for nvim-treesitter
  # tree-sitter-cli # for nvim-treesitter
  python3
  python3-pip
  python3-pynvim # support for python plugins in Nvim
  fzf            # for fzf-lua
  ripgrep        # for fzf-lua
  fd             # for fzf-lua
  nodejs
  unzip # for mason.nvim
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
