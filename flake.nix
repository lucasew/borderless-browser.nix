{
  description = "Launch chromium-like windows without borders";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = {self, flake-utils, nixpkgs}:
  flake-utils.lib.eachDefaultSystem (system: {

    homeModules.default = import ./home-manager.nix;
    overlays.default = import ./overlay.nix;
    packages.default = nixpkgs.legacyPackages.${system}.callPackage ./package.nix {};

  });
}
