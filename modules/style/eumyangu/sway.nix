{
  config,
  ...
}: let

  style = config.modules.style;

in {
  modules.system.display.wm.sway.settings = {

    gaps = {
      inner = 4;
      outer = 0;
    };

    font = "pango:monospace 10";

    default_border = "normal 0";
    default_floating_border = "pixel 0";

    titlebar_border_thickness = 0;
    titlebar_padding = "12 4";
    title_align = "center";

    output."*".bg = 
      if (style.wallpaper != null) then
        "${"style.wallpaper"} fill"
      else "#090707 solid_color";

    for_window."[class=\".*\"]".title_format = "<span></span>";

    "client.focused"          = "#202020 #202020 #F8F8F6 #3E4A4F #212121";
    "client.focused_inactive" = "#161616 #161616 #F8F8F6 #484E50 #161616";
    "client.unfocused"        = "#161616 #161616 #F8F8F6 #292D2E #161616";
    "client.urgent"           = "#141B1E #E52323 #F8F8F6 #E52323 #E52323";
    "client.placeholder"      = "#000000 #0C0C0C #F8F8F6 #000000 #0C0C0C";
  };
}
