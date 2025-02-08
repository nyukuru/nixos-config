{
  options,
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib.options) mkOption mkEnableOption mkPackageOption;
  inherit (lib.modules) mkIf mkMerge mkDefault mkDefaultAttr mkOptionDefault;
  inherit (lib.types) nullOr bool str package either;
  inherit (lib.attrsets) attrNames filterAttrs;
  inherit (lib.lists) mutuallyInclusive optional length head elem;
  inherit (lib.meta) getExe;

  enabledWms = attrNames 
    (filterAttrs (_: v: v.enable or false && v ? package) 
      (removeAttrs cfg.wm ["default"]));

  cfg = config.modules.system.display;
in {
  imports = [
    # Import specific wrapper stuff for implemented wms.
    ./wm
  ];

  options.modules.system.display = {
    wm.default = mkOption {
      type = nullOr str;
      default = if ((length enabledWms) > 0)
	then (head enabledWms)
        else null;
      apply = w: if (elem w enabledWms)
      	then cfg.wm.${w}.package
	else null;
      description = ''
        Determines some default behaviors such as what to boot into.
      '';
    };

    isWayland = mkOption {
      type = bool;
      # (non-exhaustive)
      # TODO: find better solution
      # move this to inside the wm
      default = mutuallyInclusive enabledWms ["hyprland" "sway" "river"];
      readOnly = true;
      description = ''
        Whether to enable wayland only packages, environment variables,
        modules, overlays. Also disables all X exclusive packages, variables,
        modules, etc.
      '';
    };
  };

  config = mkIf config.hardware.graphics.enable (mkMerge [{
    warnings = optional ((length enabledWms) > 1) ''
      You have more then one window manager enabled, this may break
      functionality if you have not ensured options handle this correctly.
    '' ++ optional (cfg.wm.default == null) ''
      Default WM is null, you may not boot
      into a graphical environment.
    '';
  }
  # TODO instead of making these system wide I need to apply a wrapper around each wm 
  # so that it doesn't fuck up wayland and x11 bastard children configs
  (mkIf cfg.isWayland {
    security = {
      polkit.enable = mkDefault true;
      pam.services.swaylock = {};
    };

    programs = {
      dconf.enable = mkDefault true;
      xwayland.enable = mkDefault true;
    };

    services = {
      seatd = {
        enable = mkDefault true;
	group = "wheel";
      };
    };

    xdg.portal = {
      enable = true;
      extraPortals = with pkgs; [xdg-desktop-portal-gtk];

      config = {
        common = let
	  portal = if (cfg.wm.hyprland.enable or false)
	    then "hyprland"
	    else "wlr";
	in {
	  default = ["gtk"];
	  "org.freedesktop.impl.portal.Screencast" = ["${portal}"];
	  "org.freedesktop.impl.portal.Screenshot" = ["${portal}"];
	  "org.freedesktop.impl.portal.Inhibit" = "none";
	};
      };

      wlr = {
        enable = true;

	settings = {
	  screencast = {
	    max_fps = 30;
	    chooser_type = "simple";
	    chooser_cmd = mkOptionDefault ("${getExe pkgs.slurp} -orf %o");
	  };
	};
      };
    };
  })]);
}
