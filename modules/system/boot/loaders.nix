{
  config,
  lib,
  ...
}: let
  inherit
    (lib.options)
    mkEnableOption
    mkOption
    ;

  inherit
    (lib.modules)
    mkDefault
    ;

  inherit
    (lib.types)
    enum
    ;

  loaders = {
    grub = {
      enable = true;
      useOSProber = mkDefault true;
      efiSupport = mkDefault true;
      device = mkDefault "nodev";
      inherit (cfg) memtest86;
    };

    systemd-boot = {
      enable = true;
      consoleMode = mkDefault "max";
      editor = mkDefault false;
      inherit (cfg) memtest86;
    };
  };

  cfg = config.nyu.boot.loader;
in {
  options.nyu.boot.loader = {
    type = mkOption {
      type = enum ["grub" "systemd-boot"];
      default = "systemd-boot";
      description = ''
               Which bootloader to use for the device, in general
        use systemd-boot for UEFI devices and grub for legacy boot.
      '';
    };

    memtest86.enable = {
      enable = mkEnableOption "Memtest86." // {default = true;};
    };
  };

  config.boot.loader.${cfg.type} = loaders.${cfg.type};
}
