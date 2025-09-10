{
  lib,
  runCommandNoCC,
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
    runCommandNoCC "gtk.css" ''
      target=$out/share/theme/${name}/gtk-3.0/gtk.css
      mkdir -p "$(dirname "$target")"

      substitute ${cssFile} $target ${colorsToSubstitutions colors}

      eval "$checkPhase"
    ''
