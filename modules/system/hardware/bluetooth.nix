{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit
    (lib.options)
    mkPackageOption
    mkEnableOption
    ;

  inherit
    (lib.modules)
    mkDefault
    mkIf
    ;

  cfg = config.nyu.hardware.bluetooth;
in {
  options.nyu.hardware.bluetooth = {
    enable = mkEnableOption "Bluetooth.";

    package = mkPackageOption pkgs "bluez" {
      default = "bluez-experimental";
    };
  };

  config = mkIf cfg.enable {
    boot.kernelParams = ["btusb"];
    services.blueman.enable = true;

    hardware.bluetooth = {
      enable = true;
      package = cfg.package;
      powerOnBoot = mkDefault true;

      disabledPlugins = ["sap"];

      settings = mkDefault {
        General = {
          Enable = "Source,Sink,Media,Socket";
          JustWorksRepairing = "always";
          Experimental = true;
        };
      };
    };
  };
}
