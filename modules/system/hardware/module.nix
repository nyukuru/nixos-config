{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit
    (lib.options)
    mkOption
    ;

  inherit
    (lib.modules)
    mkMerge
    mkIf
    ;

  inherit
    (lib.types)
    nullOr
    enum
    ;

  cfg = config.nyu.hardware;
in {
  imports = [
    ./cpu
    ./gpu

    ./bluetooth.nix
    ./tpm.nix
    ./yubikey.nix
  ];

  options.nyu.hardware = {
    cpu = mkOption {
      type = nullOr (enum ["pi" "intel" "amd"]);
      default = null;
      description = ''
        The vendor/architecture of the CPU. Determines drivers and specializations for that cpu.
      '';
    };

    igpu = mkOption {
      type = nullOr (enum ["amd" "intel"]);
      default = null;
      description = ''
               The vendor/architecture(s) of the iGPU, installs drivers and enable modules
        Should be null if no iGPU is present or use of the iGPU is undesired.
      '';
    };

    dgpu = mkOption {
      type = nullOr (enum ["amd" "intel" "nvidia"]);
      default = null;
      description = ''
        The vendor/architecture of the dGPU, installs drivers and enables modules
      '';
    };
  };

  config = mkMerge [
    {
      warnings = [
        (mkIf (cfg.cpu == null) "CPU Type is undefined")
        (mkIf (config.hardware.graphics.enable && ((cfg.igpu == null) || (cfg.dgpu == null)))
          "GPU is undefined while graphics is enabled.")
      ];
    }
    (mkIf (cfg.igpu != null || cfg.dgpu != null) {
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

        vaapiVdpau
        vdpauinfo

        mesa
      ];
    })
  ];
}
