{ chromium
  , zenity
  , writeShellScript
  , writeShellScriptBin
  , queryText ? "Link a ser aberto"
  , noURLSpecifiedText ? "Nenhuma URL especificada"
}:
let
  zenityBin = "${zenity}/bin/zenity";
  browserBin = "${chromium}/bin/chromium";
in writeShellScript "webapp"''
  if [ -z "$@" ]
  then
    URL=$(${zenityBin} --entry --text="${queryText}")
  else
    URL="$@"
  fi
  echo $URL
  if [ -z "$URL" ]
  then
    ${zenityBin} --error --text="${noURLSpecifiedText}"
    exit 1
  fi
  if [[ "$URL" =~ ^~ ]]
  then
    URL=$(echo $URL | sed -E s:^~\/?::)
    URL="file://$HOME/$URL"
  fi
  if [[ "$URL" =~ ^\/ ]]
  then
    URL="file://$URL"
  fi
  if [[ "$URL" =~ ^(file|https?)?:\/\/ ]]
  then
    true
  else
    URL="https://$URL"
  fi
  echo $URL
  ${browserBin} --app="$URL"
''
