{ config, pkgs, ... }:

{
  # ============================================================
  # Neovim 配置 (home/huaijin/config/neovim.nix)
  # ============================================================
  # Neovim 使用 LazyVim 发行版，配置文件极其复杂（Lua 模块化、插件管理、
  # LSP 配置等），不适合转为 nix attrset。直接链接 dotfiles 中的完整配置目录。
  #
  # 来源：/home/huaijin/dotfiles/tools/.config/nvim/
  # ============================================================

  # Neovim 软件包
  home.packages = with pkgs; [
    neovim # Neovim 编辑器
  ];

  # 链接 nvim 配置目录到 ~/.config/nvim
  xdg.configFile."nvim".source = config.lib.file.mkOutOfStoreSymlink
    /home/huaijin/dotfiles/tools/.config/nvim;
}
