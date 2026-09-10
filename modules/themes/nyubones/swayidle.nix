{...}: {
  nyu.services.swayidle = {
    enable = true;

    waitForCommand = true;
    lock = "pidof swaylock || swaylock";
    beforeSleep = "swaylock";
    afterResume = "niri msg action power-on-monitors";

    timeouts = [
      {
        timeout = 100;
        command = "brightnessctl -s set 10%";
        resumeCommand = "brightnessctl -r";
      }
      {
        timeout = 200;
        command = "swaylock";
      }
      {
        timeout = 220;
        command = "niri msg action power-off-monitors";
        resumeCommand = "niri msg action power-on-monitors";
      }
    ];
  };
}
