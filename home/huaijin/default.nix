{ config, pkgs, ... }:

{
  imports = [
    ../../modules/home/editor
  ];

  home.username = "huaijin";
  home.homeDirectory = "/home/huaijin";

  home.packages = with pkgs; [
    git
    opencode
    sops
    uv
  ];

  home.stateVersion = "26.05";

  programs.home-manager.enable = true;
}
