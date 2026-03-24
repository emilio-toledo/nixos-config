{
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    gcc
    act
    gnumake
  ];

  home.sessionVariables = {
    PKG_CONFIG_PATH = "${pkgs.openssl.dev}/lib/pkgconfig";
  };
}
