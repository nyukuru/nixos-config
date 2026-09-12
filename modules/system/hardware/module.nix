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
      type = nullOr (enum ["intel" "amd"]);
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
      # enableAllHardware pulls in every driver/firmware indiscriminately
      # (e.g. the carbon live/installer medium), so an undeclared
      # cpu/igpu/dgpu is expected there rather than a real omission.
      assertions = [
        {
          assertion = config.hardware.enableAllHardware || cfg.cpu != null;
          message = "CPU Type is undefined";
        }
        {
          assertion = config.hardware.enableAllHardware || !config.hardware.graphics.enable || (cfg.igpu != null && cfg.dgpu != null);
          message = "GPU is undefined while graphics is enabled.";
        }
      ];
    }
    (mkIf (config.hardware.enableAllHardware || cfg.igpu != null || cfg.dgpu != null) {
      hardware.graphics = {
        enable = true;
        enable32Bit = true;
      };

      environment.systemPackages = with pkgs; [
        vulkan-tools
        vulkan-loader
        vulkan-validation-layers
        vulkan-extension-layer

        libva
        libva-utils

        libva-vdpau-driver
        vdpauinfo

        mesa
      ];
    })
  ];
}
