#!/bin/bash
# 由 switch-theme.sh 在主题切换时自动重写
gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita'
gsettings set org.gnome.desktop.interface icon-theme 'Papirus'
gsettings set org.gnome.desktop.interface font-name 'Noto Sans'
gsettings set org.gnome.desktop.interface gtk-application-prefer-dark-theme '0'
