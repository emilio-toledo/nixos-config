{
  config,
  pkgs,
  lib,
  ...
}:
{
  # Shell configuration profile (fish, starship, zoxide, fzf)
  programs = {
    fish = {
      enable = true;
      shellInit = ''
        fish_add_path "~/.proto/bin"
        fish_add_path "/mnt/c/Program Files/Microsoft VS Code/bin"
        set -g fish_greeting ""
      '';
      interactiveShellInit = ''
        pfetch
      '';
    };

    starship = {
      enable = true;
      enableFishIntegration = true;
    };

    zoxide = {
      enable = true;
      enableFishIntegration = true;
      options = [ "--cmd cd" ];
    };

    fzf = {
      enable = true;
    };
  };
}
