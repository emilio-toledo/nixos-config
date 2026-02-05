# WSL-specific configuration
# This file is for host-specific overrides only
# Common configuration is in the root flake.nix

{
  config,
  lib,
  pkgs,
  ...
}:

{
  # Host-specific settings can go here
  # For example:
  # networking.hostName = "wsl-machine";
  # time.timeZone = "America/New_York";
}
