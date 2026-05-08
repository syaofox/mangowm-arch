#!/bin/bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

log_step "Installing gtk applications..."

PACMAN_packages=(
    glib2
    nwg-look
    qt5ct
    xdg-desktop-portal
    xdg-desktop-portal-gtk
    kvantum    
    gnome-themes-extra
    papirus-icon-theme
)

log_info "Installing official packages..."
if ! sudo pacman -S --needed --noconfirm "${PACMAN_packages[@]}"; then
    log_error "Failed to install some official packages"
    exit 1
fi


log_info "Installing AUR packages via yay..."
AUR_PACKAGES=(
    papirus-folders
    papirus-nord
)
if command -v yay >/dev/null; then
    yay -S --needed --noconfirm "${AUR_PACKAGES[@]}" || log_warn "Some AUR packages failed to install"
fi



log_info "User applications installation complete"
exit 0
