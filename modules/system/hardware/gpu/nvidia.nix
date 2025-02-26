{
  config,
  pkgs,
  lib,
  ...
}: let

  inherit
    (lib.modules)
    mkDefault
    mkIf
    ;

  inherit
    (lib.lists)
    elem
    ;

  inherit
    (lib.strings)
    versionOlder
    ;

  # Use beta drivers when available
  nvStable = config.boot.kernelPackages.nvidiaPackages.stable;
  nvBeta = config.boot.kernelPackages.nvidiaPackages.beta;

  nvidiaPackage = if (versionOlder nvStable.version nvBeta.version) then
    nvBeta
  else
    nvStable;

  isHybrid = elem "hybrid-nvidia" cfg.type;
  isNvidia = isHybrid || elem "nvidia" cfg.type;

  cfg = config.modules.system.hardware.gpu;
in {
  config = mkIf isNvidia {
    hardware = {
      nvidia = {
	package = mkDefault nvidiaPackage;
	modesetting.enable = mkDefault true;

	prime.offload = {
	  enable = mkDefault isHybrid;
	  enableOffloadCmd = mkDefault isHybrid;
	};

	powerManagement = {
	  enable = mkDefault true;
	  finegrained = mkDefault isHybrid;
	};

	open = mkDefault true;
	nvidiaSettings = false;
      };

      graphics = {
        extraPackages = with pkgs; [
          nvidia-vaapi-driver
        ];

        extraPackages32 = with pkgs; [
          pkgsi686Linux.nvidia-vaapi-driver
        ];
      };
    };

    boot = {
      initrd.kernelModules = [
        "nvidia"
	"nvidia_modeset"
	"nvidia_uvm"
	"nvidia_drm"
      ];

      blacklistedKernelModules = ["nouveau"];
    };

    services.xserver.videoDrivers = ["nvidia"];
    environment.sessionVariables.LIBVA_DRIVER_NAME = "nvidia";
  };
}
