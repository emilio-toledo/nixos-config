{ config, pkgs, ... }:
{
  programs = {
    ssh.startAgent = true;
    fish.enable = true;
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
        xorg.libX11
        xorg.libXcomposite
        xorg.libXdamage
        xorg.libXext
        xorg.libXfixes
        xorg.libXrandr
        xorg.libxcb
        mesa
        libgbm
        expat
        alsa-lib
        at-spi2-atk
        at-spi2-core
        libxkbcommon
      ];
    };
    direnv.enable = true;
  };
}
