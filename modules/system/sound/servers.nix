{
  config,
  lib,
  ...
}: let
  inherit (lib.options) mkOption;
  inherit (lib.modules) mkIf mkMerge mkForce mkDefault;
  inherit (lib.types) enum;

  cfg = config.modules.system.sound.server;
in {
  options.modules.system.sound.server = {
    type = mkOption {
      type = enum ["pulseaudio" "pipewire"];
      default = "pipewire";
      description = ''
               Determines your sound server. Pipewire is the newer and more sane option.
        Pulseaudio should only be chosen if forced by hardware compatability.
      '';
    };
  };

  config = mkIf config.modules.system.sound.enable (mkMerge [
    (mkIf (cfg.type == "pipewire") {
      security.rtkit.enable = mkForce true;

      services.pipewire = {
        enable = mkForce true;
        audio.enable = mkDefault true;
        pulse.enable = mkDefault true;
        alsa.enable = mkDefault true;
        wireplumber.enable = mkDefault true;
      };

      systemd.user.services = {
        pipewire.wantedBy = ["default.target"];
        pipewire-pulse.wantedBy = ["default.target"];
      };
    })

    (mkIf (cfg.type == "pulseaudio") {
      hardware.pulseaudio.enable = mkForce true;
    })
  ]);
}
