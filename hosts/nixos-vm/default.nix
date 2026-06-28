{ inputs, ... }:

{
  imports = [
    ./configuration.nix
    ../../modules
    ../../modules/sops.nix
  ];
}
