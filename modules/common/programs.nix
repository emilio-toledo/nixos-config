{ config, pkgs, ... }:
{
  programs = {
    ssh.startAgent = true;
    fish.enable = true;
    nix-ld.enable = true;
    direnv.enable = true;
  };
}
