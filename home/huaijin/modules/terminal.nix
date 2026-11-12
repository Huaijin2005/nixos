{ config, pkgs, ... }:

{
  # ============================================================
  # 终端配置 (home/huaijin/modules/terminal.nix)
  # ============================================================
  # 三个终端模拟器：kitty、ghostty、wezterm
  # 统一风格：Catppuccin Mocha 主题、FiraCode Nerd Font、80% 不透明度、模糊
  # kitty 和 ghostty 使用 home-manager 的 programs.* 选项管理
  # wezterm 配置过于复杂（Lua 模块化），直接链接 dotfiles
  # ============================================================

  # ============================================================
  # Kitty 终端配置
  # ============================================================
  programs.kitty = {
    enable = true;

    # 终端字体
    font = {
      name = "FiraCode Nerd Font"; # 替换原 CodeNewRoman Nerd Font
      size = 13;
    };

    # 光标样式
    settings = {
      # 光标为竖线形状（beam），宽度适中（8.0）
      cursor_shape = "beam";
      cursor_beam_thickness = 8.0;
      cursor_blink_interval = "0.6 ease-in-out"; # 光标呼吸式闪烁
      cursor_trail = 3; # 光标拖尾效果

      # 回滚缓冲区（10000 行历史）
      scrollback_lines = 10000;

      # 窗口设置
      background_opacity = "0.8"; # 80% 不透明度
      background_blur = 1; # 模糊由 niri 合成器控制
      window_padding_width = "4 6"; # 左右 4px，上下 6px
      hide_window_decorations = "no"; # 显示窗口标题栏
      scrollbar = "never"; # 不显示滚动条

      # URL 样式
      url_style = "straight"; # 直线下划线
      underline_hyperlinks = "hover"; # 鼠标悬停时显示下划线
      modify_font = "underline_thickness 50%"; # 下划线粗细
    };

    # 额外配置（快捷键、鼠标、主题引入）
    extraConfig = ''
      # ============================================================
      # 主题引入
      # ============================================================
      include ~/.config/kitty/themes/Catppuccin-Mocha.conf

      # ============================================================
      # 快捷键配置
      # ============================================================
      # 清除所有默认快捷键
      clear_all_shortcuts yes

      # 字体大小调节
      map ctrl+equal change_font_size all +1.0
      map ctrl+plus change_font_size all +1.0
      map ctrl+minus change_font_size all -1.0
      map ctrl+0 change_font_size all 0

      # 复制粘贴（标准终端快捷键）
      map ctrl+shift+c copy_to_clipboard
      map ctrl+shift+v paste_from_clipboard

      # Shift+Enter 发送字面换行符（不是执行命令）
      map shift+enter send_text all \n

      # ============================================================
      # 鼠标配置
      # ============================================================
      # 选中文本自动复制到剪贴板
      copy_on_select clipboard

      # 右键粘贴
      mouse_map right press ungrabbed,grabbed paste_from_clipboard

      # Ctrl+中键 重置字体大小
      mouse_map ctrl+middle press ungrabbed,grabbed change_font_size all 0
    '';
  };

  # ============================================================
  # 终端包安装
  # ============================================================
  # kitty 通过 programs.kitty.enable 自动安装
  # ghostty 和 wezterm 需要手动添加到 home.packages
  home.packages = with pkgs; [
    ghostty # Ghostty 终端模拟器
    wezterm # WezTerm 终端模拟器
  ];

  xdg.configFile."ghostty/config".text = ''
    # ============================================================
    # Ghostty 配置 - 由 home-manager 生成
    # 来源：home/huaijin/modules/terminal.nix
    # ============================================================

    # 主题
    theme = Catppuccin Mocha

    # 字体（替换 CodeNewRoman 为 FiraCode NF）
    font-family = FiraCode Nerd Font
    font-size = 12

    # 窗口设置
    background-opacity = 0.8
    background-blur = true
    window-decoration = auto
    window-show-tab-bar = never
    window-padding-x = 5
    window-padding-y = 3

    # 光标
    cursor-style = block
    cursor-style-blink = true

    # 回滚缓冲区（约 50MB）
    scrollback-limit = 50000000

    # 终端行为
    mouse-hide-while-typing = true
    copy-on-select = clipboard
    confirm-close-surface = false
    gtk-titlebar = false
    gtk-single-instance = false

    # Shell 集成
    shell-integration = detect
    shell-integration-features = no-cursor,sudo,title

    # 通知
    app-notifications = no-clipboard-copy,no-config-reload

    # ============================================================
    # 快捷键配置
    # ============================================================
    # 清除所有默认快捷键
    keybind = clear

    # 字体大小调节
    keybind = ctrl+equal=increase_font_size:1
    keybind = ctrl+plus=increase_font_size:1
    keybind = ctrl+minus=decrease_font_size:1
    keybind = ctrl+zero=reset_font_size

    # 复制粘贴
    keybind = ctrl+shift+c=copy_to_clipboard
    keybind = ctrl+shift+v=paste_from_clipboard

    # 实用快捷键
    keybind = ctrl+shift+r=reload_config
    keybind = ctrl+comma=open_config
    keybind = shift+enter=text:\n
  '';

  # ============================================================
  # WezTerm 终端配置
  # ============================================================
  # ponytail: WezTerm 的 Lua 模块化配置（appearance/keybindings/mousebindings）
  # 过于复杂，不适合转为 nix attrset。直接链接 dotfiles 中的完整配置目录。
  xdg.configFile."wezterm".source = config.lib.file.mkOutOfStoreSymlink
    /home/huaijin/dotfiles/terminal/.config/wezterm;

  # ============================================================
  # Kitty 主题文件
  # ============================================================
  # Catppuccin Mocha 主题文件（kitty 通过 include 指令加载）
  home.file.".config/kitty/themes/Catppuccin-Mocha.conf".source =
    config.lib.file.mkOutOfStoreSymlink
      /home/huaijin/dotfiles/terminal/.config/kitty/themes/Catppuccin-Mocha.conf;
}
