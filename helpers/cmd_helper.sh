# Generic "is installed" check with per-distro command names.
#   $1 = app name
cmd_is_installed() {
  local app_name=$1
  command -v "$app_name" >/dev/null 2>&1
}
