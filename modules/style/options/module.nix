{
  lib,
  pkgs,
  ...
}: let
  inherit
    (lib.options)
    mkOption
    ;

  inherit
    (lib.types)
    package
    nullOr
    path
    str
    int
    ;

  mkColorOption = default: mkOption {
    type = str;
    inherit default;
  };

in {
  imports = [
    ./nyufox
    ./foot
    ./tty
    ./gtk
  ];

  options.style = {
    wallpaper = mkOption {
      type = nullOr path;
      default = null;
      description = "Wallpaper background image";
    };

    colors = {
      background = mkColorOption "000000";
      foreground = mkColorOption "f8f8f6";

      base0 = mkColorOption "232a2d";
      base1 = mkColorOption "e57474";
      base2 = mkColorOption "57553c";
      base3 = mkColorOption "8ccf7e";
      base4 = mkColorOption "67b0e8";
      base5 = mkColorOption "c47fd5";
      base6 = mkColorOption "6cbfbf";
      base7 = mkColorOption "b3b9b8";

      base8 = mkColorOption "2d3437";
      base9 = mkColorOption "ef7e7e";
      baseA = mkColorOption "96d988";
      baseB = mkColorOption "f4d67a";
      baseC = mkColorOption "71baf2";
      baseD = mkColorOption "ce89df";
      baseE = mkColorOption "67cbe7";
      baseF = mkColorOption "bdc3c2";
    };

    font = {
      package = mkOption {
        type = nullOr package;
        default = pkgs.jetbrains-mono;
      };

      name = mkOption {
        type = str;
        default = "JetBrains Mono";
      };

      size = mkOption {
        type = int;
        default = 10;
      };
    };
  };
}
