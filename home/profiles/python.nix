{
  pkgs,
  ...
}:
{
  programs = {
    uv = {
      enable = true;
    };
  };

  home.packages = with pkgs; [
    python315
  ];
}
