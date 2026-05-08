#!/usr/bin/env python3
"""mangowm theme switcher"""

import os
import sys
import re
import shutil
import subprocess
import time

HOME = os.path.expanduser("~")
THEMES_DIR = os.path.join(HOME, ".config/themes")
CURRENT_CONF = os.path.join(THEMES_DIR, "current.conf")


def notify(msg):
    subprocess.run(["notify-send", "-r", "9990", "switch-theme", msg])


def load_colors(theme_dir):
    colors = {}
    path = os.path.join(theme_dir, "colors.sh")
    with open(path) as f:
        for line in f:
            line = line.strip()
            if not line or line.startswith("#") or "=" not in line:
                continue
            key, _, val = line.partition("=")
            key = key.strip()
            val = val.strip()
            if len(val) >= 2 and val[0] == val[-1] and val[0] in ("'", '"'):
                val = val[1:-1]
            colors[key] = val
    return colors


def strip_hash(c):
    return c.lstrip("#")


def pick_theme():
    if len(sys.argv) >= 2:
        return sys.argv[1]
    dirs = sorted(
        d for d in os.listdir(THEMES_DIR)
        if os.path.isdir(os.path.join(THEMES_DIR, d))
        and os.path.isfile(os.path.join(THEMES_DIR, d, "colors.sh"))
    )
    if not dirs:
        notify("No themes found")
        sys.exit(1)
    proc = subprocess.run(
        ["rofi", "-dmenu", "-p", "Switch Theme"],
        input="\n".join(dirs),
        capture_output=True, text=True
    )
    theme = proc.stdout.strip()
    if not theme:
        sys.exit(0)
    return theme


def copy_file(src_name, dst, post_func=None):
    src = os.path.join(theme_dir, src_name)
    if os.path.isfile(src) and os.path.isfile(dst):
        shutil.copy2(src, dst)
        if post_func:
            post_func()


def replace_all(target, pairs):
    if not os.path.isfile(target):
        return
    with open(target) as f:
        content = f.read()
    for pattern, replacement in pairs:
        content = re.sub(pattern, replacement, content, flags=re.MULTILINE)
    with open(target, "w") as f:
        f.write(content)


# --- main ---
theme = pick_theme()
theme_dir = os.path.join(THEMES_DIR, theme)
colors = load_colors(theme_dir)

notify(f"Switching to {colors['THEME_NAME']}...")

# --- Waybar ---
copy_file("waybar-colors.css", os.path.join(HOME, ".config/waybar/colors.css"),
          lambda: (subprocess.run(["pkill", "waybar"]),
                   subprocess.Popen(["waybar"])))

# --- Mango ---
copy_file("mango-colors.conf", os.path.join(HOME, ".config/mango/colors.conf"),
          lambda: subprocess.run(["mmsg", "-d", "reload_config"]))

# --- Rofi ---
copy_file("rofi-theme.rasi", os.path.join(HOME, ".config/rofi/theme.rasi"))

# --- Swaylock ---
replace_all(os.path.join(HOME, ".config/swaylock/config"), [
    (r"^inside-color=.*", f"inside-color={strip_hash(colors['SURFACE'])}"),
    (r"^inside-clear-color=.*", f"inside-clear-color={strip_hash(colors['SURFACE'])}"),
    (r"^inside-ver-color=.*", f"inside-ver-color={strip_hash(colors['SURFACE'])}"),
    (r"^inside-wrong-color=.*", f"inside-wrong-color={strip_hash(colors['SURFACE'])}"),
    (r"^ring-color=.*", f"ring-color={strip_hash(colors['MAGENTA'])}"),
    (r"^ring-clear-color=.*", f"ring-clear-color={strip_hash(colors['GREEN'])}"),
    (r"^ring-ver-color=.*", f"ring-ver-color={strip_hash(colors['CYAN'])}"),
    (r"^ring-wrong-color=.*", f"ring-wrong-color={strip_hash(colors['RED'])}"),
    (r"^text-color=.*", f"text-color={strip_hash(colors['TEXT'])}"),
    (r"^text-clear-color=.*", f"text-clear-color={strip_hash(colors['BG'])}"),
    (r"^text-ver-color=.*", f"text-ver-color={strip_hash(colors['BG'])}"),
    (r"^text-wrong-color=.*", f"text-wrong-color={strip_hash(colors['BG'])}"),
    (r"^key-hl-color=.*", f"key-hl-color={strip_hash(colors['MAGENTA'])}"),
    (r"^separator-color=.*", f"separator-color={strip_hash(colors['SURFACE'])}"),
    (r"^line-color=.*", f"line-color={strip_hash(colors['SURFACE'])}"),
    (r"^line-clear-color=.*", f"line-clear-color={strip_hash(colors['SURFACE'])}"),
    (r"^line-ver-color=.*", f"line-ver-color={strip_hash(colors['SURFACE'])}"),
    (r"^line-wrong-color=.*", f"line-wrong-color={strip_hash(colors['SURFACE'])}"),
    (r"^layout-text-color=.*", f"layout-text-color={strip_hash(colors['MAGENTA'])}"),
])

# --- Mako ---
mako_conf = os.path.join(HOME, ".config/mako/config")
replace_all(mako_conf, [
    (r"^background-color=.*", f"background-color={colors['SURFACE']}"),
    (r"^text-color=.*", f"text-color={colors['TEXT']}"),
    (r"^border-color=.*", f"border-color={colors['BLUE']}"),
    (r"^progress-color=.*", f"progress-color=over {colors['CYAN']}"),
])
if os.path.isfile(mako_conf):
    with open(mako_conf) as f:
        content = f.read()
    content = re.sub(
        r"(?<=\[urgency=low\])(.*?)(?=\[)",
        lambda m: re.sub(r"^border-color=.*", f"border-color={colors['BRBLK']}", m.group(0), flags=re.MULTILINE),
        content, flags=re.DOTALL
    )
    content = re.sub(
        r"(?<=\[urgency=high\])(.*?)(?=\[)",
        lambda m: re.sub(r"^border-color=.*", f"border-color={colors['RED']}", m.group(0), flags=re.MULTILINE),
        content, flags=re.DOTALL
    )
    content = re.sub(
        r"(?<=\[urgency=high\])(.*?)(?=\[)",
        lambda m: re.sub(r"^text-color=.*", f"text-color={colors['RED']}", m.group(0), flags=re.MULTILINE),
        content, flags=re.DOTALL
    )
    content = re.sub(
        r"(?<=\[app-name=Spotify\])(.*?)(?=\[)",
        lambda m: re.sub(r"^border-color=.*", f"border-color={colors['GREEN']}", m.group(0), flags=re.MULTILINE),
        content, flags=re.DOTALL
    )
    content = re.sub(r"(?<=\[app-name=Spotify\])(.*?)$",
        lambda m: re.sub(r"^border-color=.*", f"border-color={colors['GREEN']}", m.group(0), flags=re.MULTILINE),
        content, flags=re.DOTALL
    )
    with open(mako_conf, "w") as f:
        f.write(content)

# --- Foot ---
foot_sec = re.compile(r"^\[colors-dark\](.*?)(?=^\[|\Z)", re.MULTILINE | re.DOTALL)
foot_dst = os.path.join(HOME, ".config/foot/foot.ini")
if os.path.isfile(foot_dst):
    with open(foot_dst) as f:
        content = f.read()

    def foot_repl(m):
        section = m.group(1)
        pairs = [
            ("background", strip_hash(colors["BG"])),
            ("foreground", strip_hash(colors["TEXT"])),
        ] + [(f"regular{i}", strip_hash(colors.get(f"REG{i}", ""))) for i in range(8)]
        pairs += [(f"bright{i}", strip_hash(colors.get(f"BRIGHT{i}", ""))) for i in range(8)]
        for key, val in pairs:
            section = re.sub(rf"^{key}=.*", f"{key}={val}", section, flags=re.MULTILINE)
        return f"[colors-dark]{section}"

    with open(foot_dst, "w") as f:
        f.write(foot_sec.sub(foot_repl, content))

# --- Wlwallpick ---
replace_all(os.path.join(HOME, ".config/wlwallpick/wlwallpick.conf"), [
    (r"^background\s*=.*", f"background       = {colors['BG']}"),
    (r"^border_selected\s*=.*", f"border_selected  = {colors['PURPLE']}"),
])

# --- GTK settings ---
gtk_ini = os.path.join(HOME, ".config/gtk-3.0/settings.ini")
if os.path.isfile(gtk_ini):
    replace_all(gtk_ini, [
        (r"^gtk-theme-name=.*", f"gtk-theme-name={colors['GTK_THEME']}"),
        (r"^gtk-icon-theme-name=.*", f"gtk-icon-theme-name={colors['GTK_ICON_THEME']}"),
    ])
    subprocess.run(["gsettings", "set", "org.gnome.desktop.interface", "gtk-theme", colors["GTK_THEME"]],
                   capture_output=True)
    subprocess.run(["gsettings", "set", "org.gnome.desktop.interface", "icon-theme", colors["GTK_ICON_THEME"]],
                   capture_output=True)

# --- GTK folder color ---
subprocess.run(["papirus-folders", "-t", "Papirus", "-C", colors["GTK_FOLDER_COLOR"], "-u"],
               capture_output=True)
subprocess.run(["papirus-folders", "-t", "Papirus-Dark", "-C", colors["GTK_FOLDER_COLOR"], "-u"],
               capture_output=True)

# --- GTK startup script ---
gtk_script = os.path.join(HOME, ".config/mango/set-gtk-theme.sh")
with open(gtk_script, "w") as f:
    f.write(f"""#!/bin/bash
# 由 switch-theme.py 自动重写
gsettings set org.gnome.desktop.interface gtk-theme '{colors["GTK_THEME"]}'
gsettings set org.gnome.desktop.interface icon-theme '{colors["GTK_ICON_THEME"]}'
gsettings set org.gnome.desktop.interface font-name 'Noto Sans'
gsettings set org.gnome.desktop.interface gtk-application-prefer-dark-theme '0'
papirus-folders -t Papirus -C '{colors["GTK_FOLDER_COLOR"]}' -u
papirus-folders -t Papirus-Dark -C '{colors["GTK_FOLDER_COLOR"]}' -u
""")
os.chmod(gtk_script, 0o755)

# --- Nvim ---
replace_all(os.path.join(HOME, ".config/nvim/after/plugin/colors.lua"), [
    (r'^vim\.cmd\.colorscheme\("[^"]*"\)', f'vim.cmd.colorscheme("{colors["NVIM_COLORSCHEME"]}")'),
])

# --- Yazi ---
replace_all(os.path.join(HOME, ".config/yazi/theme.toml"), [
    (r'^dark = ".*"', f'dark = "{colors["YAZI_FLAVOR"]}"'),
    (r'^light = ".*"', f'light = "{colors["YAZI_FLAVOR"]}"'),
])

# --- Fish (BAT_THEME) ---
replace_all(os.path.join(HOME, ".config/fish/conf.d/01-env.fish"), [
    (r'^set -gx BAT_THEME ".*"', f'set -gx BAT_THEME "{colors["BAT_THEME"]}"'),
])

# --- restart services ---
subprocess.run(["pkill", "mako"])
time.sleep(0.3)
subprocess.Popen(["mako"])

# --- persist ---
with open(CURRENT_CONF, "w") as f:
    f.write(theme + "\n")

notify(f"Theme: {colors['THEME_NAME']}")
