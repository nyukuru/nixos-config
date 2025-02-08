{
  config,
  lib,
  ...
}: let
  inherit (lib.options) mkEnableOption;
  inherit (lib.modules) mkIf;

  cfg = config.modules.system.boot;
in {
  imports = [
    # Options and config for bootloaders
    ./loaders.nix
    # Plymouth options and config
    ./plymouth.nix
    # Options and config to enable secureboot
    ./secure-boot.nix
    # Options and config for greetd login manager
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
