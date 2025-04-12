{
  packages,
  ...
}: {
  services.libinput = {
    enable = true;

    mouse = {
      accelProfile = "flat";
      accelSpeed = "0";
      middleEmulation = false;
    };

    touchpad = {
      naturalScrolling = true;
      tapping = true;
      clickMethod = "clickfinger";
      disableWhileTyping = false;
    };
  };

#TODO: move keymappings here,
# I tried actkbd but it didnt work well

}
