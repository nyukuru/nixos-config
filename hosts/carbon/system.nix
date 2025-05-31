{
  packages,
  config,
  pkgs,
  lib,
  ...
}: {
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
      yubikey = {
        enable = true;
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
    sound.enable = true;
  };
}
