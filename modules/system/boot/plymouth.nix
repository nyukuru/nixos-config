{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.modules) mkIf mkForce;
  inherit (lib.lists) optional;
  inherit (lib.types) nullOr str package;
  inherit (lib.meta) getExe';

  cfg = config.nyu.boot.plymouth;
in {
  options.nyu.boot.plymouth = {
    enable = mkEnableOption "Plymouth.";

    themePackage = mkOption {
      type = nullOr package;
      default = null;
      description = ''
        Loads a package in which a theme can be sourced from.
      '';
    };

    theme = mkOption {
      type = str;
      default = "spinner";
      description = ''
        Selects a plymouth boot splash theme.
      '';
    };
  };

  config = mkIf cfg.enable {
    boot.plymouth = {
      enable = true;

      themePackages = mkForce (optional (cfg.themePackage != null) cfg.themePackage);
      inherit (cfg) theme;
    };

    powerManagement = {
      resumeCommands = ''
        ${getExe' pkgs.plymouth "plymouth"} --quit
      '';
    };
  };
}
