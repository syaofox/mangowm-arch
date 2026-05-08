#!/bin/bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

log_info "Installing needed packages..."

if ! sudo pacman -S --needed --noconfirm sdl2; then
    log_error "Failed to install sdl2"
    exit 1
fi


log_step "Compile and install WallPick..."

compile_and_install "wlwallpick" "https://github.com/syaofox/wlwallpick.git" "/tmp/wlwallpick"
exit $?
