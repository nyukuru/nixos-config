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

  inherit
    (lib.lists)
    optionals
    ;

  cfg = config.nyu.hardware.yubikey;
in {
  options.nyu.hardware.yubikey = {
    enable = mkEnableOption "Yubikey device support and tooling.";

    cliTools = {
      enable = mkEnableOption "CLI based yubikey tooling." // {default = true;};
    };

    guiTools = {
      enable = mkEnableOption "GUI based yubikey tooling.";
    };
  };

  config = mkIf cfg.enable {
    hardware.gpgSmartcards.enable = true;

    services = {
      pcscd.enable = true;
      udev.packages = with pkgs; [
        yubikey-personalization
      ];
    };

    environment.systemPackages = with pkgs;
      optionals cfg.cliTools.enable [
        yubikey-manager
        yubikey-personalization
        yubico-piv-tool
      ]
      ++ optionals cfg.guiTools.enable [
        yubioath-flutter
      ];
  };
}
