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

  isIntel = (config.nyu.hardware.igpu == "intel") || (config.nyu.hardware.dgpu == "intel");
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

    # Prefer video decoding on igpu
    environment.variables = mkIf (config.nyu.hardware.igpu == "intel") {
      VDPAU_DRIVER = "va_gl";
    };
  };
}
