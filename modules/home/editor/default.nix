{ config, pkgs, ... }:

{
  # ── Editor meta-module: everything for local NixOS development ──
  # Scenario 3: one import gets you VS Code + nixd + settings.
  # For remote-only LSP use, import just `./nixd.nix` on the remote.
  imports = [
    ./vscode.nix
    ./nixd.nix
    ./nix-lsp-settings.nix
  ];
}
