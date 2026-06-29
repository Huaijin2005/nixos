{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    nixd # Nix language server (nix-community)
    nixfmt # Official nix formatter
  ];
}
