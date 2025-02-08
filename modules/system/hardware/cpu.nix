{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.types) nullOr enum;

  cfg = config.modules.system.hardware.cpu;
in {
  options.modules.system.hardware.cpu = {
    type = mkOption {
      type = nullOr (enum ["pi" "intel" "amd"]);
      default = null;
      description = ''
        The vendor/architecture of the CPU. Determines drivers and specializations for that cpu.
      '';
    };
  };

  config = let
    isIntel = cfg.type == "intel";
    isAmd = cfg.type == "amd";
  in
    mkMerge [
      (mkIf isIntel {
        hardware.cpu.intel.updateMicrocode = true;

        boot = {
          kernelModules = ["kvm-intel"];
          kernelParams = ["i915.fastboot=1" "enable_gvt=1"];
        };

        environment.systemPackages = with pkgs; [intel-gpu-tools];
      })

      (mkIf isAmd {
        hardware.cpu.amd.updateMicrocode = true;

        # TODO p-state and crap
      })

      (mkIf (cfg.type == null) {
        warnings = [
          ''
            No CPU type set !! This means the CPU may be unoptimized or worse.
          ''
        ];
      })
    ];
}
