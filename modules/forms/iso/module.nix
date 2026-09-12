{
  config,
  modulesPath,
  lib,
  ...
}: let
  inherit (lib.modules) mkImageMediaOverride mkDefault;
  inherit (lib.attrsets) attrNames filterAttrs;
in {
  imports = [
    "${modulesPath}/installer/cd-dvd/iso-image.nix"
    "${modulesPath}/installer/cd-dvd/channel.nix"
    "${modulesPath}/profiles/base.nix"

    ./image.nix
    ./limine.nix
  ];

  hardware = {
    enableRedistributableFirmware = true;

    enableAllHardware = true;
    enableAllFirmware = true;
  };

  swapDevices = mkImageMediaOverride [];
  zramSwap = {
    enable = true;
    memoryPercent = 150;
  };
  fileSystems = mkImageMediaOverride config.lib.isoFileSystems;
  boot.initrd.luks.devices = mkImageMediaOverride {};
  boot.loader.timeout = mkImageMediaOverride null;

  security.sudo.wheelNeedsPassword = mkImageMediaOverride false;

  environment.variables.GC_INITIAL_HEAP_SIZE = "1M";
  boot.kernel.sysctl."vm.overcommit_memory" = "1";

  nix = {
    settings = {
      extra-experimental-features = [
        "flakes"
        "nix-command"
      ];

      trusted-users = attrNames (filterAttrs (_: u: u.isNormalUser) config.users.users);
      accept-flake-config = false;
    };
  };

  programs.git.enable = true;

  system.stateVersion = mkDefault lib.trivial.release;
}
