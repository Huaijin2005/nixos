{ config, pkgs, ... }:

{
  # ============================================================
  # Fcitx5 + Rime 输入法配置 (home/huaijin/config/fcitx5.nix)
  # ============================================================
  # Fcitx5 是输入法框架，Rime 是输入法引擎。
  # 系统级配置（fcitx5-rime、rime-ice 等包安装）在
  # hosts/nixos-vm/configuration.nix 的 i18n.inputMethod 中。
  #
  # 这里管理用户级配置：
  #   - Rime 自定义 YAML 文件（方案、候选数等）
  #   - Fcitx5 主题
  #   - 应用级输入法行为（kitty/code 中自动切换英文）
  # ============================================================

  # ----------------------------------------------------------
  # Rime 自定义配置
  # ----------------------------------------------------------
  # Rime 的配置目录在不同安装方式下路径不同。
  # 通过 fcitx5 安装时，通常为 ~/.local/share/fcitx5/rime/
  # 以下文件直接链接 dotfiles 中的原始配置。
  xdg.dataFile = {
    # 默认 Rime 设置：使用雾凇拼音方案，9 个候选词
    "fcitx5/rime/default.custom.yaml".source =
      config.lib.file.mkOutOfStoreSymlink
        /home/huaijin/dotfiles/tools/.local/share/fcitx5/rime/default.custom.yaml;

    # Fcitx5 集成设置：在 kitty 和代码编辑器中自动切换为英文模式
    "fcitx5/rime/fcitx5.custom.yaml".source =
      config.lib.file.mkOutOfStoreSymlink
        /home/huaijin/dotfiles/tools/.local/share/fcitx5/rime/fcitx5.custom.yaml;

    # 雾凇拼音 Rime Ice 设置：中文标点、Ctrl+句号切换中英标点
    "fcitx5/rime/rime_ice.custom.yaml".source =
      config.lib.file.mkOutOfStoreSymlink
        /home/huaijin/dotfiles/tools/.local/share/fcitx5/rime/rime_ice.custom.yaml;
  };

  # ----------------------------------------------------------
  # Fcitx5 主题：Catppuccin Mocha Blue
  # ----------------------------------------------------------
  xdg.dataFile."fcitx5/themes/catppuccin-mocha-blue".source =
    config.lib.file.mkOutOfStoreSymlink
      /home/huaijin/dotfiles/tools/.local/share/fcitx5/themes/catppuccin-mocha-blue;
}
