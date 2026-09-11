{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib.meta) getExe getExe';
  inherit (config.style) colors;
in {
  config.services = {
    dunst.settings = {
      global = {
        width = "(0, 500)";
        height = 100;
        offset = "10x10";
        notification_limit = 0;
        progress_bar_height = 2;
        progress_bar_frame_width = 0;
        progress_bar_min_width = 120;
        padding = 24;
        horizontal_padding = 16;
        frame_width = 0;
        separator_color = "auto";
        font = "sans 10";
        markup = "full";
        hide_duplicate_count = true;
        show_indicators = false;
        min_icon_size = 0;
        max_icon_size = 72;
        sticky_history = false;
        history_length = 0;
        title = "notification";

        dmenu = "${getExe pkgs.dmenu} -p dunst";
        browser = "${getExe' pkgs.xdg-utils "xdg-open"}";

        mouse_left_click = "do_action, close_current";
        mouse_right_click = "close_current";
        mouse_middle_click = "close_all";
      };

      urgency_low = {
        background = "#${colors.base0}";
        foreground = "#${colors.base7}";
        timeout = 5;
      };

      urgency_normal = {
        background = "#${colors.base0}";
        foreground = "#${colors.base7}";
        highlight = "#${colors.base7}";
        timeout = 5;
      };

      urgency_critical = {
        background = "#${colors.base0}";
        foreground = "#${colors.base7}";
        frame_color = "#${colors.base1}";
        timeout = 120;
      };
    };
  };
}
