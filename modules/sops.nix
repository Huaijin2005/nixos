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
      '';
      owner = "root"; # nix-daemon 才需要读取, rebuild 系统
    };
  };
}
