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
    (lib.modules)
    mkIf
    ;

  cfg = config.modules.system.boot;

in {
  imports = [
    ./loaders.nix
    ./plymouth.nix
    ./secure-boot.nix
    ./greetd.nix
  ];

  options.modules.system.boot = {
    silent = {
      enable = mkEnableOption "Silent boot." // {default = true;};
    };
  };

  config.boot = {
    kernelParams = mkIf cfg.silent.enable [
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
