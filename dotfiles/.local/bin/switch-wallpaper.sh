#!/bin/bash
WALLPAPER_DIR="${1:-$HOME/.config/walls}"
WALLPAPER_CONF="$HOME/.config/wallpaper.conf"

notify() { notify-send -r 9989 "switch-wallpaper" "$1"; }

set_wallpaper() {
    local wallpaper="$1"
    [[ ! -f "$wallpaper" ]] && { notify "File not found: $wallpaper"; return 1; }

    pkill swaybg 2>/dev/null || true
    swaybg -i "$wallpaper" -m fill &
    echo "$wallpaper" > "$WALLPAPER_CONF"
    notify "Wallpaper set"
}

path=$(wlwallpick "$WALLPAPER_DIR") || { notify "wlwallpick failed"; exit 1; }

set_wallpaper "$path"
