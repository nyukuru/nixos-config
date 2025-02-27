{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: let

  inherit
    (lib.options)
    mkEnableOption
    ;

  inherit
    (lib.modules)
    mkForce
    mkIf
    ;

  inherit
    (lib.meta)
    getExe
    ;

  cfg = config.modules.system.boot.secureBoot;

in {

  imports = [inputs.lanzaboote.nixosModules.lanzaboote];

  options.modules.system.boot.secureBoot = {
    enable = mkEnableOption "Secrure boot.";
  };

  # https://github.com/nix-community/lanzaboote/blob/master/docs/QUICK_START.md
  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      sbctl
    ];

    boot = {
      initrd.systemd.extraBin.sbctl = getExe pkgs.sbctl;
      loader.systemd-boot.enable = mkForce false;
      lanzaboote = {
        enable = true;
        pkiBundle = "/etc/secureboot";
      };
    };
  };
}
