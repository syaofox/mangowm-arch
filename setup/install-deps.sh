#!/bin/bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

log_step "Installing system dependencies..."

PACMAN_packages=(
    # X11 桌面基础
    base-devel
    meson ninja 
    less

    curl wget

    btrfs-progs
    rsync
    udisks2
    bash-completion

    git 
    xclip    
    zenity
    dconf
    

    pavucontrol 

    gvfs
    mtools
    smbclient
    cifs-utils
    nfs-utils
    fuse3

    nano
    vim
    openssh
    htop
    
    smartmontools
    xdg-utils
    wlr-randr

)

log_info "Installing official packages..."
if ! sudo pacman -S --needed --noconfirm "${PACMAN_packages[@]}"; then
    log_error "Failed to install some official packages"
    exit 1
fi

log_info "System dependencies installation complete"
exit 0
