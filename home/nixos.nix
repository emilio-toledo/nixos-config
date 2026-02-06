{ config, pkgs, ... }:

{

  home = {
    username = "nixos";
    homeDirectory = "/home/nixos";
    stateVersion = "25.11";
  };

  imports = [
    ./profiles/development.nix
    ./profiles/shell.nix
    ./profiles/git.nix
    ./profiles/rust.nix
    ./profiles/go.nix
    ./profiles/editor.nix
    ./profiles/misc.nix
    ./profiles/node.nix
    ./profiles/ai.nix
  ];

  programs.home-manager = {
    enable = true;
  };
}
