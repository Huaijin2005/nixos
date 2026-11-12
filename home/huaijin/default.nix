{ config, pkgs, ... }:

{
  # ============================================================
  # 用户 huaijin 的 Home Manager 配置
  # (home/huaijin/default.nix)
  # ============================================================
  # 此文件定义用户 huaijin 的所有 home 级别配置。
  # 通过模块化拆分，每个子模块管理一个领域的配置：
  #   - modules/dms.nix    → DMS 桌面面板
  #   - modules/shell.nix  → Zsh/Fish/Tmux/Starship
  #   - modules/terminal.nix → Kitty/Ghostty/WezTerm
  #   - modules/fonts.nix  → 字体包 + fontconfig
  #   - modules/tools.nix  → yazi/lazygit/fastfetch 等工具
  #   - config/niri.nix    → niri 合成器配置（写入 hm.kdl）
  #   - config/neovim.nix  → neovim 配置（链接 dotfiles）
  #   - config/fcitx5.nix  → 输入法用户配置
  #   - config/gtk.nix     → GTK 主题 + 光标 + 设置
  # ============================================================

  imports = [
    # 现有：编辑器/LSP 配置（保留不变）
    ../../modules/home/editor

    # ----------------------------------------------------------
    # 新增：home 子模块
    # ----------------------------------------------------------
    ./modules/dms.nix      # DMS 桌面面板 + niri 集成
    ./modules/shell.nix    # Zsh + Fish + Tmux + Starship
    ./modules/terminal.nix # Kitty + Ghostty + WezTerm
    ./modules/fonts.nix    # 字体包 + fontconfig 首选顺序
    ./modules/tools.nix    # yazi + lazygit + fastfetch + eza 等

    # ----------------------------------------------------------
    # 新增：复杂配置文件（直接链接 dotfiles）
    # ----------------------------------------------------------
    ./config/niri.nix      # Niri 合成器主配置 → hm.kdl
    ./config/neovim.nix    # Neovim + LazyVim 完整配置
    ./config/fcitx5.nix    # Fcitx5 + Rime 输入法配置
    ./config/gtk.nix       # GTK 主题 + 光标 + 字体设置
  ];

  # ============================================================
  # 基本信息
  # ============================================================
  home.username = "huaijin";
  home.homeDirectory = "/home/huaijin";

  # ============================================================
  # 用户级软件包
  # ============================================================
  home.packages = with pkgs; [
    # ----------------------------------------------------------
    # 保留原有软件包
    # ----------------------------------------------------------
    git      # 版本控制
    opencode # AI 编程助手（OpenCode CLI）
    sops     # SOPS 加解密工具
    uv       # Python 包管理器（Rust 实现，替代 pip）

    # ----------------------------------------------------------
    # 新增软件包
    # ----------------------------------------------------------
    # 注意：以下工具也在子模块中声明，但 home.packages 会自动去重。
    # 将核心/常用包放在这里便于一览。
  ];

  # ============================================================
  # 版本锁定
  # ============================================================
  home.stateVersion = "26.05";

  # 启用 Home Manager 自动管理（由 NixOS module 触发）
  programs.home-manager.enable = true;
}
