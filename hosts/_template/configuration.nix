# Example host configuration template
# Copy this directory and customize for each new machine

{
  config,
  lib,
  pkgs,
  ...
}:

{
  # Host-specific settings
  networking.hostName = "my-hostname";
  time.timeZone = "America/New_York";

  # Uncomment and configure as needed:
  # networking.networkmanager.enable = true;
  # services.xserver.enable = true;
  # services.xserver.desktopManager.gnome.enable = true;
}
