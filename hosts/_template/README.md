# Template for adding new machine to flake.nix
# 
# Add this to the nixosConfigurations section in the root flake.nix:
#
#   my-hostname = nixpkgs.lib.nixosSystem {
#     inherit system;
#     specialArgs = { inherit self; };
#     modules = [
#       ragenix.nixosModules.default
#       home-manager.nixosModules.home-manager
#       ./hosts/my-hostname/configuration.nix
#       ./hosts/my-hostname/hardware-configuration.nix
#       
#       # Include common modules
#       ./modules/common/packages.nix
#       ./modules/common/programs.nix
#       ./modules/common/security.nix
#       ./modules/services/openssh.nix
#       
#       # Add users (choose one or create your own)
#       ./modules/users/nixos.nix
#       # ./modules/users/anon.nix
#       
#       # Or use the customUsers system directly:
#       # {
#       #   customUsers = {
#       #     enable = true;
#       #     users.myuser = {
#       #       shell = pkgs.fish;
#       #       extraGroups = [ "wheel" "networkmanager" ];
#       #       secretFile = ./secrets/secret-myuser.age;
#       #     };
#       #   };
#       # }
#       
#       # Home-manager configuration
#       {
#         home-manager.useGlobalPkgs = true;
#         home-manager.useUserPackages = true;
#         home-manager.users.myuser = import ./home/myuser/home.nix;
#       }
#       
#       # Experimental features
#       {
#         nix.settings.experimental-features = [
#           "nix-command"
#           "flakes"
#         ];
#       }
#     ];
#   };
#
# For WSL machines, also include:
#   nixos-wsl.nixosModules.default
#   ./modules/wsl/wsl.nix
#
# Then build with:
#   nixos-rebuild switch --flake .#my-hostname
