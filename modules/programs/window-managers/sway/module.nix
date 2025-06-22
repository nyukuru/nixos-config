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
    concatMapAttrsStringSep
    concatStringsSep
    isString
    isAttrs
    isList
    toJSON
    ;

  inherit
    (lib.types)
    attrsOf
    listOf
    nullOr
    oneOf
    bool
    path
    int
    str
    ;

  inherit
    (lib.lists)
    optional
    ;

  inherit
    (lib.meta)
    getExe'
    getExe
    ;

  swayConf = {
    type = let
      valueType =
        nullOr (oneOf [
          bool
          int
          str
          path
          (attrsOf valueType)
          (listOf valueType)
        ])
        // {
          description = "Sway config value";
        };
    in
      valueType;

    generate = let
      listToConfig = concatStringsSep "\n";
      attrToConfig = concatMapAttrsStringSep "\n" (
        n: v:
          if isAttrs v
          then "${n} {\n${attrToConfig v}\n}"
          else if isList v
          then "${n} {\n${listToConfig v}\n}"
          else if isString v
          then "${n} ${v}"
          else "${n} ${toJSON v}"
      );
    in
      name: value: pkgs.writeText name (attrToConfig value);
  };

  cfg = config.nyu.programs.sway;
in {
  imports = [
    ../wayland-shared.nix
  ];

  options.nyu.programs.sway = {
    enable = mkEnableOption "Sway window manager.";

    package =
      mkPackageOption pkgs "sway" {}
      // {
        apply = p:
          p.override {
            isNixOS = true;
            withGtkWrapper = true;
            withBaseWrapper = true;
            enableXWayland = cfg.xwayland.enable;
            extraOptions = ["--unsupported-gpu"];
            extraSessionCommands = ''
              export XDG_SESSION_DESKTOP=sway
              export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
              export _JAVA_AWT_WM_NONREPARENTING=1
              export NIXOS_OZONE_WL=1
              export GDK_BACKEND=wayland,x11
              export ANKI_WAYLAND=1
              export MOZ_ENABLE_WAYLAND=1
              export XDG_SESSION_TYPE=wayland
              export SDL_VIDEODRIVER=wayland
              export CLUTTER_BACKEND=wayland

              export WLR_BACKEND=wayland
              export WLR_NO_HARDWARE_CURSORS=1
            '' + cfg.extraSessionCommands;
          };
      };

    extraSessionCommands = mkOption {
      type = str;
      default = "";
      description = ''
        Shell commands executed just before Sway is started.
      '';
    };

    settings = mkOption {
      type = swayConf.type;
      default = {};
      description = "Sway Config content";
    };

    xwayland = {
      enable = mkEnableOption "XWayland" // {default = true;};
    };
  };

  config = mkIf cfg.enable {
    programs = {
      sway.enable = mkForce false;
      uwsm.waylandCompositors.sway = {
        prettyName = "Sway";
        comment = "Sway compositor managed by UWSM";
        binPath = getExe cfg.package;
      };
    };

    environment = {
      systemPackages =
        [cfg.package]
        ++ optional cfg.xwayland.enable pkgs.xwayland;

      etc."sway/config".source = swayConf.generate "sway.conf" cfg.settings;
    };

    # https://github.com/emersion/slurp?tab=readme-ov-file#example-usage
    xdg.portal.wlr.settings.screencast.chooser_cmd = let
      jqArgs = '''.. | select(.pid? and .visible?) | "\(.rect.x+.window_rect.x),\(.rect.y+.window_rect.y) \(.window_rect.width)x\(.window_rect.height)"''\''';
    in
      "${getExe' cfg.package "swaymsg"} -t get_tree | ${getExe pkgs.jq} -r ${jqArgs} | ${getExe pkgs.slurp}";
      #"${getExe pkgs.slurp}";

    # The default config settings
    nyu.programs.sway.settings = {
      input = {
        "type:touchpad" = {
          dwt = "disabled";
          tap = "enabled";
        };
      };

      exec = [
        # Import important environment variables into D-Bus and systemd
        "dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY SWAYSOCK XDG_CURRENT_DESKTOP"
        "\"systemctl --user import-environment {,WAYLAND_}DISPLAY SWAYSOCK; systemctl --user start sway-session.target\""
        "swaymsg -t subscribe '[\"shutdown\"]' && systemctl --user stop sway-session.target"
      ];

      bindsym = {
        # Brightness Bindings
        "XF86MonBrightnessDown" = "exec ${pkgs.scripts.brightness} 2%-";
        "XF86MonBrightnessUp" = "exec ${pkgs.scripts.brightness} 2%+";
        "Shift+XF86MonBrightnessDown" = "exec ${pkgs.scripts.brightness} 20%-";
        "Shift+XF86MonBrightnessUp" = "exec ${pkgs.scripts.brightness} 20%+";

        # Output audio control
        "XF86AudioRaiseVolume" = "exec ${pkgs.scripts.volume} set-volume @DEFAULT_SINK@ 1%+";
        "XF86AudioLowerVolume" = "exec ${pkgs.scripts.volume} set-volume @DEFAULT_SINK@ 1%-";
        "XF86AudioMute" = "exec ${pkgs.scripts.volume} set-mute @DEFAULT_SINK@ toggle";

        # Input audio control
        "Alt+XF86AudioRaiseVolume" = "exec ${pkgs.scripts.volume} set-volume @DEFAULT_SOURCE@ 1%+";
        "Alt+XF86AudioLowerVolume" = "exec ${pkgs.scripts.volume} set-volume @DEFAULT_SOURCE@ 1%-";
        "Alt+XF86AudioMute" = "exec ${pkgs.scripts.volume} set-mute @DEFAULT_SOURCE@ toggle";

        "Print" = "exec ${getExe pkgs.sway-contrib.grimshot} --notify savecopy output /media/images/screenshots/$(date '+%Y-%m-%d:%H-%M-%S').png";
        "Alt+Print" = "exec ${getExe pkgs.sway-contrib.grimshot} --notify savecopy anything /media/images/screenshots/$(date '+%Y-%m-%d:%H-%M-%S').png";

        "Mod4+Return" = "exec ${getExe pkgs.foot}";
        "Mod4+f" = "exec firefox";

        "Mod4+Space" = "floating toggle";

        "Mod4+d" = "exec ${getExe' pkgs.dmenu "dmenu_path"} | ${getExe pkgs.wmenu} | xargs swaymsg exec --";
        "Mod4+q" = "kill";

        "Mod4+h" = "focus left";
        "Mod4+j" = "focus down";
        "Mod4+k" = "focus up";
        "Mod4+l" = "focus right";

        "Mod4+Shift+h" = "move left";
        "Mod4+Shift+j" = "move down";
        "Mod4+Shift+k" = "move up";
        "Mod4+Shift+l" = "move right";

        "Mod4+1" = "workspace number 1";
        "Mod4+2" = "workspace number 2";
        "Mod4+3" = "workspace number 3";
        "Mod4+4" = "workspace number 4";
        "Mod4+5" = "workspace number 5";

        "Mod4+Shift+1" = "move container to workspace number 1";
        "Mod4+Shift+2" = "move container to workspace number 2";
        "Mod4+Shift+3" = "move container to workspace number 3";
        "Mod4+Shift+4" = "move container to workspace number 4";
        "Mod4+Shift+5" = "move container to workspace number 5";

        "Mod4+r" = "mode \"resize\"";
      };

      mode = {
        "\"resize\"" = {
          bindsym = {
            "h" = "resize shrink width 10px";
            "j" = "resize grow height 10px";
            "k" = "resize shrink height 10px";
            "l" = "resize grow width 10px";

            "Return" = "mode \"default\"";
            "Escape" = "mode \"default\"";
          };
        };
      };
    };
  };
}
