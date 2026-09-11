{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib.lists) optional;
  inherit (lib.modules) mkDefault;
  inherit (lib.strings) concatStringsSep;

  inherit (config.style) colors bootWallpaper;

  palette = concatStringsSep ";";
in {
  config = {
    boot.loader = {
      limine = {
        enable = true;
        secureBoot.autoEnrollKeys.enable = true;

        maxGenerations = mkDefault 15;

        additionalFiles = {
          "efi/memtest86/memtest86.efi" = "${pkgs.memtest86-efi}/BOOTX64.efi";
        };

        extraEntries = ''
          /memtest86
            protocol: efi
            path: boot():/limine/efi/memtest86/memtest86.efi
        '';

        style = {
          wallpapers = optional (bootWallpaper != null) bootWallpaper;
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

            margin = 0;
            marginGradient = 4;
          };
        };
      };

      efi.canTouchEfiVariables = mkDefault true;
      timeout = mkDefault null;
    };
  };
}
