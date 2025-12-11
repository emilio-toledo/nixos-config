{
  config,
  pkgs,
  lib,
  ...
}:
{
  # Legacy module - use customUsers system instead
  # Kept for backward compatibility
  imports = [ ./default.nix ];

  customUsers = {
    enable = true;
    users.nixos = {
      shell = pkgs.fish;
      extraGroups = [
        "docker"
        "wheel"
      ];
      secretFile = ../../secrets/secret-nixos.age;
    };
  };
}
