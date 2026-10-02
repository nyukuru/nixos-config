{pkgs, ...}: {
  services.dbus.packages = [pkgs.fprintd];
  environment.systemPackages = [pkgs.fprintd];
  systemd.packages = [pkgs.fprintd];

  security.pam.services.login.fprintAuth = true;

  services.libinput = {
    enable = true;

    mouse = {
      accelProfile = "flat";
      accelSpeed = "0";
      middleEmulation = false;
    };

    touchpad = {
      naturalScrolling = false;
      tapping = true;
      clickMethod = "clickfinger";
      disableWhileTyping = false;
    };
  };
}
