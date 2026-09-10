{
  lib,
  runCommand,
  fetchFromGitHub,
  sassc,
  glib,
  gdk-pixbuf,
  librsvg,
  gtk3,
  bc,
}: let
  src = fetchFromGitHub {
    owner = "themix-project";
    repo = "oomox-gtk-theme";
    rev = "a7bcc6d4a55f7b80d18294f240f091ce77a3ab43";
    hash = "sha256-5wULeGims7/QzLeuk8YSFhJHpUPWioByH2AqzZkXO7Q=";
  };

  presetToLines = lib.mapAttrsToList (key: value: "${key}=${value}");
in
  {
    name,
    colors,
  }: let
    preset = builtins.toFile "${name}.colors" (
      lib.concatLines (presetToLines ({GTK3_GENERATE_DARK = "False";} // colors))
    );
  in
    runCommand "${name}-gtk-theme"
    {
      nativeBuildInputs = [
        sassc
        glib.dev
        gdk-pixbuf.dev
        gdk-pixbuf
        librsvg
        gtk3
        bc
      ];
    }
    ''
      export GDK_PIXBUF_MODULE_FILE="$(echo ${librsvg}/lib/gdk-pixbuf-2.0/*/loaders.cache)"

      cp -r ${src} "$TMPDIR/src"
      chmod -R u+w "$TMPDIR/src"
      patchShebangs "$TMPDIR/src"

      bash "$TMPDIR/src/change_color.sh" -o ${name} -m gtk320 -t "$TMPDIR/out" ${preset}

      themeDir="$out/share/themes/${name}"
      mkdir -p "$themeDir/gtk-2.0" "$themeDir/gtk-3.20"
      generated="$TMPDIR/out/${name}"

      cp "$generated/index.theme" "$themeDir/"
      cp "$generated/gtk-2.0/gtkrc" "$generated/gtk-2.0/gtkrc.hidpi" "$themeDir/gtk-2.0/"
      cp "$generated/gtk-3.20/gtk.css" "$generated/gtk-3.20/gtk-dark.css" "$generated/gtk-3.20/gtk.gresource" "$themeDir/gtk-3.20/"
    ''
