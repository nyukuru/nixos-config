{
  config,
  lib,
  ...
}: let

  inherit
    (lib.modules)
    mkIf
    ;

  isAmd = config.modules.system.hardware.cpu == "amd";

in {
  config = mkIf isAmd {
    hardware.cpu.amd.updateMicrocode = true;

    #TODO

  };
}
