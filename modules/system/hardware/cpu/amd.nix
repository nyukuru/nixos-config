{
  config,
  lib,
  ...
}: let

  inherit
    (lib.modules)
    mkIf
    ;

  isAmd = config.nyu.hardware.cpu == "amd";

in {
  config = mkIf isAmd {
    hardware.cpu.amd.updateMicrocode = true;

    #TODO
  };
}
