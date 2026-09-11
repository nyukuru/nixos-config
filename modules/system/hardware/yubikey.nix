{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit
    (lib.options)
    mkEnableOption
    ;

  inherit
    (lib.modules)
    mkIf
    ;

  cfg = config.nyu.hardware.yubikey;
in {
  options.nyu.hardware.yubikey = {
    enable = mkEnableOption "Yubikey device support and tooling." // {default = true;};
  };

  config = mkIf cfg.enable {
    hardware.gpgSmartcards.enable = true;

    services = {
      pcscd.enable = true;
      udev.packages = with pkgs; [
        yubikey-personalization
      ];
    };

    environment.systemPackages = with pkgs; [
      yubikey-manager
      yubikey-personalization
      yubico-piv-tool
      yubioath-flutter
    ];
  };
}
