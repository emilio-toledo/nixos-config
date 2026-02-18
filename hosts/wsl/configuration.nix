# WSL-specific configuration
# This file is for host-specific overrides only
# Common configuration is in the root flake.nix

{
  pkgs,
  ...
}:
{
  # Host-specific settings can go here
  # For example:
  # networking.hostName = "wsl-machine";
  # time.timeZone = "America/New_York";
  imports = [
    ../../modules/wsl/wsl.nix
  ];

  nixpkgs.config.allowUnfree = true;

  customUsers = {
    enable = true;
    users.nixos = {
      shell = pkgs.fish;
      extraGroups = [
        "docker"
        "wheel"
      ];
      secretFile = ../../modules/secrets/secret-nixos.age;
      homeConfig = ../../home/nixos.nix;
    };
  };
}
