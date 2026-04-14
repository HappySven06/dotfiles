#!/bin/bash

install_pkg() {
  case "$CHEZMOI_DISTRO" in
    arch)
      sudo pacman -S --noconfirm "$1"
      ;;
    ubuntu|debian)
      sudo apt-get install -y "$1"
      ;;
    *)
      echo "Unsupported distro: $CHEZMOI_DISTRO"
      return 1
      ;;
  esac
}

is_installed() {
  case "$CHEZMOI_DISTRO" in
    arch)
      pacman -Q "$1" &>/dev/null
      ;;
    ubuntu|debian)
      dpkg -s "$1" &>/dev/null
      ;;
  esac
}

install_packages() {
  declare -n pkgs=$1

  for cmd in "${!pkgs[@]}"; do
    pkg="${pkgs[$cmd]}"

    if ! command -v "$cmd" &>/dev/null && ! is_installed "$pkg"; then
      echo "[INSTALL] $pkg"
      install_pkg "$pkg"
    else
      echo "[SKIP] $pkg"
    fi
  done
}

enable_services() {
  for service in "$@"; do
    sudo systemctl enable --now "$service"
  done
}