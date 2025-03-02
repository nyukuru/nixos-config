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
    # Enable for raid support
    swraid.enable = mkDefault false;

    loader = {
      # If you need to access entries hold space.
      timeout = mkDefault 0;
      generationsDir.copyKernels = mkDefault true;
      efi.canTouchEfiVariables = mkDefault true;
    };

    /*
    # Causes difficulties for large derivations
    tmp = {
      # Uses ram instead of disk space
      useTmpfs = mkDefault true;
      cleanOnBoot = !config.boot.tmp.useTmpfs;
    };
    */

    initrd = {
      verbose = mkDefault false;

      systemd = {
        # needed to support tpm decryption
        enable = mkDefault true;

        # some emergency tooling
        storePaths = with pkgs; [util-linux cryptsetup sbctl];
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
    # Temporary fix for nvidia drivers
    #kernelPackages = mkDefault pkgs.linuxPackages;
    kernelParams = [
      "pti=auto"
      # CPU idle
      # https://www.kernel.org/doc/html/v5.0/admin-guide/pm/cpuidle.html
      # poll ; actually a net negative
      # halt ; calls HLT
      # nomwait ; use acpi_idle driver
      "idle=nowait"

      # Virtualization passthrough
      "iommu=pt"

      # This is only for hibernation, which is a huge pain
      "noresume"

      "acpi_backlight=native"

      # Helps plymouth
      "fbcon=nodefer"

      "vt.global_cursor_default=0"

      "logo.nologo"

      "boot.shell_on_fail"
    ];
  };
}
