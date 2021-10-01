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
  in
  rec {
    script = pkgs.callPackage ./package.nix { 
      inherit (pkgs.gnome3) zenity;
    };
    bin = pkgs.writeShellScriptBin "borderless-browser" ''
      ${script} "$@"
    '';
    app = pkgs.makeDesktopItem {
      name = "borderless-browser";
      desktopName = "Borderless Browser Window";
      type = "Application";
      icon = "applications-internet";
      exec = "${script}";
    };
    lib.wrap = {
      name
    , wrapper ? "${script}"
    , desktopName ? name
    , url
    , icon ? "applications-internet"
    }: pkgs.makeDesktopItem {
      name = name;
      desktopName = desktopName;
      type = "Application";
      icon = icon;
      exec = ''${script} "${url}"'';
    };
    homeModules.borderless-browser = import ./home-manager.nix;
    overlay = final: pref: {
      borderlessBrowser = 
      let
        entrypoint = pkgs.symlinkJoin {
          name = "borderless-browser";
          paths = [ bin app ];
        };
      in entrypoint // { wrap = lib.wrap; };
    };
  };
}
