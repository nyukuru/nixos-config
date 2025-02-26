{
  config,
  lib,
  ...
}: let

  inherit
    (lib.options) 
    mkOption;

  inherit
    (lib.types)
    nullOr
    enum;

  cfg = config.modules.system.hardware.cpu;

in {
  imports = [
    ./intel.nix
    ./amd.nix
  ];

  options.modules.system.hardware.cpu = {
    type = mkOption {
      type = nullOr (enum ["pi" "intel" "amd"]);
      default = null;
      description = ''
        The vendor/architecture of the CPU. Determines drivers and specializations for that cpu.
      '';
    };
  };

  config.assertions = [{
    assertion = cfg.type != null;
    message = "CPU Type is undefined";
  }];
}
