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
    users.anon = {
      extraGroups = [
        "wheel"
        "networkmanager"
      ];
      secretFile = ../../secrets/secret-anon.age;
    };
  };
}
