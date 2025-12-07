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
    paru -S --needed --noconfirm yubico-authenticator

    # PAM user authentication with U2F by Yubico. Supplement or replace password authentication with your YubiKey.
    sudo pacman -S --needed --noconfirm -y pam-u2f
    ;;

  ubuntu)
    # GUI tool to access and reset information, configure slot-based credentials, and read OATH codes from your YubiKey.
    sudo apt-get install -y yubioath-desktop

    # PAM user authentication with U2F by Yubico. Supplement or replace password authentication with your YubiKey.
    sudo apt-get install -y libpam-u2f pamu2fcfg
    ;;

  fedora)
    # GUI tool to access and reset information, configure slot-based credentials, and read OATH codes from your YubiKey.
    sudo flatpak install -y flathub com.yubico.yubioath

    # PAM user authentication with U2F by Yubico. Supplement or replace password authentication with your YubiKey.
    sudo dnf install -y pam-u2f pamu2fcfg
    ;;
  esac

  # Enable and start the pcscd daemon.
  sudo systemctl enable --now pcscd
}
