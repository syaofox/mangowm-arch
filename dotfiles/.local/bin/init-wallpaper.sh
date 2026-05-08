#!/bin/bash
WALLPAPER_CONF="$HOME/.config/wallpaper.conf"
FALLBACK="$HOME/.config/walls/nord.jpg"

if [[ -f "$WALLPAPER_CONF" ]] && [[ -s "$WALLPAPER_CONF" ]]; then
    wallpaper=$(cat "$WALLPAPER_CONF")
else
    wallpaper="$FALLBACK"
fi

if [[ -f "$wallpaper" ]]; then
    swaybg -i "$wallpaper" -m fill &
else
    swaybg -i "$FALLBACK" -m fill &
fi
