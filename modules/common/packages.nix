{
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    wget
    nixfmt
    nixd
  ];
}
