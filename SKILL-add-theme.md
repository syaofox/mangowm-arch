# 添加新主题指南

## 目录结构

每个主题在 `dotfiles/.config/themes/<theme-name>/` 下，包含 4 个文件：

```
themes/<theme-name>/
├── colors.sh             # 颜色变量定义
├── mango-colors.conf     # Mango WM 边框颜色 (ARGB)
├── waybar-colors.css     # Waybar CSS 变量
└── rofi-theme.rasi       # Rofi 主题
```

## 步骤

### 1. 创建目录

```bash
mkdir -p dotfiles/.config/themes/<theme-name>
```

### 2. 编写 colors.sh

**必须定义的变量**（共 40 行）：

| 变量 | 用途 | 示例 |
|------|------|------|
| `THEME_NAME` | 显示名称 | `"Tokyo Night"` |
| `BG` | 根背景 | `#1a1b26` |
| `SURFACE` | 面板/控件背景 | `#24283b` |
| `FG` | 主要前景文字 | `#a9b1d6` |
| `TEXT` | 高亮文字 | `#c0caf5` |
| `RED` | 红色 | `#f7768e` |
| `GREEN` | 绿色 | `#9ece6a` |
| `YELLOW` | 黄色 | `#e0af68` |
| `BLUE` | 蓝色 | `#7aa2f7` |
| `MAGENTA` | 品红 | `#bb9af7` |
| `PURPLE` | 紫色（wlwallpick 边框用） | `#ad8ee6` |
| `CYAN` | 青色 | `#7dcfff` |
| `BRBLK` | 亮黑/灰（mako low urgency 边框） | `#444b6a` |
| `WHITE` | 白色 | `#ffffff` |
| `REG0`–`REG7` | 终端 8 色 | 见下文 |
| `BRIGHT0`–`BRIGHT7` | 终端亮色 8 色 | 见下文 |
| `GTK_THEME` | GTK 主题名 | `"Adwaita"` |
| `GTK_ICON_THEME` | GTK 图标主题 | `"Papirus"` |
| `GTK_FOLDER_COLOR` | Papirus 文件夹颜色 | `"indigo"` |
| `NVIM_COLORSCHEME` | Neovim 主题名 | `"tokyonight"` |
| `YAZI_FLAVOR` | Yazi flavor 名 | `"tokyo-night"` |
| `BAT_THEME` | bat 主题名 | `"ansi"` |

**终端颜色映射惯例：**

```
REG0=BG        REG1=RED    REG2=GREEN  REG3=YELLOW
REG4=BLUE      REG5=MAGENTA  REG6=CYAN   REG7=FG
BRIGHT0=BRBLK  BRIGHT1=RED  BRIGHT2=GREEN BRIGHT3=YELLOW
BRIGHT4=BLUE   BRIGHT5=MAGENTA BRIGHT6=CYAN  BRIGHT7=TEXT
```

### 3. 编写 mango-colors.conf

格式：`0xAARRGGBB`（ARGB 十六进制，alpha 通道在前）

| 变量 | 对应 colors.sh |
|------|----------------|
| `rootcolor` | `BG` → alpha 固定 `ff` |
| `bordercolor` | `SURFACE` |
| `dropcolor` | `BLUE` 或主题强调色 + alpha `55` |
| `focuscolor` | `MAGENTA` 或主题强调色 |
| `maximizescreencolor` | `MAGENTA` 或主题强调色 |
| `urgentcolor` | `RED` |
| `scratchpadcolor` | `CYAN` |
| `globalcolor` | `MAGENTA` 或主题强调色 |
| `overlaycolor` | `GREEN` |

### 4. 编写 waybar-colors.css

Waybar 使用 `@define-color` 变量，通过 `style.css` 中的 `@import url("./colors.css")` 引入。

| CSS 变量 | 对应 colors.sh |
|----------|----------------|
| `bg` | `BG` |
| `fg` | `FG` |
| `blk` | `#32344a`（深灰，非变量） |
| `red` | `RED` |
| `grn` | `GREEN` |
| `ylw` | `YELLOW` |
| `blu` | `BLUE` |
| `mag` | `PURPLE` |
| `cyn` | `CYAN` 或主题强调色 |
| `brblk` | `BRBLK` |
| `white` | `WHITE` |

### 5. 编写 rofi-theme.rasi

- 结构固定（179 行），只需替换文件顶部的颜色值
- `background` → `BG`
- `foreground` → 比 `FG` 亮一些（如 `TEXT`）
- `selected-normal-background` → 主题强调色（如 `MAGENTA`/`BLUE`）
- `selected-active-foreground` / `active-foreground` → 强调色
- 所有 `rgba()` 值使用 `BG` 的 RGB 分量

### 6. 确认 switch-theme.sh 无需修改

`switch-theme.sh` 会自动发现新主题：它通过 `ls "$THEMES_DIR"/*/colors.sh` 列出可用主题，再通过 sed 替换将 `colors.sh` 中的值传播到各应用配置。只需确保 `colors.sh` 定义了所有必需变量。

### 7. 验证清单

| 应用 | 配置文件 | 切换方式 | 验证方法 |
|------|----------|----------|----------|
| Mango WM | `~/.config/mango/colors.conf` | 复制 `mango-colors.conf`，`mmsg -d reload_config` | 边框颜色变化 |
| Waybar | `~/.config/waybar/colors.css` | 复制 `waybar-colors.css`，重启 waybar | 面板颜色变化 |
| Rofi | `~/.config/rofi/theme.rasi` | 复制 `rofi-theme.rasi` | 启动器颜色变化 |
| Swaylock | `~/.config/swaylock/config` | sed 替换 7 个颜色值 | 锁屏颜色变化 |
| Mako | `~/.config/mako/config` | sed 替换背景/文字/边框/进度条 | 通知颜色变化 |
| Foot | `~/.config/foot/foot.ini` `[colors-dark]` | sed 替换 18 个颜色值 | 终端颜色变化 |
| Wlwallpick | `~/.config/wlwallpick/wlwallpick.conf` | sed 替换 background/border_selected | 壁纸选择器颜色变化 |
| GTK | `~/.config/gtk-3.0/settings.ini` | sed 替换 + gsettings + papirus-folders | 应用主题/图标变化 |
| Nvim | `~/.config/nvim/after/plugin/colors.lua` | sed 替换 `colorscheme("...")` | 编辑器颜色变化 |
| Yazi | `~/.config/yazi/theme.toml` | sed 替换 `dark`/`light` flavor | 文件管理器颜色变化 |
| Fish | `~/.config/fish/conf.d/01-env.fish` | sed 替换 `BAT_THEME` | bat 输出颜色变化 |

### 8. 注意事项

- 主题名使用小写连字符，如 `tokyo-night-teal`
- `colors.sh` 中颜色值必须带 `#` 前缀，其他文件不带
- mango-colors.conf 是 `0xAARRGGBB` 格式（alpha 在前）
- 每个 `setup/*.sh` 独立可执行，添加主题不需要修改任何 setup 脚本
- 重新部署 dotfiles 后新主题才会出现在目标系统上
- 可通过 `Super+Shift+T` 调出主题切换菜单，或直接运行 `~/.config/themes/switch-theme.sh <theme-name>`
