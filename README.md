# NixOS Configuration Repository

Modular NixOS configuration system designed for easy multi-machine management.

## Structure

```
.
├── flake.nix                 # Main flake with all nixosConfigurations
├── hosts/                    # Per-host configurations
│   ├── wsl/                 # WSL machine configuration
│   └── _template/           # Template for new machines
├── modules/                  # Reusable NixOS modules
│   ├── common/              # Common system settings
│   │   ├── packages.nix     # System packages
│   │   ├── programs.nix     # System programs (fish, direnv, ssh)
│   │   └── security.nix     # Sudo configuration
│   ├── services/            # Service configurations
│   │   └── openssh.nix      # SSH daemon
│   ├── users/               # User management
│   │   ├── default.nix      # Parameterized user system
│   │   ├── nixos.nix        # Nixos user (example)
│   │   └── anon.nix         # Anon user (example)
│   ├── wsl/                 # WSL-specific module
│   └── secrets/             # Age encryption keys
├── home/                     # Home-manager configurations
│   ├── profiles/            # Reusable home-manager profiles
│   │   ├── development.nix  # Development tools
│   │   ├── shell.nix        # Shell configuration
│   │   ├── git.nix          # Git & VCS tools
│   │   ├── rust.nix         # Rust toolchain
│   │   ├── go.nix           # Go toolchain
│   │   └── editor.nix       # Editor configuration
│   └── emilio/              # Per-user home configurations
└── templates/                # Nix flake templates
```

## Adding a New Machine

### Option 1: Copy and Customize Template

1. Copy the template directory:
   ```bash
   cp -r hosts/_template hosts/my-hostname
   ```

2. Edit `hosts/my-hostname/configuration.nix` with host-specific settings

3. For physical machines, generate hardware config:
   ```bash
   nixos-generate-config --show-hardware-config > hosts/my-hostname/hardware-configuration.nix
   ```

4. Add to `flake.nix` nixosConfigurations (see template README for example)

5. Create secrets if using password authentication:
   ```bash
   # Create secret file
   nix run github:yaxitech/ragenix -- -e secrets/secret-myuser.age
   
   # Add public key to modules/secrets/secrets.nix
   ```

6. Build and activate:
   ```bash
   nixos-rebuild switch --flake .#my-hostname
   ```

### Option 2: Use Inline Configuration

You can also define configurations directly in `flake.nix` using the `customUsers` system:

```nix
my-hostname = nixpkgs.lib.nixosSystem {
  inherit system;
  modules = [
    # ... other modules ...
    {
      customUsers = {
        enable = true;
        users.myuser = {
          shell = pkgs.fish;
          extraGroups = [ "wheel" "docker" ];
          secretFile = ./secrets/secret-myuser.age;
        };
      };
    }
  ];
};
```

## Module System

### Common Modules
- `modules/common/packages.nix` - Essential system packages
- `modules/common/programs.nix` - Fish, direnv, SSH agent, nix-ld
- `modules/common/security.nix` - Sudo configuration

### User Management
The `customUsers` system (`modules/users/default.nix`) provides flexible user configuration:

```nix
customUsers = {
  enable = true;
  users.username = {
    shell = pkgs.fish;                        # User shell
    extraGroups = [ "wheel" "docker" ];       # Additional groups
    secretFile = ./path/to/secret.age;        # Age-encrypted password
    isNormalUser = true;                      # User type (default: true)
  };
};
```

### Home-Manager Profiles
Reusable home-manager configurations in `home/profiles/`:
- `development.nix` - Common dev tools (pfetch-rs, gcc)
- `shell.nix` - Shell setup (fish, starship, zoxide, fzf)
- `git.nix` - Git with SSH signing, gh, jujutsu
- `rust.nix` - Rust toolchain via rust-overlay
- `go.nix` - Go tools (gopls, air, gosimports)
- `editor.nix` - Neovim configuration

Import them in your home.nix:
```nix
{
  imports = [
    ../profiles/shell.nix
    ../profiles/git.nix
    ../profiles/rust.nix
  ];
}
```

## Building and Deployment

### Local rebuild:
```bash
sudo nixos-rebuild switch --flake .#hostname
```

### Build without activation:
```bash
nixos-rebuild build --flake .#hostname
```

### Update flake inputs:
```bash
nix flake update
```

### Check flake:
```bash
nix flake check
```

## Secret Management

This configuration uses [ragenix](https://github.com/yaxitech/ragenix) for age-encrypted secrets.

1. Add your SSH keys to `modules/secrets/secrets.nix`
2. Create/edit secrets:
   ```bash
   nix run github:yaxitech/ragenix -- -e secrets/secret-name.age
   ```
3. Reference in user configuration via `secretFile` option

## WSL Configuration

The WSL machine includes:
- `nixos-wsl.nixosModules.default` - NixOS-WSL integration
- `modules/wsl/wsl.nix` - WSL-specific settings

For WSL machines, ensure your flake includes both modules.
