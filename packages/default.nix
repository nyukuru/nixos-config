{
  inputs,
  lib,
  ...
}: {

  config.perSystem = {pkgs, ...}: {
    packages = {
      # Plymouth bootscreen themes
      plymouth-copland-theme = pkgs.callPackage ./plymouth-themes/plymouth-copland-theme.nix {};
      plymouth-hellonavi-theme = pkgs.callPackage ./plymouth-themes/plymouth-hellonavi-theme.nix {};

      #TODO allow set
      #scripts = {
        scripts-brightness = pkgs.callPackage ./scripts/brightness.nix {};
        scripts-volume = pkgs.callPackage ./scripts/volume.nix {};
      #};
    };
  };
}
