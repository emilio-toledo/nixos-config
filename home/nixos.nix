{

  home = {
    username = "nixos";
    homeDirectory = "/home/nixos";
    stateVersion = "25.11";
  };

  imports = [
    ./profiles/shell.nix
    ./profiles/git.nix
    ./profiles/development.nix
    ./profiles/rust.nix
    ./profiles/editor.nix
    #./profiles/go.nix
    #./profiles/misc.nix
    #./profiles/node.nix
    #./profiles/ai.nix
  ];

  programs.home-manager = {
    enable = true;
  };
}
