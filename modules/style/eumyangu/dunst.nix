{
  nyu.programs.dunst.settings = {
    global = {
      monitor = 0;
      follow = "none";
      width = "(0, 500)";
      height = 100;
      origin = "top-right";
      offset = "10x10";
      scale = 0;
      notification_limit = 0;
      progress_bar = true;
      progress_bar_height = 2;
      progress_bar_frame_width = 0;
      progress_bar_min_width = 120;
      progress_bar_max_width = 300;
      indicate_hidden = "yes";
      transparency = 0;
      separator_height = 2;
      padding = 24;
      horizontal_padding = 16;
      text_icon_padding = 0;
      corner_radius = 0;
      frame_width = 0;
      separator_color = "auto";
      sort = "yes";
      idle_threshold = 0;
      font = "sans 10";
      line_height = 0;
      markup = "full";
      format = "\"<b>%s</b>\n%b\"";
      alignment = "left";
      vertical_alignment = "center";
      show_age_threshold = 60;
      ellipsize = "middle";
      ignore_newline = "no";
      stack_duplicates = "true";
      hide_duplicate_count = true;
      show_indicators = false;
      icon_position = "left";
      min_icon_size = 0;
      max_icon_size = 72;
      sticky_history = false;
      history_length = 0;
      dmenu = "/usr/bin/dmenu -p dunst";
      browser = "/usr/bin/xdg-open";
      always_run_script = true;
      title = "notification";
      class = "Dunst";
      ignore_dbusclose = false;
      force_xwayland = false;
      force_xinerama = false;
      mouse_left_click = "do_action, close_current";
      mouse_right_click = "close_current";
      mouse_middle_click = "close_all";
    };

    experimental = {
      per_monitor_dpi = false;
    };

    urgency_low = {
      background = "#16130f";
      foreground = "#b7a59f";
      timeout = 5;
    };

    urgency_normal = {
      background = "#16130f";
      foreground = "#b7a59f";
      highlight = "#b7a59f";
      timeout = 5;
    };

    urgency_critical = {
      background = "#16130f";
      foreground = "#b7a59f";
      frame_color = "#e57474";
      timeout = 120;
    };
  };
}

