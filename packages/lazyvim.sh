# Packages that should be installed before installing this package.
# Each entry must correspond to another package script in the packages directory (without .sh).
# shellcheck disable=SC2034 # used by install.sh dependency resolver
DEPENDENCIES=(
  lazyvim-dependencies
)

# Load helper scripts
. "$ROOT_DIR/helpers/is_installed.sh"

is_installed() {
  local xdg_config_home="${XDG_CONFIG_HOME:-$HOME/.config}"
  local xdg_data_home="${XDG_DATA_HOME:-$HOME/.local/share}"

  local nvim_config_dir="$xdg_config_home/nvim"
  local lazyvim_plugin_dir="$xdg_data_home/nvim/lazy/LazyVim"

  if [[ -f "$nvim_config_dir/lua/config/lazy.lua" ]] &&
    grep -q "LazyVim/LazyVim" "$nvim_config_dir/lua/config/lazy.lua"; then
    return 0
  fi

  if [[ -d "$lazyvim_plugin_dir" ]] &&
    [[ -f "$nvim_config_dir/init.lua" ]] &&
    grep -q "config.lazy" "$nvim_config_dir/init.lua"; then
    return 0
  fi

  return 1
}

lazyvim_backup_path() {
  local path=$1
  if [[ ! -e "$path" ]]; then
    return 0
  fi

  local backup_path="${path}.bak"
  if [[ -e "$backup_path" ]]; then
    backup_path="${path}.bak.$(date +%s)"
  fi

  mv "$path" "$backup_path"
}

install_package() {
  local xdg_config_home="${XDG_CONFIG_HOME:-$HOME/.config}"
  local xdg_data_home="${XDG_DATA_HOME:-$HOME/.local/share}"
  local xdg_state_home="${XDG_STATE_HOME:-$HOME/.local/state}"
  local xdg_cache_home="${XDG_CACHE_HOME:-$HOME/.cache}"

  # Make a backup of the current Neovim files (if present)
  lazyvim_backup_path "$xdg_config_home/nvim"
  lazyvim_backup_path "$xdg_data_home/nvim"
  lazyvim_backup_path "$xdg_state_home/nvim"
  lazyvim_backup_path "$xdg_cache_home/nvim"

  mkdir -p "$xdg_config_home"

  # Clone the starter
  git clone https://github.com/LazyVim/starter "$xdg_config_home/nvim" || return 1

  # Remove the .git folder, so you can add it to your own repo later
  rm -rf "$xdg_config_home/nvim/.git" || return 1
}
