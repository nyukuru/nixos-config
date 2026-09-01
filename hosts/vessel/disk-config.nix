{inputs, ...}: {
  imports = [inputs.disko.nixosModules.default];

  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/disk/by-nvme-Samsung_SSD_980_PRO_2TB_S76ENL0X200051J";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "16G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [
                  "defaults"
                ];
              };
            };
            luks = {
              size = "100%";
              content = {
                type = "luks";
                name = "crypted-1";
                settings = {
                  crypttabExtraOpts = ["tpm2-device=auto"];
                };
                content = {
                  type = "btrfs";
                  extraArgs = ["-f" "-L fsroot"];
                  subvolumes = {
                    "/root" = {
                      mountpoint = "/";
                      mountOptions = ["subvol=root" "compress=zstd" "noatime" "ssd"];
                    };

                    "/home" = {
                      mountpoint = "/home";
                      mountOptions = ["subvol=home" "compress=zstd" "noatime" "ssd"];
                    };

                    "/nix" = {
                      mountpoint = "/nix";
                      mountOptions = ["subvol=nix" "compress=zstd" "noatime" "ssd"];
                    };

                    "/libvirt" = {
                      mountpoint = "/libvirt";
                      mountOptions = ["subvol=libvirt" "noatime" "ssd"];
                    };

                    "/swap" = {
                      mountpoint = "/.swapvol";
                      swap.swapfile.size = "32G";
                    };
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}
