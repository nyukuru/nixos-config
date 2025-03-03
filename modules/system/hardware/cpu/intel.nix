{
  config,
  lib,
  ...
}: let

  inherit
    (lib.modules)
    mkIf
    ;

  isIntel = config.nyu.hardware.cpu == "intel";

in {
  config = mkIf isIntel {
    hardware.cpu.intel.updateMicrocode = true;

    boot = {
      kernelModules = [
        "kvm-intel"
      ];

      kernelParams = [
        "i915.fastboot=1" 
	"enable_gvt=1"
      ];
    };
  };
}
