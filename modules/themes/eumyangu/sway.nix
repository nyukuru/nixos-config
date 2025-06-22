{
  config,
  ...
}: let
  inherit (config) style;
  inherit (style) colors;
in {
  nyu.programs.sway.settings = {
    gaps = {
      inner = 8;
      outer = 0;
    };

    font = "pango:monospace 10";

    default_border = "normal 0";
    default_floating_border = "pixel 0";

    titlebar_border_thickness = 0;
    titlebar_padding = "12 4";
    title_align = "center";

    output."*".bg =
      if (style.wallpaper != null)
      then "${style.wallpaper} fill"
      else "#${colors.base0} solid_color";

    # Hide titlebar text
    #for_window."[all]".title_format = "<span></span>";

    "client.focused" = "#202020 #202020 #${colors.base7}";
    "client.focused_inactive" = "#161616 #161616 #${colors.base7}";
    "client.unfocused" = "#161616 #161616 #${colors.base7}";
    "client.urgent" = "#${colors.base1} #161616 #${colors.base7}";
  };
}
