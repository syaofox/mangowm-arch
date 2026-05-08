# mangowc-arch

Arch Linux 安装后的自动化配置项目：部署 mangowm Wayland 合成器及全套桌面环境。

## 项目结构

- `install.sh` — **唯一入口**，按顺序执行 `setup/*.sh`
- `setup/` — 安装步骤脚本，每个文件是一个独立步骤
- `dotfiles/` — 用户配置，部署到 `$HOME/`（`deploy-dotfiles.sh`）
- `sdotfiles/` — 系统配置，部署到 `/`（`deploy-sdotfiles.sh`，需 sudo）
- `tools/` — 辅助工具（配置备份/还原 `config-manager.sh`、KVM 安装 `install-kvm.sh`）
- `sbin/` — 系统管理脚本（btrfs、sysctl、zram）
- `backups/` — 加密的配置备份

## 核心约定

- **必须以普通用户运行**，内部使用 sudo
- 所有 `setup/*.sh` 独立可执行，带 `set -euo pipefail`
- 失败时交互式询问 `[r]重试 / [s]跳过 / [e]退出`
- 步骤之间无状态依赖，每步自包含
- 无测试框架、无 CI、无 linter/formatter

## MangoWM 配置

- 主配置：`dotfiles/.config/mango/config.conf`
- 命令调度：`dotfiles/.config/mango/mangocmd.sh`（锁屏、音量、截图、启动器等）
- 可用布局通过 `circle_layout=tile,scroller` 限制
- 锁屏：`swaylock`，其他配置：`dotfiles/.config/swaylock/config`
- 空闲管理：`swayidle`（300s 锁屏 → 600s 关显示器）
- `Super+R` 重载配置

## 壁纸切换

- `dotfiles/.local/bin/switch-wallpaper.sh` — 用 `wlwallpick` 交互选择壁纸，`swaybg` 设置
- `dotfiles/.local/bin/init-wallpaper.sh` — 登录时恢复上次壁纸（读取 `~/.config/wallpaper.conf`，回退 `nord.jpg`）
- 壁纸目录：`~/.config/walls/`，快捷键 `Super+Shift+W`
- wlwallpick 配置：`dotfiles/.config/wlwallpick/wlwallpick.conf`

## Waybar 配置

- `dotfiles/.config/waybar/config.jsonc` + `style.css`
- 不支持的工具自动静默禁用（如 VM 中 temperature 模块）
- 自定义脚本 (`~/.local/bin/`)：`net-speed`（网速）、`gpu-stats`（NVIDIA 显卡）
- 点击/滚轮音量控制集成在 pulseaudio 模块

## 开发命令

```bash
# 完整安装（顺序执行所有步骤）
./install.sh

# 单独执行某个安装步骤
./setup/install-mango.sh
./setup/deploy-dotfiles.sh
./setup/deploy-sdotfiles.sh

# 配置备份/还原（fzf 交互）
./tools/config-manager.sh
```
