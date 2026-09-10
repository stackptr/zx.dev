{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    anemone = {
      # Pinned to PinkNoize's zola-0.23/Tera-v2 migration until it's merged
      # upstream: https://github.com/Speyll/anemone/pull/41
      url = "github:PinkNoize/anemone/8c1bae458ae24ac5fe0ff14706a463b51bf429e5";
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
      # x86_64-darwin dropped from nixpkgs 26.11; drop it here too.
      systems = ["x86_64-linux" "aarch64-linux" "aarch64-darwin"];
      perSystem = {
        pkgs,
        self',
        ...
      }: {
        devShells.default = pkgs.mkShell {packages = [pkgs.just pkgs.zola];};
        formatter = pkgs.alejandra;
        packages.zx-dev = pkgs.callPackage ./package.nix {inherit self anemone;};
        packages.default = self'.packages.zx-dev;
      };
    });
}
