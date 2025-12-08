################################################################################
# Check if an application is in PATH
################################################################################
#
#   $1 = app name
#
################################################################################
is_installed_cmd() {
  local app_name=$1
  if ! command -v "$app_name" >/dev/null 2>&1; then
    return 1
  fi

  return 0
}

################################################################################
# Check if all given dependencies are installed
################################################################################
#
# Usage:
#   is_installed_deps dep1 dep2 dep3 ...
#
# Returns:
#   0 = all dependencies installed
#   1 = at least one missing or not installed
#
################################################################################
is_installed_deps() {
  ( # Run in a subshell so sourcing package scripts and unsetting functions does not affect the caller
    set +e

    local deps=("$@")
    local dep pkg_file
    local pkgs_dir="$ROOT_DIR/packages"

    # no deps -> trivially satisfied
    if ((${#deps[@]} == 0)); then
      exit 0
    fi

    for dep in "${deps[@]}"; do
      pkg_file="$pkgs_dir/$dep.sh"

      # if there is no package script for the dependency, treat it as missing
      if [[ ! -f "$pkg_file" ]]; then
        exit 1
      fi

      unset dependencies is_installed install_package 2>/dev/null || true

      # shellcheck source=/dev/null
      . "$pkg_file" || exit 1

      # dependency script must define its own is_installed()
      if ! is_installed 2>/dev/null; then
        exit 1
      fi

      unset dependencies is_installed install_package 2>/dev/null || true
    done

    exit 0
  )
}
