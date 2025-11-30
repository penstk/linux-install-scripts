# Generic "is installed" check with per-distro command names.
#   $1 = app name
is_installed_cmd() {
  local app_name=$1
  command -v "$app_name" >/dev/null 2>&1
}

# Check if all given dependencies are installed
#
# Usage:
#   is_installed_deps dep1 dep2 dep3 ...
#
# Returns:
#   0 = all dependencies installed
#   1 = at least one missing or not installed
is_installed_deps() {
  local deps=("$@")
  local dep pkg_file
  local pkgs_dir="$ROOT_DIR/packages"

  # No deps -> trivially satisfied
  if ((${#deps[@]} == 0)); then
    return 0
  fi

  for dep in "${deps[@]}"; do
    pkg_file="$pkgs_dir/$dep.sh"

    # If there is no package script for the dependency, treat it as missing
    if [[ ! -f "$pkg_file" ]]; then
      return 1
    fi

    # Clean up any previous definitions to avoid collisions
    unset DEPENDENCIES is_installed install_package 2>/dev/null || true

    # shellcheck source=/dev/null
    . "$pkg_file" || {
      unset DEPENDENCIES is_installed install_package 2>/dev/null || true
      return 1
    }

    # Use the dependency package's own is_installed() logic
    if ! is_installed 2>/dev/null; then
      unset DEPENDENCIES is_installed install_package 2>/dev/null || true
      return 1
    fi

    # Clean up before checking the next dependency
    unset DEPENDENCIES is_installed install_package 2>/dev/null || true
  done

  return 0
}
