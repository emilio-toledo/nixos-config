{
  programs = {
    fish = {
      enable = true;
      shellInit = ''
        set -g fish_greeting ""

        fish_config theme choose "fish default"
      '';
      interactiveShellInit = ''
        promo-cli init fish | source
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
