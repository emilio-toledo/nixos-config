{
  config,
  pkgs,
  lib,
  ...
}:
{
  # AI development tools profile
  programs = {
    claude-code = {
      enable = true;
    };
  };
}
