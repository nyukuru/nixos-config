{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.modules) mkIf mkMerge mkDefault;
  inherit (lib.types) nullOr listOf enum;
  inherit (lib.strings) versionOlder;
  inherit (lib.lists) elem mutuallyInclusive optionals;

  cfg = config.modules.system.hardware.gpu;
in {
  options.modules.system.hardware.gpu = {
    enable =
      mkEnableOption "Graphics."
      // {
        default = cfg.type != null;
      };

    type = mkOption {
      type = nullOr (listOf (enum ["amd" "intel" "nvidia" "hybrid-nvidia" "hybrid-amd"]));
      default = null;
      description = ''
        The vendor/architecture(s) of the GPU, Determines what drivers and/or modules
        will be loaded for proper usage.
        In the case of a hybrid system use the hybrid-<name> for the dGPU.
      '';
    };
  };

  config = let
    isNvidia = mutuallyInclusive ["nvidia" "hybrid-nvidia"] cfg.type;
    isHybrid = mutuallyInclusive ["hybrid-nvidia" "hybrid-amd"] cfg.type;
    isIntel = elem "intel" cfg.type;
    isAmd = mutuallyInclusive ["amd" "hybrid-amd"] cfg.type;
  in
    mkIf cfg.enable (mkMerge [
      {
        hardware.graphics = {
          enable = true;
          enable32Bit = true;
        };

        environment.systemPackages = with pkgs; [
          glxinfo
          glmark2

          vulkan-tools
          vulkan-loader
          vulkan-validation-layers
          vulkan-extension-layer

          libva
          libva-utils

          mesa
        ];
      }

      (mkIf isIntel {
        hardware.graphics = {
          extraPackages = with pkgs; [
            intel-media-driver
            intel-compute-runtime
            vpl-gpu-rt
            libvdpau-va-gl
          ];

          extraPackages32 = with pkgs; [driversi686Linux.intel-media-driver];
        };

        boot = {
          # TODO benchmark xe driver
          kernelModules = ["i915"];
          initrd.kernelModules = ["i915"];
        };

        services.xserver.videoDrivers = ["modesetting"];

        environment.variables = mkIf isHybrid {
          VDPAU_DRIVER = "va_gl";
        };
      })

      (mkIf isNvidia (let
        nvStable = config.boot.kernelPackages.nvidiaPackages.stable;
        nvBeta = config.boot.kernelPackages.nvidiaPackages.beta;

        nvidiaPackage =
          if (versionOlder nvStable.version nvBeta.version)
          then nvBeta
          else nvStable;
      in {
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
            extraPackages = with pkgs; [nvidia-vaapi-driver];
            extraPackages32 = with pkgs; [pkgsi686Linux.nvidia-vaapi-driver];
          };
        };

        boot.blacklistedKernelModules = ["nouveau"];

        services.xserver.videoDrivers = ["nvidia"];

        environment.sessionVariables.LIBVA_DRIVER_NAME = "nvidia";
      }))

      (mkIf isAmd {
        hardware.graphics = {
          extraPackages = with pkgs; [amdvlk rocmPackages.clr.icd];
          extraPackages32 = with pkgs; [driversi686Linux.amdvlk];
        };

        boot = {
          kernelModules = ["amdgpu"];
          initrd.kernelModules = ["amdgpu"];
        };

        services.xserver.videoDrivers = ["modesettings" "amdgpu"];
      })
    ]);
}
