{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    wget
    nixfmt-rfc-style
    fish
  ];
}
