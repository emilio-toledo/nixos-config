{
  config,
  pkgs,
  lib,
  ...
}:

let
  rustOverlay = import (
    builtins.fetchTarball {
      url = "https://github.com/oxalica/rust-overlay/archive/master.tar.gz";
      sha256 = "0wiiywbjb7q7rdck49ifqs9x3i8gyhz2di325l2xhdqb7ic4i5fz";
    }
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
