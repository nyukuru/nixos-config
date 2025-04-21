{pkgs, ...}: {
  services = {
    printing = {
      enable = true;
    };

    dbus = {
      enable = true;
      packages = [
        pkgs.dconf
        pkgs.gcr
      ];
    };

    btrfs.autoScrub = {
      enable = true;
    };

    gnome.gnome-keyring.enable = true;
    blueman.enable = true;

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
