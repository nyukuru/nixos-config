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

  cfg = config.modules.system.virtualization.win-start;
in {
  options.modules.system.virtualization.win-start = {
    enable = mkEnableOption "Easy Windows VM start script";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.quickemu
    ];
  };
}
