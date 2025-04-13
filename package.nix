{ lib
, stdenvNoCC
, brave
, zenity
, makeDesktopItem
, copyDesktopItems
, makeWrapper
}:
let
  mkWebapp = {
    name ? "webapp"
  , desktopName ? "Web Application"
  , browser ? lib.getExe brave
  , icon ? "applications-internet"
  , url ? null
  , queryText ? "Link to be opened"
  , noURLSpecifiedText ? "No URL specified"
  , profile ? null
  , passthru ? {}
  , extraFlags ? []
  }:

  let
    wrapperArgs = []
    ++ ["--set-default" "text_QUERY" queryText]
    ++ ["--set-default" "text_NOURL" noURLSpecifiedText]
    ++ ["--set" "bin_CHROMIUM" browser]
    ++ ["--set" "bin_ZENITY" (lib.getExe zenity)]
    ++ lib.optionals (profile != null) ["--set" "CHROME_PROFILE" profile]
    ++ lib.optionals (url != null) ["--add-flags" url]
    ++ lib.flatten (lib.map (flag: ["--add-flags" flag]) extraFlags);
  in

  stdenvNoCC.mkDerivation (attrs: {
    name = "webapp-${name}";
    dontUnpack = true;
    nativeBuildInputs = [ copyDesktopItems makeWrapper ];

    installPhase = ''
      runHook preInstall
      mkdir -p $out/bin
      makeWrapper ${./borderless-browser} $out/bin/$name ${lib.escapeShellArgs wrapperArgs}
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

    passthru = passthru // {
      makeWrapperArgs = [
        "--set-default" "text_QUERY" queryText
        "--set-default" "text_NOURL" noURLSpecifiedText
        "--set" "bin_CHROMIUM" browser
        "--set" "bin_ZENITY" (lib.getExe zenity)
      ]
        ++ (lib.optionals (profile != null) [ "--set" "CHROME_PROFILE" profile ])
        ++ (lib.optionals (url != null) [ "--add-flags" url ]);
    };
  });

in mkWebapp {
  passthru = {
    wrap = mkWebapp;
  };
}
