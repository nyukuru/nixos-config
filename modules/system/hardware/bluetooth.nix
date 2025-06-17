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
    # A simple bluetooth device manager.
    services.blueman.enable = true;

    services.pipewire.wireplumber.extraConfig = {
      "10-bluetooth" = {
        "wireplumber.settings" = {
          "bluetooth.autoswitch-to-headset-profile" = false;
        };
      };
      "wh-1000xm4-ldac-hq" = {
        "monitor.bluez.rules" = [
          {
            matches = [
              { 
                "device.product.id" = "0x0d58";
                "device.vendor.id" = "usb:054c";
              }
            ];
            actions = {
              update-props = {
                "bluez5.a2dp.ldac.quality" = "hq";
                "bluez5.auto-connect" = true;
                "bluez5.profile" = "a2dp-sink";
                "bluez5.roles" = ["a2dp_source" "a2dp_sink" "bap_sink" "bap_source"];
                "bluetooth.autoswitch-profile" = false;
              };
            };
          }
        ];
      };
    };
  };
}
