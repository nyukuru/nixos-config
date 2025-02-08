{
  options,
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib.options) mkOption mkEnableOption mkPackageOption;
  inherit (lib.modules) mkIf mkMerge mkDefault mkForce;
  inherit (lib.strings) readFile;
  inherit (lib.types) package lines listOf;
  inherit (lib.lists) optional mutuallyInclusive;
  inherit (lib.meta) getExe getExe';

  cfg = config.modules.system.display.wm.sway;
in {
  options.modules.system.display.wm.sway = {
    enable = mkEnableOption "Sway window manager.";

    package =
      mkPackageOption pkgs "sway" {}
      // {
        apply = p:
          p.override {
            extraSessionCommands = cfg.extraSessionCommands;
            extraOptions =
              ["--config" "${pkgs.writeText "sway-config" cfg.config}"]
              ++ optional (mutuallyInclusive ["nvidia" "hybrid-nvidia"] config.modules.system.hardware.gpu.type)
              "--unsupported-gpu";
            withBaseWrapper = true;
            withGtkWrapper = true;
            enableXWayland = cfg.xwayland.enable;
            isNixOS = true;
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
        export SDL_VIDEODRIVER=wayland
        export CLUTTER_BACKEND=wayland

        export WLR_BACKEND=wayland
        export WLR_RENDERER=vulkan
        export WLR_NO_HARDWARE_CURSORS=1
      '';
      description = ''
        Shell commands executed just before Sway is started.
      '';
    };

    # TODO run a system check with 'sway -C'
    config = mkOption {
      type = lines;
      default = readFile "${cfg.package}/etc/sway/config";
      description = ''
        What to be loaded as sway's config file.
      '';
    };

    xwayland = {
      enable = mkEnableOption "XWayland" // {default = true;};
    };

    extraPackages = mkOption {
      type = listOf package;
      default = with pkgs; [
        swaylock
        swayidle
        foot
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

  config = mkMerge [
    {programs.sway.enable = mkForce false;}

    (mkIf cfg.enable {
      # https://github.com/emersion/slurp?tab=readme-ov-file#example-usage
      xdg.portal.wlr.settings.screencast.chooser_cmd = mkDefault ''
        ${getExe' cfg.package "swaymsg"} -t get_tree | \
        ${getExe pkgs.jq} '.. | select(.pid? and .visible?) | .rect | "\(.x),\(.y) \(.width)x\(.height)"' | \
        ${getExe pkgs.slurp}'';

      environment = {
        systemPackages = [cfg.package] ++ cfg.extraPackages;

        etc = {
          "sway/config.d/nixos.conf".source = pkgs.writeText "nixos.conf" ''
            exec dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY SWAYSOCK XDG_CURRENT_DESKTOP
          '';
        };
      };
    })
  ];
}
