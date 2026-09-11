{
  lib,
  writeShellScript,
  coreutils,
}: let
  cp = lib.getExe' coreutils "cp";
  rm = lib.getExe' coreutils "rm";
  chown = lib.getExe' coreutils "chown";
  id = lib.getExe' coreutils "id";
  snapshot = "/nixos-config-snapshot";
in
  writeShellScript "nixos-config-seed" ''
    set -euo pipefail

    for home in /home/*/; do
      home="''${home%/}"
      [[ -d "$home" ]] || continue
      user="''${home##*/}"
      target="$home/nixos-config"
      ${rm} -rf "$target"
      ${cp} -r "${snapshot}" "$target"
      ${chown} -R "$user":"$(${id} -gn "$user")" "$target"
    done
  ''
