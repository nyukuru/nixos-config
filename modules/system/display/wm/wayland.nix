{
  pkgs,
  lib,
  ...
}: let
  inherit
    (lib.modules)
    mkDefault
    ;

  inherit
    (lib.meta)
    getExe
    ;

in {
  security = {
    polkit.enable = mkDefault true;
    pam.services.swaylock = {};
  };

  programs = {
    dconf.enable = mkDefault true;
  };

  services = {
    seatd = {
      enable = mkDefault true;
      group = "wheel";
    };
  };

  environment.systemPackages = [
    pkgs.wl-clipboard
    pkgs.grim
    pkgs.mako
  ];

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [xdg-desktop-portal-gtk];

    config.common = {
      default = ["gtk"];
      "org.freedesktop.impl.portal.Screencast" = "wlr";
      "org.freedesktop.impl.portal.Screenshot" = "wlr";
      "org.freedesktop.impl.portal.Inhibit" = "none";
    };

    wlr = {
      enable = true;
      /*
      settings.screencast = {
        max_fps = 30;
        chooser_type = "simple";
        chooser_cmd = mkDefault "${getExe pkgs.slurp} -orf %o";
      };
      */
    };
  };
}
