{
  config,
  lib,
  pkgs,
  ...
}: let

  inherit 
    (lib.options)
    mkEnableOption
    mkOption
    ;

  inherit
    (lib.modules) 
    mkIf
    ;

  inherit
    (lib.types)
    listOf
    nullOr
    enum
    ;

  cfg = config.modules.system.hardware.gpu;

in {
  imports = [
    ./nvidia.nix
    ./intel.nix
    ./amd.nix
  ];

  options.modules.system.hardware.gpu = {
    enable = mkEnableOption "Graphics." // {default = cfg.type != null;};

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

  config = mkIf cfg.enable {
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
  };
}
