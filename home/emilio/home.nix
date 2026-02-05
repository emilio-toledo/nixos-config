{ config, pkgs, ... }:

{
  imports = [
    ../profiles/development.nix
    ../profiles/shell.nix
    ../profiles/git.nix
    ../profiles/rust.nix
    ../profiles/go.nix
    ../profiles/editor.nix
  ];

  home = {
    username = "nixos";
    homeDirectory = "/home/nixos";
    stateVersion = "25.11";
  };

  programs.home-manager = {
    enable = true;
  };
}
