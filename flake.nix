{
  description = "Launch chromium-like windows without borders";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };
  outputs = {self, nixpkgs}:
  let
    pkgs = import nixpkgs {
      system = "x86_64-linux"; # should work in any tuple that has chromium working
    };
  in {
    homeModules.default = import ./home-manager.nix;
    overlays.default = import ./overlay.nix;
    packages.default = pkgs.callPackage ./package.nix {};
  };
}
