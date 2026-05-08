#!/bin/bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

log_step "Installing user applications..."

PACMAN_packages=(
    # 通知
    mako libnotify

    # 兼容
    xorg-xwayland

    # 提权
    polkit-gnome
    # 密钥
    gnome-keyring
    
    grim slurp
    swaybg
    foot    
    
    wl-clipboard cliphist

    sddm
    seahorse

    qt5-wayland
    qt6-wayland

    swaylock
    swayidle
    waybar
    
)

log_info "Installing official packages..."
if ! sudo pacman -S --needed --noconfirm "${PACMAN_packages[@]}"; then
    log_error "Failed to install some official packages"
    exit 1
fi

log_info "Installing AUR packages via yay..."
AUR_PACKAGES=(    
    mangowm-git
    sddm-theme-tokyo-night-git
)
if command -v yay >/dev/null; then
    yay -S --needed --noconfirm "${AUR_PACKAGES[@]}" || log_warn "Some AUR packages failed to install"
fi

log_info "Enabling SDDM display manager..."
if ! sudo systemctl enable sddm.service; then
    log_error "Failed to enable SDDM service"
fi

# 允许 papirus-folders 无密码执行（主题切换时无需终端）
log_info "Configuring passwordless sudo for papirus-folders..."
SUDOERS_FILE=/etc/sudoers.d/papirus-folders
{
    echo "Defaults!/usr/bin/papirus-folders env_keep += \"USER_HOME XDG_DATA_DIRS\""
    echo "$USER ALL=(ALL) NOPASSWD: /usr/bin/papirus-folders"
} | sudo tee "$SUDOERS_FILE" > /dev/null
sudo chmod 440 "$SUDOERS_FILE"
log_info "Sudoers rule updated"

log_info "User applications installation complete"
exit 0
