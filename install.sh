#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Global root dir for helpers/packages
export ROOT_DIR="$SCRIPT_DIR"

PKG_DIR="$SCRIPT_DIR/packages"

PKG_CONF=""

# --- Logging -----------------------------------------------------------
LOG_FILE="${LOG_FILE:-$SCRIPT_DIR/install.log}"

init_logging() {
  # Overwrite log on each run
  : >"$LOG_FILE" || {
    echo "ERROR: Cannot write log file: $LOG_FILE" >&2
    exit 1
  }

  # Mirror all output to screen + log (stdout and stderr)
  if command -v stdbuf >/dev/null 2>&1; then
    exec > >(stdbuf -oL -eL tee "$LOG_FILE") 2>&1
  else
    exec > >(tee "$LOG_FILE") 2>&1
  fi

  echo "==> Logging to: $LOG_FILE"
}

# --- Sudo keepalive ----------------------------------------------------
SUDO_KEEPALIVE_PID=""
SUDO_KEEPALIVE_INTERVAL="${SUDO_KEEPALIVE_INTERVAL:-10}" # seconds

start_sudo_keepalive() {
  echo "==> Asking for sudo once..."
  sudo -v

  local main_pid="$$"
  local interval="$SUDO_KEEPALIVE_INTERVAL"

  (
    # Keep the timestamp fresh until the main script exits or sudo stops cooperating.
    while true; do
      sleep "$interval" || exit 0

      # Exit if the parent script is gone (avoids orphaned keepalive).
      kill -0 "$main_pid" 2>/dev/null || exit 0

      # Refresh sudo timestamp without prompting. If it fails once, stop and warn.
      if ! sudo -n -v 2>/dev/null; then
        echo "WARN: sudo keepalive stopped (sudo timestamp no longer valid or policy prevents refresh). You may be prompted again." >&2
        exit 0
      fi
    done
  ) &

  SUDO_KEEPALIVE_PID="$!"
}

stop_sudo_keepalive() {
  if [[ -n "${SUDO_KEEPALIVE_PID:-}" ]]; then
    kill "$SUDO_KEEPALIVE_PID" 2>/dev/null || true
    wait "$SUDO_KEEPALIVE_PID" 2>/dev/null || true
    SUDO_KEEPALIVE_PID=""
  fi
}

ensure_sudo_keepalive() {
  # If keepalive PID is set but dead, clear it.
  if [[ -n "${SUDO_KEEPALIVE_PID:-}" ]] && ! kill -0 "$SUDO_KEEPALIVE_PID" 2>/dev/null; then
    SUDO_KEEPALIVE_PID=""
  fi

  # If keepalive is running and sudo timestamp is still valid, nothing to do.
  if [[ -n "${SUDO_KEEPALIVE_PID:-}" ]]; then
    if sudo -n -v 2>/dev/null; then
      return 0
    fi

    # Keepalive is running but sudo auth was invalidated (e.g. sudo -k). Restart cleanly.
    echo "==> sudo timestamp was invalidated; restarting sudo keepalive..."
    stop_sudo_keepalive
  fi

  # No keepalive running (or it was stopped). Start it again.
  start_sudo_keepalive
}

# --- Print runtime -----------------------------------------------------
print_total_runtime() {
  local total="${SECONDS:-0}"
  local h=$((total / 3600))
  local m=$(((total % 3600) / 60))
  local s=$((total % 60))

  echo
  printf '==> Total runtime: %02d:%02d:%02d (hh:mm:ss)\n' "$h" "$m" "$s"
}

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

prepare_system() {
  DISTRO="$(detect_distro)" || {
    echo "ERROR: Could not detect distro (got '$DISTRO')." >&2
    exit 1
  }
  export DISTRO
  echo "==> Detected distro: $DISTRO"

  # --- Authenticate once with sudo and keepalive ------------------------------
  start_sudo_keepalive

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
}

# --- Read packages from config file -------------------------------------------
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

  # Disable 'set -e' while sourcing in case the package script has something non-fatal
  set +e
  # shellcheck source=/dev/null
  . "$pkg_file"
  local rc=$?
  set -e

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

usage() {
  cat >&2 <<EOF
Usage:
  $0 -f|--file <packages.conf>   # install from config file
  $0 <pkg1> [pkg2 ...]           # install given packages
EOF
}

parse_args() {
  CLI_PKGS=()
  PKG_CONF=""

  if (($# == 0)); then
    usage
    exit 1
  fi

  while (($# > 0)); do
    case "$1" in
    -f | --file)
      if (($# < 2)); then
        echo "ERROR: -f/--file requires a file path." >&2
        usage
        exit 1
      fi
      PKG_CONF="$2"
      shift 2
      ;;

    -h | --help)
      usage
      exit 0
      ;;

    --)
      shift
      CLI_PKGS+=("$@")
      break
      ;;

    -*)
      echo "ERROR: unknown option '$1'." >&2
      usage
      exit 1
      ;;

    *)
      CLI_PKGS+=("$1")
      shift
      ;;
    esac
  done

  # No mixing file + package names
  if [[ -n "$PKG_CONF" && ${#CLI_PKGS[@]} -gt 0 ]]; then
    echo "ERROR: cannot use -f/--file and package names at the same time." >&2
    usage
    exit 1
  fi
}

resolve_packages() {
  local -a pkgs=()

  if [[ -n "$PKG_CONF" ]]; then
    # normalize config path
    if [[ "$PKG_CONF" != /* ]]; then
      PKG_CONF="$SCRIPT_DIR/$PKG_CONF"
    fi

    if [[ ! -f "$PKG_CONF" ]]; then
      echo "ERROR: package config file '$PKG_CONF' not found." >&2
      exit 1
    fi

    mapfile -t pkgs < <(read_packages_from_conf)
  else
    pkgs=("${CLI_PKGS[@]}")
  fi

  if ((${#pkgs[@]} == 0)); then
    echo "ERROR: no packages to install (after parsing args/file)." >&2
    usage
    exit 1
  fi

  # “Return” the array by printing it line by line
  printf '%s\n' "${pkgs[@]}"
}

install_and_print_summary() {
  local -a installed_pkgs=()
  local -a failed_pkgs=()
  local -a skipped_pkgs=()
  local pkg status

  for pkg in "$@"; do
    ensure_sudo_keepalive

    if process_package "$pkg"; then
      status=0
    else
      status=$?
    fi

    case "$status" in
    0) installed_pkgs+=("$pkg") ;;
    2) skipped_pkgs+=("$pkg") ;;
    *) failed_pkgs+=("$pkg") ;;
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
  fi
}

main() {
  init_logging

  SECONDS=0

  parse_args "$@"

  # Resolve final package list (from file or CLI)
  mapfile -t pkgs < <(resolve_packages)

  # Detect distro, ask for sudo, and update system
  prepare_system

  # Build dependency-resolved install order
  build_install_order "${pkgs[@]}"

  # Install and print summary
  install_and_print_summary "${INSTALL_ORDER[@]}"

  stop_sudo_keepalive

  print_total_runtime

  echo
  echo "=================================================================================================================="
  echo "       Install complete! Please logout and login again so new tools and configs are picked up correctly."
  echo "=================================================================================================================="

  exit 0
}

main "$@"
