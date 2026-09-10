{config, ...}: let
  inherit (config) style;
  inherit (style) colors;

  hex = c: "#${c}";
in {
  nyu.services.wayle = {
    enable = true;

    config = {
      bar = {
        scale = 0.8;
        bg = "bg";
        border-location = "bottom";
        border-width = 4;
        border-color = hex colors.base8;
        module-gap = 0.5;
        button-group-module-gap = 0.5;

        layout = [
          {
            monitor = "*";
            left = ["dashboard" "clock" "bluetooth" "systray"];
            center = ["niri-workspaces"];
            right = [
              {
                name = "status";
                modules = ["volume" "brightness" "battery"];
              }
            ];
          }
        ];
      };

      modules = {
        clock = {
          format = "%b %d %I:%M %p";
          border-show = true;
          border-color = "border-accent";
          icon-bg-color = "accent";
          label-color = "accent";
        };
        dashboard = {
          border-show = true;
          border-color = "border-accent";
          icon-bg-color = "accent";
        };
        bluetooth = {
          border-show = true;
          border-color = "border-accent";
          icon-bg-color = "accent";
          label-color = "accent";
        };
        systray = {
          border-show = true;
          border-color = "border-accent";
        };
        volume = {
          border-show = true;
          border-color = "border-accent";
          icon-bg-color = "accent";
          label-color = "accent";
        };
        brightness = {
          border-show = true;
          border-color = "border-accent";
          icon-bg-color = "accent";
          label-color = "accent";
        };
        battery = {
          border-show = true;
          border-color = "border-accent";
          icon-bg-color = "accent";
          label-color = "accent";
        };
        "niri-workspaces" = {
          "min-workspace-count" = 5;
          "display-mode" = "none";
          "label-strategy" = "index";
          "app-icons-show" = true;
          "app-icons-dedupe" = true;
          "border-show" = true;
          "border-color" = hex colors.base8;
          "workspace-padding" = 0.8;
        };
      };

      styling.palette = {
        bg = hex colors.background;
        surface = hex colors.background;
        elevated = hex colors.base8;
        fg = hex colors.foreground;
        "fg-muted" = hex colors.base6;
        primary = hex colors.baseB;
        red = hex colors.base1;
        yellow = hex colors.base3;
        green = hex colors.base2;
        blue = hex colors.base4;
      };
    };

    # min-workspace-count and border-color only apply to the workspaces
    # container as a whole; the config has no per-button border/separator
    # option, so give each workspace its own border here, reusing the same
    # --ws-border-color/--ws-border-width the container itself is drawn with.
    styles = ''
      .workspaces.niri .workspace {
        border: var(--ws-border-width) solid var(--ws-border-color);
      }
    '';
  };
}
