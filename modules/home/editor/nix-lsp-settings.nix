{ config, pkgs, ... }:

{
  # ── VS Code global settings for Nix IDE extension ─────────────────
  # https://github.com/nix-community/vscode-nix-ide
  # https://github.com/nix-community/nixd/blob/main/nixd/docs/configuration.md
  #
  # Only generic defaults here.  Project-specific options (nixos/home-manager
  # expr) belong in the workspace .vscode/settings.json so they auto-resolve
  # via `builtins.getFlake (builtins.toString ./.)`.
  #
  # NOTE: managed by nix — edits via VS Code UI may be overwritten on rebuild.

  xdg.configFile."Code/User/settings.json".text = ''
    {
      "nix.enableLanguageServer": true,
      "nix.serverPath": "nixd",

      "nix.serverSettings": {
        "nixd": {
          "formatting": {
            "command": ["nixfmt", "--strict"]
          },
          "nixpkgs": {
            "expr": "import <nixpkgs> { }"
          },
          "diagnostic": {
            "suppress": []
          }
        }
      }
    }
  '';
}
