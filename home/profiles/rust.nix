{
  config,
  pkgs,
  lib,
  ...
}:

let
  rustOverlay = import (
    builtins.fetchTarball "https://github.com/oxalica/rust-overlay/archive/master.tar.gz"
  );

  pkgsWithRust = import pkgs.path {
    overlays = [ rustOverlay ];
    system = pkgs.stdenv.hostPlatform.system;
  };
in
{
  # Rust development tools
  home.packages = with pkgsWithRust; [
    rust-bin.stable.latest.default
    rust-analyzer
  ];
}
