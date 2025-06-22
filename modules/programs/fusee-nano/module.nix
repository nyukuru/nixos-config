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
        SUBSYSTEMS=="usb", ATTRS{manufacturer}=="NVIDIA Corp.", ATTRS{product}=="APX", MODE="0666"
        SUBSYSTEM=="usb", ATTRS{idVendor}=="057e", ATTRS{idProduct}=="3000", MODE="0666"
        SUBSYSTEM=="usb", ATTRS{idVendor}=="0955", ATTRS{idProduct}=="7321", MODE="0666"
      '';
    };
  };
}
