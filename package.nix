{ lib
, stdenvNoCC
, chromium
, gnome3
, zenity ? gnome3.zenity
, makeDesktopItem
, copyDesktopItems
, makeWrapper
}:
let
  mkWebapp = {
    name ? "webapp"
  , desktopName ? "Web Application"
  , browser ? lib.getExe chromium
  , icon ? "applications-internet"
  , url ? null
  , queryText ? "Link to be opened"
  , noURLSpecifiedText ? "No URL specified"
  , profile ? null
  , passthru ? {}
  }:

  let
    self = stdenvNoCC.mkDerivation (attrs: {
      name = "webapp-${name}";

      dontUnpack = true;

      makeWrapperArgs = lib.escapeShellArgs ([
        "--set-default" "text_QUERY" queryText
        "--set-default" "text_NOURL" noURLSpecifiedText
        "--set" "bin_CHROMIUM" browser
        "--set" "bin_ZENITY" (lib.getExe zenity)
      ]
        ++ (lib.optionals (profile != null) [ "--set" "CHROME_PROFILE" profile ])
        ++ (lib.optionals (url != null) [ "--add-flags" url ])
      );

      nativeBuildInputs = [ copyDesktopItems makeWrapper ];

      script = ./borderless-browser;

      installPhase = ''
        runHook preInstall

        mkdir -p $out/bin

        makeWrapper ${attrs.script} $out/bin/$name ${attrs.makeWrapperArgs}

        runHook postInstall
      '';

      postFixup = ''
        substituteInPlace $out/share/applications/$name.desktop --replace @bin@ $out/bin/$name
      '';

      desktopItems = [
        (makeDesktopItem {
          inherit (attrs) name;
          inherit desktopName icon;
          type = "Application";
          exec = "@bin@";
        })
      ];

      inherit passthru;
    });
  in self;

in mkWebapp {
  passthru = {
    wrap = mkWebapp;
  };
}
