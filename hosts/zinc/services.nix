{
  services = {
    btrfs.autoScrub.enable = true;
    udev = {
      enable = true;
      # BFQ keeps the desktop responsive on the rotational root disk
      extraRules = ''
        ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="1", ATTR{queue/scheduler}="bfq"
      '';
    };

    # Keep Bluetooth pairings in sync with the Windows install
    bluesetta = {
      enable = true;
      hivePath = "/mnt/windows/Windows/System32/config/SYSTEM";
      createOnWindows = true;
    };

    # RGB for the Corsair Lighting Nodes and the motherboard ITE controller
    hardware.openrgb = {
      enable = true;
      motherboard = "amd";
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
    swayidle = {
      enable = true;
      timeouts = [{
        timeout = 300;
        command = "brightnessctl -s set 10%";
        resumeCommand = "brightnessctl -r";
      }
      {
        timeout = 600;
        command = "systemctl suspend-then-hibernate";
      }];
    };
  };
}
