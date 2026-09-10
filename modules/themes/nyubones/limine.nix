{
  config,
  lib,
  ...
}: let
  inherit
    (lib.strings)
    concatStringsSep
    ;

  inherit (config.style) colors;

  palette = concatStringsSep ";";
in {
  boot.loader.limine.style = {
    wallpapers = [./leaves.png];
    wallpaperStyle = "stretched";
    backdrop = colors.base8;

    interface = {
      brandingColor = colors.baseB;
      helpColor = colors.base3;
      helpColorBright = colors.base7;
    };

    graphicalTerminal = {
      palette = palette (with colors; [base0 base1 base2 base3 base4 base5 base6 base7]);
      brightPalette = palette (with colors; [base8 base9 baseA baseB baseC baseD baseE baseF]);

      foreground = colors.base7;
      background = colors.base0;
      brightForeground = colors.baseF;
      brightBackground = colors.base8;

      margin = 64;
      marginGradient = 4;
    };
  };
}
