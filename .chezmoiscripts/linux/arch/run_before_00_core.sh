#!/bin/bash

# Format: ["command_to_check"]="package_name"
declare -A install_packages=(
  [chezmoi]="chezmoi"
  [git]="git"
  [ssh]="openssh"
)

# Packages to enabel
enable_packages=(
  "sshd"
)

# Packages to remove (just package names)
remove_packages=()

echo "--------------------------------------------------"
echo "[INSTALL] Installing core tools..."
echo ""

# Install packages
for cmd in "${!install_packages[@]}"; do
  pkg="${install_packages[$cmd]}"
  if ! command -v "$pkg" &>/dev/null && ! pacman -Q "$pkg" &>/dev/null; then
    echo "[INSTALL] Installing $pkg (provides $cmd)..."
    sudo pacman -S --noconfirm "$pkg"
  else
    echo "[INFO] $cmd already available"
  fi
done

# Activate packages
for service in "${enable_packages[@]}"; do
  echo "[SERVICE] Enabling and starting $service..."
  sudo systemctl enable --now "$service".service
done

# Remove unwanted packages
for pkg in "${remove_packages[@]}"; do
  if pacman -Q "$pkg" &>/dev/null; then
    echo "[REMOVE] Removing $pkg..."
    sudo pacman -R --noconfirm "$pkg"
  else
    echo "[INFO] $pkg is not installed"
  fi
done

echo ""
echo "[SUCCESS] Core tools installed successfully!"
