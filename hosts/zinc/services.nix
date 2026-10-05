{
  pkgs,
  lib,
  ...
}: {
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
  nyu.services.noctalia.settings.idle = {
    behavior_order = ["dim" "suspend"];
    behavior = {
      dim = {
        timeout = 300;
        action = "command";
        command = "${lib.getExe pkgs.brightnessctl} -s set 10%";
        resume_command = "${lib.getExe pkgs.brightnessctl} -r";
      };
      suspend = {
        timeout = 600;
        action = "command";
        command = "systemctl suspend-then-hibernate";
      };
    };
  };
}
