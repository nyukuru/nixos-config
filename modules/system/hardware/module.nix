{
  config,
  lib,
  ...
}: let
  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.modules) mkDefault;

  cfg = config.modules.system.hardware;
in {
  imports = [
    # CPU options and specialization
    ./cpu.nix
    # GPU options and specialization
    ./gpu.nix
    # Bluetooth enable and options
    ./bluetooth.nix
    # TPM enable
    ./tpm.nix
    # Yubikey enable
    ./yubikey.nix
  ];

  options.modules.system.hardware = {
    #TODO nothing here makes me sad
  };

  config = {
    # Move to sane defaults folder
    hardware.enableRedistributableFirmware = mkDefault true;
  };
}
