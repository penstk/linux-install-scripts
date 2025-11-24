#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Global root dir for helpers/packages
export ROOT_DIR="$SCRIPT_DIR"

PKG_CONF="$SCRIPT_DIR/packages.conf"
PKG_DIR="$SCRIPT_DIR/packages"

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

# --- Read packages from packages.conf
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

main() {
  mapfile -t pkgs < <(read_packages_from_conf)

  local -a installed_pkgs=()
  local -a failed_pkgs=()
  local -a skipped_pkgs=()

  for pkg in "${pkgs[@]}"; do
    pkg_file="$PKG_DIR/$pkg.sh"

    if [[ ! -f "$pkg_file" ]]; then
      echo "Skipping '$pkg' (file '$pkg_file' not found)"
      failed_pkgs+=("$pkg (missing script)")
      continue
    fi

    echo "=== $pkg ==="

    # Load is_installed() and install_package()
    # shellcheck source=/dev/null
    . "$pkg_file"

    if is_installed; then
      echo "Already installed, skipping."
      skipped_pkgs+=("$pkg")
    else
      echo "Installing..."

      set +e # Temporarily disable 'set -e' so a failure doesn't kill the whole script
      install_package
      status=$?
      set -e

      if ((status == 0)); then
        echo "Install of '$pkg' succeeded."
        installed_pkgs+=("$pkg")
      else
        echo "Install of '$pkg' FAILED."
        failed_pkgs+=("$pkg")
      fi
    fi

    # Cleanup so next package can't accidentally reuse the is_installed and install_package functions
    unset -f is_installed install_package
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
