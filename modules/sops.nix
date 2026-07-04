{ config, ... }:

{
  sops = {
    defaultSopsFile = ../secrets/secrets.yaml;
    defaultSopsFormat = "yaml";
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

    secrets = {
      github_token = { };
    };

    templates."nix-netrc" = {
      content = ''
        machine github.com
          login oauth2
          password ${config.sops.placeholder.github_token}
        machine api.github.com
          login oauth2
          password ${config.sops.placeholder.github_token}
      '';
      owner = "root"; # nix-daemon rebuild 系统
      group = "wheel"; # nix flake update 需要
      mode = "0640"; # root可写, wheel可读
    };
  };
}
