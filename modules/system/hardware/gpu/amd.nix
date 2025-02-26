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

  isHybrid = elem "hybrid-amd" cfg.type;
  isAmd = isHybrid || (elem "amd" cfg.type);

  cfg = config.modules.system.hardware.gpu;

in {
  config = mkIf isAmd {
    boot = {
      kernelModules = [
        "amdgpu"
      ];

      initrd.kernelModules = [
        "amdgpu"
      ];
    };

    hardware.graphics = {
      extraPackages = with pkgs; [
	amdvlk
	rocmPackages.clr.icd
      ];

      extraPackages32 = with pkgs; [
	driversi686Linux.amdvlk
      ];
    };

    services.xserver.videoDrivers = [
      "modesettings"
      "amdgpu"
    ];
  };
}
