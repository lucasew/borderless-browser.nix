{lib, pkgs, config, ...}:
{
  options.borderless-browser = {
    chromium = lib.mkOption {
      type = lib.types.package;
      description = "Which chromium-like browser to use";
      default = pkgs.chromium;
      example = lib.literalExpression "pkgs.google-chrome";
    };
    apps = lib.mkOption {
      description = "All webapps to create as borderless applications";
      default = {};
      type = lib.types.attrsOf (lib.types.submodule {
        options = {
          profile = lib.mkOption {
            description = "Use a different profile to allow using different accounts. null means use the default profile.";
            type = lib.types.nullOr lib.types.str;
            default = null;
            example = "work";
          };
          desktopName = lib.mkOption {
            description = "The name that will be shown to the user";
            type = lib.types.str;
          };
          url = lib.mkOption {
            description = "The URL that the borderless webapp will open";
            type = lib.types.str;
            example = "https://calendar.google.com";
          };
          icon = lib.mkOption {
            description = "The icon that will be attributed to the shortcut";
            type = lib.types.str;
            default = "applications-internet";
            example = "calendar";
          };
          extraFlags = lib.mkOption {
            description = "Additional command-line flags to pass to the browser";
            type = lib.types.listOf lib.types.str;
            default = [];
            example = ["--disable-gpu" "--force-device-scale-factor=1.5"];
          };
        };
      });
    };
  };
  config = let
    defs = config.borderless-browser.apps;
    convert = k: v: pkgs.borderlessBrowser.wrap {
      name = k;
      inherit (v) desktopName url icon profile;
      extraFlags = if (builtins.hasAttr "extraFlags" v) then v.extraFlags else [];
      browser = config.borderless-browser.chromium;
    };
    attrNormalized = lib.mapAttrs convert defs;
    packages = lib.attrValues attrNormalized;
  in {
    home.packages = packages ++ [ pkgs.borderlessBrowser ];
  };
}
