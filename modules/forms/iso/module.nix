{
  modulesPath, 
  lib,
  ...
}: {
  imports = [
    "${modulesPath}/installer/cd-dvd/iso-image.nix"
    "${modulesPath}/installer/cd-dvd/channel.nix"

    ./image.nix
  ];

  boot.loader.grub.memtest86.enable = true;

  hardware = {
    enableRedistributableFirmware = true;

    enableAllHardware = true;
    enableAllFirmware = true;
  };

  nix = {
    settings = {
      extra-experimental-features = [
        "flakes"
        "nix-command"
      ];

      accept-flake-config = false;
    };
  };

  programs.git.enable = true;

  system.stateVersion = lib.trivial.release;

}
