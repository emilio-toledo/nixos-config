let
  host = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKjmudr8GL0p4ppXW3TBfdsJCYbC8jZfpXkzXlzjaw/J root@nixos";
  nixos = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMgupqpuy/H0mRkao4kFcVtCMxHMwga8KMEISwu7uFow nixos@nixos";
in
{
  "secret-anon.age".publicKeys = [
    host
    nixos
  ];
  "secret-nixos.age".publicKeys = [
    host
    nixos
  ];
}
