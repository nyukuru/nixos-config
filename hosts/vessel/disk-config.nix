{inputs, ...}: {
  imports = [inputs.disko.nixosModules.default];

  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/disk/by-path/pci-0000:00:0e.0-pci-10000:e2:00.0-nvme-1";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "512M";
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
                content = {
                  type = "btrfs";
                  extraArgs = ["-f" "-L fsroot"];
                  subvolumes = {
                    "/root" = {
                      mountpoint = "/";
                      mountOptions = ["subvol=root" "compress=zstd" "noatime"];
                    };
                    "/home" = {
                      mountpoint = "/home";
                      mountOptions = ["subvol=home" "compress=zstd" "noatime"];
                    };
                    "/nix" = {
                      mountpoint = "/nix";
                      mountOptions = ["subvol=nix" "compress=zstd" "noatime"];
                    };
                    "/persist" = {
                      mountpoint = "/persist";
                      mountOptions = ["subvol=perist" "compress=zstd" "noatime"];
                    };
                    "/swap" = {
                      mountpoint = "/.swapvol";
                      swap.swapfile.size = "16G";
                    };
                  };
                };
              };
            };
          };
        };
      };
      sub = {
        type = "disk";
        device = "/dev/disk/by-path/pci-0000:00:0e.0-pci-10000:e1:00.0-nvme-1";
        content = {
          type = "gpt";
          partitions = {
            luks = {
              size = "100%";
              content = {
                type = "luks";
                name = "crypted-2";
		content = {
		  type = "btrfs";
		  extraArgs = ["-f" "-L media"];
		  subvolumes = {
		    "media" = {
		      mountpoint = "/media";
		      mountOptions = ["subvol=media" "compress=zstd" "noatime"];
		    };

		    "media/games" = {
		      mountpoint = "/media/games";
		      mountOptions = ["subvol=games" "compress=zstd" "noatime"];
		    };

		    "media/video" = {
		      mountpoint = "/media/video";
		      mountOptions = ["subvol=video" "compress=zstd" "noatime"];
		    };

		    "media/music" = {
		      mountpoint = "/media/music";
		      mountOptions = ["subvol=music" "compress=zstd" "noatime"];
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
