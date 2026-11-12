{ config, pkgs, ... }:

{
  # ============================================================
  # 字体配置 (home/huaijin/modules/fonts.nix)
  # ============================================================
  # 用户级别字体管理。
  # 系统级字体已在 hosts/nixos-vm/configuration.nix 安装。
  # 这里安装额外的用户专属字体和 fontconfig 设置。
  # ============================================================

  # 用户级字体包
  home.packages = with pkgs; [
    # ----------------------------------------------------------
    # Nerd Fonts：带图标的编程字体补丁
    # FiraCode：带连字（ligatures）的现代编程字体
    # 替代原 dotfiles 中的 CodeNewRoman Nerd Font（nixpkgs 中不存在）
    nerd-fonts.fira-code
    # ----------------------------------------------------------
    # 中文编程字体
    lxgw-wenkai-screen # 屏幕优化版（含等宽变体）
    # ponytail: lxgw-wenkai-mono 不在 nixpkgs 中，
    # lxgw-wenkai-screen 本身也适合代码编辑
  ];

  # ============================================================
  # Fontconfig：字体首选顺序和回退
  # ============================================================
  # fontconfig 是 Linux 字体渲染的调度中心。
  # 当程序请求 "sans-serif" 时，fontconfig 按这里的顺序逐个尝试。
  fonts.fontconfig = {
    enable = true; # 启用用户级 fontconfig 管理

    # 默认字体族首选顺序
    # ponytail: 使用 HM 的 defaultFonts 选项而非手写 XML
    defaultFonts = {
      # 无衬线字体（UI、菜单、对话框）
      sansSerif = [
        "LXGW WenKai GB Screen" # 中文首选：含内嵌英文
        "LXGW WenKai TC" # 繁体回退
      ];

      # 衬线字体（正文、文档）
      serif = [
        "LXGW WenKai GB Screen" # 中文首选
        "LXGW WenKai TC" # 繁体回退
      ];

      # 等宽字体（终端、代码编辑器）
      monospace = [
        "FiraCode Nerd Font" # 英文等宽首选（替代 CodeNewRoman NF）
        "LXGW WenKai Mono GB Screen" # 中文等宽回退
      ];
    };
  };
}
