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
  nyu.boot.greetd.autologin = {
    enable = true;
    user = "nyu";
    command = let
      session = lib.getExe config.nyu.programs.sway.package;
      sessionWrapper = "${lib.getExe config.programs.uwsm.package} start -S -F";
    in "${sessionWrapper} ${session} >/dev/null";
  };
}
