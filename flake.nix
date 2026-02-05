{
  description = "NixOS configuration for all machines";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-wsl.url = "github:nix-community/NixOS-WSL";
    ragenix.url = "github:yaxitech/ragenix";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nixos-wsl,
      ragenix,
      home-manager,
    }:
    let
      system = "x86_64-linux";
    in
    {
      nixosConfigurations = {
        # WSL configuration
        nixos = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit self; };
          modules = [
            nixos-wsl.nixosModules.default
            ragenix.nixosModules.default
            home-manager.nixosModules.home-manager
            ./modules/common/packages.nix
            ./modules/common/programs.nix
            ./modules/common/security.nix
            ./modules/services/openssh.nix
            ./modules/users/default.nix
            ./hosts/wsl/configuration.nix
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
            }
            {
              nix.settings.experimental-features = [
                "nix-command"
                "flakes"
              ];
            }
          ];
        };
      };
    };
}
