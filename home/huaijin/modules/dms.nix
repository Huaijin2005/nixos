{ config, pkgs, ... }:

{
  # ============================================================
  # DMS (Dank Material Shell) 配置
  # (home/huaijin/modules/dms.nix)
  # ============================================================
  # DMS 是一个基于 Quickshell 的 Wayland 桌面 Shell，
  # 提供面板栏、应用启动器（spotlight）、通知中心、
  # 电源菜单、进程管理、壁纸管理等功能。
  #
  # 安装方式：通过 home-manager 模块
  # （flake input: github:AvengeMedia/DankMaterialShell/stable）
  # 文档：https://danklinux.com/docs/dankmaterialshell/nixos-flake
  # ============================================================

  programs.dank-material-shell = {
    enable = true;

    # ----------------------------------------------------------
    # 启动方式：通过 systemd 用户服务自动启动
    # DMS 会在用户登录后自动运行，由 systemd 管理生命周期
    # ----------------------------------------------------------
    systemd.enable = true;
    systemd.restartIfChanged = true; # nix rebuild 后自动重启 DMS

    # ----------------------------------------------------------
    # 功能开关
    # ----------------------------------------------------------
    enableSystemMonitoring = true; # 系统监控（CPU、内存、磁盘等）
    enableDynamicTheming = true; # 壁纸取色动态主题（matugen）
    enableAudioWavelength = true; # 音频可视化（cava）
    enableCalendarEvents = false; # 日历集成（暂无 khal 需求）
    enableVPN = false; # VPN 管理（暂无需求）
    enableClipboardPaste = true; # 剪贴板粘贴功能

    # ============================================================
    # DMS 设置（映射自 settings.json）
    # ============================================================
    settings = {
      # 主题：Catppuccin Mocha + 蓝色强调色
      currentThemeName = "custom";
      currentThemeCategory = "registry";
      registryThemeVariants = {
        catppuccin = {
          dark = {
            flavor = "mocha"; # Catppuccin 深色变体
            accent = "blue"; # 蓝色强调色（与 GTK 主题一致）
          };
        };
      };

      # 壁纸动态取色
      matugenScheme = "scheme-vibrant"; # 鲜艳配色方案
      runUserMatugenTemplates = true; # 运行用户自定义 matugen 模板

      # 界面透明度
      popupTransparency = 1; # 弹窗完全不透明
      dockTransparency = 1; # 面板完全不透明

      # 组件颜色模式
      widgetBackgroundColor = "sch"; # widget 背景色模式
      widgetColorMode = "colorful"; # 彩色 widget
      controlCenterTileColorMode = "primary"; # 控制中心使用主色调
      buttonColorMode = "primary"; # 按钮使用主色调

      # 圆角
      cornerRadius = 12; # 全局圆角 12px

      # 时间显示
      use24HourClock = true; # 24 小时制
      showSeconds = false; # 不显示秒
      padHours12Hour = false;

      # 天气
      useFahrenheit = false; # 摄氏度
      windSpeedUnit = "ms"; # 风速单位：米/秒

      # 动画
      animationSpeed = 4; # 动画速度（1-10）
      customAnimationDuration = 50; # 自定义动画时长（ms）
      syncComponentAnimationSpeeds = true; # 所有组件同步动画速度

      # 模糊
      blurEnabled = false; # DMS 本身不模糊（由 niri 合成器处理模糊）
      blurForegroundLayers = true;
      blurLayerOutlineOpacity = 0.12;
      blurBorderColor = "outline";

      # 夜间模式
      nightModeEnabled = false;
    };

    # ----------------------------------------------------------
    # 会话设置
    # ----------------------------------------------------------
    session = {
      isLightMode = false; # 深色模式
    };

    # ----------------------------------------------------------
    # 剪贴板设置
    # ----------------------------------------------------------
    clipboardSettings = {
      maxHistory = 25; # 最多保存 25 条
      maxEntrySize = 5242880; # 单条最大 5MB
      autoClearDays = 1; # 每天自动清理
      clearAtStartup = true; # 启动时清理剪贴板历史
      disabled = false;
      disableHistory = false;
      disablePersist = true; # 不持久化剪贴板历史（隐私）
    };
  };

  # ============================================================
  # 注意：DMS 首次启动时需要运行 dms setup 来生成初始配置
  # ============================================================
  # DMS 的 niri 模块会在 niri 启动时自动生成 dms/*.kdl 文件。
  # 如果遇到 niri 启动错误说找不到 dms/*.kdl 文件，
  # 请在终端执行：dms setup
  # 或者单独生成需要的文件，如：
  #   dms setup binds
  #   dms setup colors
  #   dms setup layout
  # ============================================================
}
