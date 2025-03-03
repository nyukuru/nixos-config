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
    mkOption
    ;

  inherit 
    (lib.modules)
    mkIf
    ;

  toml = pkgs.formats.toml {};
  cfg = config.nyu.programs.dunst;

in {
  options.nyu.programs.dunst = {
    enable = mkEnableOption "Dunst notification daemon.";
    package = mkPackageOption pkgs "dunst" {};

    settings = mkOption {
      type = toml.type;
      default = {};
      description = "Dunst settings (https://github.com/dunst-project/dunst/blob/master/docs/dunst.5.pod)";
    };
  };

  config = mkIf cfg.enable {
    environment = {
      systemPackages = [cfg.package];
      etc."dunstrc".source = toml.generate "dunstrc" cfg.settings;
    };
  };
}
