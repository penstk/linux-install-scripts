is_installed() {
  case "$DISTRO" in
  arch | cachyos)
    is_installed_cmd "authenticator"
    ;;
  ubuntu)
    is_installed_cmd "yubioath-desktop"
    ;;
  fedora)
    flatpak info com.yubico.yubioath &>/dev/null
    ;;
  esac
}

install_package() {
  case "$DISTRO" in
  arch | cachyos)
    # GUI tool to access and reset information, configure slot-based credentials, and read OATH codes from your YubiKey.
    paru -S --needed --noconfirm yubico-authenticator || return 1
    ;;

  ubuntu)
    # GUI tool to access and reset information, configure slot-based credentials, and read OATH codes from your YubiKey.
    sudo apt-get install -y yubioath-desktop || return 1
    ;;

  fedora)
    # GUI tool to access and reset information, configure slot-based credentials, and read OATH codes from your YubiKey.
    sudo flatpak install -y flathub com.yubico.yubioath || return 1
    ;;
  esac

  # Enable and start the pcscd daemon.
  sudo systemctl enable --now pcscd || return 1
}
