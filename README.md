# Nvidia 显卡设置检查

## 1. 配置文件检查（安装后立即执行）

```bash
# mkinitcpio — MODULES 应包含 nvidia nvidia_modeset nvidia_uvm nvidia_drm
grep "^MODULES=" /etc/mkinitcpio.conf
# 预期: MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm ...)

# GRUB 内核参数
grep "nvidia_drm" /etc/default/grub
# 预期: GRUB_CMDLINE_LINUX_DEFAULT="... nvidia_drm.modeset=1 nvidia_drm.fbdev=1"

# systemd-boot 内核参数（任一即可）
cat /etc/kernel/cmdline 2>/dev/null || grep "nvidia_drm" /boot/loader/entries/*.conf
# 预期: 包含 nvidia_drm.modeset=1 nvidia_drm.fbdev=1

# modprobe 模块参数
cat /etc/modprobe.d/nvidia.conf
# 预期: options nvidia_drm modeset=1 / fbdev=1 / NVreg_PreserveVideoMemoryAllocations=1

# Nvidia Wayland 环境变量
cat /etc/environment.d/nvidia.conf
# 预期: GBM_BACKEND=nvidia-drm / __GLX_VENDOR_LIBRARY_NAME=nvidia / WLR_NO_HARDWARE_CURSORS=1
```

## 2. 运行时检查（重启后执行）

```bash
# 当前内核参数中 nvidia_drm 应生效
cat /proc/cmdline | grep nvidia_drm
# 预期: 输出 nvidia_drm.modeset=1 nvidia_drm.fbdev=1

# nvidia 内核模块应已加载
lsmod | grep nvidia
# 预期: 输出 nvidia, nvidia_modeset, nvidia_uvm, nvidia_drm 等多行

# Wayland 会话下 GBM 后端正确
echo $GBM_BACKEND
# 预期: nvidia-drm

# 显卡驱动信息
nvidia-smi
# 预期: 显示 GPU 型号、驱动版本、CUDA 版本
```

## 3. 常见问题排查

| 现象 | 原因 | 解决 |
|---|---|---|
| `nvidia-smi` 报错 "No devices were found" | 模块未加载 | 检查 `lsmod \| grep nvidia`，确认 mkinitcpio 配置正确 |
| Wayland 会话闪退/黑屏 | 缺少 `nvidia_drm.modeset=1` | 检查 `/proc/cmdline`，确认 bootloader 配置已生效 |
| 休眠唤醒后黑屏 | 缺少 `NVreg_PreserveVideoMemoryAllocations` | 检查 `/etc/modprobe.d/nvidia.conf` |
| 鼠标指针闪烁/消失 | 硬件光标问题 | 确认 `WLR_NO_HARDWARE_CURSORS=1` 已设置 |
