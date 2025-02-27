{
  config,
  lib,
  ...
}: let

  inherit
    (lib.options)
    mkEnableOption
    mkOption
    ;

  inherit
    (lib.modules)
    mkBefore
    mkIf
    ;

  inherit
    (lib.strings)
    concatStringsSep
    ;

  inherit
    (lib.lists)
    optional
    ;

  inherit
    (lib.types)
    strMatching
    listOf
    ;

  pciIDType = strMatching "([0-z]{4}:[0-z]{4})?";

  cfg = config.modules.system.virtualization.vfio;

in {
  options.modules.system.virtualization.vfio = {
    enable = mkEnableOption "VFIO";

    pciIds = mkOption {
      type = listOf pciIDType;
      default = [];
      description = ''
        PCIe Devices given to the VFIO driver for passthrough
      '';
    };
  };

  config = mkIf cfg.enable {
    boot = {
      # Ensures vfio can claim gpus before other drivers (like nvidia)
      initrd.kernelModules = mkBefore [
        "vfio_pci"
	"vfio"
	"vfio_iommu_type1"
	"vfio_virqfd"
      ];

      kernelParams = optional (cfg.pciIds != []) 
	("vfio-pci.ids=" + concatStringsSep "," cfg.pciIds)
      ++ (optional (config.modules.system.hardware.cpu.type == "amd") "amd_iommu=on")
      ++ (optional (config.modules.system.hardware.cpu.type == "intel") "intel_iommu=on");
    };
  };
}
