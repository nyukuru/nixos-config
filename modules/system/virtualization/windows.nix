{
  config,
  pkgs,
  lib,
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
    bool
    str
    ;

  cfg = config.modules.system.virtualization.windows;

in {
  options.modules.system.virtualization.windows = {
    enable = mkEnableOption "Windows VM";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.quickemu
    ];
  };
}
