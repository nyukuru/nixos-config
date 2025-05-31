{
  config,
  lib,
  ...
}: let
  inherit
    (lib.options)
    mkEnableOption
    ;

  inherit
    (lib.lists)
    optionals
    ;

  cfg = config.nyu.boot;
in {
  imports = [
    ./loaders.nix
    ./plymouth.nix
    ./secure-boot.nix
    ./greetd.nix
  ];

  options.nyu.boot = {
    silent.enable = mkEnableOption "Silent boot";
  };

  config.boot = {
    kernelParams = optionals cfg.silent.enable [
      "quiet"

      # Errors or worse
      "loglevel=3"
      "udev.log_level=3"
      "rd.udev.log_level=3"

      # Disable systemd messaging
      "systemd.show_status=false"
      "rd.systemd.show_status=false"
    ];
  };
}
