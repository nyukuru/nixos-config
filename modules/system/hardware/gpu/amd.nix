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

  isAmd = (config.nyu.hardware.igpu == "amd") || (config.nyu.hardware.dgpu == "amd");
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
