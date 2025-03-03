{
  config,
  lib,
  ...
}: let

  inherit
    (lib.modules)
    mkForce
    mkIf
    ;

  isPulse = (config.nyu.sound.server == "pulseaudio") && config.nyu.sound.enable;

  in {
    config = mkIf isPulse {
      hardware.pulseaudio.enable = mkForce true;
    };
  }
