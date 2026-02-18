{
  description = "NixOS configuration for all machines";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-wsl.url = "github:nix-community/NixOS-WSL";
    ragenix = {
      url = "github:yaxitech/ragenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
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
      rust-overlay,
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
            ./hosts/wsl/hardware-configuration.nix
            {
              nixpkgs.overlays = [ rust-overlay.overlays.default ];
            }
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "bak";
            }
            {
              nix.settings.experimental-features = [
                "nix-command"
                "flakes"
              ];
              # Auto-register this flake
              nix.registry.nixos-config.flake = self;
            }
          ];
        };
      };

      templates = import ./modules/templates/templates.nix;
    };
}
