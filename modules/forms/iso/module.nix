{
  config,
  modulesPath,
  lib,
  ...
}: let
  inherit (lib.modules) mkImageMediaOverride mkDefault;
in {
  imports = [
    "${modulesPath}/installer/cd-dvd/iso-image.nix"
    "${modulesPath}/installer/cd-dvd/channel.nix"
    "${modulesPath}/profiles/base.nix"

    ./image.nix
    ./installer.nix
  ];

  boot.loader.grub.memtest86.enable = true;

  hardware = {
    enableRedistributableFirmware = true;

    enableAllHardware = true;
    enableAllFirmware = true;
  };

  # An installation medium cannot tolerate a host-defined filesystem layout
  # on a fresh, unformatted machine.
  swapDevices = mkImageMediaOverride [];
  fileSystems = mkImageMediaOverride config.lib.isoFileSystems;
  boot.initrd.luks.devices = mkImageMediaOverride {};

  security.sudo.wheelNeedsPassword = mkImageMediaOverride false;

  environment.variables.GC_INITIAL_HEAP_SIZE = "1M";
  boot.kernel.sysctl."vm.overcommit_memory" = "1";

  nix = {
    settings = {
      extra-experimental-features = [
        "flakes"
        "nix-command"
      ];

      trusted-users = ["nyu"];
      accept-flake-config = false;
    };
  };

  programs.git.enable = true;

  system.stateVersion = mkDefault lib.trivial.release;
}
