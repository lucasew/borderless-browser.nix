{ lib
, stdenvNoCC
, chromium
, zenity
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

  stdenvNoCC.mkDerivation (attrs: {
    name = "webapp-${name}";
    dontUnpack = true;
    nativeBuildInputs = [ copyDesktopItems makeWrapper ];

    installPhase = ''
      runHook preInstall
      mkdir -p $out/bin
      makeWrapper ${./borderless-browser} $out/bin/$name \
        --set-default text_QUERY "${queryText}" \
        --set-default text_NOURL "${noURLSpecifiedText}" \
        --set bin_CHROMIUM "${browser}" \
        --set bin_ZENITY "${lib.getExe zenity}" \
        ${lib.optionalString (profile != null) "--set CHROME_PROFILE ${profile}"} \
        ${lib.optionalString (url != null) "--add-flags ${url}"}
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
