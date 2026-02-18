{
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    wget
    nixfmt
    nil
  ];
}
