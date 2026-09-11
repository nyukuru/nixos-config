{
  pkgs,
  config,
  ...
}: let
  inherit (config.style) colors;

  nyubones-gtk = pkgs.writers.makeOomoxGtkTheme {
    name = "Nyubones";
    colors = {
      BG = colors.base0;
      FG = colors.foreground;
      BTN_BG = colors.base8;
      BTN_FG = colors.foreground;
      HDR_BG = colors.base8;
      HDR_FG = colors.foreground;
      HDR_BTN_BG = colors.base8;
      HDR_BTN_FG = colors.foreground;
      SEL_BG = colors.base5;
      SEL_FG = colors.background;
      ACCENT_BG = colors.base5;
      TXT_BG = colors.base0;
      TXT_FG = colors.foreground;
      WM_BORDER_FOCUS = colors.baseB;
      WM_BORDER_UNFOCUS = colors.base8;
      GRADIENT = "0";
      ROUNDNESS = "4";
      SPACING = "3";
    };
  };
in {
  imports = [
    ./nvim.nix
  ];

  style = {
    wallpaper = ./sailor.png;
    bootWallpaper = ./leaves.png;

    colors = {
      background = "1C1917";
      foreground = "E8E5DF";

      base0 = "1C1917";
      base1 = "D88991";
      base2 = "8FA77A";
      base3 = "6F6A64";
      base4 = "7F9FB5";
      base5 = "8A827B";
      base6 = "A49C94";
      base7 = "C8C4BE";

      base8 = "332F2C";
      base9 = "E39AA1";
      baseA = "A6BD8E";
      baseB = "8D8780";
      baseC = "94B2C6";
      baseD = "AAA39B";
      baseE = "C1BBB4";
      baseF = "E8E5DF";
    };
  };

  gtk = {
    theme = {
      package = nyubones-gtk;
      name = "Nyubones";
    };

    iconTheme = {
      package = pkgs.morewaita-icon-theme;
      name = "MoreWaita";
    };

    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
  };
}
