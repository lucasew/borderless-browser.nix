{lib, pkgs, config, ...}:
with lib;
{
  options.borderless-browser = {
    chromium = mkOption {
      type = types.str;
      description = "Which chromium-like browser use";
      default = pkgs.chromium;
    };
    apps = mkOption {
      description = "All webapps";
      default = {};
      type = with types; attrsOf (submodule {
        options = {
          desktopName = mkOption {
            description = "The name that will be shown to the user";
            type = types.str;
          };
          url = mkOption {
            description = "The URL that the borderless webapp will open";
            type = types.str;
          };
          icon = mkOption {
            description = "The icon that will be attributed to the shortcut";
            type = types.str;
            default = "applications-internet";
          };
        };
      });
    };
  };
  config = let
    defs = config.borderless-browser.apps;
    convert = k: v: pkgs.webapp.wrap {
      name = k;
      inherit (v) desktopName url icon;
    };
    attrNormalized = builtins.mapAttrs (convert) defs;
    packages = builtins.attrValues attrNormalized;
  in {
    home.packages = packages;
  };
}
