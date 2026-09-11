{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit
    (lib.options)
    mkEnableOption
    mkOption
    mkPackageOption
    ;

  inherit
    (lib.modules)
    mkIf
    mkDefault
    ;

  inherit
    (lib.types)
    lines
    str
    ;

  toml = pkgs.formats.toml {};
  cfg = config.nyu.services.wayle;
  colors = config.style.colors;

  hex = c: "#${c}";

  wrapConfigHome = package:
    pkgs.symlinkJoin {
      name = "${package.pname or package.name}-wrapped";
      paths = [package];
      nativeBuildInputs = [pkgs.makeWrapper];
      postBuild = ''
        for bin in "$out"/bin/*; do
          wrapProgram "$bin" --set XDG_CONFIG_HOME /etc
        done
      '';
    };
in {
  options.nyu.services.wayle = {
    enable = mkEnableOption "Wayle desktop shell.";

    package =
      mkPackageOption pkgs "wayle" {}
      // {apply = wrapConfigHome;};

    config = mkOption {
      type = toml.type;
      default = {};
      description = "Wayle configuration, written to /etc/wayle/config.toml.";
    };

    styles = mkOption {
      type = lines;
      default = "";
      description = ''
        Custom SCSS written to /etc/wayle/styles/index.scss. Layered on top
        of Wayle's built-in stylesheet; the escape hatch for tweaks not
        exposed through {option}`config` (see Wayle's "Custom styles" guide).
      '';
    };

    systemd.target = mkOption {
      type = str;
      default = "graphical-session.target";
      description = "Systemd user target that the wayle service attaches to.";
    };
  };

  config = mkIf cfg.enable {
    nyu.services.wayle = {
      config = mkDefault {
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
              left = ["dashboard" "clock" "bluetooth" "idle-inhibit" "systray"];
              center = ["niri-workspaces"];
              right = ["volume" "brightness" "battery"];
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
          "idle-inhibit" = {
            border-show = true;
            border-color = "border-accent";
            label-show = false;
            icon-bg-color = "accent";
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
      styles = mkDefault ''
        .workspaces.niri .workspace {
          border: var(--ws-border-width) solid var(--ws-border-color);
        }
      '';
    };

    environment = {
      systemPackages = [cfg.package];
      etc = {
        "wayle/config.toml".source = toml.generate "wayle-config.toml" cfg.config;
        "wayle/styles/index.scss" = mkIf (cfg.styles != "") {
          text = cfg.styles;
        };
      };
    };

    systemd.user.services.wayle = {
      description = "Wayle desktop shell";

      after = [cfg.systemd.target];
      partOf = [cfg.systemd.target];
      wantedBy = [cfg.systemd.target];

      unitConfig = {
        StartLimitIntervalSec = 30;
        StartLimitBurst = 5;
      };

      # Without this, wayle only gets the minimal default PATH (coreutils,
      # findutils, grep, sed, systemd) - no `sh`, so every dashboard button
      # that shells out (lock, logout, reboot, poweroff) fails to spawn.
      path = ["/run/current-system/sw"];

      serviceConfig = {
        ExecStart = "${cfg.package}/bin/wayle shell";
        Restart = "on-failure";
        RestartSec = 3;
        Slice = "session.slice";
      };
    };
  };
}
