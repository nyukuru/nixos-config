{
  imports = [
    ./power
    ./input

    ./packages.nix
  ];

  nyu.programs.swaylock.enable = true;
  nyu.services.swayidle.enable = true;

  # Only run the scheduled trim while plugged in, to save battery.
  systemd.services.fstrim = {
    unitConfig.ConditionACPower = true;
    serviceConfig = {
      Nice = 19;
      IOSchedulingClass = "idle";
    };
  };
}
