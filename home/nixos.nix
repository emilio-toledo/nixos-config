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
    ./profiles/ai.nix
    ./profiles/python.nix
  ];

  programs.home-manager = {
    enable = true;
  };
}
