{
  config,
  pkgs,
  lib,
  ...
}: let

  inherit
    (lib.options)
    mkEnableOption
    mkPackageOption
    ;

  inherit
    (lib.modules)
    mkIf
    ;

  cfg = config.nyu.programs.fusee-nano;
in {

  options.nyu.programs.fusee-nano = {
    enable = mkEnableOption "Fusee-nano payload injector.";
    package = mkPackageOption pkgs "fusee-nano" {};
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [cfg.package];

    users.extraGroups.nintendo-switch = {};

    services.udev = {
      extraRules = ''
        SUBSYSTEMS=="usb", ATTRS{manufacturer}=="NVIDIA Corp.", ATTRS{product}=="APX", GROUP="nintendo-switch"
      '';
    };
  };


}
