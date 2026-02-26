{
  pkgs,
  ...
}:
{
  systemd.user.services.sccache = {
    Unit = {
      Description = "sccache daemon";
    };
    Service = {
      Type = "forking";
      ExecStart = "${pkgs.sccache}/bin/sccache --start-server";
      ExecStop = "${pkgs.sccache}/bin/sccache --stop-server";
      Environment = [
        "SCCACHE_IDLE_TIMEOUT=0"
        "SCCACHE_SERVER_UDS=%t/sccache.sock"
      ];
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };

  home.sessionVariables = {
    SCCACHE_SERVER_UDS = "/run/user/1000/sccache.sock";
  };

  home.packages = [
    (pkgs.rust-bin.nightly.latest.default.override {
      extensions = [
        "rust-src"
        "rust-analyzer"
      ];
    })

    pkgs.cargo-watch
    pkgs.mold
    pkgs.sccache
  ];

}
