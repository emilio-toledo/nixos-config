{
  config,
  pkgs,
  lib,
  ...
}:
{
  # Common development tools profile
  home.packages = with pkgs; [
    pfetch-rs
    gcc
  ];
}
