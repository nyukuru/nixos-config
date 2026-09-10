{
  lib,
  runCommand,
}: let
  colorsToSubstitutions =
    lib.mapAttrsToList
    (color: value: "--subst-var-by ${color} ${value}");
in
  {
    name,
    colors,
    cssFile,
  }:
    runCommand "gtk.css" {} ''
      target=$out/share/themes/${name}/gtk-3.0/gtk.css
      mkdir -p "$(dirname "$target")"

      substitute ${cssFile} $target ${lib.concatStringsSep " " (colorsToSubstitutions colors)}

      if grep -qE '@[A-Za-z_][A-Za-z0-9_]*@' "$target"; then
        echo "makeGtkTheme: unsubstituted @variable@ left in $target:" >&2
        grep -E '@[A-Za-z_][A-Za-z0-9_]*@' "$target" >&2
        exit 1
      fi
    ''
