{config, ...}: let
  inherit (config) style;
  inherit (style) colors;
in {
  nyu.programs.niri = {
    wallpaper = style.wallpaper;
    backgroundColor = "#${colors.base0}";

    layout = ''
      gaps 8

      focus-ring {
        off
      }

    border {
      width 4
      active-color "#${colors.baseB}"
      inactive-color "#${colors.base8}"
      urgent-color "#${colors.base1}"
    }

    shadow {
      softness 30
      spread 5
      offset x=0 y=5
      color "#${colors.base0}77"
    }
    '';

    settings = ''
      prefer-no-csd

      workspace "1"
      workspace "2"
      workspace "3"
      workspace "4"
      workspace "5"
    '';
  };
}
