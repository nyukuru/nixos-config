{pkgs, ...}: {
  nyu.programs = {
    fuzzel.enable = true;

    firefox = {
      enable = true;

      # Host configs still layer on their own extensions; this always
      # applies regardless of what a host adds.
      extensions = [
        {
          shortID = "ublock-origin";
          addonID = "uBlock0@raymondhill.net";
        }
      ];
    };
  };

  nyu.services.wayle.enable = true;

  nyu.boot = {
    silent.enable = true;
    plymouth.enable = true;
  };

  programs = {
    foot.enable = true;
    thunar.enable = true;
    dconf.enable = true;

    obs-studio = {
      enable = true;
      plugins = with pkgs.obs-studio-plugins; [
        wlrobs
        obs-pipewire-audio-capture
      ];
    };
  };

  # gnome-keyring's own module already registers itself (and gcr) with
  # dbus; dconf.enable above does the same for dconf - no manual
  # services.dbus.packages needed.
  services = {
    dunst.enable = true;
    printing.enable = true;
    gvfs.enable = true;
    udisks2.enable = true;
    gnome.gnome-keyring.enable = true;
  };
}
