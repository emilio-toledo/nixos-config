{
  description = "Playwright development environment";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.playwright.url = "github:pietdevries94/playwright-web-flake";

  outputs =
    {
      self,
      flake-utils,
      nixpkgs,
      playwright,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        overlay = final: prev: {
          inherit (playwright.packages.${system}) playwright-test playwright-driver;
        };
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ overlay ];
        };
      in
      {
        devShells = {
          default = pkgs.mkShell {
            packages = with pkgs; [
              playwright-test
              nodejs_24
              pnpm
              bun
              moon
            ];
            shellHook = ''
              export PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1
              export PLAYWRIGHT_BROWSERS_PATH="${pkgs.playwright-driver.browsers}"

              echo ""
              echo "🚀 Web Dev Environment"
              echo "Node: $(node --version)"
              echo "pnpm: $(pnpm --version)"
              echo "bun: $(bun --version)"
              echo "moon: $(moon --version)"
              echo ""
            '';
          };
        };
      }
    );
}
