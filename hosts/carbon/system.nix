{
  config,
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
    hardware = {
      bluetooth.enable = true;
      tpm.enable = true;
    };

    boot.greetd = {
      greeter = null;
      autologin = {
        enable = true;
        user = "nixos";
        command = let
          session = lib.getExe config.programs.niri.package;
          sessionWrapper = "${lib.getExe config.programs.uwsm.package} start";
        in "${sessionWrapper} ${session} >/dev/null";
      };
    };

    programs.niri.skipHotkeyOverlayAtStartup = false;
  };
}
