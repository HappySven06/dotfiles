#!/bin/bash

# Format: ["command_to_check"]="package_name"
declare -A install_packages=(
    [micro]="micro"
    [ttf-jetbrains-mono-nerd]="ttf-jetbrains-mono-nerd"
    [starship]="starship"
    [eza]="eza"
    [bat]="bat"
    [zoxide]="zoxide"
    [fzf]="fzf"
)

# Packages to remove (just package names)
remove_packages=()

echo "[INSTALL] Installing terminal tools..."

# Install packages
for cmd in "${!install_packages[@]}"; do
    pkg="${install_packages[$cmd]}"
    if ! command -v "$cmd" &>/dev/null; then
        echo "[INSTALL] Installing $pkg (provides $cmd)..."
        sudo pacman -S --noconfirm "$pkg"
    else
        echo "[INFO] $cmd already available"
    fi
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

echo "[SUCCESS] Terminal tools installed successfully!"
