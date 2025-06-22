{
  lib,
  writeShellScript,
  obs-cmd,
  fetchpatch,
}: let
  obs-cmf = lib.getExe (obs-cmd.overrideAttrs {
    patches = [
      (fetchpatch {
        url = "https://github.com/nyukuru/obs-cmd/commit/bf7b8623b67c7f767886318177a392c1623bca5d.patch";
        hash = "sha256-nsK8dVULtsYysgmYJWZx/aOyopwMMAfo2CRvtE+88MM=";
      })
    ];
  });
in
  writeShellScript "waybar-module-obs" ''
    output=$(${obs-cmf} info)
    if [[ $output != Error* ]]; then
      SCENE = $(${obs-cmf} scene current | sed 's/^"\(.*\)"$/\1/')
      if ${obs-cmf} recording status | grep -q true || ${obs-cmf} streaming status | grep -q true; then
        LIVE="Live"
      else
        LIVE=""
      fi
      echo " $LIVE"
    fi
  ''
