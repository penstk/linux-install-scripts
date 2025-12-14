# Application name (used in logs / messages)
APP_NAME="docker"

# Command to check for in PATH.
# Use a different value if the binary name differs from APP_NAME.
CMD_NAME="$APP_NAME"

# Load helper scripts
. "$ROOT_DIR/helpers/is_installed.sh"

is_installed() {
  is_installed_cmd "$CMD_NAME"
}

install_package() {
  case "$DISTRO" in
  arch | cachyos)
    sudo pacman -S --noconfirm --needed docker docker-compose || return 1
    sudo systemctl enable --now docker.service || return 1
    ;;
  ubuntu)
    # Uninstall any conflicting package
    sudo apt -y remove "$(dpkg --get-selections docker.io docker-compose docker-compose-v2 docker-doc podman-docker containerd runc | cut -f1)"
    # Only run apt-get update if it hasn’t been done in this session
    if [[ "${APT_UPDATED:-0}" != 1 ]]; then
      sudo apt-get update
      APT_UPDATED=1
    fi

    # Set up Docker's apt repository.
    # Add Docker's official GPG key:
    sudo apt-get update || return 1
    sudo apt -y install ca-certificates curl || return 1
    sudo install -m 0755 -d /etc/apt/keyrings || return 1
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc || return 1
    sudo chmod a+r /etc/apt/keyrings/docker.asc || return 1

    # Add the repository to Apt sources:
    sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc
EOF

    sudo apt-get update

    # Install the Docker packages.
    sudo apt -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin || return 1
    ;;
  fedora)
    # Uinstall any conflicting package
    sudo dnf -y remove docker \
      docker-client \
      docker-client-latest \
      docker-common \
      docker-latest \
      docker-latest-logrotate \
      docker-logrotate \
      docker-selinux \
      docker-engine-selinux \
      docker-engine
    # Set up the repository
    sudo dnf -y install dnf-plugins-core || return 1
    sudo dnf-3 config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo || return 1

    # Install the Docker packages.
    sudo dnf -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin || return 1
    # Start Docker Engine.
    sudo systemctl enable --now docker || return 1
    ;;
  *)
    echo "$APP_NAME: Unsupported distro '$DISTRO'." >&2
    return 1
    ;;
  esac

  # Create the docker group.
  sudo groupadd -f docker || return 1
  # Add the current user to the docker group.
  sudo usermod -aG docker "$USER" || return 1
  # Ensure ~/.docker exists and has correct ownership & permissions
  mkdir -p "$HOME/.docker" || return 1
  sudo chown -R "$USER":"$USER" "$HOME"/.docker || return 1
  sudo chmod -R g+rwx "$HOME/.docker" || return 1
}
