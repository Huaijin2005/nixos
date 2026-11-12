{ config, pkgs, ... }:

{
  # ============================================================
  # 共享 NixOS 模块 (modules/default.nix)
  # ============================================================
  # 此文件被所有 host 导入（目前仅 nixos-vm）。
  # 放在这里的配置会自动应用到每个机器上，无需在每个 host 里重复。
  # 将来如果有多台机器，通用的 NixOS 配置都放这里。
  # ============================================================

  # 启用 Nix Flakes 和 nix 命令（所有机器都需要）
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # 允许安装非自由软件包（如 VS Code、Steam 等）
  nixpkgs.config.allowUnfree = true;
}
