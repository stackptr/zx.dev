{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    anemone = {
      url = "github:Speyll/anemone";
      flake = false;
    };
  };

  outputs = inputs @ {
    flake-parts,
    anemone,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} (top @ {
      self,
      config,
      withSystem,
      moduleWithSystem,
      ...
    }: {
      flake = {
        nixConfig = {
          experimental-features = ["nix-command" "flakes"];
          extra-substituters = [
            "https://stackptr.cachix.org"
          ];
          extra-trusted-public-keys = [
            "stackptr.cachix.org-1:5e2q7OxdRdAtvRmHTeogpgJKzQhbvFqNMmCMw71opZA="
          ];
        };
        nixosModules.zx-dev = moduleWithSystem (
          perSystem @ {config}: (import ./modules/zx-dev.nix {
            zx-dev = perSystem.config.packages.zx-dev;
          })
        );
        nixosModules.default = self.nixosModules.zx-dev;
      };
      systems = ["x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin"];
      perSystem = {
        pkgs,
        self',
        ...
      }: {
        devShells.default = pkgs.mkShell {packages = [pkgs.just pkgs.zola];};
        formatter = pkgs.alejandra;
        packages.zx-dev = pkgs.callPackage ./package.nix {inherit anemone;};
        packages.default = self'.packages.zx-dev;
      };
    });
}
