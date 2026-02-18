{
  pkgs,
  ...
}:
{
  system.stateVersion = "25.05";

  wsl = {
    enable = true;

    defaultUser = "nixos";

    interop.includePath = false;
    docker-desktop.enable = true;
    useWindowsDriver = true;

    extraBin = with pkgs; [
      { src = "${coreutils}/bin/whoami"; }
      { src = "${coreutils}/bin/uname"; }
    ];
  };

  systemd.tmpfiles.rules = [
    "d /run/user/1000 0700 nixos root -"
  ];

  users.users.nixos.linger = true;
}
