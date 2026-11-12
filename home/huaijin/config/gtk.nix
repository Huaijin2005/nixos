{ config, pkgs, ... }:

{
  # ============================================================
  # GTK 主题 + 光标 + 设置 (home/huaijin/config/gtk.nix)
  # ============================================================
  # 统一视觉风格：Tokyonight Dark Storm GTK 主题 + Catppuccin Mocha 光标
  #
  # Tokyonight GTK 主题不在 nixpkgs 中，直接从 dotfiles 链接。
  # Catppuccin 光标在 nixpkgs 中有包，直接安装。
  # ============================================================

  # Catppuccin 光标主题（nixpkgs 中有包）
  home.packages = with pkgs; [
    catppuccin-cursors # Catppuccin Mocha Dark 光标主题
  ];

  # ============================================================
  # GTK 全局设置
  # ============================================================
  gtk = {
    enable = true;

    # 主题名（需与 ~/.themes 中的目录名一致）
    theme = {
      name = "Tokyonight-BL-LB-Dark-Storm";
      # GTK 主题由 home.file 从 dotfiles 链接到 ~/.themes
      package = null; # 不使用 nixpkgs 中的包
    };

    # 光标主题
    cursorTheme = {
      name = "catppuccin-mocha-dark-cursors";
      size = 24;
    };

    # 图标主题
    iconTheme = {
      name = "Tela-circle-Dark"; # Tokyonight 主题配套图标
      # ponytail: Tela-circle-Dark 图标不在 nixpkgs 中，
      # 暂时使用系统默认图标。不影响核心功能。
      package = null;
    };

    # 字体
    font = {
      name = "LXGW WenKai GB Screen";
      size = 11;
    };

    # GTK3 额外设置
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1; # 优先使用深色主题
      gtk-im-module = "fcitx"; # 输入法模块
    };

    # GTK4 额外设置
    gtk4.extraConfig = {
      gtk-im-module = "fcitx"; # 输入法模块
    };
  };

  # ============================================================
  # Tokyonight GTK 主题文件链接
  # ============================================================
  # 将 dotfiles 中的完整主题目录链接到 ~/.themes
  # GTK 会从此目录加载主题
  home.file.".themes/Tokyonight-BL-LB-Dark-Storm".source =
    config.lib.file.mkOutOfStoreSymlink
      /home/huaijin/dotfiles/ricing/.themes/Tokyonight-BL-LB-Dark-Storm;

  # ============================================================
  # GTK4 额外 CSS 主题文件
  # ============================================================
  # Tokyonight 主题的 CSS 变量和样式覆盖
  xdg.configFile = {
    "gtk-4.0/gtk.css".source = config.lib.file.mkOutOfStoreSymlink
      /home/huaijin/dotfiles/ricing/.config/gtk-4.0/gtk.css;

    "gtk-4.0/gtk-dark.css".source = config.lib.file.mkOutOfStoreSymlink
      /home/huaijin/dotfiles/ricing/.config/gtk-4.0/gtk-dark.css;

    # GTK4 图标资源（复选框、单选框、滑块等 SVG/PNG）
    "gtk-4.0/assets".source = config.lib.file.mkOutOfStoreSymlink
      /home/huaijin/dotfiles/ricing/.config/gtk-4.0/assets;
  };
}
