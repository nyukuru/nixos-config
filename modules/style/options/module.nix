{lib, ...}: let
  inherit
    (lib.options)
    mkOption
    ;

  inherit
    (lib.types)
    nullOr
    path
    str
    ;
in {
  imports = [
    ./nyufox
    ./foot
  ];

  options.style = {
    wallpaper = mkOption {
      type = nullOr path;
      default = null;
      description = "Wallpaper background image";
    };

    colors = {
      background = mkOption {
        type = str;
        default = "16130f";
      };
      foreground = mkOption {
        type = str;
        default = "b7a59f";
      };
      base0 = mkOption {
        type = str;
        default = "16130f";
      };
      base1 = mkOption {
        type = str;
        default = "633f38";
      };
      base2 = mkOption {
        type = str;
        default = "57553c";
      };
      base3 = mkOption {
        type = str;
        default = "5f4333";
      };
      base4 = mkOption {
        type = str;
        default = "5f424f";
      };
      base5 = mkOption {
        type = str;
        default = "544160";
      };
      base6 = mkOption {
        type = str;
        default = "5d5249";
      };
      base7 = mkOption {
        type = str;
        default = "b7a59f";
      };
      base8 = mkOption {
        type = str;
        default = "4e403b";
      };
      base9 = mkOption {
        type = str;
        default = "8c4f4a";
      };
      baseA = mkOption {
        type = str;
        default = "898471";
      };
      baseB = mkOption {
        type = str;
        default = "816656";
      };
      baseC = mkOption {
        type = str;
        default = "90707e";
      };
      baseD = mkOption {
        type = str;
        default = "72657b";
      };
      baseE = mkOption {
        type = str;
        default = "80756d";
      };
      baseF = mkOption {
        type = str;
        default = "e2dbd9";
      };
    };
  };
}
