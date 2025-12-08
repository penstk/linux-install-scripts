################################################################################
# Install an application via asdf-vm
################################################################################
#
#   $1 = app name              (e.g. "python", "nodejs", "golang")
#   $2 = version (optional)    (e.g. "3.11.7", "22.11.0", "latest"; default: latest)
#   $3 = plugin URL (optional) (e.g. "https://github.com/danhper/asdf-python.git")
#
################################################################################
install_via_asdf() {
  local app_name=$1
  local version=${2:-latest}
  local plugin_url=${3:-}

  if [ -z "$app_name" ]; then
    echo "install_via_asdf: app name is required" >&2
    return 1
  fi

  # Ensure asdf is available
  if ! is_installed_cmd asdf; then
    echo "install_via_asdf: asdf is not installed or not in PATH" >&2
    return 1
  fi

  # Ensure plugin exists
  if ! asdf plugin list 2>/dev/null | grep -qx -- "$app_name"; then
    if [ -n "$plugin_url" ]; then
      asdf plugin add "$app_name" "$plugin_url" || return 1
    else
      asdf plugin add "$app_name" || return 1
    fi
  fi

  # Install version (asdf will skip if already installed / or reuse)
  asdf install "$app_name" "$version" || return 1

  # Set version as user-global (fall back to 'global' if 'set -u' isn't available)
  if asdf set help >/dev/null 2>&1; then
    asdf set -u "$app_name" "$version" || return 1
  else
    asdf global "$app_name" "$version" || return 1
  fi

  # Regenerate shims
  asdf reshim "$app_name" || true

  return 0
}

################################################################################
# Check if an application is installed via asdf-vm
################################################################################
#
#   $1 = app name
#
################################################################################
is_installed_asdf() {
  local app_name=$1
  local version=${2:-}

  # Does the python plugin exist in asdf?
  if ! asdf plugin list 2>/dev/null | grep -qx -- "$app_name"; then
    return 1
  fi

  if [ -z "$version" ]; then
    # No version given -> Does asdf have any version installed?
    if ! asdf list "$app_name" >/dev/null 2>&1; then
      return 1
    fi
  else
    # Version given -> Check if the version appears anywhere in the output
    if ! asdf list "$app_name" 2>/dev/null | grep -q -- "$version"; then
      return 1
    fi
  fi

  return 0
}
