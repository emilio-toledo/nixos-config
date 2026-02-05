let
  host = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIX0NQwY+23gv/kDrNkjEtMIIUV7ptnkrIQdNgFr6aek root@nixos";
  nixos = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM5SvuPnEwBudkan7zfLbDqbKxvurRxAZwrPMgblL8mA nixos@nixos";
in {
  "secret-anon.age".publicKeys = [ host nixos ];
  "secret-nixos.age".publicKeys = [ host nixos ];
}
