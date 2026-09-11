{
  services = {
    btrfs.autoScrub.enable = true;
    udev.enable = true;
  };

  services.pipewire.wireplumber.extraConfig = {
    "10-alsa" = {
      "monitor.alsa.rules" = [
        {
          matches = [
            {
              # Dell XPS 15 mic
              "node.name" = "alsa_input.pci-0000_00_1f.3.analog-stereo";
            }
          ];
          actions = {
            update-props = {
              "node.disabled" = true;
            };
          };
        }
      ];
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
