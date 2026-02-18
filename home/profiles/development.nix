{
  pkgs,
  ...
}:
{
  # Common development tools profile
  home.packages = with pkgs; [
    gcc
  ];
}
