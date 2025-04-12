{
  config,
  lib,
  ...
}: let
  inherit
    (lib.options)
    mkOption
    ;

  inherit
    (lib.modules)
    mkIf
    ;

  inherit
    (lib.types)
    int
    ;

  colors = config.style.colors;
  cfg = config.style.foot;
in {

  options.style.foot = {
    font = {
      size = mkOption {
        type = int;
        default = 10;
        description = "Font size of the terminal";
      };
    };
  };

  config = mkIf config.programs.foot.enable {
    programs.foot.settings = {
      main = {
        font = "monospace:size=${toString cfg.font.size}";
        pad = "4x4";
      };

      colors = {
        background = colors.base0;
        foreground = colors.base7;

        regular0 = colors.base0;
        regular1 = colors.base1;
        regular2 = colors.base2;
        regular3 = colors.base3;
        regular4 = colors.base4;
        regular5 = colors.base5;
        regular6 = colors.base6;
        regular7 = colors.base7;

        bright0 = colors.base8;
        bright1 = colors.base9;
        bright2 = colors.baseA;
        bright3 = colors.baseB;
        bright4 = colors.baseC;
        bright5 = colors.baseD;
        bright6 = colors.baseE;
        bright7 = colors.baseF;
      };
    };
  };
}
