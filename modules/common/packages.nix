{
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    wget
    nixfmt
    nixd
    openssl
    openssl.dev
    pkg-config
  ];

  environment.sessionVariables = {
    PKG_CONFIG_PATH = "${pkgs.openssl.dev}/lib/pkgconfig";
  };
}
