{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit
    (lib.modules)
    mkDefault
    mkForce
    mkIf
    ;

  isPipe = (config.nyu.sound.server == "pipewire") && config.nyu.sound.enable;
in {
  config = mkIf isPipe {
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

    environment.systemPackages = [
      pkgs.pulseaudio
    ];
  };
}
