{
  config,
  pkgs,
  lib,
  ...
}:

let
  # npmOverlay = final: prev: {
  #   claude-max-api-proxy = prev.buildNpmPackage rec {
  #     name = "claude-max-api-proxy";

  #     src = prev.fetchFromGitHub {
  #       owner = "atalovesyou";
  #       repo = "claude-max-api-proxy";
  #       rev = "main";
  #       hash = "sha256-ypzeNoVIGTWhWng7vHWTBgL4/DTzBFX+4ljJ+dDipyA=";
  #     };

  #     npmDepsHash = "sha256-qS3YN6mwyMINyLRqD4ocEwhOoBAcfkjN79QVy+x5s2E=";
  #   };
  # };

  pkgsWithNpm = import pkgs.path {
    overlays = [ npmOverlay ];
    system = pkgs.stdenv.hostPlatform.system;
  };
in
{
  # Node.js development tools
  home.packages = with pkgsWithNpm; [
    bun
    nodejs_24
  ];
}
