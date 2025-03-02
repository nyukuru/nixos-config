{
  config,
  pkgs,
  lib,
  ...
}: let

  inherit
    (lib.modules)
    mkIf
    ;

  inherit
    (lib.lists)
    elem
    ;

  isIntel = elem "intel" cfg.type;

  cfg = config.modules.system.hardware.gpu;
in {
  config = mkIf isIntel {
    boot = {
      # TODO eventually switch to modern xe driver
      kernelModules = [
        "i915"
      ];

      initrd.kernelModules = [
        "i915"
      ];
    };

    hardware.graphics = {
      extraPackages = with pkgs; [
        intel-media-driver
	intel-compute-runtime
	vpl-gpu-rt
	libvdpau-va-gl
      ];

      extraPackages32 = with pkgs; [
        driversi686Linux.intel-media-driver
      ];
      
    };

    services.xserver.videoDrivers = ["modesetting"];
    #environment.variables.VDPAU_DRIVER = "va_gl";
  };
}

