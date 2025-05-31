{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit
    (lib.modules)
    mkDefault
    ;

  inherit
    (lib.meta)
    getExe'
    ;

in {
  config.boot = {
    consoleLogLevel = mkDefault 3;

    loader = {
      # To access entries hold space.
      timeout = mkDefault 0;
      efi.canTouchEfiVariables = mkDefault true;
    };

    tmp.cleanOnBoot = !config.boot.tmp.useTmpfs;

    initrd = {
      verbose = mkDefault false;
      systemd = {
        enable = mkDefault true;

        # some emergency tooling
        storePaths = with pkgs; [
          util-linux
          cryptsetup
          sbctl
        ];

        extraBin = {
          fdisk = getExe' pkgs.util-linux "fdisk";
          lsblk = getExe' pkgs.util-linux "lsblk";
        };
      };

      kernelModules = [
        "btrfs"
        "nvme"
        "tpm"
        "sd_mod"
        "dm_mod"
        "ahci"
        "vfat"
      ];
    };

    kernelPackages = mkDefault pkgs.linuxPackages_latest;
    kernelParams = [
      "pti=auto"
      "idle=nowait"
      "iommu=pt"
      "acpi_backlight=native"

      # Helps plymouth
      "fbcon=nodefer"
      "vt.global_cursor_default=0"
      "logo.nologo"
      "boot.shell_on_fail"
    ];
  };
}
