{
  config,
  lib,
  ...
}: let
  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.modules) mkDefault mkForce;
  inherit (lib.types) enum;

  loader = {
    grub = {
      enable = true;
      useOSProber = mkDefault true;
      efiSupport = mkDefault true;
      device = mkDefault "nodev";
      memtest86.enable = cfg.memtest86.enable;
    };

    systemd-boot = {
      enable = true;
      consoleMode = "max";
      editor = false;
      memtest86.enable = cfg.memtest86.enable;
    };
  };

  cfg = config.modules.system.boot.loader;
in {
  options.modules.system.boot.loader = {
    type = mkOption {
      type = enum ["grub" "systemd-boot"];
      default = "systemd-boot";
      description = ''
               Which bootloader to use for the device, in general
        use systemd-boot for UEFI devices and grub for legacy boot.
      '';
    };

    memtest86 = {
      enable = mkEnableOption "Memtest86." // {default = true;};
    };
  };

  config.boot.loader.${cfg.type} = loader.${cfg.type};
}
