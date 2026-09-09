{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit
    (lib.options)
    mkPackageOption
    mkEnableOption
    mkOption
    ;

  inherit
    (lib.modules)
    mkForce
    mkIf
    ;

  inherit
    (lib.strings)
    concatMapStringsSep
    concatStringsSep
    optionalString
    removeSuffix
    splitString
    ;

  inherit
    (lib.types)
    nullOr
    lines
    path
    str
    ;

  inherit
    (lib.lists)
    optionals
    optional
    filter
    ;

  inherit
    (lib.meta)
    getExe'
    getExe
    ;

  cfg = config.nyu.programs.niri;

  brightness = "${pkgs.scripts.brightness}";
  screenshot = "${pkgs.scripts.niri-screenshot}";
  volume = "${pkgs.scripts.volume}";
  playerctl = getExe pkgs.playerctl;

  # Keep the nodes of a section lined up with the block they are nested in.
  indent = body:
    concatMapStringsSep "\n"
    (line: optionalString (line != "") "    ${line}")
    (splitString "\n" (removeSuffix "\n" body));

  section = name: body:
    optionalString (body != "") ''
      ${name} {
      ${indent body}
      }
    '';

  # KDL takes every argument of a node separately quoted.
  spawn = command: args: concatStringsSep " " (map (arg: "\"${arg}\"") ([command] ++ args));

  # swaybg is only spawned once a theme actually asks for a background.
  swaybgArgs =
    optionals (cfg.backgroundColor != null) ["-c" cfg.backgroundColor]
    ++ optionals (cfg.wallpaper != null) ["-m" "fill" "-i" "${cfg.wallpaper}"];

  configFile =
    pkgs.writeText "niri.kdl"
    (concatStringsSep "\n" (filter (s: s != "") [
      cfg.settings
      (section "layout" cfg.layout)
      (section "binds" cfg.binds)
    ]));
in {
  imports = [
    ../wayland-shared.nix
  ];

  options.nyu.programs.niri = {
    enable = mkEnableOption "Niri window manager.";
    package = mkPackageOption pkgs "niri" {};

    settings = mkOption {
      type = lines;
      default = "";
      description = "Top level nodes of the niri config, see niri(1).";
    };

    layout = mkOption {
      type = lines;
      default = "";
      description = ''
        Nodes of the niri `layout` block. Kept apart from
        {option}`settings` so themes can contribute to it.
      '';
    };

    binds = mkOption {
      type = lines;
      default = "";
      description = ''
        Nodes of the niri `binds` block. Kept apart from
        {option}`settings` so other modules can contribute to it.
      '';
    };

    wallpaper = mkOption {
      type = nullOr path;
      default = null;
      description = ''
        Image displayed as the background through swaybg.
        Usually set from {option}`style.wallpaper` by a theme.
      '';
    };

    backgroundColor = mkOption {
      type = nullOr str;
      default = null;
      description = ''
        Solid color (`#rrggbb`) drawn behind the wallpaper through swaybg.
        Usually set from {option}`style.colors` by a theme.
      '';
    };

    xwayland = {
      enable = mkEnableOption "XWayland" // {default = true;};
    };
  };

  config = mkIf cfg.enable {
    programs = {
      niri.enable = mkForce false;
      uwsm.waylandCompositors.niri = {
        prettyName = "Niri";
        comment = "Niri compositor managed by UWSM";
        binPath = getExe cfg.package;
      };
    };

    systemd.packages = [cfg.package];
    systemd.user.services.niri = {
      restartIfChanged = false;
      enableDefaultPath = false;
    };

    environment = {
      systemPackages =
        [cfg.package]
        ++ optional cfg.xwayland.enable pkgs.xwayland-satellite
        ++ optional (swaybgArgs != []) pkgs.swaybg;

      etc."niri/config.kdl".source = configFile;
    };

    # The default config settings
    nyu.programs.niri = {
      settings = ''
        spawn-at-startup "uwsm" "finalize"
        ${optionalString (swaybgArgs != [])
          ''spawn-at-startup ${spawn (getExe' pkgs.swaybg "swaybg") swaybgArgs}''}

        input {
            touchpad {
                tap
                scroll-method "two-finger"
                disabled-on-external-mouse
            }

            mouse {
                accel-profile "flat"
            }

            warp-mouse-to-focus
            focus-follows-mouse max-scroll-amount="30%"
        }

        output "eDP-1" {
            mode "1920x1080"
            scale 1

            transform "normal"

            position x=1280 y=0
        }

        hotkey-overlay {
            skip-at-startup
        }

        // Formatted with strftime(3), a leading ~ is the home directory.
        screenshot-path "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png"

        animations {
            off
        }

        gestures {
            hot-corners {
                off
            }
        }

        window-rule {
            match app-id=r#"firefox$"# title="^Picture-in-Picture$"
            open-floating true
        }

        // Keep password managers out of screen captures.
        window-rule {
            match app-id=r#"^org\.keepassxc\.KeePassXC$"#
            match app-id=r#"^org\.gnome\.World\.Secrets$"#

            block-out-from "screen-capture"
        }
      '';

      layout = ''
        center-focused-column "on-overflow"

        // Widths cycled through by "switch-preset-column-width" (Mod+R).
        preset-column-widths {
            proportion 0.33333
            proportion 0.5
            proportion 0.66667
        }

        default-column-width { proportion 0.5; }
      '';

      binds = ''
        Mod+Shift+Slash { show-hotkey-overlay; }

        Super+Return hotkey-overlay-title="Open Terminal: foot" { spawn ${spawn (getExe pkgs.foot) []}; }
        Super+F hotkey-overlay-title="Open Firefox" { spawn "firefox"; }
        Super+Alt+L hotkey-overlay-title="Lock the Screen: swaylock" { spawn ${spawn (getExe pkgs.swaylock) []}; }

        // Brightness bindings
        XF86MonBrightnessUp allow-when-locked=true { spawn ${spawn brightness ["2%+"]}; }
        XF86MonBrightnessDown allow-when-locked=true { spawn ${spawn brightness ["2%-"]}; }
        Shift+XF86MonBrightnessUp allow-when-locked=true { spawn ${spawn brightness ["20%+"]}; }
        Shift+XF86MonBrightnessDown allow-when-locked=true { spawn ${spawn brightness ["20%-"]}; }

        // Output audio control
        XF86AudioRaiseVolume allow-when-locked=true { spawn ${spawn volume ["set-volume" "@DEFAULT_SINK@" "1%+"]}; }
        XF86AudioLowerVolume allow-when-locked=true { spawn ${spawn volume ["set-volume" "@DEFAULT_SINK@" "1%-"]}; }
        XF86AudioMute allow-when-locked=true { spawn ${spawn volume ["set-mute" "@DEFAULT_SINK@" "toggle"]}; }

        // Input audio control
        Alt+XF86AudioRaiseVolume allow-when-locked=true { spawn ${spawn volume ["set-volume" "@DEFAULT_SOURCE@" "1%+"]}; }
        Alt+XF86AudioLowerVolume allow-when-locked=true { spawn ${spawn volume ["set-volume" "@DEFAULT_SOURCE@" "1%-"]}; }
        Alt+XF86AudioMute allow-when-locked=true { spawn ${spawn volume ["set-mute" "@DEFAULT_SOURCE@" "toggle"]}; }
        XF86AudioMicMute allow-when-locked=true { spawn ${spawn volume ["set-mute" "@DEFAULT_SOURCE@" "toggle"]}; }

        // MPRIS media control
        XF86AudioPlay allow-when-locked=true { spawn ${spawn playerctl ["play-pause"]}; }
        XF86AudioStop allow-when-locked=true { spawn ${spawn playerctl ["stop"]}; }
        XF86AudioPrev allow-when-locked=true { spawn ${spawn playerctl ["previous"]}; }
        XF86AudioNext allow-when-locked=true { spawn ${spawn playerctl ["next"]}; }

        // Screenshots, the niri screenshot UI is kept on Ctrl+Print.
        Print { spawn ${spawn screenshot ["screen"]}; }
        Alt+Print { spawn ${spawn screenshot ["area"]}; }
        Ctrl+Print { screenshot; }

        // A zoomed out view of workspaces and windows.
        Mod+O repeat=false { toggle-overview; }
        Mod+Q repeat=false { close-window; }

        Mod+H { focus-column-left; }
        Mod+J { focus-window-down; }
        Mod+K { focus-window-up; }
        Mod+L { focus-column-right; }

        Mod+Ctrl+H { move-column-left; }
        Mod+Ctrl+J { move-window-down; }
        Mod+Ctrl+K { move-window-up; }
        Mod+Ctrl+L { move-column-right; }

        Mod+Home { focus-column-first; }
        Mod+End { focus-column-last; }
        Mod+Ctrl+Home { move-column-to-first; }
        Mod+Ctrl+End { move-column-to-last; }

        Mod+Shift+H { focus-monitor-left; }
        Mod+Shift+J { focus-monitor-down; }
        Mod+Shift+K { focus-monitor-up; }
        Mod+Shift+L { focus-monitor-right; }

        Mod+Shift+Ctrl+H { move-column-to-monitor-left; }
        Mod+Shift+Ctrl+J { move-column-to-monitor-down; }
        Mod+Shift+Ctrl+K { move-column-to-monitor-up; }
        Mod+Shift+Ctrl+L { move-column-to-monitor-right; }

        Mod+Page_Down { focus-workspace-down; }
        Mod+Page_Up { focus-workspace-up; }
        Mod+U { focus-workspace-down; }
        Mod+I { focus-workspace-up; }

        Mod+Ctrl+Page_Down { move-column-to-workspace-down; }
        Mod+Ctrl+Page_Up { move-column-to-workspace-up; }
        Mod+Ctrl+U { move-column-to-workspace-down; }
        Mod+Ctrl+I { move-column-to-workspace-up; }

        Mod+Shift+Page_Down { move-workspace-down; }
        Mod+Shift+Page_Up { move-workspace-up; }
        Mod+Shift+U { move-workspace-down; }
        Mod+Shift+I { move-workspace-up; }

        // Rate limited so scrolling does not fly through the workspaces.
        Mod+WheelScrollDown cooldown-ms=150 { focus-workspace-down; }
        Mod+WheelScrollUp cooldown-ms=150 { focus-workspace-up; }
        Mod+Ctrl+WheelScrollDown cooldown-ms=150 { move-column-to-workspace-down; }
        Mod+Ctrl+WheelScrollUp cooldown-ms=150 { move-column-to-workspace-up; }

        Mod+WheelScrollRight { focus-column-right; }
        Mod+WheelScrollLeft { focus-column-left; }
        Mod+Ctrl+WheelScrollRight { move-column-right; }
        Mod+Ctrl+WheelScrollLeft { move-column-left; }

        Mod+Shift+WheelScrollDown { focus-column-right; }
        Mod+Shift+WheelScrollUp { focus-column-left; }
        Mod+Ctrl+Shift+WheelScrollDown { move-column-right; }
        Mod+Ctrl+Shift+WheelScrollUp { move-column-left; }

        Mod+1 { focus-workspace 1; }
        Mod+2 { focus-workspace 2; }
        Mod+3 { focus-workspace 3; }
        Mod+4 { focus-workspace 4; }
        Mod+5 { focus-workspace 5; }

        Mod+Ctrl+1 { move-column-to-workspace 1; }
        Mod+Ctrl+2 { move-column-to-workspace 2; }
        Mod+Ctrl+3 { move-column-to-workspace 3; }
        Mod+Ctrl+4 { move-column-to-workspace 4; }
        Mod+Ctrl+5 { move-column-to-workspace 5; }

        Mod+BracketLeft { consume-or-expel-window-left; }
        Mod+BracketRight { consume-or-expel-window-right; }

        Mod+Comma { consume-window-into-column; }
        Mod+Period { expel-window-from-column; }

        Mod+R { switch-preset-column-width; }
        Mod+Shift+R { switch-preset-column-width-back; }

        Mod+Ctrl+Shift+R { switch-preset-window-height; }
        Mod+Ctrl+R { reset-window-height; }

        Mod+Space { maximize-column; }
        Mod+M { maximize-window-to-edges; }

        Mod+Ctrl+F { expand-column-to-available-width; }

        Mod+C { center-column; }
        Mod+Ctrl+C { center-visible-columns; }

        Mod+Minus { set-column-width "-10%"; }
        Mod+Equal { set-column-width "+10%"; }

        Mod+Shift+Minus { set-window-height "-10%"; }
        Mod+Shift+Equal { set-window-height "+10%"; }

        Mod+V { toggle-window-floating; }
        Mod+Shift+V { switch-focus-between-floating-and-tiling; }

        Mod+W { toggle-column-tabbed-display; }

        // Escape hatch for clients inhibiting the compositor shortcuts.
        Mod+Escape allow-inhibiting=false { toggle-keyboard-shortcuts-inhibit; }
        Ctrl+Alt+Delete { quit; }
      '';
    };
  };
}
