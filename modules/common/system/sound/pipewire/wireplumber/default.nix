{lib, ...}: let
  inherit (lib.modules) mkDefaultAttr;
in {
  # Reminder to self, bluetooth properties set in bluetooth module
  # https://pipewire.pages.freedesktop.org/wireplumber/daemon/configuration.html
  services.pipewire.wireplumber.extraConfig = {
    "10-default" = mkDefaultAttr {
      "wireplumber.settings" = {
        "device.routes.default-sink-volume" = 1.0;
      };
    };
  };
}
