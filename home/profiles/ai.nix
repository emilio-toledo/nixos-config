{
  pkgs,
  ...
}:

let
  aiOverlay = final: prev: {
    cli-proxy-api-plus = prev.stdenv.mkDerivation {
      name = "cli-proxy-api-plus";

      src = prev.fetchurl {
        url = "https://github.com/router-for-me/CLIProxyAPIPlus/releases/download/v6.8.1-1/CLIProxyAPIPlus_6.8.1-1_linux_amd64.tar.gz";
        sha256 = "sha256-hEGpF1+0bdIK42nX/vuh8zOov1dSExFbYX8/3TuQWLQ=";
      };

      sourceRoot = ".";

      installPhase = ''
        mkdir -p $out/bin
        cp cli-proxy-api-plus $out/bin/
        chmod +x $out/bin/cli-proxy-api-plus
      '';
    };
  };

  pkgsWithAI = import pkgs.path {
    overlays = [ aiOverlay ];
    system = pkgs.stdenv.hostPlatform.system;
  };
in
{
  programs = {
    claude-code = {
      enable = true;
    };
  };

  # AI development tools profile
  home.packages = with pkgsWithAI; [
    cli-proxy-api-plus
  ];
}
