{
  config,
  pkgs,
  lib,
  ...
}:
{
  # Common development tools profile
  home.packages = with pkgs; [
    bun
    nodejs_24
  ];
}
