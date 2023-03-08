{ lib
, stdenvNoCC
, chromium
, gnome3
, zenity ? gnome3.zenity
, writeShellScript
, makeDesktopItem
, copyDesktopItems
}:
let
  mkWebapp = {
    name ? "webapp"
  , desktopName ? "Web Application"
  , browser ? "${chromium}/bin/chromium"
  , icon ? "applications-internet"
  , url ? null
  , queryText ? "Link a ser aberto"
  , noURLSpecifiedText ? "Nenhuma URL especificada"
  , passthru ? {}
  }:
  let
    script = writeShellScript name ''
      PATH="${lib.makeBinPath [ zenity ]}"
      if [ -z "$@" ]; then
        URL=$(zenity --entry --text="${queryText}")
      else
        URL="$@"
      fi
      echo $URL
      if [ -z "$URL" ]; then
        zenity --error --text="${noURLSpecifiedText}"
        exit 1
      fi
      if [[ "$URL" =~ ^~ ]]; then
        URL=$(echo $URL | sed -E s:^~\/?::)
        URL="file://$HOME/$URL"
      fi
      if [[ "$URL" =~ ^\/ ]]; then
        URL="file://$URL"
      fi
      if [[ "$URL" =~ ^(file|https?)?:\/\/ ]]; then
        true
      else
        URL="https://$URL"
      fi
      echo $URL
      ${browser} --app="$URL"
    '';
    desktop = makeDesktopItem {
      name = name;
      desktopName = desktopName;
      type = "Application";
      icon = icon;
      exec = ''${script} ${nameIfUrl ''"${url}"''}'';
    };
    nameIfUrl = lib.optionalString (url != null);

  in stdenvNoCC.mkDerivation {
    name = "borderless-browser${nameIfUrl "-${name}"}";

    dontUnpack = true;

    preferLocalBuild = true;

    nativeBuildInputs = [ copyDesktopItems ];

    desktopItems = [ desktop ];

    installPhase = ''
      runHook preInstall

      mkdir $out/bin -p
      install ${script} $out/bin/webapp${nameIfUrl "-${name}"}

      runHook postInstall
    '';

    inherit passthru;
  };
in mkWebapp {
  passthru = {
    wrap = mkWebapp;
  };
}
