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
    mkForce
    mkIf
    mkMerge
    ;

  inherit
    (lib.types)
    attrsOf
    str
    ;

  inherit (lib.attrsets) mapAttrs' optionalAttrs;

  toml = pkgs.formats.toml {};
  json = pkgs.formats.json {};
  cfg = config.nyu.services.noctalia;
  inherit (config.style) colors wallpaper;

  hex = c: "#${c}";
  msg = "${cfg.package}/bin/noctalia msg";

  # NOCTALIA_CONFIG_HOME (unlike XDG_CONFIG_HOME) only affects noctalia
  # itself, so apps launched from the shell keep the normal config home.
  wrapConfigHome = package:
    pkgs.symlinkJoin {
      name = "${package.pname or package.name}-wrapped";
      paths = [package];
      nativeBuildInputs = [pkgs.makeWrapper];
      postBuild = ''
        wrapProgram "$out/bin/noctalia" --set NOCTALIA_CONFIG_HOME /etc
      '';
    };
in {
  options.nyu.services.noctalia = {
    enable = mkEnableOption "Noctalia desktop shell.";

    package =
      mkPackageOption pkgs "noctalia" {}
      // {apply = wrapConfigHome;};

    settings = mkOption {
      type = toml.type;
      default = {};
      description = ''
        Noctalia configuration, written to /etc/noctalia/config.toml.
        GUI changes still land in ~/.local/state/noctalia/settings.toml and
        take precedence over this.
      '';
    };

    palettes = mkOption {
      type = attrsOf json.type;
      default = {};
      description = ''
        Custom palettes written to /etc/noctalia/palettes/<name>.json,
        selectable through `theme.custom_palette`.
      '';
    };

    systemd.target = mkOption {
      type = str;
      default = "graphical-session.target";
      description = "Systemd user target that the noctalia service attaches to.";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      nyu.services.noctalia = {
        palettes.nyu.dark = {
          mPrimary = hex colors.baseB;
          mOnPrimary = hex colors.background;
          mSecondary = hex colors.base4;
          mOnSecondary = hex colors.background;
          mTertiary = hex colors.base2;
          mOnTertiary = hex colors.background;
          mError = hex colors.base1;
          mOnError = hex colors.background;
          mSurface = hex colors.background;
          mOnSurface = hex colors.foreground;
          mSurfaceVariant = hex colors.base8;
          mOnSurfaceVariant = hex colors.base6;
          mOutline = hex colors.base8;
          mShadow = hex colors.base0;
          mHover = hex colors.base8;
          mOnHover = hex colors.foreground;
        };

        settings = {
          shell = {
            font_family = config.style.font.name;
            telemetry_enabled = false;
          };

          theme = {
            mode = "dark";
            source = "custom";
            custom_palette = "nyu";
          };

          wallpaper =
            {
              enabled = true;
              fill_mode = "crop";
              fill_color = hex colors.base0;
            }
            // optionalAttrs (wallpaper != null) {
              default.path = "${wallpaper}";
            };

          # Lock on lid close / suspend.
          lockscreen.lock_before_suspend = true;

          bar.main = {
            position = "top";
            thickness = 32;
            scale = 0.8;
            background_opacity = 1.0;
            shadow = false;

            # Full-width, square, flush with the screen edge.
            margin_ends = 0;
            margin_edge = 0;
            radius = 0;
            concave_edge_corners = false;
            padding = 8;
            widget_spacing = 6;

            border = "outline";
            border_width = 4;

            # Every widget gets an accent-bordered box with accent text.
            capsule = true;
            capsule_fill = "surface";
            capsule_border = "primary";
            capsule_border_width = 2;
            capsule_radius = 0;
            color = "primary";

            start = ["control-center" "clock" "bluetooth" "caffeine" "tray"];
            center = ["taskbar"];
            end = ["volume" "brightness"];
          };

          widget = {
            clock.format = "{:%b %d %I:%M %p}";
            bluetooth.show_label = true;
            tray.hide_passive = false;

            # Workspaces with their app icons, like wayle's niri-workspaces.
            taskbar = {
              group_by_workspace = true;
              group_single_icon_per_app = true;
              hide_empty_workspaces = false;
              show_workspace_label = true;
              workspace_label_placement = "inside";
              capsule_border = "outline";
            };
          };
        };
      };

      environment = {
        systemPackages = [cfg.package];
        etc =
          {
            "noctalia/config.toml".source = toml.generate "noctalia-config.toml" cfg.settings;
          }
          // mapAttrs' (name: value: {
            name = "noctalia/palettes/${name}.json";
            value.source = json.generate "noctalia-palette-${name}.json" value;
          })
          cfg.palettes;
      };

      # Freedesktop sound theme, a runtime dependency for shell sounds.
      xdg.sounds.enable = true;

      systemd.user.services.noctalia = {
        description = "Noctalia desktop shell";
        documentation = ["https://docs.noctalia.dev/"];

        after = [cfg.systemd.target];
        partOf = [cfg.systemd.target];
        wantedBy = [cfg.systemd.target];

        unitConfig = {
          StartLimitIntervalSec = 30;
          StartLimitBurst = 5;
        };

        # Without this, noctalia only gets the minimal default PATH, so
        # session actions and custom commands that shell out fail to spawn.
        path = ["/run/current-system/sw"];

        serviceConfig = {
          ExecStart = "${cfg.package}/bin/noctalia";
          Restart = "on-failure";
          RestartSec = 3;
          Slice = "session.slice";
        };
      };
    }

    (mkIf config.nyu.programs.niri.enable {
      programs.niri.settings = {
        window-rules = [
          {
            matches = [{app-id = "^dev\\.noctalia\\.Noctalia$";}];
            open-floating = true;
          }
        ];

        # Lets notification actions raise their window.
        debug.honor-xdg-activation-with-invalid-serial = [];

        binds = {
          "Super+Alt+L" = {
            hotkey-overlay.title = "Lock the Screen";
            action.spawn-sh = "${msg} session lock";
          };
          "Mod+D" = {
            hotkey-overlay.title = "Open Application Launcher";
            action.spawn-sh = "${msg} panel-toggle launcher";
          };
        };
      };
    })

    (mkIf config.nyu.programs.sway.enable {
      nyu.programs.sway.settings.bindsym = {
        "Mod4+Alt+l" = "exec ${msg} session lock";
        "Mod4+d" = mkForce "exec ${msg} panel-toggle launcher";
      };
    })
  ]);
}
