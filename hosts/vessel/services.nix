{pkgs, ...}: {
  services = {
    printing.enable = true;
    gvfs.enable = true;
    udisks2.enable = true;
    btrfs.autoScrub.enable = true;
    gnome.gnome-keyring.enable = true;
    blueman.enable = true;

    udev = {
      enable = true;
      packages = with pkgs; [
        android-udev-rules
        edl
      ];
    };

    dbus = {
      enable = true;
      packages = with pkgs; [
        dconf
        gcr
      ];
    };
  };

  systemd.services = {
    fstrim = {
      unitConfig.ConditionACPower = true;
      serviceConfig = {
        Nice = 19;
        IOSchedulingClass = "idle";
      };
    };
  };
  /*
    ____          _                    __  __           _       _
   / ___|   _ ___| |_ ___  _ __ ___   |  \/  | ___   __| |_   _| | ___  ___
  | |  | | | / __| __/ _ \| '_ ` _ \  | |\/| |/ _ \ / _` | | | | |/ _ \/ __|
  | |__| |_| \__ \ || (_) | | | | | | | |  | | (_) | (_| | |_| | |  __/\__ \
   \____\__,_|___/\__\___/|_| |_| |_| |_|  |_|\___/ \__,_|\__,_|_|\___||___/
  */
  nyu.services = {
  };
}
