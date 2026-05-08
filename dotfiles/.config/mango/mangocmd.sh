#!/bin/bash

mode="$1"
shift # 移除第一个参数 (mode)，使 $@ 包含剩下的参数

case "$mode" in
    launcher)
        rofi -show drun -show-icons
        ;;
    yazi)
        exec foot -a yazi-float bash -l -i -c 'exec yazi'
        ;;
    file_gui)
        nemo --no-desktop
        ;;
    clipboard)
        cliphist list | rofi -dmenu -p "剪贴板历史" -theme-str 'listview { columns: 1; }' | cliphist decode | wl-copy
        ;;
    clipboard_wipe)
        cliphist wipe && notify-send "剪贴板已清空"
        ;;    
    terminal)
        # 现在的 $@ 已经是空的（如果你只传了 term）
        # 或者包含了 term 之后的参数
        exec foot "$@"
        ;;
    shot_copy)
        grim -l 0 -g "$(slurp)" - | wl-copy && \
        notify-send -r 9988 -t 2000 '截图已保存到剪贴板' || \
        notify-send -r 9988 -t 2000 '截图失败'
        ;;
    shot_save)
        mkdir -p "$HOME/Pictures/Screenshots"
        filepath="$HOME/Pictures/Screenshots/screenshot_$(date +%Y%m%d_%H%M%S).png"
        
        # Capture the selection and save to path
        grim -l 0 -g "$(slurp)" "$filepath" && \
        (wl-copy < "$filepath"; notify-send -r 9988 -t 2000 "截图已保存: $filepath") || \
        notify-send -r 9988 -t 2000 '截图失败'
        ;;
    switch_theme)
        exec "$HOME/.config/themes/switch-theme.sh" "$@"
        ;;
    rebar)
        pkill waybar; waybar &
        ;;
    lock)
        swaylock
        ;;
    idle)
        swayidle -w timeout 300 'swaylock' timeout 600 'wlr-randr | grep "^[^ ]" | cut -d" " -f1 | xargs -I{} wlr-randr --output {} --off' resume 'wlr-randr | grep "^[^ ]" | cut -d" " -f1 | xargs -I{} wlr-randr --output {} --on'
        ;;
esac