{
  inputs,
  config,
  lib,
  ...
}: let
  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.modules) mkIf mkForce;
  inherit (lib.attrsets) attrNames;
  inherit (lib.types) int enum nullOr listOf;
  inherit (lib.lists) elem optional;
  inherit (lib.strings) concatMapStringsSep concatStringsSep;

  cfg = config.modules.system.filesystem.impermanence;
  filesystemNames = attrNames config.filesystems;
in {
  imports = [
    inputs.impermanence.nixosModules.impermanence
  ];

  options.modules.system.filesystem.impermanence = {
    btrfs = {
      enable = mkEnableOption "btrfs impermanence.";

      snapshotDays = mkOption {
        type = int;
        default = 5;
        description = ''
          The amount of days an old root will stay in persistence to allow
          for recovery.
        '';
      };
    };
    tmpfs = {
      enable = mkEnableOption "tmpfs impermanence.";
    };

    persistPart = mkOption {
      type = nullOr (enum filesystemNames);
      default = null;
      description = ''
        The persistent volume partition.
      '';
    };

    impermanentParts = mkOption {
      type = listOf (enum filesystemNames);
      default = optional (elem "/" filesystemNames) "/";
      description = ''
        Subvolumes to be deleted during impermanence purges.
      '';
    };
  };

  # TODO implement tmpfs
  config = mkIf cfg.btrfs.enable (let
    # These are the same under disko btrfs systems.
    persistMountPoint =
      if cfg.persistPart != null
      then config.fileSystems.${cfg.persistPart}.mountPoint
      else null;
  in {
    # Keeps this partition in initrd, absolutely required
    fileSystems.${cfg.persistPart}.neededForBoot = mkForce true;
    users.mutableUsers = mkForce false;

    # Network manager symlinks
    # maybe not needed?
    systemd.tmpfiles.rules = [
      "L /var/lib/NetworkManager/secret_key - - - - /persist/var/lib/NetworkManager/secret_key"
      "L /var/lib/NetworkManager/seen-bssides - - - - /persist/var/lib/NetworkManager/seen-bssids"
      "L /var/lib/NetworkManager/timestamps - - - - /persist/var/lib/NetworkManager/timestamps"
    ];

    environment.persistence.${persistMountPoint} = {
      directories = [
        "/etc/nixos"
        "/etc/nix"
        "/etc/NetworkManager/system-connections"
        "/var/log"
        "/var/lib/nixos"
        "/var/lib/bluetooth"
        "/var/lib/systemd/coredump"

        "/etc/ssh"
      ];

      files = [
        "etc/machine-id"
      ];

      users.nyoo = {
        directories = [
          "uni"
          "dev"
          "nixos-config"
        ];
      };
    };

    boot.initrd.systemd.services.impermanence = {
      description = "Purge BTRFS impermanent subvolumes and make snapshots.";
      wantedBy = ["initrd.target"];
      after =
        optional config.modules.system.encryption
        "systemd-cryptsetup@.service";
      before = ["sysroot.mount"];
      unitConfig.DefaultDependencies = "no";
      serviceConfig.Type = "oneshot";
      script = let
        opt = part: config.fileSystems.${part}.options;
        dev = part: config.fileSystems.${part}.device;
        mnt = part: config.fileSystems.${part}.mountPoint;
      in ''
               mkdir /btrfs_tmp

        ${concatMapStringsSep "\n" (part: ''
            mount -o ${concatStringsSep "," (opt part)} ${dev part} ${"/btrfs_tmp" + (mnt part)}
          '')
          cfg.impermanentParts}

        if [[ -e /btrfs_tmp/root ]]; then
          mkdir -p /btrfs_tmp/old_roots
          timestamp=$(date --date="@$(stat -c %Y /btrfs_tmp/root)" "+%Y-%m-%-d_%H:%M:%S")
          mv /btrfs_tmp/root "/btrfs_tmp/old_roots/$timestamp"
        fi

        delete_subvolume_recursively() {
          IFS=$'\n'
          for i in $(btrfs subvolume list -o "$1" | cut -f 9- -d ' '); do
            delete_subvolume_recursively "/btrfs_tmp/$i"
          done
          btrfs subvolume delete "$i"
        }

        for i in $(find /btrfs_tmp/old_roots/ -maxdept 1 -mtime +5); do
          delete_subvolume_recursively "$i"
        done

               btrfs subvolume create /btrfs_tmp/root
        umount /btrfs_tmp
      '';
    };
    assertions = [
      {
        assertion = cfg.persistPart != null;
        message = ''
          Persist partition not defined while impermanence module is enabled.
        '';
      }
      {
        assertion = cfg.impermanenceParts != [];
        message = ''
                 There are no impermanence subvolumes assigned in the impermanence module,
          this makes the module pointless and should be fixed by either disabling the
          module or adding the root partition to impermanenceParts.
        '';
      }
    ];
  });
}
