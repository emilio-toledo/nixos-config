{

  home = {
    username = "nixos";
    homeDirectory = "/home/nixos";
    stateVersion = "26.05";
  };

  imports = [
    ./profiles/shell.nix
    ./profiles/git.nix
    ./profiles/development.nix
    ./profiles/rust.nix
    ./profiles/editor.nix
    ./profiles/ai.nix
    ./profiles/python.nix
    ./profiles/node.nix
    ./profiles/cloud.nix
  ];

  programs.home-manager = {
    enable = true;
  };
}
