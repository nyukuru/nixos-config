{
  packages,
  ...
}: {
  boot = {
    extraModprobeConfig = ''
      options iwlwifi power_save=1 disable_11ax=1
    '';

    # From generated hardware-config
    initrd.availableKernelModules = [
      "xhci_pci"
      "thunderbolt"
      "vmd"
      "nvme"
      "usb_storage"
      "sd_mod"
      "rtsx_pci_sdmmc"
    ];
  };

  modules.system = {
    /*
     _  _             _
    | || |__ _ _ _ __| |_ __ ____ _ _ _ ___
    | __ / _` | '_/ _` \ V  V / _` | '_/ -_)
    |_||_\__,_|_| \__,_|\_/\_/\__,_|_| \___|
    */
    hardware = {
      cpu.type = "intel";
      gpu.type = ["intel" "hybrid-nvidia"];

      tpm.enable = true;
      bluetooth.enable = true;

      yubikey = {
        # Currently fails due to broken dep chain
        #enable = true;
        cliTools.enable = true;
      };
    };
    /*
     _  _     _                  _   _
    | \| |___| |___ __ _____ _ _| |_(_)_ _  __ _
    | .` / -_)  _\ V  V / _ \ '_| / / | ' \/ _` |
    |_|\_\___|\__|\_/\_/\___/_| |_\_\_|_||_\__, |
                                            |___/
    */
    networking = {
      enable = true;

      ssh = {
        enable = true;
        port = 30;

        tarpit = {
          enable = true;
          port = 22;
        };
      };

      firewall = {
        enable = true;
      };
    };
    /*
     ___           _
    | _ ) ___  ___| |_
    | _ \/ _ \/ _ \  _|
    |___/\___/\___/\__|
    */
    boot = {
      silent.enable = true;
      secureBoot.enable = true;

      plymouth = {
        enable = true;
        themePackage = packages.plymouth-hellonavi-theme;
        theme = "hellonavi";
      };

      greetd = {
        enable = true;
        autologin = {
          enable = true;
          user = "nyoo";
        };
      };
    };
    /*
     ___                   _
    / __| ___ _  _ _ _  __| |
    \__ \/ _ \ || | ' \/ _` |
    |___/\___/\_,_|_||_\__,_|
    */
    sound = {
      enable = true;

    /*
      realtime = {
        enable = true;
        soundcardPci = "0000:00:1f.3";
      };
    */
    };
    /*
     ___                       _   _
    | __|_ _  __ _ _ _  _ _ __| |_(_)___ _ _
    | _|| ' \/ _| '_| || | '_ \  _| / _ \ ' \
    |___|_||_\__|_|  \_, | .__/\__|_\___/_||_|
                     |__/|_|
    */
    encryption = {
      enable = true;

      devices.crypted-1 = {
        keyFile = {
          enable = true;
          rdKey = true;
          file = "/persist/secrets/luks.key";
        };
      };

      devices.crypted-2 = {
        keyFile = {
          enable = true;
          rdKey = true;
          file = "/persist/secrets/luks.key";
        };
      };
    };
    /*
     ___ _ _                _
    | __(_) |___ ____  _ __| |_ ___ _ __
    | _|| | / -_|_-< || (_-<  _/ -_) '  \
    |_| |_|_\___/__/\_, /__/\__\___|_|_|_|
                    |__/
    */
    filesystem = {
      enabledFilesystems = ["vfat" "btrfs"];
    };
    /*
     ___  _         _
    |   \(_)____ __| |__ _ _  _
    | |) | (_-< '_ \ / _` | || |
    |___/|_/__/ .__/_\__,_|\_, |
              |_|          |__/
    */
    display = {
      wm = {
        default = "sway";
        sway.enable = true;
      };
    };
  };
}
