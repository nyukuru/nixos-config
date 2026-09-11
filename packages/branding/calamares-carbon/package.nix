{
  runCommand,
  calamares,
  calamares-nixos-extensions,
  glibcLocales,
  zenity,
  mkpasswd,
}: let
  extensions =
    runCommand "calamares-carbon-extensions" {}
    ''
      mkdir -p $out/etc/calamares/modules
      mkdir -p $out/lib/calamares/modules/{nixos-config-install,nixos-config-generate,collect-secrets}
      mkdir -p $out/share/calamares/branding/carbon

      cp ${calamares-nixos-extensions}/etc/calamares/modules/welcome.conf $out/etc/calamares/modules/
      cp ${calamares-nixos-extensions}/etc/calamares/modules/finished.conf $out/etc/calamares/modules/

      cp ${./locale.conf} $out/etc/calamares/modules/locale.conf
      substituteInPlace $out/etc/calamares/modules/locale.conf --replace-fail @glibcLocales@ ${glibcLocales}

      cp ${./keyboard.conf} $out/etc/calamares/modules/keyboard.conf
      cp ${./users.conf} $out/etc/calamares/modules/users.conf
      cp ${./packagechooser-forms.conf} $out/etc/calamares/modules/packagechooser-forms.conf
      cp ${./packagechooser-theme.conf} $out/etc/calamares/modules/packagechooser-theme.conf
      cp ${./packagechooser-filesystem.conf} $out/etc/calamares/modules/packagechooser-filesystem.conf
      cp ${./packagechooser-disk.conf} $out/etc/calamares/modules/packagechooser-disk.conf
      cp ${./packagechooser-cpu.conf} $out/etc/calamares/modules/packagechooser-cpu.conf
      cp ${./packagechooser-gpu.conf} $out/etc/calamares/modules/packagechooser-gpu.conf
      cp ${./notesqml-internet-help.conf} $out/etc/calamares/modules/notesqml-internet-help.conf

      cp ${./settings.conf} $out/etc/calamares/settings.conf
      substituteInPlace $out/etc/calamares/settings.conf --replace-fail @out@ $out

      cp ${./modules/nixos-config-install/module.desc} $out/lib/calamares/modules/nixos-config-install/module.desc
      cp ${./modules/nixos-config-install/main.py} $out/lib/calamares/modules/nixos-config-install/main.py

      cp ${./modules/nixos-config-generate/module.desc} $out/lib/calamares/modules/nixos-config-generate/module.desc
      cp ${./modules/nixos-config-generate/main.py} $out/lib/calamares/modules/nixos-config-generate/main.py

      cp ${./modules/collect-secrets/module.desc} $out/lib/calamares/modules/collect-secrets/module.desc
      cp ${./modules/collect-secrets/main.py} $out/lib/calamares/modules/collect-secrets/main.py

      cp -r ${calamares-nixos-extensions}/share/calamares/branding/nixos/* $out/share/calamares/branding/carbon/
      chmod -R u+w $out/share/calamares/branding/carbon
      rm -f $out/share/calamares/branding/carbon/branding.desc
      cp ${./branding.desc} $out/share/calamares/branding/carbon/branding.desc
      cp ${./notesqml-internet-help.qml} "$out/share/calamares/branding/carbon/notesqml@internet-help.qml"
    '';
in
  calamares.override {
    extraWrapperArgs = [
      "--prefix XDG_DATA_DIRS : ${extensions}/share"
      "--prefix XDG_CONFIG_DIRS : ${extensions}/etc"
      "--add-flag --xdg-config"
      "--prefix PATH : ${zenity}/bin:${mkpasswd}/bin"
    ];
  }
