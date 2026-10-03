{
  services = {
    btrfs.autoScrub.enable = true;
    udev.enable = true;

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
