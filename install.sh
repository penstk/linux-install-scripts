#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Global root dir for helpers/packages
export ROOT_DIR="$SCRIPT_DIR"

PKG_DIR="$SCRIPT_DIR/packages"

DEFAULT_PKG_CONF="$SCRIPT_DIR/packages.conf"

# If no config file is passed as an argument use the default config file
PKG_CONF="${1:-$DEFAULT_PKG_CONF}"

# If the config file path is not absolute, treat it as relative to the script
if [[ "$PKG_CONF" != /* ]]; then
  PKG_CONF="$SCRIPT_DIR/$PKG_CONF"
fi

# --- Detect distro ----------------------------------------------------
detect_distro() {
  if [[ "$(uname -s)" != "Linux" ]]; then
    echo "unknown"
    return 1
  fi

  if [[ -r /etc/os-release ]]; then
    # shellcheck source=/dev/null
    . /etc/os-release

    id="${ID,,}"

    case "$id" in
    arch)
      echo "arch"
      return 0
      ;;
    cachyos)
      echo "cachyos"
      return 0
      ;;
    ubuntu)
      echo "ubuntu"
      return 0
      ;;
    fedora)
      echo "fedora"
      return 0
      ;;
    *)
      echo "unknown"
      return 1
      ;;
    esac
  fi

  echo "unknown"
  return 1
}

DISTRO="$(detect_distro)" || {
  echo "ERROR: Could not detect distro (got '$DISTRO')." >&2
  exit 1
}
export DISTRO
echo "==> Detected distro: $DISTRO"

# --- Authenticate once with sudo and keepalive ------------------------------
echo "==> Asking for sudo once..."
sudo -v

(
  while true; do
    sudo -n true 2>/dev/null || exit 0
    sleep 60
  done
) &
SUDO_KEEPALIVE_PID=$!
trap 'kill "$SUDO_KEEPALIVE_PID" 2>/dev/null || true' EXIT

# --- Update all packages before installing ----------------------------------
echo "==> Updating system..."
case "$DISTRO" in
arch | cachyos)
  sudo pacman -Syu --noconfirm
  ;;
ubuntu)
  sudo apt-get update
  sudo apt-get dist-upgrade -y
  export APT_UPDATED=1
  ;;
fedora)
  sudo dnf upgrade -y
  ;;
*)
  echo "ERROR: Unsupported distro '$DISTRO' for system update." >&2
  exit 1
  ;;
esac

# --- Read packages from packages.conf ----------------------------------------
read_packages_from_conf() {
  local line first

  while IFS= read -r line || [[ -n "$line" ]]; do
    # Strip comments
    line="${line%%#*}"
    # Trim leading/trailing whitespace
    line="${line#"${line%%[![:space:]]*}"}"
    line="${line%"${line##*[![:space:]]}"}"

    [[ -z "$line" ]] && continue

    # First word is the package name
    set -- $line
    first="$1"
    [[ -z "$first" ]] && continue

    echo "$first"
  done <"$PKG_CONF"
}

# --- Resolve dependencies from a package script ------------------------------
get_package_dependencies() {
  local pkg="$1"
  local pkg_file="$PKG_DIR/$pkg.sh"

  # If the script doesn't exist, we can't know dependencies; let process_package fail later
  if [[ ! -f "$pkg_file" ]]; then
    return 0
  fi

  # Clean up any previous DEPENDENCIES/functions
  unset DEPENDENCIES is_installed install_package 2>/dev/null || true
  DEPENDENCIES=()

  # shellcheck source=/dev/null
  # Disable 'set -e' while sourcing in case the package script has something non-fatal
  set +e
  . "$pkg_file"
  local rc=$?
  set -e

  # Optional debug:
  # echo "DEBUG: deps for $pkg: ${DEPENDENCIES[*]-<none>}" >&2

  # Print dependencies if any
  if ((${#DEPENDENCIES[@]} > 0)); then
    printf '%s\n' "${DEPENDENCIES[@]}"
  fi

  # Clean up again so this doesn't leak into later calls
  unset DEPENDENCIES is_installed install_package 2>/dev/null || true

  return "$rc"
}

# Global install order and seen set for dependency resolution
declare -a INSTALL_ORDER=()
declare -A SEEN_PKGS=()

add_with_dependencies() {
  local pkg="$1"

  # Avoid processing the same pkg multiple times
  if [[ -n "${SEEN_PKGS[$pkg]+x}" ]]; then
    return
  fi
  SEEN_PKGS["$pkg"]=1

  # First handle dependencies
  local dependencies=()
  mapfile -t dependencies < <(get_package_dependencies "$pkg")

  local dep
  for dep in "${dependencies[@]}"; do
    add_with_dependencies "$dep"
  done

  # Then add this package itself
  INSTALL_ORDER+=("$pkg")
}

build_install_order() {
  INSTALL_ORDER=()
  SEEN_PKGS=()

  local pkg
  for pkg in "$@"; do
    add_with_dependencies "$pkg"
  done
}

# --- Handle install logic for a single package name from packages.conf ---------
# Returns:
#   0 = install succeeded
#   1 = failed (including missing script)
#   2 = already installed (skipped)
process_package() {
  local pkg="$1"
  local pkg_file="$PKG_DIR/$pkg.sh"

  if [[ ! -f "$pkg_file" ]]; then
    echo "Skipping '$pkg' (file '$pkg_file' not found)"
    return 1
  fi

  echo "=== $pkg ==="

  # shellcheck source=/dev/null
  . "$pkg_file"

  if is_installed; then
    echo "Already installed, skipping."
    unset -f is_installed install_package
    return 2
  fi

  echo "Installing..."

  set +e
  install_package
  local status=$?
  set -e

  unset -f is_installed install_package

  if ((status == 0)); then
    echo "Install of '$pkg' succeeded."
    return 0
  else
    echo "Install of '$pkg' FAILED (exit $status)."
    return 1
  fi
}

main() {
  mapfile -t pkgs < <(read_packages_from_conf)

  # Build dependency-resolved install order
  build_install_order "${pkgs[@]}"

  # Debug message - TODO: remove
  echo "==> Install order: ${INSTALL_ORDER[*]}"

  local -a installed_pkgs=()
  local -a failed_pkgs=()
  local -a skipped_pkgs=()

  # Install all packages

  for pkg in "${INSTALL_ORDER[@]}"; do
    set +e
    process_package "$pkg"
    status=$?
    set -e

    case "$status" in
    0)
      installed_pkgs+=("$pkg")
      ;;
    2)
      skipped_pkgs+=("$pkg")
      ;;
    *)
      failed_pkgs+=("$pkg")
      ;;
    esac
  done

  echo
  echo "=============================="
  echo "      Installation summary"
  echo "=============================="

  if ((${#installed_pkgs[@]} > 0)); then
    echo "Installed packages:"
    for p in "${installed_pkgs[@]}"; do
      echo "  - $p"
    done
  else
    echo "Installed packages: none"
  fi

  if ((${#skipped_pkgs[@]} > 0)); then
    echo
    echo "Already installed (skipped):"
    for p in "${skipped_pkgs[@]}"; do
      echo "  - $p"
    done
  fi

  if ((${#failed_pkgs[@]} > 0)); then
    echo
    echo "FAILED installations:"
    for p in "${failed_pkgs[@]}"; do
      echo "  - $p"
    done
    # Non-zero exit if anything failed
    exit 1
  else
    echo
    echo "FAILED installations: none"
  fi
}

main
