{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: let
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.modules) mkIf mkForce;
  inherit (lib.types) nullOr path str bool;
  inherit (lib.lists) optional optionals;
  inherit (lib.meta) getExe getExe';

  cfg = config.nyu.programs.niri;
  colors = config.style.colors;

  brightness = "${pkgs.scripts.brightness}";
  screenshot = "${pkgs.scripts.niri-screenshot}";
  volume = "${pkgs.scripts.volume}";
  playerctl = getExe pkgs.playerctl;
  fuzzel = getExe' config.nyu.programs.fuzzel.package "fuzzel";
  foot = getExe pkgs.foot;
  swaylock = getExe' config.nyu.programs.swaylock.package "swaylock";

  swaybgArgs =
    optionals (cfg.backgroundColor != null) ["-c" cfg.backgroundColor]
    ++ optionals (cfg.wallpaper != null) ["-m" "fill" "-i" "${cfg.wallpaper}"];
in {
  imports = [
    ../wayland-shared.nix
    inputs.niri-flake.lib.internal.settings-module
  ];

  options.nyu.programs.niri = {
    enable = mkEnableOption "Niri window manager.";

    wallpaper = mkOption {
      type = nullOr path;
      default = config.style.wallpaper;
      description = ''
        Image displayed as the background through swaybg.
        Defaults to {option}`style.wallpaper`.
      '';
    };

    backgroundColor = mkOption {
      type = nullOr str;
      default = "#${colors.base0}";
      description = ''
        Solid color (`#rrggbb`) drawn behind the wallpaper through swaybg.
        Defaults to {option}`style.colors.base0`.
      '';
    };

    xwayland.enable = mkEnableOption "XWayland" // {default = true;};

    skipHotkeyOverlayAtStartup = mkOption {
      type = bool;
      default = true;
      description = "Whether niri's keybind cheat-sheet overlay is skipped on startup.";
    };
  };

  config = mkIf cfg.enable {
    programs = {
      niri.enable = mkForce false;
      uwsm.waylandCompositors.niri = {
        prettyName = "Niri";
        comment = "Niri compositor managed by UWSM";
        binPath = getExe config.programs.niri.package;
      };
    };

    systemd.packages = [config.programs.niri.package];
    systemd.user.services.niri = {
      restartIfChanged = false;
      enableDefaultPath = false;
    };

    environment.systemPackages =
      [config.programs.niri.package]
      ++ optional cfg.xwayland.enable pkgs.xwayland-satellite
      ++ optional (swaybgArgs != []) pkgs.swaybg;

    environment.etc."niri/config.kdl".source =
      pkgs.runCommand "config.kdl" {
        config = config.programs.niri.finalConfig;
        passAsFile = ["config"];
        buildInputs = [config.programs.niri.package];
      } ''
        niri validate -c $configPath
        cp $configPath $out
      '';

    programs.niri.settings = {
      prefer-no-csd = true;

      spawn-at-startup =
        [{argv = ["uwsm" "finalize"];}]
        ++ optional (swaybgArgs != []) {argv = [(getExe' pkgs.swaybg "swaybg")] ++ swaybgArgs;};

      workspaces = {
        "1" = {};
        "2" = {};
        "3" = {};
        "4" = {};
        "5" = {};
      };

      input = {
        touchpad = {
          tap = true;
          scroll-method = "two-finger";
          disabled-on-external-mouse = true;
        };

        mouse.accel-profile = "flat";

        warp-mouse-to-focus.enable = true;
        focus-follows-mouse = {
          enable = true;
          max-scroll-amount = "30%";
        };
      };

      outputs."eDP-1" = {
        mode = {
          width = 1920;
          height = 1080;
        };
        scale = 1;
        position = {
          x = 1280;
          y = 0;
        };
      };

      hotkey-overlay.skip-at-startup = cfg.skipHotkeyOverlayAtStartup;

      screenshot-path = "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png";

      animations.slowdown = 0.8;

      gestures.hot-corners.enable = false;

      window-rules = [
        {
          matches = [
            {
              app-id = "firefox$";
              title = "^Picture-in-Picture$";
            }
          ];
          open-floating = true;
        }
        {
          matches = [
            {app-id = "^org\\.keepassxc\\.KeePassXC$";}
            {app-id = "^org\\.gnome\\.World\\.Secrets$";}
          ];
          block-out-from = "screen-capture";
        }
      ];

      layout = {
        gaps = 8;

        focus-ring.enable = false;

        border = {
          enable = true;
          width = 4;
          active.color = "#${colors.baseB}";
          inactive.color = "#${colors.base8}";
          urgent.color = "#${colors.base1}";
        };

        shadow = {
          enable = true;
          softness = 30;
          spread = 5;
          offset = {
            x = 0;
            y = 5;
          };
          color = "#${colors.base0}77";
        };

        center-focused-column = "on-overflow";

        preset-column-widths = [
          {proportion = 0.33333;}
          {proportion = 0.5;}
          {proportion = 0.66667;}
        ];

        default-column-width = {proportion = 0.5;};
      };

      binds = {
        "Mod+Shift+Slash".action.show-hotkey-overlay = {};

        "Super+Return" = {
          hotkey-overlay.title = "Open Terminal: foot";
          action.spawn = foot;
        };
        "Super+F" = {
          hotkey-overlay.title = "Open Firefox";
          action.spawn = "firefox";
        };
        "Super+Alt+L" = {
          hotkey-overlay.title = "Lock the Screen: swaylock";
          action.spawn = swaylock;
        };
        "Mod+D" = {
          hotkey-overlay.title = "Open Application Launcher: fuzzel";
          action.spawn = fuzzel;
        };

        "XF86MonBrightnessUp" = {
          allow-when-locked = true;
          action.spawn = [brightness "2%+"];
        };
        "XF86MonBrightnessDown" = {
          allow-when-locked = true;
          action.spawn = [brightness "2%-"];
        };
        "Shift+XF86MonBrightnessUp" = {
          allow-when-locked = true;
          action.spawn = [brightness "20%+"];
        };
        "Shift+XF86MonBrightnessDown" = {
          allow-when-locked = true;
          action.spawn = [brightness "20%-"];
        };

        "XF86AudioRaiseVolume" = {
          allow-when-locked = true;
          action.spawn = [volume "set-volume" "@DEFAULT_SINK@" "1%+"];
        };
        "XF86AudioLowerVolume" = {
          allow-when-locked = true;
          action.spawn = [volume "set-volume" "@DEFAULT_SINK@" "1%-"];
        };
        "XF86AudioMute" = {
          allow-when-locked = true;
          action.spawn = [volume "set-mute" "@DEFAULT_SINK@" "toggle"];
        };

        "Alt+XF86AudioRaiseVolume" = {
          allow-when-locked = true;
          action.spawn = [volume "set-volume" "@DEFAULT_SOURCE@" "1%+"];
        };
        "Alt+XF86AudioLowerVolume" = {
          allow-when-locked = true;
          action.spawn = [volume "set-volume" "@DEFAULT_SOURCE@" "1%-"];
        };
        "Alt+XF86AudioMute" = {
          allow-when-locked = true;
          action.spawn = [volume "set-mute" "@DEFAULT_SOURCE@" "toggle"];
        };
        "XF86AudioMicMute" = {
          allow-when-locked = true;
          action.spawn = [volume "set-mute" "@DEFAULT_SOURCE@" "toggle"];
        };

        "XF86AudioPlay" = {
          allow-when-locked = true;
          action.spawn = [playerctl "play-pause"];
        };
        "XF86AudioStop" = {
          allow-when-locked = true;
          action.spawn = [playerctl "stop"];
        };
        "XF86AudioPrev" = {
          allow-when-locked = true;
          action.spawn = [playerctl "previous"];
        };
        "XF86AudioNext" = {
          allow-when-locked = true;
          action.spawn = [playerctl "next"];
        };

        "Print".action.spawn = [screenshot "screen"];
        "Alt+Print".action.spawn = [screenshot "area"];
        "Ctrl+Print".action.screenshot = {};

        "Mod+O" = {
          repeat = false;
          action.toggle-overview = {};
        };
        "Mod+Q" = {
          repeat = false;
          action.close-window = {};
        };

        "Mod+H".action.focus-column-left = {};
        "Mod+J".action.focus-window-down = {};
        "Mod+K".action.focus-window-up = {};
        "Mod+L".action.focus-column-right = {};

        "Mod+Shift+H".action.move-column-left = {};
        "Mod+Shift+J".action.move-window-down = {};
        "Mod+Shift+K".action.move-window-up = {};
        "Mod+Shift+L".action.move-column-right = {};

        "Mod+Home".action.focus-column-first = {};
        "Mod+End".action.focus-column-last = {};
        "Mod+Ctrl+Home".action.move-column-to-first = {};
        "Mod+Ctrl+End".action.move-column-to-last = {};

        "Mod+U".action.focus-workspace-down = {};
        "Mod+I".action.focus-workspace-up = {};

        "Mod+Shift+U".action.move-column-to-workspace-down = {};
        "Mod+Shift+I".action.move-column-to-workspace-up = {};

        "Mod+Shift+Page_Down".action.move-workspace-down = {};
        "Mod+Shift+Page_Up".action.move-workspace-up = {};

        "Mod+1".action.focus-workspace = 1;
        "Mod+2".action.focus-workspace = 2;
        "Mod+3".action.focus-workspace = 3;
        "Mod+4".action.focus-workspace = 4;
        "Mod+5".action.focus-workspace = 5;

        "Mod+Shift+1".action.move-column-to-workspace = 1;
        "Mod+Shift+2".action.move-column-to-workspace = 2;
        "Mod+Shift+3".action.move-column-to-workspace = 3;
        "Mod+Shift+4".action.move-column-to-workspace = 4;
        "Mod+Shift+5".action.move-column-to-workspace = 5;

        "Mod+BracketLeft".action.consume-or-expel-window-left = {};
        "Mod+BracketRight".action.consume-or-expel-window-right = {};

        "Mod+Comma".action.consume-window-into-column = {};
        "Mod+Period".action.expel-window-from-column = {};

        "Mod+R".action.switch-preset-column-width = {};
        "Mod+Shift+R".action.switch-preset-column-width-back = {};

        "Mod+Ctrl+Shift+R".action.switch-preset-window-height = {};
        "Mod+Ctrl+R".action.reset-window-height = {};

        "Mod+Space".action.maximize-column = {};
        "Mod+M".action.maximize-window-to-edges = {};

        "Mod+Ctrl+F".action.expand-column-to-available-width = {};

        "Mod+C".action.center-column = {};
        "Mod+Ctrl+C".action.center-visible-columns = {};

        "Mod+Minus".action.set-column-width = "-10%";
        "Mod+Equal".action.set-column-width = "+10%";

        "Mod+Shift+Minus".action.set-window-height = "-10%";
        "Mod+Shift+Equal".action.set-window-height = "+10%";

        "Mod+V".action.toggle-window-floating = {};
        "Mod+Shift+V".action.switch-focus-between-floating-and-tiling = {};

        "Mod+W".action.toggle-column-tabbed-display = {};

        "Mod+Escape" = {
          allow-inhibiting = false;
          action.toggle-keyboard-shortcuts-inhibit = {};
        };
        "Ctrl+Alt+Delete".action.quit = {};
      };
    };
  };
}
