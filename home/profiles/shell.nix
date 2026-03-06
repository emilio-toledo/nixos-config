{
  programs = {
    fish = {
      enable = true;
      shellInit = ''
        set -g fish_greeting ""

        fish_config theme choose "fish default"
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
