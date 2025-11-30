# Application name (used in logs / messages)
APP_NAME="appimagelauncher"

# Command to check for in PATH.
# Use a different value if the binary name differs from APP_NAME.
CMD_NAME="ail-cli"

# Load helper scripts
. "$ROOT_DIR/helpers/is_installed.sh"

is_installed() {
  is_installed_cmd "$CMD_NAME"
}

detect_arch() {
  # $1 = deb|rpm
  local kind="$1" m
  m="$(uname -m)"

  case "$kind:$m" in
  deb:x86_64 | deb:amd64) echo "amd64" ;;
  deb:aarch64 | deb:arm64) echo "arm64" ;;
  deb:armv7l | deb:armhf) echo "armhf" ;;
  rpm:x86_64 | rpm:amd64) echo "x86_64" ;;
  rpm:aarch64 | rpm:arm64) echo "aarch64" ;;
  rpm:armv7l) echo "armv7hl" ;;
  *)
    echo "$APP_NAME: unsupported arch '$m' for $kind package" >&2
    return 1
    ;;
  esac
}

github_latest_url() {
  # $1 = deb|rpm, $2 = arch string used in file name
  local kind="$1" arch="$2"
  curl -fsSL "https://api.github.com/repos/TheAssassin/AppImageLauncher/releases/latest" |
    grep -Po '"browser_download_url":\s*"\K[^"]+' |
    grep "\.${kind}$" |
    grep "$arch" |
    head -n1
}

install_from_github_pkg() {
  # $1 = deb|rpm
  local kind="$1" arch url tmpdir rc

  arch="$(detect_arch "$kind")" || return 1
  url="$(github_latest_url "$kind" "$arch")" || true

  if [[ -z "$url" ]]; then
    echo "$APP_NAME: could not find .$kind asset for arch '$arch' in latest release" >&2
    return 1
  fi

  tmpdir="$(mktemp -d)"
  (
    cd "$tmpdir" || exit 1
    echo "Downloading AppImageLauncher from: $url"
    curl -fLo "appimagelauncher.$kind" "$url" || exit 1

    case "$kind" in
    deb)
      sudo dpkg -i appimagelauncher.deb || sudo apt-get install -f -y
      ;;
    rpm)
      sudo dnf install -y ./appimagelauncher.rpm
      ;;
    esac
  )
  rc=$?
  rm -rf "$tmpdir"
  return "$rc"
}

install_package() {
  case "$DISTRO" in
  arch | cachyos)
    paru -S --needed --noconfirm appimagelauncher
    ;;

  ubuntu)
    install_from_github_pkg deb
    ;;

  fedora)
    install_from_github_pkg rpm
    ;;

  *)
    echo "$APP_NAME: Unsupported distro '$DISTRO'." >&2
    return 1
    ;;
  esac
}
