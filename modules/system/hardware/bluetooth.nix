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
      default = "bluez5-experimental";
    };
  };

  config = mkIf cfg.enable {
    boot.kernelParams = ["btusb"];

    hardware.bluetooth = {
      enable = true;
      package = cfg.package;
      powerOnBoot = mkDefault true;

      # Security vulnerability
      #disabledPlugins = ["sap"];

      /*
      settings = mkDefault {
        General = {
          JustWorksRepairing = "always";
          DiscoverableTimeout = 0;
          Experimental = true;
        };
      };
      */
    };
    # A simple bluetooth device manager.
    services.blueman.enable = true;

    # Bluetooth audio if using pipewire sound server.
    # https://nixos.wiki/wiki/PipeWire#Bluetooth_Configuration
    services.pipewire.wireplumber.extraConfig = {
      "10-bluez" = {
        "monitor.bluez.properties" = {
          "bluez5.enable-sbc-xq" = true;
          "bluez5.enable-msbc" = true;
          "bluez5.enable-hw-volume" = true;
          "bluez5.roles" = ["hsp_hs" "hsp_ag" "hfp_hf" "hfp_ag"];
        };
      };
    };
  };
}
