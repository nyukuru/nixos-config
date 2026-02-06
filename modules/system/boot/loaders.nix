{
  config,
  pkgs,
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
    mkIf
    ;

  inherit
    (lib.types)
    enum
    ;

  inherit
    (lib.meta)
    getExe
    ;

  inherit
    (lib.strings)
    optionalString
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

    limine = {
      enable = true;
      additionalFiles = mkIf cfg.memtest86.enable {
        "efi/memtest86/memtest86.efi" = "${pkgs.memtest86-efi}/BOOTX64.efi";
      };
      extraEntries = optionalString cfg.memtest86.enable ''
        /memtest86
          protocol: efi
          path: boot():/limine/efi/memtest86/memtest86.efi
      '';
      extraConfig = optionalString config.nyu.boot.silent.enable ''
        quiet: yes
      '';
      inherit (cfg) secureBoot;
    };
  };

  cfg = config.nyu.boot.loader;
in {
  options.nyu.boot.loader = {
    type = mkOption {
      type = enum ["grub" "systemd-boot" "limine"];
      default = "limine";
      description = ''
               Which bootloader to use for the device, in general
        use systemd-boot for UEFI devices and grub for legacy boot.
      '';
    };

    memtest86.enable = mkEnableOption "Memtest86." // {default = true;};
    secureBoot.enable = mkEnableOption "Secrure boot.";
  };

  config = {
    assertions = [
      {
        assertion = !cfg.secureBoot.enable || (cfg.type == "limine");
        message = "SecureBoot is only supported on the limine boot loader";
      }
    ];
    environment.systemPackages = with pkgs; [
      sbctl
    ];

    boot.loader.${cfg.type} = loaders.${cfg.type};
    boot.loader = {
      efi.canTouchEfiVariables = mkDefault true;
      timeout = mkDefault 3;
    };
    boot.initrd.systemd.extraBin.sbctl = getExe pkgs.sbctl;
  };
}
