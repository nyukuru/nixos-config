{
  config,
  pkgs,
  lib,
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

  # Permission for media drive
  users.extraGroups.media = {};

  /*
  virtualisation = {
    waydroid.enable = true;
  };

  systemd.tmpfiles.rules = let 
    # https://wiki.nixos.org/wiki/Waydroid
    waydroid_base = ''
      sys.use_memfd=true
    '';
      # Extra settings needed for nvidia gpu rendering
      # kept disabled until I need to use dgpu rather than igpu
      #ro.hardware.gralloc=default
      #ro.hardware.egl=swiftshader

  in [
    "w+ /var/lib/waydroid/waydroid_base.prop  - - - -  ${waydroid_base}"
  ];

  /*
    ____          _                    __  __           _       _
   / ___|   _ ___| |_ ___  _ __ ___   |  \/  | ___   __| |_   _| | ___  ___
  | |  | | | / __| __/ _ \| '_ ` _ \  | |\/| |/ _ \ / _` | | | | |/ _ \/ __|
  | |__| |_| \__ \ || (_) | | | | | | | |  | | (_) | (_| | |_| | |  __/\__ \
   \____\__,_|___/\__\___/|_| |_| |_| |_|  |_|\___/ \__,_|\__,_|_|\___||___/
  */
  nyu = {
    /*
     _  _             _
    | || |__ _ _ _ __| |_ __ ____ _ _ _ ___
    | __ / _` | '_/ _` \ V  V / _` | '_/ -_)
    |_||_\__,_|_| \__,_|\_/\_/\__,_|_| \___|
    */
    hardware = {
      cpu = "intel";
      igpu = "intel";
      dgpu = "nvidia";

      tpm.enable = true;
      bluetooth.enable = true;

      yubikey = {
        enable = true;
        cliTools.enable = true;
        guiTools.enable = true;
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
        enable = false;
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
        themePackage = pkgs.plymouth-hellonavi-theme;
        theme = "hellonavi";
      };

      greetd = {
        enable = true;
        autologin = {
          enable = true;
          user = "nyu";
          command = let
            session = lib.getExe config.nyu.programs.sway.package;
            sessionWrapper = "${lib.getExe config.programs.uwsm.package} start -S -F";
          in "${sessionWrapper} ${session} >/dev/null";
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

      realtime = {
        enable = false;
        soundcardPci = "0000:00:1f.3";
      };
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
    __   ___     _             _ _         _   _          
    \ \ / (_)_ _| |_ _  _ __ _| (_)_____ _| |_(_)___ _ _  
     \ V /| | '_|  _| || / _` | | |_ / _` |  _| / _ \ ' \ 
      \_/ |_|_|  \__|\_,_\__,_|_|_/__\__,_|\__|_\___/_||_|
    */
    /*
    virtualization = {
      wfvm.enable = true;
    };
    */
  };
}
