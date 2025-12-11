{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-wsl.url = "github:nix-community/NixOS-WSL";
    ragenix.url = "github:yaxitech/ragenix";
  };

  outputs =
    {
      self,
      nixpkgs,
      nixos-wsl,
      ragenix,
    }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in
    {
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          nixos-wsl.nixosModules.default
          ragenix.nixosModules.default
          ./modules/wsl/wsl.nix
          ./modules/users/nixos.nix
          #./modules/users/anon.nix
          {
            nix.settings.experimental-features = [
              "nix-command"
              "flakes"
            ];
          }
          {
            security.sudo = {
              enable = true;
              wheelNeedsPassword = true;
            };
          }
          {
            services.openssh = {
              enable = true;

              hostKeys = [
                {
                  type = "ed25519";
                  path = "/etc/ssh/ssh_host_ed25519_key";
                  bits = 256;
                }
              ];
            };

          }
          {
            environment.systemPackages = with pkgs; [
              ragenix.packages."${system}".default
              wget
              nixfmt
              fish
              home-manager
            ];
          }
          {
            programs.ssh.startAgent = true;
            programs.fish.enable = true;
            programs.nix-ld.enable = true;
	    programs.direnv.enable = true;
          }
          {
            users.groups.docker = { };
          }
        ];
      };
    };
}
