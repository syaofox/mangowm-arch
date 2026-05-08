#!/bin/bash

# 1. 启动 PolicyKit 代理（确保能弹出权限框）
/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &

# 2. 启动 GNOME Keyring
eval $(gnome-keyring-daemon --start --components=secrets,ssh,pkcs11)
export SSH_AUTH_SOCK

# 3. 其他组件（如视频中提到的 Waybar 和壁纸）
waybar &
swaybg -i ~/Pictures/wall.jpg &







#!/bin/bash
log() { echo "[$(date +'%H:%M:%S')] $*"; }
err() { echo "[$(date +'%H:%M:%S')] ERROR: $*" >&2; }

LOGDIR="/tmp/dwm"
LOGFILE="$LOGDIR/dwm.log"
mkdir -p "$LOGDIR"
[ -f "$LOGFILE" ] && [ "$(stat -c%s "$LOGFILE")" -gt 1048576 ] && mv "$LOGFILE" "$LOGFILE.old"
exec > >(tee -a "$LOGFILE") 2>&1
log "=== DWM session starting (PID: $$) ==="

#!/bin/bash
# 环境变量
export XDG_CURRENT_DESKTOP=dwm
export XDG_SESSION_DESKTOP=dwm
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx
export SDL_IM_MODULE=fcitx
# export GLFW_IM_MODULE=fcitx  # 之前日志显示为 ibus，这里强制改回
export GLFW_IM_MODULE=ibus
export __GLX_VENDOR_LIBRARY_NAME=nvidia
export QT_QPA_PLATFORMTHEME=qt5ct


# X基础设置
# xset -dpms
# xset s off
# xset s noblank

# 设置屏幕保护和电源管理
xset dpms 0 0 900
xset s 600 s noblank
xss-lock -- slock -m "Single is simple, double is double." &

# 主题逻辑加载 (移动到这里)
if [ -f "$HOME/.config/theme" ]; then
    THEME=$(cat "$HOME/.config/theme")
else
    THEME="tokyonight"
fi

# 加载 Xresources
xrdb -merge ~/.Xresources
if [ -f "$HOME/.Xresources.d/${THEME}" ]; then
    xrdb -merge "$HOME/.Xresources.d/${THEME}"
fi

# 生成主题 (首次启动时，.config/theme 不存在说明未运行过 switch-theme.sh)
if [ ! -f "$HOME/.config/theme" ] && [ -f "$HOME/.local/bin/generate-app-themes.py" ] && [ -n "$THEME" ] && [ -f "$HOME/.Xresources.d/${THEME}" ]; then
    python3 "$HOME/.local/bin/generate-app-themes.py" "$HOME/.Xresources.d/${THEME}"
fi

# 检查是否已经运行，避免重复启动导致的报错
if [ -z "$GNOME_KEYRING_CONTROL" ]; then
    # 使用 eval 捕获输出，并将错误输出重定向到 /dev/null 防止阻塞或报错影响启动
    eval $(gnome-keyring-daemon --start --components=pkcs11,secrets,ssh 2>/dev/null)
fi

# 即使 eval 失败，也尝试导出变量（如果变量为空则不操作）
export SSH_AUTH_SOCK
export GNOME_KEYRING_CONTROL


command -v dbus-update-activation-environment >/dev/null &&
    dbus-update-activation-environment --systemd --all

/usr/lib/policykit-1-gnome/polkit-gnome-authentication-agent-1 >/dev/null 2>&1 &

if command -v numlockx >/dev/null 2>&1; then
    numlockx on &
else
    log "numlockx not installed, skipping"
fi


log "Starting pasystray..."
pasystray >/dev/null 2>&1 &

for svc in xsettingsd dunst slstatus nm-applet blueman-applet xfce4-clipman; do
    log "Starting $svc..."
    $svc &
done

log "Starting fcitx5..."
fcitx5 -d &


log "Starting picom..."
# picom --config "$HOME/.config/picom/picom.conf" -b &

if command -v xwallpaper >/dev/null; then
    WALLPAPER_CONF="$HOME/.config/wallpaper.conf"
    WALLPAPER=$([[ -f "$WALLPAPER_CONF" ]] && [[ -s "$WALLPAPER_CONF" ]] && cat "$WALLPAPER_CONF" || echo "$HOME/.config/walls/nord-2.png")
    log "Setting wallpaper: $WALLPAPER"
    xwallpaper --zoom "$WALLPAPER" &
else
    err "xwallpaper not found, wallpaper not set"
fi

systemctl --user import-environment DISPLAY XAUTHORITY XDG_CURRENT_DESKTOP
