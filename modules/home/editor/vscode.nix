{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    vscode-fhs # VS Code in FHS env, allows marketplace extensions
  ];
}
