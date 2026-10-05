{
  pkgs,
  lib,
  ...
}: let
  brightnessctl = lib.getExe pkgs.brightnessctl;
in {
  imports = [
    ./power
    ./input

    ./packages.nix
  ];

  nyu.services.noctalia.settings = {
    bar.main.end = lib.mkAfter ["battery"];

    idle = {
      behavior_order = ["dim" "lock" "suspend"];
      behavior = {
        dim = {
          timeout = 100;
          action = "command";
          command = "${brightnessctl} -s set 10%";
          resume_command = "${brightnessctl} -r";
        };
        lock = {
          timeout = 200;
          action = "lock";
        };
        suspend = {
          timeout = 230;
          action = "command";
          command = "systemctl suspend-then-hibernate";
        };
      };
    };
  };

  # Only run the scheduled trim while plugged in, to save battery.
  systemd.services.fstrim = {
    unitConfig.ConditionACPower = true;
    serviceConfig = {
      Nice = 19;
      IOSchedulingClass = "idle";
    };
  };
}
