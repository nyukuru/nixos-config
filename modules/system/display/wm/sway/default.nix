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
    isString
    isAttrs
    toJSON
    ;

  inherit
    (lib.types)
    package
    attrsOf
    listOf
    nullOr
    oneOf
    lines
    bool
    path
    int
    str
    ;

  inherit
    (lib.lists)
    mutuallyInclusive
    optional
    ;

  inherit
    (lib.meta)
    getExe'
    getExe
    ;

  swayConf = {
    type = let
      valueType = nullOr (oneOf [
        bool
	int
	str
	path
	(attrsOf valueType)
      ]) // {
        description = "Sway config value";
      };
    in valueType;

    generate = let
      attrToConfig = concatMapAttrsStringSep "\n" (
        n: v: 
	  if isAttrs v then
	    "${n} {\n${attrToConfig v}\n}"
	  else if isString v then
	    "${n} ${v}"
	  else
	    "${n} ${toJSON v}"
      );
      
    in name: value: pkgs.writeText name (attrToConfig value);
  };

  cfg = config.modules.system.display.wm.sway;
  gpu = config.modules.system.hardware.gpu.type;
in {
  imports = [
    ../wayland.nix
  ];

  options.modules.system.display.wm.sway = {
    enable = mkEnableOption "Sway window manager.";

    package =
      mkPackageOption pkgs "sway" {}
      // {
        apply = p:
          p.override {
            extraSessionCommands = cfg.extraSessionCommands;
            withBaseWrapper = true;
            withGtkWrapper = true;
            enableXWayland = cfg.xwayland.enable;
            isNixOS = true;
            extraOptions = [
                "--config"
                "${swayConf.generate "sway.conf" cfg.settings}"
              ]
              ++ optional (mutuallyInclusive ["nvidia" "hybrid-nvidia"] gpu)
              "--unsupported-gpu";
          };
      };

    extraSessionCommands = mkOption {
      type = lines;
      default = ''
        export XDG_SESSION_DESKTOP=sway
        export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
        export _JAVA_AWT_WM_NONREPARENTING=1
        export NIXOS_OZONE_WL=1
        export GDK_BACKEND=wayland,x11
        export ANKI_WAYLAND=1
        export MOZ_ENABLE_WAYLAND=1
        export XDG_SESSION_TYPE=wayland
        export SDL_VIDEODRIVER=wayland, x11
        export CLUTTER_BACKEND=wayland

        export WLR_BACKEND=wayland
        export WLR_RENDERER=vulkan
        export WLR_NO_HARDWARE_CURSORS=1
      '';
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

    extraPackages = mkOption {
      type = listOf package;
      default = with pkgs; [
        swaylock
        swayidle
        dmenu
        wmenu
        brightnessctl
        wl-clipboard
        grim
        slurp
        mako
      ];
    };
  };

  config = mkIf cfg.enable {
    programs.sway.enable = mkForce false;

    programs.foot.enable = true;

    modules.system.display.wm.sway.settings = {
      input = {
	"type:touchpad" = {
	  dwt = "disabled";
	  tap = "enabled";
	};
      };

      bindsym = {
	"Mod4+Return" = "exec foot";
	"Mod4+f" = "exec firefox";

	"Mod4+d" = "exec dmenu_path | wmenu | xargs swaymsg exec --";
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

      bar = {
	position = "top";
      };
    };

    environment.systemPackages =
      [cfg.package]
      ++ cfg.extraPackages
      ++ optional cfg.xwayland.enable pkgs.xwayland;

    environment.etc = {
      "sway/config.d/nixos.conf".source = pkgs.writeText "nixos.conf" ''
        exec dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY SWAYSOCK XDG_CURRENT_DESKTOP
      '';
    };

    # https://github.com/emersion/slurp?tab=readme-ov-file#example-usage
    xdg.portal.wlr.settings.screencast.chooser_cmd = ''
      ${getExe' cfg.package "swaymsg"} -t get_tree | \
      ${getExe pkgs.jq} '.. | select(.pid? and .visible?) | .rect | "\(.x),\(.y) \(.width)x\(.height)"' | \
      ${getExe pkgs.slurp}'';
  };
}
