{
  description = "Launch chromium-like windows without borders";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, flake-utils, nixpkgs }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      homeModules.default = import ./home-manager.nix;
      overlays.default = import ./overlay.nix;

      packages = {
        default = pkgs.callPackage ./package.nix {};
      };

      devShells.default = pkgs.mkShell {
        buildInputs = with pkgs; [
          nixpkgs-fmt
        ];
      };

      apps.default = flake-utils.lib.mkApp {
        drv = self.packages.${system}.default;
      };
    });
}
