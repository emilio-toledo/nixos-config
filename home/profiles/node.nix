{
  config,
  pkgs,
  lib,
  ...
}:
{
  # Node.js development tools
  home.packages = with pkgs; [
    bun
    nodejs_25
    pnpm
    moon
  ];
}
