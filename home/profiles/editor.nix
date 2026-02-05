{
  config,
  pkgs,
  lib,
  ...
}:
{
  # Editor configuration
  programs.neovim = {
    enable = true;
  };
}
