{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib.options) mkEnableOption;
  inherit (lib.modules) mkDefault mkForce mkIf;

  cfg = config.nyu.sound;
in {
  options.nyu.sound = {
    enable = mkEnableOption "Sound capabilities." // {default = true;};
  };

  config = mkIf cfg.enable {
    security.rtkit.enable = mkForce true;

    services.pipewire = {
      enable = mkForce true;
      audio.enable = mkDefault true;
      pulse.enable = mkDefault true;
      alsa.enable = mkDefault true;
      wireplumber = {
        enable = mkDefault true;
        extraConfig = {
          "10-defaults" = {
            "wireplumber.settings" = {
              "bluetooth.autoswitch-to-headset-profile" = false;
              "device.routes.default-sink-volume" = 1.0;
            };
          };
        };
      };
    };

    systemd.user.services = {
      pipewire.wantedBy = ["default.target"];
      pipewire-pulse.wantedBy = ["default.target"];
    };

    environment.systemPackages = [
      pkgs.pulseaudio
    ];
  };
}
