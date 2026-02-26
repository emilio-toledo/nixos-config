{
  pkgs,
  ...
}:
{
  programs = {
    nix-ld = {
      enable = true;

      libraries = with pkgs; [
        # Chromium / Puppeteer runtime dependencies
        glib
        nss
        nspr
        dbus
        atk
        cups
        libdrm
        gtk3
        pango
        cairo
        libx11
        libxcomposite
        libxdamage
        libxext
        libxfixes
        libxrandr
        libxcb
        mesa
        libgbm
        expat
        alsa-lib
        at-spi2-atk
        at-spi2-core
        libxkbcommon
      ];
    };

    fish.enable = true;

    direnv.enable = true;
  };
}
