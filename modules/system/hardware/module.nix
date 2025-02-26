{
  imports = [
    ./cpu
    ./gpu

    ./bluetooth.nix
    ./tpm.nix
    ./yubikey.nix
  ];

  config.hardware.enableRedistributableFirmware = true;
}
