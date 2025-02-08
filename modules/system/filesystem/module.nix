{
  inputs,
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.modules) mkIf mkAfter;
  inherit (lib.lists) optionals optional elem;
  inherit (lib.types) listOf str enum;

  cfg = config.modules.system.filesystem;
in {
  imports = [
    # Wrapper for impermanence module.
    ./impermanence.nix
  ];

  options.modules.system.filesystem = {
    enabledFilesystems = mkOption {
      type = listOf str;
      default = ["vfat"];
    };

    btrfs = {
      scrub = {
        enable =
          mkEnableOption "Automatically scrubbing (error correct) of btrfs subvolumes."
          // {
            default = elem "btrfs" cfg.enabledFilesystems;
          };
        interval = mkOption {
          type = str;
          default = "Sun"; #Every Sunday
          description = ''
            Systemd time to hook the service with.
          '';
        };
        subvolumes = mkOption {
          type = listOf str;
          default = ["/"];
          description = ''
            Subvolumes to scrub.
          '';
        };
      };
    };
  };

  config = {
    boot = {
      supportedFilesystems = cfg.enabledFilesystems;
      initrd.supportedFilesystems = cfg.enabledFilesystems;
    };

    services = {
      btrfs.autoScrub = mkIf (elem "btrfs" cfg.enabledFilesystems) {
        inherit (cfg.btrfs.scrub) enable interval;
        fileSystems = cfg.btrfs.scrub.subvolumes;
      };
    };

    systemd.services.fstrim = {
      unitConfig.ConditionACPower = true;
      serviceConfig = {
        Nice = 19;
        IOScedulingClass = "idle";
      };
    };

    environment.systemPackages = optional (elem "btrfs" cfg.enabledFilesystems) pkgs.btrfs-progs;

    warnings =
      if (cfg.enabledFilesystems == [])
      then [
        ''
          There are no filesystems configured, this may cause issues mounting and accessing.
        ''
      ]
      else if !(elem "vfat" cfg.enabledFilesystems)
      then [
        ''
          'vfat' is not included in enabled filsystems (defaultly the boot partiotion in UEFI systems).
        ''
      ]
      else [];
  };
}
