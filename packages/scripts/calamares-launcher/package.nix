{
  pkgs,
  pciutils,
  util-linux,
  branding,
}:
pkgs.writers.writePython3Bin "calamares-launcher" {flakeIgnore = ["E501"];} (
  builtins.replaceStrings
  [
    "@calamares@"
    "@lspci@"
    "@lsblk@"
  ]
  [
    "${branding.calamares-carbon}/bin/calamares"
    "${pciutils}/bin/lspci"
    "${util-linux}/bin/lsblk"
  ]
  (builtins.readFile ./launcher.py)
)
