{config, ...}: let
  inherit (config.style) colors wallpaper font;
in {
  nyu.programs.swaylock = {
    enable = true;

    settings =
      {
        daemonize = true;
        ignore-empty-password = true;
        show-failed-attempts = false;
        indicator-caps-lock = true;

        color = colors.base0;

        font = font.name;
        font-size = 24;

        indicator-radius = 90;
        indicator-thickness = 7;

        inside-color = colors.base0;
        inside-clear-color = colors.base0;
        inside-ver-color = colors.base0;
        inside-wrong-color = colors.base0;

        ring-color = colors.base8;
        ring-clear-color = colors.base8;
        ring-ver-color = colors.base8;
        ring-wrong-color = colors.base1;

        line-uses-ring = true;

        key-hl-color = colors.baseA;
        bs-hl-color = colors.base1;

        text-color = "${colors.foreground}ee";
        text-clear-color = "${colors.foreground}ee";
        text-ver-color = "${colors.foreground}ee";
        text-wrong-color = "${colors.foreground}ee";
      }
      // (
        if wallpaper != null
        then {
          image = "${wallpaper}";
          scaling = "fill";
        }
        else {}
      );
  };
}
