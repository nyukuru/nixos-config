{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit
    (lib.modules)
    mkIf
    ;

  isAmd = config.nyu.hardware.cpu == "amd";
in {
  config = mkIf isAmd {
    environment.systemPackages = [pkgs.amdctl];
    hardware.cpu.amd.updateMicrocode = true;
    boot = {
      kernelModules = ["kvm-amd"];
      kernelParams = ["amd_iommu=on"];
    };
  };
}
